extern crate hex;

use fltk::app::Receiver;
use fltk::dialog::{FileDialog, FileDialogType, NativeFileChooser};
use fltk::frame::Frame;
use fltk::menu::Choice;
use fltk::{
    app,
    button::Button,
    dialog,
    enums::{Font, FrameType, Shortcut},
    menu,
    prelude::*,
    text::TextDisplay,
    window::Window,
};
use opcode::oc::Opcode;
use parser::parse::Parser;
use std::cell::RefCell;
use std::rc::Rc;
use std::{env, fs};

mod assembly_creator;
mod opcode;
mod parser;

#[derive(Copy, Clone)]
pub enum Message {
    Open,
    SaveLeftWindow,
    SaveRightWindow,
    ExportBinary,
    ExportText,
    Quit,
}

// https://github.com/fltk-rs/fltk-rs/blob/master/fltk/examples/editor2.rs
// https://fltk-rs.github.io/fltk-book/Menus.html

fn main() {
    env::set_var("RUST_BACKTRACE", "full");

    let app: app::App = app::App::default().load_system_fonts();
    let font = Font::load_font("Assets/Consolas-Regular.ttf").unwrap();
    Font::set_font(Font::Helvetica, &font);
    app::set_font_size(12);
    let mut wind: fltk::window::DoubleWindow =
        Window::new(100, 100, 820, 620, "C64 Binary to Assembly Converter");

    let left_display: TextDisplay = TextDisplay::new(5, 35, 400, 550, None);
    let right_display: TextDisplay = TextDisplay::new(415, 35, 400, 550, None);

    let r = configure_menu_bar();

    let mut frame = Frame::new(360, 10, 140, 20, "");
    frame.set_label_size(12);
    frame.set_frame(FrameType::NoBox);

    let mut but: Button = Button::new(350, 590, 120, 20, "Generate labels");

    wind.end();
    wind.show();

    let parser = Rc::new(RefCell::new(Parser::new()));

    but.set_callback({
        let converter = parser.clone();
        move |_| {
            click(
                wind.to_owned(),
                converter.to_owned(),
                right_display.to_owned(),
            )
        }
    });
    but.activate();

    while app.wait() {
        if let Some(msg) = r.recv() {
            match msg {
                Message::Open => open(parser.clone(), left_display.clone(), frame.clone()),
                Message::SaveLeftWindow => save_left_window(parser.clone()).expect("OK"),
                Message::SaveRightWindow => save_right_window(parser.clone()).expect("OK"),
                Message::ExportBinary => save_binary(parser.clone()).expect("OK"),
                Message::ExportText => save_text(parser.clone()).expect("OK"),
                Message::Quit => app.quit(),
            }
        }
    }
    app.run().unwrap();
}

fn configure_menu_bar() -> Receiver<Message> {
    let (sender, receiver) = app::channel::<Message>();
    let mut menu: menu::SysMenuBar = menu::SysMenuBar::default().with_size(800, 20);
    menu.set_frame(FrameType::FlatBox);
    menu.add_emit(
        "&File/Open...\t",
        Shortcut::Ctrl | 'o',
        menu::MenuFlag::Normal,
        sender,
        Message::Open,
    );

    menu.add_emit(
        "&File/Save.../Left Window\t",
        Shortcut::Ctrl | 'w',
        menu::MenuFlag::Normal,
        sender,
        Message::SaveLeftWindow,
    );

    menu.add_emit(
        "&File/Save.../Right Window\t",
        Shortcut::Ctrl | 'w',
        menu::MenuFlag::Normal,
        sender,
        Message::SaveRightWindow,
    );

    menu.add_emit(
        "&File/Export Bytes/As Binary\t",
        Shortcut::Ctrl | 'w',
        menu::MenuFlag::Normal,
        sender,
        Message::ExportBinary,
    );

    menu.add_emit(
        "&File/Export Bytes/As Text\t",
        Shortcut::Ctrl | 'w',
        menu::MenuFlag::Normal,
        sender,
        Message::ExportText,
    );

    menu.add_emit(
        "&File/Quit\t",
        Shortcut::Ctrl | 'q',
        menu::MenuFlag::Normal,
        sender,
        Message::Quit,
    );
    receiver
}

fn click(_wind: Window, parser: Rc<RefCell<Parser>>, right_display: TextDisplay) {
    // TODO use a custom chooser to allow the user selection for start/end addresses
    let start_memory_location = "0800";
    let start = get_index(start_memory_location, &parser);
    let end = get_index("1000", &parser);

    parser.borrow_mut().assembly_creator.add_labels(
        start,
        end,
        start_memory_location,
        true,
        1,
        2,
        right_display,
    );
}

fn get_index(start_text: &str, parser: &Rc<RefCell<Parser>>) -> i32 {
    let line_numbers = parser.borrow().line_numbers.clone();
    let index = line_numbers.iter().position(|x| x.contains(start_text));
    index.unwrap() as i32

    // match index {
    //     Some(i) => return index.unwrap() as i32,
    //     None => println!("Not found"),
    // }
}

fn open(converter: Rc<RefCell<Parser>>, left_display: TextDisplay, mut frame: Frame) {
    let mut chooser =
        dialog::FileChooser::new(".", "*", dialog::FileChooserType::Single, "Select a file");
    chooser.show();
    chooser.window().set_pos(300, 300);

    while chooser.shown() {
        app::wait();
    }

    match chooser.value(1) {
        Some(file_name) => {
            let pos = file_name.rfind('/');
            let f = file_name.split_at(pos.unwrap() + 1).1;
            frame.set_label(&f);
            match memory_location_selector() {
                Some(memory_location) => {
                    converter.borrow_mut().init(&*file_name);
                    let _data = converter
                        .borrow_mut()
                        .parse_file_content(left_display, memory_location);
                    converter
                        .borrow_mut()
                        .assembly_creator
                        .update_assembly_code(_data);
                }
                None => println!("Cancelled"),
            }
        }
        None => println!("No file selected"),
    }
}

fn save_left_window(parser: Rc<RefCell<Parser>>) -> std::io::Result<()> {
    let title = "Save left window content";
    let chooser = display_save_dialogue(title, "ASM Files\t*.asm", "output.asm");

    let filename = chooser.filename();
    if !filename.to_string_lossy().is_empty() {
        let _data = parser.borrow_mut().assembly_code.clone();
        if _data.len() > 0 {
            let contents = _data.join("");
            fs::write(filename, contents)?;
        }
    }
    Ok(())
}

fn save_right_window(parser: Rc<RefCell<Parser>>) -> std::io::Result<()> {
    let title = "Save right window content";
    let chooser = display_save_dialogue(title, "ASM Files\t*.asm", "output.asm");

    let filename = chooser.filename();
    if !filename.to_string_lossy().is_empty() {
        let _data = parser.borrow_mut().assembly_creator.pass_three.clone();
        if _data.len() > 0 {
            let contents = _data.join("\n");
            fs::write(filename, contents)?;
        }
    }
    Ok(())
}

fn save_binary(parser: Rc<RefCell<Parser>>) -> std::io::Result<()> {
    let title = "Save selected memory as Binary";
    let _chooser = display_save_dialogue(title, "Binary Files\t*.bin", "output.bin");
    Ok(())
}

fn save_text(parser: Rc<RefCell<Parser>>) -> std::io::Result<()> {
    let title = "Save selected memory as Text";
    let _chooser = display_save_dialogue(title, "Text Files\t*.txt", "output.txt");
    Ok(())
}

fn display_save_dialogue(title: &str, filter: &str, preset: &str) -> FileDialog {
    let mut chooser = NativeFileChooser::new(FileDialogType::BrowseSaveFile);
    chooser.set_title(title);
    chooser.set_filter(filter);
    chooser.set_preset_file(preset);
    chooser.show();
    chooser
}

fn memory_location_selector() -> Option<String> {
    let mut dialog_win = Window::new(150, 150, 300, 200, "Memory Location");
    let mut frame = Frame::new(
        50,
        25,
        200,
        60,
        "Please select memory location \n to load the file into",
    );
    frame.set_label_size(10);

    let mut memory_locations = Choice::new(120, 80, 60, 30, "$");
    memory_locations.add_choice("0400|0800|1000|3000|4000");
    memory_locations.set_value(1);

    let mut ok_btn = Button::new(80, 120, 50, 25, "OK");
    let mut cancel_btn = Button::new(160, 120, 50, 25, "Cancel");
    ok_btn.set_label_size(10);

    let result: Rc<RefCell<Option<String>>> = Rc::new(RefCell::new(None));
    {
        let result = result.clone();
        let mut win = dialog_win.clone();
        ok_btn.set_callback(move |_| {
            let choice = memory_locations.choice().clone();
            *result.borrow_mut() = Some(choice.unwrap());
            win.hide();
        });
    }
    {
        let result = result.clone();
        let mut win = dialog_win.clone();

        cancel_btn.set_callback(move |_| {
            *result.borrow_mut() = None;
            win.hide();
        });
    }

    dialog_win.end();
    dialog_win.show();

    while dialog_win.shown() {
        app::wait();
    }

    let value = result.borrow().clone();
    value
}

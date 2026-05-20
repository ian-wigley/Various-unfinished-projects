extern crate hex;

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

    let (s, r) = app::channel::<Message>();
    let mut menu: menu::SysMenuBar = menu::SysMenuBar::default().with_size(800, 20);
    menu.set_frame(FrameType::FlatBox);
    menu.add_emit(
        "&File/Open...\t",
        Shortcut::Ctrl | 'o',
        menu::MenuFlag::Normal,
        s,
        Message::Open,
    );

    menu.add_emit(
        "&File/Save.../Left Window\t",
        Shortcut::Ctrl | 'w',
        menu::MenuFlag::Normal,
        s,
        Message::SaveLeftWindow,
    );

    menu.add_emit(
        "&File/Save.../Right Window\t",
        Shortcut::Ctrl | 'w',
        menu::MenuFlag::Normal,
        s,
        Message::SaveRightWindow,
    );

    menu.add_emit(
        "&File/Quit\t",
        Shortcut::Ctrl | 'q',
        menu::MenuFlag::Normal,
        s,
        Message::Quit,
    );

    let mut frame = Frame::new(360, 10, 140, 20, "");
    frame.set_label_size(12);
    frame.set_frame(FrameType::NoBox);

    let mut but: Button = Button::new(370, 590, 80, 20, "Add labels");

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
                Message::SaveLeftWindow => save_as(parser.clone()).expect("OK"),
                Message::SaveRightWindow => println!("SaveRightWindow"),
                Message::Quit => app.quit(),
            }
        }
    }
    app.run().unwrap();
}

fn click(_wind: Window, parser: Rc<RefCell<Parser>>, right_display: TextDisplay) {
    // wind.clone().set_label("TODO Add labels!");
    parser
        .borrow_mut()
        .assembly_creator
        .add_labels("1000", "2000", true, 1, 2, right_display);
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

fn save_as(parser: Rc<RefCell<Parser>>) -> std::io::Result<()> {
    let _data = parser.borrow_mut().assembly_code.clone();
    if _data.len() > 0 {
        let contents = _data.join("");
        fs::write("output.txt", contents)?;
        println!("File written!");
    }
    Ok(())
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
    memory_locations.add_choice("0400|0800|1000");
    memory_locations.set_value(1);

    let mut ok_btn = Button::new(80, 120, 50, 25, "OK");
    let mut cancel_btn = Button::new(160, 120, 50, 25, "Cancel");
    ok_btn.set_label_size(10);

    let result: Rc<RefCell<Option<String>>> = Rc::new(RefCell::new(None));
    {
        let result = result.clone();
        let mut win = dialog_win.clone();
        let choice = memory_locations.choice().clone();

        ok_btn.set_callback(move |_| {
            *result.borrow_mut() = Some(choice.clone().unwrap());
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

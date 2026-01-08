extern crate hex;

use converter::con::Converter;
use fltk::app::Sender;
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
use std::cell::RefCell;
use std::env;
use std::rc::Rc;

mod converter;
mod opcode;

#[derive(Copy, Clone)]
pub enum Message {
    Open,
    SaveAs,
    Quit,
    Convert,
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
        "&File/Save as...\t",
        Shortcut::Ctrl | 'w',
        menu::MenuFlag::Normal,
        s,
        Message::SaveAs,
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

    let mut but: Button = Button::new(380, 590, 80, 20, "Add labels");

    wind.end();
    wind.show();

    let converter = Rc::new(RefCell::new(Converter::new()));

    but.set_callback({
        let converter = converter.clone();
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
                Message::Open => open(converter.clone(), left_display.clone(), frame.clone(), s),
                Message::SaveAs => println!("SaveAs  selected"),
                Message::Quit => app.quit(),
                Message::Convert => println!("Convert from file"),
            }
        }
    }
    app.run().unwrap();
}

fn click(wind: Window, converter: Rc<RefCell<Converter>>, right_display: TextDisplay) {
    wind.clone().set_label("TODO Add labels!");
    converter
        .borrow_mut()
        .add_labels("1000", "2000", true, 1, 2, right_display);
    // println!("Added labels!");
}

fn open(
    converter: Rc<RefCell<Converter>>,
    left_display: TextDisplay,
    mut frame: Frame,
    s: Sender<Message>,
) {
    let mut chooser =
        dialog::FileChooser::new(".", "*", dialog::FileChooserType::Single, "Select a file");
    chooser.show();
    chooser.window().set_pos(300, 300);

    while chooser.shown() {
        app::wait();
    }

    if let Some(file_name) = chooser.value(1) {
        let pos = file_name.rfind('/');
        println!("{:?}", pos);
        let f = file_name.split_at(pos.unwrap() + 1).1;
        println!("Selected file: {}", f);
        println!("Selected file: {}", file_name);
        frame.set_label(&f);
    } else {
        println!("No file selected");
    }

    let file_name = chooser.value(1).unwrap();
    // frame.set_label(&file_name);

    let start_address = memory_location_selector(s).unwrap();
    println!("Mls: {:?}", start_address);

    converter.borrow_mut().init(&*file_name);
    //converter.borrow_mut().convert_to_assembly(left_display);
}

fn memory_location_selector(s: Sender<Message>) -> Option<String> {
    let mut dialog_win = Window::new(150, 150, 300, 200, "Memory Location");
    let mut frame = Frame::new(
        50,
        25,
        200,
        60,
        "Please select memory location to load the file into",
    );
    frame.set_label_size(10);

    let mut memory_locations = Choice::new(120, 80, 60, 30, "$");

    //     new { Text = "0400", Value = 1024 },
    //     new { Text = "0800", Value = 2048 },
    //     new { Text = "1000", Value = 4096 },

    memory_locations.add_choice("0400|0800|1000");
    memory_locations.set_value(1);

    let mut ok_btn = Button::new(40, 120, 100, 35, "Ok");
    let mut cancel_btn = Button::new(160, 120, 100, 35, "Cancel");
    ok_btn.set_label_size(10);

    ok_btn.set_callback({
        let mut dialog_win = dialog_win.clone();
        // let memory_location = memory_locations.clone();
        // let mut ok_btns = ok_btn.clone();
        move |_| {
            dialog_win.hide();
            // if let Some(selected) = memory_location.choice() {
            //     println!("Selected: {}", selected);
            //     println!("Selected memory location: {}", memory_location.value());
            //     ok_btns.emit(s, Message::Convert);
            // }
        }
    });

    cancel_btn.set_callback({
        let mut dialog_win = dialog_win.clone();
        move |_| dialog_win.hide()
    });

    dialog_win.end();
    dialog_win.show();

    while dialog_win.shown() {
        app::wait();
    }

    memory_locations.choice()
}

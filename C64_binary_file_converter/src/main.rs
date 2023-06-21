extern crate hex;

use fltk::{
    app,
    button::Button,
    enums::{Font, FrameType, Shortcut},
    menu,
    prelude::*,
    text::TextDisplay,
    window::Window,
};

use std::{collections::HashMap, env};

mod converter;
mod opcode;

#[derive(Copy, Clone)]
pub struct Opcode {}

#[derive(Clone)]
struct Converter {
    opcode: Opcode,
    opcodes: HashMap<&'static str, [&'static str; 5]>,
    hex_content: Vec<String>,
    file_content: Vec<u8>,
    assembly_code: Vec<String>,
}

#[derive(Copy, Clone)]
pub enum Message {
    Changed,
    SaveAs,
}

fn main() {
    env::set_var("RUST_BACKTRACE", "full");

    let app: app::App = app::App::default().load_system_fonts();
    Font::set_font(Font::Courier, "Monospace");
    app::set_font_size(10);

    let mut wind: fltk::window::DoubleWindow =
        Window::new(100, 100, 820, 620, "C64 Binary to Assembly Converter");
    let left_display: TextDisplay = TextDisplay::new(5, 35, 400, 550, None);
    let right_display: TextDisplay = TextDisplay::new(415, 35, 400, 550, None);

    let (s, _r) = app::channel::<Message>();
    let mut menu: menu::SysMenuBar = menu::SysMenuBar::default().with_size(800, 35);
    menu.set_frame(FrameType::FlatBox);
    menu.add_emit(
        "&File/Save as...\t",
        Shortcut::Ctrl | 'w',
        menu::MenuFlag::Normal,
        s,
        Message::SaveAs,
    );
    let mut but: Button = Button::new(380, 590, 80, 20, "Add labels");

    wind.end();
    wind.show();

    let mut converter: Converter = Converter::new();
    converter.init();
    converter.convert_to_assembly(left_display);

    but.set_callback(move |_| {
        click(
            wind.to_owned(),
            converter.to_owned(),
            right_display.to_owned(),
        )
    });
    but.activate();

    app.run().unwrap();
}

fn click(wind: Window, converter: Converter, right_display: TextDisplay) {
    wind.clone().set_label("TODO Add labels!");
    converter.add_labels("1000", "2000", true, 1, 2, right_display);
}

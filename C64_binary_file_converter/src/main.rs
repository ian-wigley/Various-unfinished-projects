extern crate hex;

use fltk::{
    app,
    button::Button,
    enums::{Font, FrameType, Shortcut},
    menu,
    prelude::*,
    text::{TextBuffer, TextDisplay},
    window::Window,
};

use std::collections::HashMap;
use std::env;
use std::io::Read;
use std::str::FromStr;

mod opcode;

#[derive(Copy, Clone)]
pub struct Opcode {}

#[derive(Copy, Clone)]
pub enum Message {
    Changed,
    SaveAs,
}

//https://www.reddit.com/r/rust/comments/q58q2n/fltkrs_textdisplay_how_to_update/

fn main() {
    env::set_var("RUST_BACKTRACE", "full");

    let app = app::App::default().load_system_fonts();
    Font::set_font(Font::Helvetica, "Monospace");
    app::set_font_size(10);

    let mut wind = Window::new(100, 100, 820, 620, "C64 Binary to Assembly Converter");
    let left_display = TextDisplay::new(5, 35, 400, 550, None);
    let _right_display = TextDisplay::new(415, 35, 400, 550, None);

    let (s, _r) = app::channel::<Message>();
    let mut menu = menu::SysMenuBar::default().with_size(800, 35);
    menu.set_frame(FrameType::FlatBox);
    menu.add_emit(
        "&File/Save as...\t",
        Shortcut::Ctrl | 'w',
        menu::MenuFlag::Normal,
        s,
        Message::SaveAs,
    );
    let mut but = Button::new(380, 590, 80, 20, "Add labels");

    wind.end();
    wind.show();

    but.set_callback(move |_| click(wind.to_owned()));

    // Create a new OpCode Object
    let opcode = Opcode::new();

    // Populate the OpCode Map
    let opcodes = opcode.populate_opcodes();

    // Load the external binary file
    let file_content: Vec<u8> = load_bin_file().unwrap();

    let hex_content = parse_content(file_content.clone());

    convert_to_assembly(
        hex_content,
        opcode,
        opcodes.clone(),
        file_content,
        left_display,
    );

    but.activate();

    app.run().unwrap();
}

fn click(wind: Window) {
    wind.clone().set_label("TODO Add labels!");
}

fn convert_to_assembly(
    hex_content: Vec<String>,
    opcode: Opcode,
    opcodes: HashMap<&str, [&str; 5]>,
    file_content: Vec<u8>,
    disp: TextDisplay,
) {
    let mut diplay_text = disp;
    let mut buf = TextBuffer::default();

    let mut file_position = 0;
    let mut pc: usize = 0;

    while file_position < 1000
    //hex.len()
    {
        let op_code = hex_content[file_position].clone().to_uppercase();
        let values = opcode.get_match(opcodes.clone(), op_code.as_str());
        let nmenonic = values[0];
        let incrementer = i32::from_str(values[1]).unwrap_or(1);

        let mut _two: String = String::from("  ");
        let mut _three: String = String::from("  ");
        let mut _padding: String = String::new();

        if incrementer == 2 {
            if is_branch(nmenonic) {
                let mut _u: u8 = file_content[pc + 1];
                let mut _v: i8 = _u as i8;
                let _w = (_v + 2) as i32;
                let mut _s = (pc as i32) + _w;

                let mut _vv: i8 = ((file_content[pc + 1]) as i8) + 2;
                let mut _ss = (pc as i32) + _vv as i32;

                _two = "".to_owned();
                _three = format!("{:04X}", _s);
            } else {
                _three = hex_content[pc + 1].clone().to_uppercase();
            }
        }
        if incrementer == 3 {
            _two = hex_content[pc + 2].to_uppercase().as_str().parse().unwrap();
            _padding = _two.clone();
            _three = hex_content[pc + 1].to_uppercase().as_str().parse().unwrap();
        }

        // increment the pc
        pc += incrementer as usize;

        let code = format!(
            "{:04X} {} {} {}        {} {}{}{}{}\n",
            file_position, op_code, _three, _two, nmenonic, values[2], _padding, _three, values[3]
        );
        buf.append(&code);

        file_position += incrementer as usize;
    }
    diplay_text.set_buffer(buf.clone());
}

fn is_branch(nmenonic: &str) -> bool {
    //
    // Method returns if there is a match between the supplied &str & the values below.
    //
    // # Arguments
    // * `nmenonic` string
    //
    return nmenonic == "BCC"
        || nmenonic == "BCS"
        || nmenonic == "BEQ"
        || nmenonic == "BMI"
        || nmenonic == "BNE"
        || nmenonic == "BPL"
        || nmenonic == "BVC"
        || nmenonic == "BVS";
}

fn load_bin_file() -> std::io::Result<Vec<u8>> {
    //
    // Method to load the file.
    //
    // # Arguments
    // * none
    //
    let path = env::current_dir()?;
    let bin_path = path.join("Assets/C64_Binary.bin");
    let mut file = std::fs::File::open(bin_path)?;
    let mut v: Vec<u8> = Vec::new();
    let _content = file.read_to_end(&mut v);
    Ok(v)
}

fn parse_content(bin: Vec<u8>) -> Vec<String> {
    //
    // Method to iterate through each object in the Vector to Populate a HashMap.
    //
    // # Arguments
    // * bin
    //
    // println!("Vec Length: {}", bin.len());
    let mut opcode_mappings = Vec::new();
    for n in bin.iter() {
        let num_usize = [*n as u8];
        let hop_code = hex::encode(num_usize);
        opcode_mappings.push((*hop_code).parse().unwrap());
    }
    return opcode_mappings;
}

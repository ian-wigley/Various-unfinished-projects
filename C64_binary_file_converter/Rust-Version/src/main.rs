extern crate hex;

use bitmap_viewer::bitmap_viewer::C64Bitmap;
use byte_viewer::BytesView;

use fltk::app::Receiver;
use fltk::dialog::{FileDialog, FileDialogType, NativeFileChooser};
use fltk::frame::Frame;
use fltk::group::{Group, Tabs};
use fltk::input::IntInput;
use fltk::menu::SysMenuBar;
use fltk::{
    app,
    button::Button,
    enums::{Font, FrameType, Shortcut},
    menu,
    prelude::*,
    text::TextDisplay,
    window::Window,
};
use load_into_memory_location_selector::LoadIntoMemoryLocationSelector;
use opcode::oc::Opcode;
use parser::parse::Parser;

use crate::memory_locations_to_convert_selector::MemoryLocationsToConvertSelector;
use fltk::valuator::Scrollbar;
use image::{ImageBuffer, Rgb};
use std::cell::RefCell;
use std::rc::Rc;
use std::{env, fs};

mod assembly_creator;
mod bitmap_viewer;
mod byte_viewer;
mod load_into_memory_location_selector;
mod memory_locations_to_convert_selector;
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

#[derive(Clone)]
struct State {
    pub(crate) bytes_view: BytesView,
    pub(crate) scroll: Scrollbar,
    pub(crate) start_address: String,
}

impl State {
    pub fn new() -> State {
        State {
            bytes_view: BytesView::new(100, 650, 620, 190),
            scroll: Scrollbar::new(750, 650, 15, 180, ""),
            start_address: String::new(),
        }
    }
}

// https://github.com/fltk-rs/fltk-rs/blob/master/fltk/examples/editor2.rs
// https://fltk-rs.github.io/fltk-book/Menus.html

fn main() {
    env::set_var("RUST_BACKTRACE", "full");

    let parser = Rc::new(RefCell::new(Parser::new()));
    let app: app::App = app::App::default().load_system_fonts();
    let font = Font::load_font("Assets/Consolas-Regular.ttf").unwrap();
    Font::set_font(Font::Helvetica, &font);
    app::set_font_size(12);
    let mut wind: fltk::window::DoubleWindow =
        Window::new(100, 100, 820, 860, "C64 Binary to Assembly Converter");

    let left_display: TextDisplay = TextDisplay::new(5, 35, 400, 550, None);
    let right_display: TextDisplay = TextDisplay::new(415, 35, 400, 550, None);

    let (menu, receiver) = configure_menu_bar();

    let mut frame = Frame::new(340, 10, 180, 20, "");
    frame.set_label_size(12);
    frame.set_frame(FrameType::NoBox);

    let mut but: Button = Button::new(350, 590, 120, 20, "Generate labels");
    let state = configure_tabs(parser.clone());

    wind.end();
    wind.show();

    but.set_callback({
        let converter = parser.clone();
        move |_| {
            let (start, end) = converter.borrow().clone().collect_start_and_end_addresses();
            let m = MemoryLocationsToConvertSelector::new(start.clone(), end.clone());
            let mut n = m.borrow().window.clone();
            n.show();
            while n.shown() {
                app::wait();
            }
            click(
                wind.to_owned(),
                converter.to_owned(),
                right_display.to_owned(),
                start.clone(),
                end.clone(),
            )
        }
    });
    but.deactivate();

    while app.wait() {
        if let Some(msg) = receiver.recv() {
            match msg {
                Message::Open => {
                    open(
                        parser.clone(),
                        left_display.clone(),
                        frame.clone(),
                        state.clone(),
                    );
                    but.clone().activate();
                    if let Some(mut item) = menu.find_item("&File/Save...") {
                        item.activate();
                    }
                    if let Some(mut item) = menu.find_item("&File/Export Bytes") {
                        item.activate();
                    }
                }
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

fn configure_tabs(parser: Rc<RefCell<Parser>>) -> State {
    let state;
    let data = Rc::new(RefCell::new(Vec::<u8>::new()));
    // https://www.youtube.com/watch?v=X4CD-pDdOrk & https://www.seriss.com/people/erco/fltk/#TabsExample
    let tabs: Tabs = Tabs::new(20, 620, 780, 230, "");
    {
        let tab1: Group = Group::new(10, 640, 780, 210, "Assembly Viewer\n");

        state = State::new();
        let view = state.bytes_view.clone();
        let mut scroll = state.scroll.clone();
        scroll.set_step(1.0, 1);

        scroll.set_callback({
            let mut view = view.clone();
            move |s| {
                view.scroll_to(s.value() as usize);
            }
        });
        tab1.end();
    }
    {
        let tab2: Group = Group::new(0, 640, 790, 210, "Bitmap Viewer\n");
        let mut tab_frame = Frame::default().with_size(320, 210).center_of(&tab2);
        let mut bitmap_location: IntInput = IntInput::new(80, 660, 60, 20, "Bitmap");
        bitmap_location.set_maximum_size(6);
        bitmap_location.set_value("0x2000");
        let mut screen_location: IntInput = IntInput::new(80, 690, 60, 20, "Screen");
        screen_location.set_maximum_size(6);
        screen_location.set_value("0x3F40");
        let mut colour_location: IntInput = IntInput::new(80, 720, 60, 20, "Colour");
        colour_location.set_maximum_size(6);
        colour_location.set_value("0x4328");

        let data_display = Rc::clone(&data);
        let mut display_btn = Button::new(45, 750, 85, 25, "Show Bitmap");
        display_btn.set_callback(move |_| {
            if !parser.borrow().line_numbers.is_empty() {
                let start_address: usize =
                    usize::from_str_radix(&parser.borrow().start_address.clone(), 16).unwrap();
                let bitmap_start_address: usize =
                    usize::from_str_radix(&*bitmap_location.value().replace("0x", ""), 16).unwrap()
                        - start_address;
                let screen_start_address: usize =
                    usize::from_str_radix(&*screen_location.value().replace("0x", ""), 16).unwrap()
                        - start_address;
                let colour_start_address: usize =
                    usize::from_str_radix(&*colour_location.value().replace("0x", ""), 16).unwrap()
                        - start_address;

                let (bitmap, screen, color) = get_bitmap_data(
                    bitmap_start_address,
                    screen_start_address,
                    colour_start_address,
                    parser.clone(),
                );
                let bitmap_image =
                    C64Bitmap::convert_multicolor_to_image(&bitmap, &screen, &color, 9);
                tab_frame.set_image(Some(bitmap_image.clone()));
                tab_frame.redraw();
                *data_display.borrow_mut() = bitmap_image.to_rgb_data();
            }
        });
        display_btn.set_label_size(12);

        let data_save = Rc::clone(&data);
        let mut save_bitmap_btn = Button::new(45, 780, 85, 25, "Save Bitmap");
        save_bitmap_btn.set_callback(move |_| {
            save_bitmap_image(data_save.borrow().clone()).expect("OK");
        });
        save_bitmap_btn.set_label_size(12);

        tab2.end();
    }
    tabs.end();
    state
}

fn save_bitmap_image(data: Vec<u8>) -> Result<(), Box<dyn std::error::Error>> {
    let title: &str = "Save Bitmap";
    let chooser = display_save_dialogue(title, "Image Files\t*.png", "output.png");
    let filename = chooser.filename();
    if !filename.to_string_lossy().is_empty() {
        let buffer: ImageBuffer<Rgb<u8>, Vec<u8>> =
            ImageBuffer::from_raw(320, 200, data).ok_or("Failed to create image buffer")?;
        buffer.save(filename)?;
    }
    Ok(())
}

fn get_bitmap_data(
    bitmap_start_address: usize,
    screen_start_address: usize,
    colour_start_address: usize,
    parser: Rc<RefCell<Parser>>,
) -> (Vec<u8>, Vec<u8>, Vec<u8>) {
    // 8192 u8's
    let bitmap: Vec<u8> =
        parser.borrow().file_content[bitmap_start_address..bitmap_start_address + 8192].to_vec();
    // println!("{} {}", "bitmap length ", bitmap.len().to_string());

    // 1024 u8's
    let screen: Vec<u8> =
        parser.borrow().file_content[screen_start_address..screen_start_address + 4096].to_vec();
    // println!("{} {}", "screen length ", screen.len().to_string());

    // 1024 u8's
    let color: Vec<u8> =
        parser.borrow().file_content[colour_start_address..colour_start_address + 4096].to_vec();
    // println!("{} {}", "color length ", color.len().to_string());

    (bitmap, screen, color)
}

fn configure_menu_bar() -> (SysMenuBar, Receiver<Message>) {
    let (sender, receiver) = app::channel::<Message>();
    let mut menu: SysMenuBar = SysMenuBar::default().with_size(800, 20);
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

    if let Some(mut item) = menu.find_item("&File/Save...") {
        item.deactivate();
    }
    if let Some(mut item) = menu.find_item("&File/Export Bytes") {
        item.deactivate();
    }
    (menu, receiver)
}

fn click(
    _wind: Window,
    parser: Rc<RefCell<Parser>>,
    right_display: TextDisplay,
    start: Vec<char>,
    end: Vec<char>,
) {
    let local_start: String = start.into_iter().collect();
    let start_memory_location: &str = local_start.as_str();
    let local_end: String = end.into_iter().collect();
    let end_memory_location: &str = local_end.as_str();
    let start: i32 = get_index(start_memory_location, &parser);
    let end: i32 = get_index(end_memory_location, &parser);
    if start != -1 && end != -1 {
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
}

fn get_index(start_text: &str, parser: &Rc<RefCell<Parser>>) -> i32 {
    let line_numbers = parser.borrow().line_numbers.clone();
    let index = line_numbers.iter().position(|x| x.contains(start_text));
    match index {
        Some(_i) => index.unwrap() as i32,
        None => {
            println!("Line number not found");
            -1
        }
    }
}

fn open(
    converter: Rc<RefCell<Parser>>,
    left_display: TextDisplay,
    mut frame: Frame,
    mut state: State,
) {
    let mut chooser = NativeFileChooser::new(FileDialogType::BrowseFile);
    chooser.set_title("Select a file");
    chooser.set_filter("Binary Files\t*.bin");
    chooser.set_preset_file("*.bin");
    chooser.show();

    let file_path = chooser.filename();
    let full_path = file_path.to_string_lossy().to_string();
    let filename = file_path
        .file_name()
        .and_then(|f| f.to_str())
        .unwrap_or("unknown");

    frame.set_label(&filename);

    match memory_location_selector() {
        Some(memory_location) => {
            converter.borrow_mut().init(&*full_path.clone());
            let _data = converter
                .borrow_mut()
                .parse_file_content(left_display, memory_location.clone());
            converter
                .borrow_mut()
                .assembly_creator
                .update_assembly_code(_data.clone());
            let start_address =
                usize::from_str_radix(memory_location.clone().as_str(), 16).unwrap();
            state
                .bytes_view
                .set_bytes(converter.borrow_mut().file_content.clone(), start_address);
            state.start_address = memory_location.clone();
            println!("State start address {}", state.start_address);

            if converter.borrow_mut().line_numbers.clone().len() / 8 > 1 {
                state.scroll.set_bounds(
                    0.0,
                    ((converter.borrow_mut().line_numbers.clone().len() / 8) - 8) as f64,
                );
                //0.0, ((converter.borrow_mut().file_content.clone().len() / 8) - 8) as f64);
            }
        }
        None => println!("Cancelled"),
    }
}

fn save_left_window(parser: Rc<RefCell<Parser>>) -> std::io::Result<()> {
    let title: &str = "Save left window content";
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

fn save_binary(_parser: Rc<RefCell<Parser>>) -> std::io::Result<()> {
    let title = "Save selected memory as Binary";
    let _chooser = display_save_dialogue(title, "Binary Files\t*.bin", "output.bin");
    Ok(())
}

fn save_text(_parser: Rc<RefCell<Parser>>) -> std::io::Result<()> {
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
    LoadIntoMemoryLocationSelector::show()
}

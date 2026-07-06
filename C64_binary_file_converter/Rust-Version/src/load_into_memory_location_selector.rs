use fltk::enums::{Event, Key};
use fltk::frame::Frame;
use fltk::{app, button::Button, misc::InputChoice, prelude::*, window::Window};
use std::{cell::RefCell, rc::Rc};

pub(crate) struct LoadIntoMemoryLocationSelector {
    result: Rc<RefCell<Option<String>>>,
}

#[derive(Debug, Clone)]
pub struct SelectedAddress {
    pub text: String,
    pub value: i32,
}

const ADDRESS_ITEMS: &[(&str, i32)] = &[
    ("0400", 1024),
    ("0800", 2048),
    ("0900", 2304),
    ("0A00", 2560),
    ("0C00", 3072),
    ("0D00", 3328),
    ("0E00", 3584),
    ("0F00", 3840),
    ("1000", 4096),
    ("2000", 8192),
    ("3000", 12288),
    ("4000", 16384),
    ("5000", 20480),
    ("6000", 24576),
    ("7000", 28672),
    ("8000", 32768),
    ("9000", 36864),
    ("A000", 40960),
    ("B000", 45056),
    ("C000", 49152),
    ("D000", 53248),
    ("E000", 57344),
    ("F000", 61440),
];

impl LoadIntoMemoryLocationSelector {
    pub fn show() -> Option<String> {
        let mut dialog_win = Window::new(150, 150, 300, 200, "Memory Location");
        dialog_win.make_resizable(false);
        let mut frame = Frame::new(
            50,
            25,
            200,
            60,
            "Please select memory location \n to load the file into",
        );
        frame.set_label_size(10);

        let mut memory_locations = InputChoice::new(120, 80, 60, 30, "$");
        for (text, _) in ADDRESS_ITEMS {
            memory_locations.add(text);
        }
        memory_locations.set_value("0800");

        let mut ok_btn = Button::new(80, 120, 50, 25, "OK");
        let mut cancel_btn = Button::new(160, 120, 50, 25, "Cancel");
        ok_btn.set_label_size(10);

        let result: Rc<RefCell<Option<String>>> = Rc::new(RefCell::new(None));
        {
            let result = result.clone();
            let mut win = dialog_win.clone();
            let win_c = win.clone();
            let address_selector_c = memory_locations.clone();
            let result_c: Rc<RefCell<Option<SelectedAddress>>> = Rc::new(RefCell::new(None));

            memory_locations.handle(move |inp, ev| match ev {
                Event::KeyDown => {
                    if app::event_key() == Key::Enter {
                        try_accept(&win_c, &address_selector_c, &result_c);
                        return true;
                    }
                    if let Some(ch) = app::event_text().chars().next() {
                        if !ch.is_ascii_control() && !ch.is_ascii_hexdigit() {
                            // swallow disallowed character
                            return true;
                        }
                    }
                    false
                }
                Event::KeyUp => {
                    let upper = inp.value().unwrap().to_uppercase();
                    if upper != inp.value().unwrap().to_uppercase() {
                        inp.set_value(&upper);
                    }
                    false
                }
                _ => false,
            });

            ok_btn.set_callback(move |_| {
                let choice = memory_locations.value().clone();
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
}

/// Equivalent of `Regex.IsMatch(text, @"\A[0-9A-F]{1,4}\z")`.
fn is_valid(text: &str) -> bool {
    (1..=4).contains(&text.len())
        && text
            .chars()
            .all(|c| c.is_ascii_hexdigit() && !c.is_ascii_lowercase())
}

fn show_invalid_input_message() {
    fltk::dialog::alert_default("Enter a hexadecimal value (1\u{2013}4 characters).");
}

fn try_accept(
    win: &Window,
    address_selector: &InputChoice,
    result: &Rc<RefCell<Option<SelectedAddress>>>,
) {
    let text = address_selector.value().unwrap_or_default();
    if !is_valid(&text) {
        show_invalid_input_message();
        return;
    }
    let value = ADDRESS_ITEMS
        .iter()
        .find(|(t, _)| *t == text)
        .map(|(_, v)| *v)
        .unwrap_or(0);
    *result.borrow_mut() = Some(SelectedAddress { text, value });
    let mut w = win.clone();
    w.hide();
}

use fltk::enums::{Event, Key};
use fltk::frame::Frame;
use fltk::{app, button::Button, misc::InputChoice, prelude::*, window::Window};
use std::{cell::RefCell, rc::Rc};

pub(crate) struct LoadIntoMemoryLocationSelector {
    result: Rc<RefCell<Option<String>>>,
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
            // let mut input = memory_locations.input();
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
                        //let _ = inp.set_position(upper.len() as i32);
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

// if let Some(address) = LoadIntoMemoryLocationSelector::show() {
// println!("Selected address: {}", address);
// }

// //! Rust + FLTK-RS port of the C# `LoadIntoMemoryLocationSelector` WinForms dialog.
// //!
// //! Behaviour ported from the original:
// //!  - Fixed-size, non-resizable dialog with no maximize/minimize buttons
// //!    (`FormBorderStyle.FixedSingle`, `MaximizeBox/MinimizeBox = false`).
// //!  - An editable combo box (`InputChoice` here) pre-populated with C64
// //!    hex memory addresses, defaulting to the second entry ("0800").
// //!  - Key-press filtering: only hex digits are accepted, lowercase is
// //!    normalized to uppercase, and Enter accepts the dialog (like clicking OK).
// //!  - Validation on accept: the text must match `\A[0-9A-F]{1,4}\z`,
// //!    otherwise a warning message box is shown and the dialog stays open.
// //!  - `GetMemStartLocation` exposed as a getter method.
//
// use fltk::{
//     app,
//     button::Button,
//     enums::{Event, Key},
//     // menu::InputChoice,
//     misc::InputChoice,
//     prelude::*,
//     window::Window,
// };
// use std::cell::RefCell;
// use std::rc::Rc;
//
// /// (display text, numeric value) pairs - mirrors the C# anonymous-type list
// /// that was bound to `StartAddressSelector.DataSource`.
// const ADDRESS_ITEMS: &[(&str, i32)] = &[
//     ("0400", 1024),
//     ("0800", 2048),
//     ("0900", 2304),
//     ("0A00", 2560),
//     ("0C00", 3072),
//     ("0D00", 3328),
//     ("0E00", 3584),
//     ("0F00", 3840),
//     ("1000", 4096),
//     ("2000", 8192),
//     ("3000", 12288),
//     ("4000", 16384),
//     ("5000", 20480),
//     ("6000", 24576),
//     ("7000", 28672),
//     ("8000", 32768),
//     ("9000", 36864),
//     ("A000", 40960),
//     ("B000", 45056),
//     ("C000", 49152),
//     ("D000", 53248),
//     ("E000", 57344),
//     ("F000", 61440),
// ];
//
// /// Result handed back once the dialog closes with a valid, accepted value
// /// (equivalent to checking `DialogResult == DialogResult.OK` afterwards).
#[derive(Debug, Clone)]
pub struct SelectedAddress {
    pub text: String,
    pub value: i32,
}
//
// pub struct LoadIntoMemoryLocationSelector {
//     win: Window,
//     address_selector: InputChoice,
//     result: Rc<RefCell<Option<SelectedAddress>>>,
// }
//
// impl LoadIntoMemoryLocationSelector {
//     pub fn new() -> Self {
//         let mut win = Window::new(0, 0, 300, 90, "Load Into Memory Location");
//         win.make_resizable(false); // FixedSingle + no Maximize/Minimize boxes
//
//         let mut address_selector = InputChoice::new(20, 15, 180, 28, "");
//         for (text, _value) in ADDRESS_ITEMS {
//             address_selector.add(text);
//         }
//         // SelectedIndex = 1 in the original code -> "0800".
//         address_selector.set_value(ADDRESS_ITEMS[1].0);
//
//         let mut ok_button = Button::new(210, 15, 70, 28, "OK");
//
//         win.end();
//
//         let result: Rc<RefCell<Option<SelectedAddress>>> = Rc::new(RefCell::new(None));
//
//         // --- Key filtering on the editable text part of the combo box ---
//         // Mirrors ValidateKeyInput: only hex digits are accepted, Enter
//         // accepts the dialog. Case is normalized to uppercase on key-up
//         // (simpler and more robust in FLTK than rewriting the keystroke
//         // in-place, which is what the original WinForms handler did via
//         // `e.KeyChar = c`).
//         {
//             let mut input = address_selector.input();
//             let win_c = win.clone();
//             let address_selector_c = address_selector.clone();
//             let result_c = Rc::clone(&result);
//             input.handle(move |inp, ev| match ev {
//                 Event::KeyDown => {
//                     if app::event_key() == Key::Enter {
//                         try_accept(&win_c, &address_selector_c, &result_c);
//                         return true;
//                     }
//                     if let Some(ch) = app::event_text().chars().next() {
//                         if !ch.is_ascii_control() && !ch.is_ascii_hexdigit() {
//                             return true; // swallow disallowed character
//                         }
//                     }
//                     false
//                 }
//                 Event::KeyUp => {
//                     let upper = inp.value().to_uppercase();
//                     if upper != inp.value() {
//                         inp.set_value(&upper);
//                         let _ = inp.set_position(upper.len() as i32);
//                     }
//                     false
//                 }
//                 _ => false,
//             });
//         }
//
//         // --- OK button click: validate, then close like DialogResult.OK ---
//         {
//             let win_c = win.clone();
//             let address_selector_c = address_selector.clone();
//             let result_c = Rc::clone(&result);
//             ok_button.set_callback(move |_| {
//                 try_accept(&win_c, &address_selector_c, &result_c);
//             });
//         }
//
//         // --- Validate on any attempt to close the window (e.g. the [X]
//         // button), mirroring the Closing/CancelEventArgs handler that
//         // could cancel the close. ---
//         {
//             let address_selector_c = address_selector.clone();
//             win.set_callback(move |w| {
//                 if is_valid(&address_selector_c.value().unwrap_or_default()) {
//                     w.hide();
//                 } else {
//                     show_invalid_input_message();
//                 }
//             });
//         }
//
//         Self {
//             win,
//             address_selector,
//             result,
//         }
//     }
//
//     /// Runs the FLTK event loop until the dialog is closed, then returns
//     /// the selected address if the user accepted with a valid value.
//     pub fn show_modal(&mut self) -> Option<SelectedAddress> {
//         self.win.set_pos(
//             (app::screen_size().0 as i32 - self.win.width()) / 2,
//             (app::screen_size().1 as i32 - self.win.height()) / 2,
//         );
//         self.win.show();
//         while self.win.shown() {
//             app::wait();
//         }
//         self.result.borrow().clone()
//     }
//
//     /// Equivalent of the C# `GetMemStartLocation` property.
//     pub fn get_mem_start_location(&self) -> String {
//         self.address_selector.value().unwrap_or_default()
//     }
// }
//
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

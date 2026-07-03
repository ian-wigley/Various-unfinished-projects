use fltk::frame::Frame;
use fltk::{app, button::Button, misc::InputChoice, prelude::*, window::Window};
use std::{cell::RefCell, rc::Rc};

pub(crate) struct LoadIntoMemoryLocationSelector {
    result: Rc<RefCell<Option<String>>>,
}

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

        let addresses = [
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

        let mut memory_locations = InputChoice::new(120, 80, 60, 30, "$");
        for (text, _) in addresses {
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


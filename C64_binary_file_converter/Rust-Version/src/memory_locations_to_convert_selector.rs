use fltk::{
    app,
    button::{Button, CheckButton},
    group::{Group, Pack, PackType},
    menu::Choice,
    prelude::*,
    window::Window,
};

use fltk::enums::Event;
use std::{cell::RefCell, rc::Rc};

pub(crate) struct MemoryLocationsToConvertSelector {
    pub window: Window,
    start_boxes: [Choice; 4],
    end_boxes: [Choice; 4],
    // illegal_checkbox: CheckButton,
    start_address: u16,
    end_address: u16,
    original_start: Vec<char>,
    original_end: Vec<char>,
}

impl MemoryLocationsToConvertSelector {
    pub fn new(start: Vec<char>, end: Vec<char>) -> Rc<RefCell<Self>> {
        let win = Window::new(100, 100, 275, 245, "Memory Selector");
        let start_group = Group::new(20, 20, 235, 65, "Select Memory Start Address");
        let mut start_pack = Pack::new(25, 30, 200, 25, "");
        start_pack.set_spacing(6);
        start_pack.set_type(PackType::Horizontal);

        let mut start_boxes = [
            Choice::default().with_size(40, 25),
            Choice::default().with_size(40, 25),
            Choice::default().with_size(40, 25),
            Choice::default().with_size(40, 25),
        ];

        start_pack.end();
        start_group.end();

        let end_group = Group::new(20, 85, 235, 65, "Select Memory End Address");
        let mut end_pack = Pack::new(25, 100, 200, 25, "");
        end_pack.set_spacing(6);
        end_pack.set_type(PackType::Horizontal);

        let mut end_boxes = [
            Choice::default().with_size(40, 25),
            Choice::default().with_size(40, 25),
            Choice::default().with_size(40, 25),
            Choice::default().with_size(40, 25),
        ];

        end_pack.end();
        end_group.end();

        let mut illegal = CheckButton::new(40, 165, 190, 25, "Convert Illegal opcodes to data");
        illegal.hide();

        let mut ok = Button::new(100, 205, 75, 28, "OK");

        win.end();

        for b in start_boxes.iter_mut().chain(end_boxes.iter_mut()) {
            Self::init_choice(b);
        }

        for i in 0..4 {
            start_boxes[i].set_value(start[i].to_digit(16).unwrap() as i32);
            end_boxes[i].set_value(end[i].to_digit(16).unwrap() as i32);
        }

        let start_addr = u16::from_str_radix(&start.iter().collect::<String>(), 16).unwrap();
        let end_addr = u16::from_str_radix(&end.iter().collect::<String>(), 16).unwrap();

        let selector = Rc::new(RefCell::new(Self {
            window: win,
            start_boxes,
            end_boxes,
            // illegal_checkbox: illegal,
            start_address: start_addr,
            end_address: end_addr,
            original_start: start,
            original_end: end,
        }));

        {
            let s = selector.clone();
            ok.set_callback(move |_| {
                let w = s.try_borrow().unwrap();
                let mut wi = w.window.clone();
                wi.hide();
            });
        }

        // Start callbacks
        for i in 0..4 {
            let s = selector.clone();
            selector.borrow_mut().start_boxes[i].set_callback(move |_| {
                s.borrow_mut().validate_start(i);
            });
        }

        // End callbacks
        for i in 0..4 {
            let s = selector.clone();
            selector.borrow_mut().end_boxes[i].set_callback(move |_| {
                s.borrow_mut().validate_end(i);
            });
        }

        selector
    }

    fn init_choice(choice: &mut Choice) {
        for i in 0..16 {
            choice.add_choice(&format!("{:X}", i));
        }

        // Optional: allow keyboard hex entry
        choice.handle(|c, ev| {
            if ev == Event::KeyDown {
                if let Some(ch) = app::event_text().chars().next() {
                    if ch.is_ascii_hexdigit() {
                        let value = ch.to_digit(16).unwrap() as i32;
                        c.set_value(value);
                        return true;
                    }
                }
            }
            false
        });
    }

    pub fn selected_start(&self) -> String {
        self.start_boxes
            .iter()
            .map(|c| c.text(c.value()).unwrap())
            .collect()
    }

    pub fn selected_end(&self) -> String {
        self.end_boxes
            .iter()
            .map(|c| c.text(c.value()).unwrap())
            .collect()
    }

    // pub fn convert_illegal_opcodes(&self) -> bool {
    //     self.illegal_checkbox.value()
    // }

    fn validate_start(&mut self, idx: usize) {
        let addr = u16::from_str_radix(&self.selected_start(), 16).unwrap();
        if addr < self.start_address || addr > self.end_address {
            self.start_boxes[idx].set_value(self.original_start[idx].to_digit(16).unwrap() as i32);
        }
    }

    fn validate_end(&mut self, idx: usize) {
        let addr = u16::from_str_radix(&self.selected_end(), 16).unwrap();
        if addr < self.start_address || addr > self.end_address {
            self.end_boxes[idx].set_value(self.original_end[idx].to_digit(16).unwrap() as i32);
        }
    }
}

use fltk::{
    draw,
    enums::{Align, Color, Font},
    prelude::*,
    widget::Widget,
};
use std::{cell::RefCell, rc::Rc};

#[derive(Clone)]
pub(crate) struct BytesView {
    inner: Widget,
    state: Rc<RefCell<State>>,
}

struct State {
    data: Vec<u8>,
    start_address: usize,
    start_line: usize,
    row_count: usize,
    column_count: usize,
}

impl BytesView {
    pub fn new(x: i32, y: i32, w: i32, h: i32) -> Self {
        let mut inner = Widget::new(x, y, w, h, None);

        let state = Rc::new(RefCell::new(State {
            data: Vec::new(),
            start_address: 0,
            start_line: 0,
            row_count: 25,
            column_count: 8,
        }));

        let state_draw = state.clone();

        inner.draw(move |w| {
            let st = state_draw.borrow();

            draw::set_draw_color(Color::White);
            draw::draw_rectf(w.x(), w.y(), w.w(), w.h());
            draw::set_draw_color(Color::Black);

            for line in 0..st.row_count {
                let y = w.y() + 7 + (line as i32 * 21);

                let offset = (st.start_line + line) * st.column_count;

                if offset >= st.data.len() {
                    break;
                }

                let end = (offset + st.column_count).min(st.data.len());
                let slice = &st.data[offset..end];

                // Address column
                let addr = format!("{:04X} {:04X}", offset, st.start_address + offset);

                draw::set_font(Font::Helvetica, 12);
                draw::draw_text2(&addr, w.x() + 5, y, 70, 20, Align::Left);

                // Hex column
                let mut hex = String::new();

                for (i, b) in slice.iter().enumerate() {
                    hex.push_str(&format!("{:02X} ", b));

                    if i == 3 {
                        hex.push(' ');
                    }
                }

                draw::set_font(Font::Courier, 12);
                draw::draw_text2(&hex, w.x() + 76, y, 300, 20, Align::Left);

                // ASCII column
                let ascii: String = slice
                    .iter()
                    .map(|&b| {
                        let c = b as char;
                        if c.is_control() {
                            '.'
                        } else {
                            c
                        }
                    })
                    .collect();

                draw::draw_text2(&ascii, w.x() + 400, y, 100, 20, Align::Left);
                draw_char_bitmap(w.x() + 500, y, slice);
            }

            // Border
            draw::set_draw_color(Color::Dark3);
            draw::draw_rect(w.x() + 0, w.y() + 0, 75, (st.row_count as i32 * 8) - 9);
            draw::draw_rect(w.x() + 74, w.y() + 0, 546, (st.row_count as i32 * 8) - 9);
        });

        Self { inner, state }
    }

    pub fn set_bytes(&mut self, data: Vec<u8>, start_address: usize) {
        let mut st = self.state.borrow_mut();
        st.data = data;
        st.start_address = start_address;

        self.inner.redraw();
    }

    pub fn scroll_to(&mut self, line: usize) {
        self.state.borrow_mut().start_line = line;
        self.inner.redraw();
    }
}

fn draw_char_bitmap(x: i32, y: i32, data: &[u8]) {
    if data.len() != 8 {
        return;
    }

    const SCALE: i32 = 2;

    draw::set_draw_color(Color::Black);

    for (row, byte) in data.iter().enumerate() {
        for bit in 0..8 {
            if byte & (0x80 >> bit) != 0 {
                draw::draw_rectf(x + bit * SCALE, y + row as i32 * SCALE, SCALE, SCALE);
            }
        }
    }
}

pub mod bitmap_viewer {
    use fltk::enums::ColorDepth;
    use fltk::image::RgbImage;

    const C64_PALETTE: [[u8; 3]; 16] = [
        [0, 0, 0],
        [255, 255, 255],
        [136, 0, 0],
        [170, 255, 238],
        [204, 68, 204],
        [0, 204, 85],
        [0, 0, 170],
        [238, 238, 119],
        [221, 136, 85],
        [102, 68, 0],
        [255, 119, 119],
        [51, 51, 51],
        [119, 119, 119],
        [170, 255, 102],
        [0, 136, 255],
        [187, 187, 187],
    ];

    pub(crate) struct C64Bitmap {
        width: u32,
        height: u32,
        pixels: Vec<u8>,
    }

    impl C64Bitmap {
        pub fn convert_multicolor_to_image(
            bitmap_data: &[u8],
            screen_data: &[u8],
            color_data: &[u8],
            background_color: u8,
        ) -> RgbImage {
            const WIDTH: usize = 320;
            const HEIGHT: usize = 200;

            let mut pixels = vec![0u8; WIDTH * HEIGHT * 3];

            for char_y in 0..25 {
                for char_x in 0..40 {
                    let cell_index = char_y * 40 + char_x;
                    let col00 = C64_PALETTE[(background_color & 0x0f) as usize];
                    let col01 = C64_PALETTE[((screen_data[cell_index] >> 4) & 0x0f) as usize];
                    let col10 = C64_PALETTE[(screen_data[cell_index] & 0x0f) as usize];
                    let col11 = C64_PALETTE[(color_data[cell_index] & 0x0f) as usize];
                    for row in 0..8 {
                        let bitmap_index = cell_index * 8 + row;
                        let pixel_byte = bitmap_data[bitmap_index];
                        let pixel_y = char_y * 8 + row;
                        for bit_pair in 0..4 {
                            let shift = 6 - (bit_pair * 2);
                            let color_bits = (pixel_byte >> shift) & 0x03;
                            let color = match color_bits {
                                0 => col00,
                                1 => col01,
                                2 => col10,
                                3 => col11,
                                _ => col00,
                            };
                            let pixel_x = (char_x * 8) + (bit_pair * 2);
                            // double-width pixel
                            for dx in 0..2 {
                                let x = pixel_x + dx;
                                let idx = (pixel_y * WIDTH + x) * 3;
                                pixels[idx] = color[0];
                                pixels[idx + 1] = color[1];
                                pixels[idx + 2] = color[2];
                            }
                        }
                    }
                }
            }

            RgbImage::new(&pixels, WIDTH as i32, HEIGHT as i32, ColorDepth::Rgb8).unwrap()
        }

        //fn save_png(&self, path: &str);
    }
}

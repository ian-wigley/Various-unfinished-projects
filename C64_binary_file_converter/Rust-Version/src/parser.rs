pub mod parse {
    use std::collections::HashMap;
    use std::io::Read;
    use std::str::FromStr;

    use fltk::prelude::DisplayExt;
    use fltk::text::TextBuffer;
    use fltk::text::TextDisplay;

    use crate::assembly_creator::ac::AssemblyCreator;
    use crate::Opcode;

    #[derive(Clone)]
    pub(crate) struct Parser {
        opcode: Opcode,
        pub(crate) assembly_creator: AssemblyCreator,
        opcodes: HashMap<&'static str, [&'static str; 5]>,
        hex_content: Vec<String>,
        pub(crate) file_content: Vec<u8>,
        pub(crate) assembly_code: Vec<String>,
        pub(crate) line_numbers: Vec<String>,
        pub(crate) start_address: String,
    }

    impl Parser {
        pub fn new() -> Parser {
            Parser {
                opcode: Opcode::new(),
                assembly_creator: AssemblyCreator::new(),
                opcodes: HashMap::new(),
                hex_content: Vec::new(),
                file_content: Vec::new(),
                assembly_code: Vec::new(),
                line_numbers: Vec::new(),
                start_address: "".to_string(),
            }
        }

        pub(crate) fn init(&mut self, file_name: &str) {
            // Populate the OpCode Map
            self.opcodes = self.opcode.populate_opcodes();
            // Load the external binary file
            self.file_content = self.load_bin_file(file_name).unwrap().clone();
            self.hex_content = self.parse_content(self.file_content.clone());
        }

        pub(crate) fn parse_file_content(
            &mut self, display: TextDisplay,
            start_address: String
        ) -> Vec<String> {
            self.start_address = start_address.clone();
            let mut display_text: TextDisplay = display;
            let mut buf: TextBuffer = TextBuffer::default();
            let mut file_position: usize = 0;
            let mut pc: usize = 0;
            let starting_address = self.clone().convert_hex_string_to_int(&*start_address.clone()).unwrap();

            while file_position < self.hex_content.len()
            {
                let line_number = starting_address as usize + file_position;
                self.line_numbers.push(format!("{:04X}", line_number));
                let op_code: String = self.hex_content[file_position].clone().to_uppercase();
                let values: [&str; 5] = self
                    .opcode
                    .get_match(self.opcodes.clone(), op_code.as_str());
                let mnemonic: String = values[0].to_string();
                let num_bytes: i32 = i32::from_str(values[1]).unwrap_or(1);

                let mut _two: String = String::new();
                let mut _three: String = String::new();
                let mut _four: String = String::new();
                let mut _padding: String = String::new();

                if num_bytes == 2 && pc + 1 <= self.file_content.len() {
                    if self.isa_branch(&mnemonic) {
                        let mut _u: u8 = self.file_content[pc + 1];
                        let mut _v: i8 = _u as i8;
                        let _w: i32 = (_v as i32) + 2;
                        let _s: i32 = (line_number as i32) + _w;

                        _two = "".to_owned();
                        _three = format!("{:02X}", _v);
                        _four = format!("{:04X}", _s);
                    } else {
                        _three = self.hex_content[pc + 1].clone().to_uppercase();
                        _four = self.hex_content[pc + 1].clone().to_uppercase();
                    }
                }
                if num_bytes == 3 && pc + 2 <= self.file_content.len() {
                    _two = self.hex_content[pc + 2]
                        .to_uppercase()
                        .as_str()
                        .parse()
                        .unwrap();
                    _padding = _two.clone();
                    _three = self.hex_content[pc + 1]
                        .to_uppercase()
                        .as_str()
                        .parse()
                        .unwrap();
                    _four = self.hex_content[pc + 1]
                        .to_uppercase()
                        .as_str()
                        .parse()
                        .unwrap();
                }

                // increment the pc
                pc += num_bytes as usize;

                let code: String = format!(
                    "{:04X} {} {:2} {:<20} {} {}{}{}{}\n",
                    line_number,
                    op_code,
                    _three,
                    _two,
                    mnemonic,
                    values[2],
                    _padding,
                    _four,
                    values[3]
                );
                buf.append(&code);
                self.assembly_code.push(code);

                file_position += num_bytes as usize;
            }
            display_text.set_buffer(buf.clone());

            self.assembly_code.clone()
        }

        fn isa_branch(&mut self, mnemonic: &String) -> bool {
            //
            // Method returns if there is a match between the supplied &str & the values below.
            //
            // # Arguments
            // * `mnemonic` string
            //
            mnemonic == "BCC"
                || mnemonic == "BCS"
                || mnemonic == "BEQ"
                || mnemonic == "BMI"
                || mnemonic == "BNE"
                || mnemonic == "BPL"
                || mnemonic == "BVC"
                || mnemonic == "BVS"
        }

        fn load_bin_file(&mut self, file_name: &str) -> std::io::Result<Vec<u8>> {
            //
            // Method to load the file.
            //
            // # Arguments
            // * none
            //
            let mut file: std::fs::File = std::fs::File::open(file_name)?;
            let mut v: Vec<u8> = Vec::new();
            let _content: Result<usize, std::io::Error> = file.read_to_end(&mut v);
            Ok(v)
        }

        fn parse_content(&mut self, bin: Vec<u8>) -> Vec<String> {
            //
            // Method to iterate through each object in the Vector to Populate a HashMap.
            //
            // # Arguments
            // * bin: Vec<u8>
            //
            let mut opcode_mappings: Vec<String> = Vec::new();
            for n in bin.iter() {
                let num_usize: [u8; 1] = [*n as u8];
                let op_code: String = hex::encode(num_usize);
                opcode_mappings.push((*op_code).parse().unwrap());
            }
            opcode_mappings
        }

        fn convert_hex_string_to_int(self, hex_string: &str) -> Option<i32> {
            match i32::from_str_radix(hex_string, 16) {
                Ok(parsed_int) => Some(parsed_int),
                Err(_) => None,
            }
        }
    }
}

pub mod con {

    use std::collections::HashMap;
    // use std::env;
    use std::io::Read;
    use std::str::FromStr;

    use fltk::prelude::DisplayExt;
    use fltk::text::TextBuffer;
    use fltk::text::TextDisplay;

    use crate::Opcode;

    #[derive(Clone)]
    pub(crate) struct Converter {
        opcode: Opcode,
        opcodes: HashMap<&'static str, [&'static str; 5]>,
        hex_content: Vec<String>,
        file_content: Vec<u8>,
        assembly_code: Vec<String>,
    }

    impl Converter {
        pub fn new() -> Converter {
            Converter {
                opcode: Opcode::new(),
                opcodes: HashMap::new(),
                hex_content: Vec::new(),
                file_content: Vec::new(),
                assembly_code: Vec::new(),
            }
        }

        pub(crate) fn init(&mut self, file_name: &str) {
            // Populate the OpCode Map
            // self.opcode.load_xml("Assets/6502-codes.xml");
            self.opcodes = self.opcode.populate_opcodes();
            // Load the external binary file
            self.file_content = self.load_bin_file(file_name).unwrap().clone();
            self.hex_content = self.parse_content(self.file_content.clone());
        }

        pub(crate) fn convert_to_assembly(&mut self, display: TextDisplay) {
            let mut display_text: TextDisplay = display;
            let mut buf: TextBuffer = TextBuffer::default();

            let mut file_position: usize = 0;
            let mut pc: usize = 0;

            while file_position < 0x500
            // while file_position < self.hex_content.len()
            {
                let op_code: String = self.hex_content[file_position].clone().to_uppercase();
                let values: [&str; 5] = self
                    .opcode
                    .get_match(self.opcodes.clone(), op_code.as_str());
                let mnemonic: String = values[0].to_string();
                let num_bytes: i32 = i32::from_str(values[1]).unwrap_or(1);

                let mut _two: String = String::new();
                let mut _three: String = String::new();
                let mut _padding: String = String::new();
                // _two = format!("{:<2}", "");
                // _three = format!("{:<2}", "");

                if num_bytes == 2 {
                    if self.is_branch(&mnemonic) {
                        let mut _u: u8 = self.file_content[pc + 1];
                        let mut _v: i8 = _u as i8;
                        let _w: i32 = (_v + 2) as i32;
                        let _s: i32 = (pc as i32) + _w;

                        let mut _vv: i8 = ((self.file_content[pc + 1]) as i8) + 2;
                        let _ss: i32 = (pc as i32) + _vv as i32;

                        _two = "".to_owned();
                        _three = format!("{:04X}", _s);
                    } else {
                        _three = self.hex_content[pc + 1].clone().to_uppercase();
                    }
                }
                if num_bytes == 3 {
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
                }

                // increment the pc
                pc += num_bytes as usize;

                let code: String = format!(
                    "{:04X} {} {:2} {:<20} {} {}{}{}{}\n",
                    file_position,
                    op_code,
                    _three,
                    _two,
                    mnemonic,
                    values[2],
                    _padding,
                    _three,
                    values[3]
                );
                buf.append(&code);
                self.assembly_code.push(code);

                file_position += num_bytes as usize;
            }
            display_text.set_buffer(buf.clone());
        }

        fn is_branch(&mut self, mnemonic: &String) -> bool {
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

        // pub(crate) fn add_labels(
            //self,
        pub fn add_labels(
            &mut self,
            start: &str,
            _end: &str,
            _replace_illegal_opcodes: bool,
            /*Dictionary<string, string[]> bucket,*/
            _first_occurrence: i32,
            _last_occurrence: i32,
            right_display: TextDisplay,
        ) {
            let branch: &str = "branch";
            let label_count: i32 = 0;
            let branch_count: i32 = 0;
            let mut jump_label_locations: HashMap<String, String> = HashMap::new();
            let mut branch_label_locations: HashMap<String, String> = HashMap::new();
            let mut buf: TextBuffer = TextBuffer::default();
            let first_pass: bool = true;
            let count: usize = 0;
            let mut pass_one: Vec<String> = Vec::new();
            let mut pass_two: Vec<String> = Vec::new();
            let mut pass_three: Vec<String> = Vec::new();
            let mut found: Vec<String> = Vec::new();
            let label: &str = "label";
            pass_three.push(format!("{:<20}*=${}", "", start));

            if self.assembly_code.is_empty() {
                println!("assembly_code is empty");
                return;
            }


            self.clone().initial_pass(
                first_pass,
                count,
                &mut jump_label_locations,
                label,
                label_count,
                &mut pass_one,
                &mut branch_label_locations,
                branch,
                branch_count,
            );

            self.clone().second_pass(
                &pass_one,
                &jump_label_locations,
                &branch_label_locations,
                &mut pass_two,
            );

            self.clone().final_pass(
                &pass_one,
                &jump_label_locations,
                &mut found,
                branch_label_locations,
                &mut pass_three,
                pass_two,
            );

            // Finally iterate through the found list & add references to the address not found
            for mem_location in jump_label_locations.clone() {
                if !found.contains(&mem_location.0) {
                    pass_three.push(format!("{} = ${}", mem_location.1, mem_location.0));
                }
            }

            // TO-DO
            for i in 0..pass_three.len() {
                let code = format!("{}\n", &pass_three[i]);
                buf.append(&code);
            }
            let mut display = right_display.clone();
            display.set_buffer(buf.clone());
        }

        fn initial_pass(
            self,
            mut first_pass: bool,
            mut count: usize,
            label_loc: &mut HashMap<String, String>,
            label: &str,
            mut label_count: i32,
            pass_one: &mut Vec<String>,
            branch_loc: &mut HashMap<String, String>,
            branch: &str,
            mut branch_count: i32,
        ) {
            // First pass parses the content looking for branch & jump conditions
            while first_pass {
                // Split each line into a Vector<&str>
                let line_detail: Vec<&str> = self.assembly_code[count].split_whitespace().collect();
                if line_detail.len() > 1 {
                    // string[] dataValue;
                    // Replace the Illegal Opcodes with data statement
                    // if (replaceIllegalOpcodes && bucket.TryGetValue(lineDetails[0], out dataValue))
                    if line_detail.len() == 0 {
                        //
                        // foreach (string str in dataValue) {
                        //
                        //   passOne.Add(str);
                        // }
                    } else {
                        let value: String = line_detail[1].to_ascii_uppercase();
                        match value.as_str() {
                            "20" | "4C" => {
                                // "20": JSR | "4C": JMP

                                // Populate the Jump labels
                                if !label_loc.contains_key(&format!("{}", line_detail[5])) {
                                    // let address = line_detail[5].replace("$", "");
                                    label_loc.insert(
                                        format!("{}", line_detail[5].replace("$", "")),
                                        format!("{}{}", label, label_count),
                                    );
                                    label_count += 1;
                                }
                                pass_one.push(format!("{} {}", line_detail[4], line_detail[5]));
                            }

                            "90" | "B0" | "F0" | "30" | "D0" | "10" | "50" | "70" => {
                                // "90": BCC | "B0": BCS | "F0": BEQ | "30": BMI
                                // "D0": BNE | "10": BPL | "50": BVC | "70": BVS

                                // Populate the Branch labels
                                if !branch_loc
                                    .contains_key(&format!("{}", line_detail[4].replace("$", "")))
                                {
                                    branch_loc.insert(
                                        format!("{}", line_detail[4].replace("$", "")),
                                        format!("{}{}", branch, branch_count),
                                    );
                                    branch_count += 1;
                                }
                                pass_one.push(format!("{} {}", line_detail[3], line_detail[4]));
                            }

                            _ => {
                                if line_detail.len() == 3 {
                                    pass_one.push(line_detail[2].to_string());
                                } else if line_detail.len() == 5 {
                                    pass_one.push(format!("{} {}", line_detail[3], line_detail[4]));
                                } else if line_detail.len() == 6 {
                                    pass_one.push(format!("{} {}", line_detail[4], line_detail[5]));
                                }
                            }
                        }
                    }
                }
                count += 1;
                if count >= self.assembly_code.len() {
                    first_pass = false;
                }
            }
        }

        fn second_pass(
            self,
            pass_one: &Vec<String>,
            label_locations: &HashMap<String, String>,
            branch_locations: &HashMap<String, String>,
            pass_two: &mut Vec<String>,
        ) {
            // Second pass iterates through first pass collection adding labels and branches details into the code
            for i in 0..pass_one.len() {
                let mut assembly: String = pass_one[i].clone();
                let detail: Vec<&str> = pass_one[i].split_whitespace().collect();
                if detail.len() > 1 {
                    let key: String = format!("{}", detail[1].replace("$", ""));
                    if label_locations.contains_key(&key) && detail[0].contains("JSR")
                        || detail[0].contains("JMP")
                    {
                        assembly = format!("{} {}", detail[0], label_locations[&key].clone());
                    }
                    if branch_locations.contains_key(&key) && detail[0].contains("BNE")
                        || detail[0].contains("BEQ")
                        || detail[0].contains("BPL")
                    {
                        assembly = format!("{} {}", detail[0], branch_locations[&key].clone());
                    }
                }
                pass_two.push(assembly);
            }
        }

        fn final_pass(
            self,
            pass_one: &Vec<String>,
            jump_label_loc: &HashMap<String, String>,
            found: &mut Vec<String>,
            branch_label_loc: HashMap<String, String>,
            pass_three: &mut Vec<String>,
            pass_two: Vec<String>,
        ) {
            // Third pass adds the branch labels to the front of the code
            let mut counter: usize = 0;
            for i in 0..pass_one.len() - 1 {
                let copy: String = self.assembly_code[counter].clone();
                counter += 1;
                let detail: Vec<String> = copy.split_whitespace().map(str::to_string).collect();
                let mut label: String = String::from("");
                if detail.len() > 1 {
                    let key: String = format!("{}", detail[0].clone().replace("$", ""));
                    if jump_label_loc.contains_key(&key) {
                        label = format!("{} ", jump_label_loc.get(&key).unwrap());
                        // Store the memory address into the found vector
                        found.push(key);
                    }
                    let new_key: String = format!("{}", detail[0].clone().replace("$", ""));
                    if branch_label_loc.contains_key(&new_key) {
                        label = format!("{} ", branch_label_loc.get(&new_key).unwrap());
                    }
                }
                let offset: usize = if label.len() == 0 {
                    20
                } else {
                    20 - (label.len() - 2)
                };
                pass_three.push(format!("{:offset$}{}", label, pass_two[i].clone()));
            }
        }
    }
}

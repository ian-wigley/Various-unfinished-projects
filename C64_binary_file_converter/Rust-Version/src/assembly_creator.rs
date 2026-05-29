pub mod ac {
    use fltk::prelude::DisplayExt;
    use fltk::text::{TextBuffer, TextDisplay};
    use std::collections::HashMap;

    #[derive(Clone)]
    pub(crate) struct AssemblyCreator {
        assembly_code: Vec<String>,
        pub(crate) pass_three: Vec<String>,
        branch: String,
        label: String,
    }

    impl AssemblyCreator {
        pub fn new() -> AssemblyCreator {
            AssemblyCreator {
                assembly_code: Vec::new(),
                pass_three: Vec::new(),
                branch: String::from("branch"),
                label: String::from("label"),
            }
        }
        pub(crate) fn update_assembly_code(&mut self, assembly_code: Vec<String>) {
            self.assembly_code = assembly_code;
        }

        pub(crate) fn add_labels(
            &mut self,
            start: i32,
            end: i32,
            start_memory_location: &str,
            _replace_illegal_opcodes: bool,
            _first_occurrence: i32,
            _last_occurrence: i32,
            right_display: TextDisplay,
        ) {
            let label_count: i32 = 0;
            let branch_count: i32 = 0;
            let mut jump_label_locations: HashMap<String, String> = HashMap::new();
            let mut branch_label_locations: HashMap<String, String> = HashMap::new();
            let mut buf: TextBuffer = TextBuffer::default();
            let first_pass: bool = true;
            let count: usize = start as usize;
            let mut pass_one: Vec<String> = Vec::new();
            let mut pass_two: Vec<String> = Vec::new();
            let mut found: Vec<String> = Vec::new();

            if self.assembly_code.is_empty() {
                println!("assembly_code is empty");
                return;
            }

            self.clone().initial_pass(
                first_pass,
                count,
                end as usize,
                &mut jump_label_locations,
                label_count,
                &mut pass_one,
                &mut branch_label_locations,
                branch_count,
            );

            self.clone().second_pass(
                &pass_one,
                &jump_label_locations,
                &branch_label_locations,
                &mut pass_two,
            );

            self.pass_three = self.clone().final_pass(
                &pass_one,
                &jump_label_locations,
                &mut found,
                branch_label_locations,
                &pass_two,
                start_memory_location,
            );

            // Finally iterate through the found list & add references to the address not found
            for mem_location in jump_label_locations.clone() {
                if !found.contains(&mem_location.0) {
                    self.pass_three
                        .push(format!("{} = ${}", mem_location.1, mem_location.0));
                }
            }

            // TO-DO
            for i in 0..self.pass_three.len() {
                let code = format!("{}\n", &self.pass_three[i]);
                buf.append(&code);
            }
            let mut display = right_display.clone();
            display.set_buffer(buf.clone());
        }

        fn initial_pass(
            self,
            mut first_pass: bool,
            mut count: usize,
            end: usize,
            label_loc: &mut HashMap<String, String>,
            mut label_count: i32,
            pass_one: &mut Vec<String>,
            branch_loc: &mut HashMap<String, String>,
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
                                        format!("{}{}", self.label, label_count),
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
                                        format!("{}{}", self.branch, branch_count),
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
                if count > end || count >= self.assembly_code.len() {
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
            // Second pass iterates through first pass collection adding labels and branches
            // details into the code
            let mut second_pass: bool = true;
            let mut index = 0;
            while second_pass {
                let mut assembly: String = pass_one[index].clone();
                let detail: Vec<&str> = pass_one[index].split_whitespace().collect();
                if detail.len() > 1 {
                    let key: String = format!("{}", detail[1].replace("$", ""));

                    // println!("{}", index);
                    let _vstop_value: usize = 11633;
                    if index == _vstop_value {
                        let _stop = true;
                    }
                    if label_locations.contains_key(&key) && detail[0].contains("JSR")
                        || detail[0].contains("JMP")
                    {
                        //assembly = format!("{} {}", detail[0], label_locations[&key].clone());
                        assembly = format!("{}", detail[0]);
                    }
                    if branch_locations.contains_key(&key) && detail[0].contains("BNE")
                        || detail[0].contains("BEQ")
                        || detail[0].contains("BPL")
                    {
                        assembly = format!("{} {}", detail[0], branch_locations[&key].clone());
                    }
                }
                pass_two.push(assembly);
                index += 1;
                if index >= pass_one.len() {
                    second_pass = false;
                }
            }
        }

        fn final_pass(
            &mut self,
            pass_one: &Vec<String>,
            jump_label_loc: &HashMap<String, String>,
            found: &mut Vec<String>,
            branch_label_loc: HashMap<String, String>,
            pass_two: &Vec<String>,
            start_memory_location: &str,
        ) -> Vec<String> {
            // Third pass adds the branch labels to the front of the code
            let mut pass_three: Vec<String> = Vec::new();
            pass_three.push(format!("{:<20}*=${:04}", "", start_memory_location));
            let mut third_pass: bool = true;
            let mut index: usize = 0;
            while third_pass {
                let copy: String = self.assembly_code[index].clone();
                index += 1;
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
                    20 // - 2 //(label.len() - 2)
                };

                //println!("Offset: {}", offset);

                if index >= pass_one.len() {
                    third_pass = false;
                } else {
                    pass_three.push(format!("{:offset$}{}", label, pass_two[index].clone()));
                }
            }
            pass_three
        }
    }
}

pub mod con {

    use std::collections::HashMap;
    use std::env;
    use std::io::Read;
    use std::str::FromStr;

    use fltk::prelude::DisplayExt;
    use fltk::text::TextBuffer;
    use fltk::text::TextDisplay;

    use crate::Converter;
    use crate::Opcode;

    impl Converter {
        pub fn new() -> Converter {
            Converter {
                opcode: Opcode::new(),
                opcodes: HashMap::new(),
                hex_content: Vec::new(),
                file_content: Vec::new(),
            }
        }

        pub(crate) fn init(&mut self, left_display: TextDisplay) {
            // Populate the OpCode Map
            self.opcodes = self.opcode.populate_opcodes();

            // Load the external binary file
            self.file_content = self.load_bin_file().unwrap().clone();
            self.hex_content = self.parse_content(self.file_content.clone());

            self.convert_to_assembly(left_display);
        }

        pub(crate) fn convert_to_assembly(&mut self, disp: TextDisplay) {
            let mut diplay_text = disp;
            let mut buf = TextBuffer::default();

            let mut file_position = 0;
            let mut pc: usize = 0;

            while file_position < 1000
            //hex.len()
            {
                let op_code = self.hex_content[file_position].clone().to_uppercase();
                let values = self
                    .opcode
                    .get_match(self.opcodes.clone(), op_code.as_str());
                let nmenonic = values[0];
                let incrementer = i32::from_str(values[1]).unwrap_or(1);

                let mut _two: String = String::from("  ");
                let mut _three: String = String::from("  ");
                let mut _padding: String = String::new();

                if incrementer == 2 {
                    if self.is_branch(nmenonic) {
                        let mut _u: u8 = self.file_content[pc + 1];
                        let mut _v: i8 = _u as i8;
                        let _w = (_v + 2) as i32;
                        let mut _s = (pc as i32) + _w;

                        let mut _vv: i8 = ((self.file_content[pc + 1]) as i8) + 2;
                        let mut _ss = (pc as i32) + _vv as i32;

                        _two = "".to_owned();
                        _three = format!("{:04X}", _s);
                    } else {
                        _three = self.hex_content[pc + 1].clone().to_uppercase();
                    }
                }
                if incrementer == 3 {
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
                pc += incrementer as usize;

                let code = format!(
                    "{:04X} {} {} {}        {} {}{}{}{}\n",
                    file_position,
                    op_code,
                    _three,
                    _two,
                    nmenonic,
                    values[2],
                    _padding,
                    _three,
                    values[3]
                );
                buf.append(&code);

                file_position += incrementer as usize;
            }
            diplay_text.set_buffer(buf.clone());
        }

        fn is_branch(&mut self, nmenonic: &str) -> bool {
            //
            // Method returns if there is a match between the supplied &str & the values below.
            //
            // # Arguments
            // * `nmenonic` string
            //
            return nmenonic == "BCC"
                || nmenonic == "BCS"
                || nmenonic == "BEQ"
                || nmenonic == "BMI"
                || nmenonic == "BNE"
                || nmenonic == "BPL"
                || nmenonic == "BVC"
                || nmenonic == "BVS";
        }

        fn load_bin_file(&mut self) -> std::io::Result<Vec<u8>> {
            //
            // Method to load the file.
            //
            // # Arguments
            // * none
            //
            let path = env::current_dir()?;
            let bin_path = path.join("Assets/C64_Binary.bin");
            let mut file = std::fs::File::open(bin_path)?;
            let mut v: Vec<u8> = Vec::new();
            let _content = file.read_to_end(&mut v);
            Ok(v)
        }

        fn parse_content(&mut self, bin: Vec<u8>) -> Vec<String> {
            //
            // Method to iterate through each object in the Vector to Populate a HashMap.
            //
            // # Arguments
            // * bin
            //
            // println!("Vec Length: {}", bin.len());
            let mut opcode_mappings = Vec::new();
            for n in bin.iter() {
                let num_usize = [*n as u8];
                let hop_code = hex::encode(num_usize);
                opcode_mappings.push((*hop_code).parse().unwrap());
            }
            return opcode_mappings;
        }

        pub(crate) fn add_labels(
            self,
            start: &str,
            end: &str,
            replace_illegal_opcodes: bool,
            /*Dictionary<string, string[]> bucket,*/
            first_occurance: i32,
            last_occurrance: i32,
        ) {
            // textBox2.Clear();
            // ClearRightWindow();
            // passThree.Add("                *=$" + start);
            // let originalFileContent = code;
            let mut first_pass = true;
            let mut count = 0;

            // First pass parses the content looking for branch & jump conditions
            while first_pass {
                // Split each line into an array
                //     var lineDetails = originalFileContent[count++].Split(' ');

                //     if (lineDetails.Length > 1)
                //     {
                //         string[] dataValue;
                //         // Replace the Illegal Opcodes with data statement
                //         if (replaceIllegalOpcodes && bucket.TryGetValue(lineDetails[0], out dataValue))
                //         {
                //             foreach (string str in dataValue)
                //             {
                //                 passOne.Add(str);
                //             }
                //         }
                //         else
                //         {
                //             switch (lineDetails[2].ToUpper())
                //             {
                //                 case "20": // JSR
                //                 case "4C": // JMP
                //                     if (!labelLoc.Keys.Contains(lineDetails[4] + lineDetails[3]))
                //                     {
                //                         labelLoc.Add(lineDetails[4] + lineDetails[3], label + labelCount++.ToString());
                //                     }
                //                     passOne.Add(lineDetails[8] + " " + lineDetails[9]);
                //                     break;
                //                 case "90": // BCC
                //                 case "B0": // BCS
                //                 case "F0": // BEQ
                //                 case "30": // BMI
                //                 case "D0": // BNE
                //                 case "10": // BPL
                //                 case "50": // BVC
                //                 case "70": // BVS
                //                     if (!branchLoc.Keys.Contains(lineDetails[11].Replace("$", "")))
                //                     {
                //                         branchLoc.Add(lineDetails[11].Replace("$", ""), branch + branchCount++.ToString());
                //                     }
                //                     passOne.Add(lineDetails[10] + " " + lineDetails[11]);
                //                     break;
                //                 default:
                //                     if (lineDetails[3] == "" && lineDetails[4] == "")
                //                     {
                //                         passOne.Add(lineDetails[12]);
                //                     }
                //                     else if (lineDetails[3] != "" && lineDetails[4] == "")
                //                     {
                //                         passOne.Add(lineDetails[10] + " " + lineDetails[11]);
                //                     }
                //                     else if (lineDetails[3] != "" && lineDetails[4] != "")
                //                     {
                //                         passOne.Add(lineDetails[8] + " " + lineDetails[9]);
                //                     }
                //                     break;
                //             }
                //         }
                //     }
                //     if (count >= int.Parse(end, System.Globalization.NumberStyles.HexNumber) || count >= originalFileContent.Count || lineDetails[0].ToLower().Contains(end.ToLower()))
                //     {
                //         firstPass = false;
                //     }
                first_pass = false;
            }

            // Second pass iterates through first pass collection adding labels and branches into the code
            // int counter = 0;
            // for (int i = 0; i < passOne.Count; i++)
            // {

            //     string label = "";
            //     string assembly = passOne[counter++];
            //     foreach (KeyValuePair<String, String> memLocation in labelLoc)
            //     {
            //         if (passOne[i].ToUpper().Contains(memLocation.Key))
            //         //   if (originalFileContent[i].ToUpper().Contains(memLocation.Key))
            //         {
            //             var dets = assembly.Split(' ');
            //             if (dets[0].Contains("JSR") || dets[0].Contains("JMP"))
            //             {
            //                 assembly = dets[0] + " " + memLocation.Value;
            //             }
            //         }
            //     }
            //     foreach (KeyValuePair<String, String> memLocation in branchLoc)
            //     {
            //         if (originalFileContent[i].ToUpper().Contains(memLocation.Key))
            //         {
            //             var dets = assembly.Split(' ');
            //             if (dets[0].Contains("BNE") || dets[0].Contains("BEQ") || dets[0].Contains("BPL"))
            //             {
            //                 assembly = dets[0] + " " + memLocation.Value;
            //             }
            //         }
            //     }
            //     passTwo.Add(label + assembly);
            // }

            // Add the labels to the front of the code
            // counter = 0;
            // for (int i = 0; i < passOne.Count; i++)
            // {
            //     var dets = originalFileContent[counter++].Split(' ');
            //     string label = "                ";
            //     foreach (KeyValuePair<String, String> memLocation in labelLoc)
            //     {
            //         if (dets[0].ToUpper().Contains(memLocation.Key))
            //         {
            //             label = memLocation.Value + "          ";
            //             // The moemory address has been found add it another list
            //             found.Add(memLocation.Key);
            //         }
            //     }

            //     foreach (KeyValuePair<String, String> memLocation in branchLoc)
            //     {
            //         if (dets[0].ToUpper().Contains(memLocation.Key))
            //         {
            //             label = memLocation.Value + "         ";
            //         }
            //     }
            //     passThree.Add(label + passTwo[i]);
            // }

            // // Finally iterate through the found list & add references to the address not found
            // foreach (KeyValuePair<String, String> memLocation in labelLoc)
            // {
            //     if (!found.Contains(memLocation.Key))
            //     {
            //         passThree.Add(memLocation.Value + " = $" + memLocation.Key);
            //     }
            // }

            // textBox2.Font = new Font(FontFamily.GenericMonospace, textBox2.Font.Size);
            // textBox2.Lines = passThree.ToArray();
            // rightWindowToolStripMenuItem.Enabled = true;
        }
    }
}
pub mod oc {
    use std::collections::HashMap;
    use quick_xml::events::{BytesStart, Event};
    use quick_xml::Reader;

    #[derive(Copy, Clone)]
    pub(crate) struct Opcode {}

    impl Opcode {
        pub fn new() -> Opcode {
            Opcode {}
        }

        fn print_results(self, seen: &HashMap<String, usize>, counter: &usize) {
            let mut keys: Vec<&String> = seen.keys().into_iter().collect();
            keys.sort();

            for item in keys {
                println!("{}: {:?}", item, seen.get(item).unwrap());
            }

            println!("Found not considered nodes: {}", counter);
        }

        fn increment_counters(self, seen: &mut HashMap<String, usize>, key: String) {
            if let Some(value) = seen.get_mut(&key) {
                (*value) += 1;
            } else {
                seen.insert(key, 1);
            }
        }

        fn process_attributes(self, seen: &mut HashMap<String, usize>, path: &mut Vec<String>, node: BytesStart) {
            path.push("@attribute".into());

            for attribute in node.attributes() {
                path.push(format!(
                    "{:?}",
                    String::from_utf8(attribute.unwrap().key.0.to_vec()).unwrap()
                ));
                self.increment_counters(seen, path.join(" / "));
                path.pop();
            }
            path.pop();
        }


        // https://amacal.medium.com/learn-rust-parsing-big-xml-files-67ec923f6977
        pub(crate) fn load_xml(self, file_name: &str) {
            let mut reader = Reader::from_file(file_name).unwrap();

            let mut path = Vec::new();
            let mut seen = HashMap::new();

            let mut buffer = Vec::new();
            let mut counter = 0;

            loop {
                match reader.read_event_into(&mut buffer) {
                    Err(error) => break println!("{}", error),
                    Ok(Event::Eof) => break println!("Completed."),
                    Ok(Event::Start(node)) => {
                        path.push(format!("{:?}", String::from_utf8(node.name().0.to_vec()).unwrap()));
                        self.increment_counters(&mut seen, path.join(" / "));
                        self.process_attributes(&mut seen, &mut path, node);
                    }
                    Ok(Event::End(_)) => {
                        path.pop();
                    }
                    Ok(Event::Text(_)) => {
                        path.push("@text".into());
                        self.increment_counters(&mut seen, path.join(" / "));
                        path.pop();
                    }
                    Ok(Event::Empty(node)) => {
                        path.push(format!("{:?}", String::from_utf8(node.name().0.to_vec()).unwrap()));
                        self.increment_counters(&mut seen, path.join(" / "));
                        self.process_attributes(&mut seen, &mut path, node);
                        path.pop();
                    }
                    Ok(_) => counter += 1,
                }

                buffer.clear();
            }

            self.print_results(&seen, &counter);
        }

        pub(crate) fn populate_opcodes(self) -> HashMap<&'static str, [&'static str; 5]> {
            let mut opcode_mappings: HashMap<&str, [&str; 5]> = HashMap::new();
            opcode_mappings.insert("00", ["BRK", "1", "", "", "false"]);
            opcode_mappings.insert("01", ["ORA", "2", "($", ",X)", "false"]);
            opcode_mappings.insert("02", ["JAM", "1", "", "", "true"]);
            opcode_mappings.insert("03", ["SLO", "2", "($", ",X)", "true"]);
            opcode_mappings.insert("04", ["NOP", "2", "$", "", "true"]);
            opcode_mappings.insert("05", ["ORA", "2", "$", "", "false"]);
            opcode_mappings.insert("06", ["ASL", "2", "$", "", "false"]);
            opcode_mappings.insert("07", ["SLO", "2", "$", "", "true"]);
            opcode_mappings.insert("08", ["PHP", "1", "", "", "false"]);
            opcode_mappings.insert("09", ["ORA", "2", "#$", "", "false"]);
            opcode_mappings.insert("0A", ["ASL", "1", "", "", "false"]);
            opcode_mappings.insert("0B", ["ANC", "2", "#$", "", "true"]);
            opcode_mappings.insert("0C", ["NOP", "3", "$", "", "true"]);
            opcode_mappings.insert("0D", ["ORA", "3", "$", "", "false"]);
            opcode_mappings.insert("0E", ["ASL", "3", "$", "", "false"]);
            opcode_mappings.insert("0F", ["SLO", "3", "$", "", "true"]);
            opcode_mappings.insert("10", ["BPL", "2", "$", "", "false"]);
            opcode_mappings.insert("11", ["ORA", "2", "($", "),Y", "false"]);
            opcode_mappings.insert("12", ["JAM", "1", "", "", "true"]);
            opcode_mappings.insert("13", ["SLO", "2", "($", "),Y", "true"]);
            opcode_mappings.insert("14", ["NOP", "2", "$", ",X", "true"]);
            opcode_mappings.insert("15", ["ORA", "2", "$", ",X", "false"]);
            opcode_mappings.insert("16", ["ASL", "2", "$", ",X", "false"]);
            opcode_mappings.insert("17", ["SLO", "2", "$", ",X", "true"]);
            opcode_mappings.insert("18", ["CLC", "1", "", "", "false"]);
            opcode_mappings.insert("19", ["ORA", "3", "$", ",Y", "false"]);
            opcode_mappings.insert("1A", ["NOP", "1", "", "", "true"]);
            opcode_mappings.insert("1B", ["SLO", "3", "$", ",Y", "true"]);
            opcode_mappings.insert("1C", ["NOP", "3", "$", ",X", "true"]);
            opcode_mappings.insert("1D", ["ORA", "3", "$", ",X", "false"]);
            opcode_mappings.insert("1E", ["ASL", "3", "$", ",X", "false"]);
            opcode_mappings.insert("1F", ["SLO", "3", "", ",X", "true"]);
            opcode_mappings.insert("20", ["JSR", "3", "$", "", "false"]);
            opcode_mappings.insert("21", ["AND", "2", "($", ",X)", "false"]);
            opcode_mappings.insert("22", ["JAM", "1", "", "", "true"]);
            opcode_mappings.insert("23", ["RLA", "2", "($", ",X)", "true"]);
            opcode_mappings.insert("24", ["BIT", "2", "$", "", "false"]);
            opcode_mappings.insert("25", ["AND", "2", "$", "", "false"]);
            opcode_mappings.insert("26", ["ROL", "2", "$", "", "false"]);
            opcode_mappings.insert("27", ["RLA", "2", "", "", "true"]);
            opcode_mappings.insert("28", ["PLP", "1", "", "", "false"]);
            opcode_mappings.insert("29", ["AND", "2", "#$", "", "false"]);
            opcode_mappings.insert("2A", ["ROL", "1", "", "", "false"]);
            opcode_mappings.insert("2B", ["ANC", "2", "#$", "", "true"]);
            opcode_mappings.insert("2C", ["BIT", "3", "$", "", "false"]);
            opcode_mappings.insert("2D", ["AND", "3", "$", "", "false"]);
            opcode_mappings.insert("2E", ["ROL", "3", "$", "", "false"]);
            opcode_mappings.insert("2F", ["RLA", "3", "", "", "true"]);
            opcode_mappings.insert("30", ["BMI", "2", "$", "", "false"]);
            opcode_mappings.insert("31", ["AND", "2", "($", "),Y", "false"]);
            opcode_mappings.insert("32", ["JAM", "1", "", "", "true"]);
            opcode_mappings.insert("33", ["RLA", "2", "($", "),Y", "true"]);
            opcode_mappings.insert("34", ["NOP", "2", "$", ",X", "true"]);
            opcode_mappings.insert("35", ["AND", "2", "$", ",X", "false"]);
            opcode_mappings.insert("36", ["ROL", "2", "$", ",X", "false"]);
            opcode_mappings.insert("37", ["RLA", "2", "$", ",X", "true"]);
            opcode_mappings.insert("38", ["SEC", "1", "", "", "false"]);
            opcode_mappings.insert("39", ["AND", "3", "$", ",Y", "false"]);
            opcode_mappings.insert("3A", ["NOP", "1", "", "", "true"]);
            opcode_mappings.insert("3B", ["RLA", "3", "$", ",Y", "true"]);
            opcode_mappings.insert("3C", ["NOP", "3", "$", ",X", "true"]);
            opcode_mappings.insert("3D", ["AND", "3", "$", ",X", "false"]);
            opcode_mappings.insert("3E", ["ROL", "3", "$", ",X", "false"]);
            opcode_mappings.insert("3F", ["RLA", "3", "$", ",X", "true"]);
            opcode_mappings.insert("40", ["RTI", "1", "", "", "false"]);
            opcode_mappings.insert("41", ["EOR", "2", "($", ",X)", "false"]);
            opcode_mappings.insert("42", ["JAM", "1", "", "", "true"]);
            opcode_mappings.insert("43", ["SRE", "2", "($", ",X)", "true"]);
            opcode_mappings.insert("44", ["NOP", "2", "$", "", "true"]);
            opcode_mappings.insert("45", ["EOR", "2", "$", "", "false"]);
            opcode_mappings.insert("46", ["LSR", "2", "$", "", "false"]);
            opcode_mappings.insert("47", ["SRE", "2", "$", "", "true"]);
            opcode_mappings.insert("48", ["PHA", "1", "", "", "false"]);
            opcode_mappings.insert("49", ["EOR", "2", "#$", "", "false"]);
            opcode_mappings.insert("4A", ["LSR", "1", "", "", "false"]);
            opcode_mappings.insert("4B", ["ASR", "2", "#$", "", "true"]);
            opcode_mappings.insert("4C", ["JMP", "3", "$", "", "false"]);
            opcode_mappings.insert("4D", ["EOR", "3", "$", "", "false"]);
            opcode_mappings.insert("4E", ["LSR", "3", "$", "", "false"]);
            opcode_mappings.insert("4F", ["SRE", "3", "$", "", "true"]);
            opcode_mappings.insert("50", ["BVC", "2", "$", "", "false"]);
            opcode_mappings.insert("51", ["EOR", "2", "($", "),Y", "false"]);
            opcode_mappings.insert("52", ["JAM", "1", "", "", "true"]);
            opcode_mappings.insert("53", ["SRE", "2", "($", "),Y", "true"]);
            opcode_mappings.insert("54", ["NOP", "2", "$", ",X", "true"]);
            opcode_mappings.insert("55", ["EOR", "2", "$", ",X", "false"]);
            opcode_mappings.insert("56", ["LSR", "2", "$", ",X", "false"]);
            opcode_mappings.insert("57", ["SRE", "2", "$", ",X", "true"]);
            opcode_mappings.insert("58", ["CLI", "1", "", "", "false"]);
            opcode_mappings.insert("59", ["EOR", "2", "$", ",Y", "false"]);
            opcode_mappings.insert("5A", ["NOP", "1", "", "", "true"]);
            opcode_mappings.insert("5B", ["SRE", "3", "$", ",Y", "true"]);
            opcode_mappings.insert("5C", ["NOP", "3", "$", ",X", "true"]);
            opcode_mappings.insert("5D", ["EOR", "2", "$", ",X", "false"]);
            opcode_mappings.insert("5E", ["LSR", "3", "$", ",X", "false"]);
            opcode_mappings.insert("5F", ["SRE", "3", "$", ",X", "true"]);
            opcode_mappings.insert("60", ["RTS", "1", "", "", "false"]);
            opcode_mappings.insert("61", ["ADC", "2", "($", ",X)", "false"]);
            opcode_mappings.insert("62", ["JAM", "1", "", "", "true"]);
            opcode_mappings.insert("63", ["RRA", "2", "($", ",X)", "true"]);
            opcode_mappings.insert("64", ["NOP", "2", "$", "", "true"]);
            opcode_mappings.insert("65", ["ADC", "2", "$", "", "false"]);
            opcode_mappings.insert("66", ["ROR", "2", "$", "", "false"]);
            opcode_mappings.insert("67", ["RRA", "2", "$", "", "true"]);
            opcode_mappings.insert("68", ["PLA", "1", "", "", "false"]);
            opcode_mappings.insert("69", ["ADC", "2", "#$", "", "false"]);
            opcode_mappings.insert("6A", ["ROR", "1", "", "", "false"]);
            opcode_mappings.insert("6B", ["ARR", "2", "#$", "", "true"]);
            opcode_mappings.insert("6C", ["JMP", "3", "($", ")", "false"]);
            opcode_mappings.insert("6D", ["ADC", "3", "$", "", "false"]);
            opcode_mappings.insert("6E", ["ROR", "3", "$", "", "false"]);
            opcode_mappings.insert("6F", ["RRA", "3", "$", "", "true"]);
            opcode_mappings.insert("70", ["BVS", "2", "$", "", "false"]);
            opcode_mappings.insert("71", ["ADC", "2", "($", ",Y)", "false"]);
            opcode_mappings.insert("72", ["JAM", "1", "", "", "true"]);
            opcode_mappings.insert("73", ["RRA", "2", "($", "),Y", "true"]);
            opcode_mappings.insert("74", ["NOP", "2", "$", ",X", "true"]);
            opcode_mappings.insert("75", ["ADC", "2", "$", ",X", "false"]);
            opcode_mappings.insert("76", ["ROR", "2", "$", ",X", "false"]);
            opcode_mappings.insert("77", ["RRA", "2", "$", ",X", "true"]);
            opcode_mappings.insert("78", ["SEI", "1", "", "", "false"]);
            opcode_mappings.insert("79", ["ADC", "3", "$", ",Y", "false"]);
            opcode_mappings.insert("7A", ["NOP", "1", "", "", "true"]);
            opcode_mappings.insert("7B", ["RRA", "3", "$", ",Y", "true"]);
            opcode_mappings.insert("7C", ["NOP", "3", "$", ",X", "true"]);
            opcode_mappings.insert("7D", ["ADC", "3", "$", ",X", "false"]);
            opcode_mappings.insert("7E", ["ROR", "3", "$", ",X", "false"]);
            opcode_mappings.insert("7F", ["RRA", "3", "$", ",X", "true"]);
            opcode_mappings.insert("80", ["NOP", "2", "#$", "", "true"]);
            opcode_mappings.insert("81", ["STA", "2", "($", ",X)", "false"]);
            opcode_mappings.insert("82", ["NOP", "2", "#$", "", "true"]);
            opcode_mappings.insert("83", ["SAX", "2", "($", ",X)", "true"]);
            opcode_mappings.insert("84", ["STY", "2", "$", "", "false"]);
            opcode_mappings.insert("85", ["STA", "2", "$", "", "false"]);
            opcode_mappings.insert("86", ["STX", "2", "$", "", "false"]);
            opcode_mappings.insert("87", ["SAX", "2", "$", "", "true"]);
            opcode_mappings.insert("88", ["DEY", "1", "", "", "false"]);
            opcode_mappings.insert("89", ["NOP", "2", "#$", "", "true"]);
            opcode_mappings.insert("8A", ["TXA", "1", "", "", "false"]);
            opcode_mappings.insert("8B", ["ANE", "2", "#$", "", "true"]);
            opcode_mappings.insert("8C", ["STY", "3", "$", "", "false"]);
            opcode_mappings.insert("8D", ["STA", "3", "$", "", "false"]);
            opcode_mappings.insert("8E", ["STX", "3", "$", "", "false"]);
            opcode_mappings.insert("8F", ["SAX", "3", "$", "", "true"]);
            opcode_mappings.insert("90", ["BCC", "2", "$", "", "false"]);
            opcode_mappings.insert("91", ["STA", "2", "($", "),Y", "false"]);
            opcode_mappings.insert("92", ["JAM", "1", "", "", "true"]);
            opcode_mappings.insert("93", ["SHA", "2", "($", "),Y", "true"]);
            opcode_mappings.insert("94", ["STY", "2", "$", ",X", "false"]);
            opcode_mappings.insert("95", ["STA", "2", "$", ",X", "false"]);
            opcode_mappings.insert("96", ["STX", "2", "$", ",Y", "false"]);
            opcode_mappings.insert("97", ["SAX", "2", "$", "", "true"]);
            opcode_mappings.insert("98", ["TYA", "1", "", "", "false"]);
            opcode_mappings.insert("99", ["STA", "3", "$", ",Y", "false"]);
            opcode_mappings.insert("9A", ["TXS", "1", "", "", "false"]);
            opcode_mappings.insert("9B", ["SHS", "3", "$", ",Y", "true"]);
            opcode_mappings.insert("9C", ["SHY", "3", "$", ",X", "true"]);
            opcode_mappings.insert("9D", ["STA", "3", "$", ",X", "false"]);
            opcode_mappings.insert("9E", ["SHX", "3", "$", ",Y", "true"]);
            opcode_mappings.insert("9F", ["SHA", "3", "$", ",Y", "true"]);
            opcode_mappings.insert("A0", ["LDY", "2", "#$", "", "false"]);
            opcode_mappings.insert("A1", ["LDA", "2", "($", ",X)", "false"]);
            opcode_mappings.insert("A2", ["LDX", "2", "#$", "", "false"]);
            opcode_mappings.insert("A3", ["LAX", "2", "($", ",X)", "true"]);
            opcode_mappings.insert("A4", ["LDY", "2", "$", "", "false"]);
            opcode_mappings.insert("A5", ["LDA", "2", "$", "", "false"]);
            opcode_mappings.insert("A6", ["LDX", "2", "$", "", "false"]);
            opcode_mappings.insert("A7", ["LAX", "2", "$", "", "true"]);
            opcode_mappings.insert("A8", ["TAY", "1", "", "", "false"]);
            opcode_mappings.insert("A9", ["LDA", "2", "#$", "", "false"]);
            opcode_mappings.insert("AA", ["TAX", "1", "", "", "false"]);
            opcode_mappings.insert("AB", ["LXA", "2", "#$", "", "true"]);
            opcode_mappings.insert("AC", ["LDY", "3", "$", "", "false"]);
            opcode_mappings.insert("AD", ["LDA", "3", "$", "", "false"]);
            opcode_mappings.insert("AE", ["LDX", "3", "$", "", "false"]);
            opcode_mappings.insert("AF", ["LAX", "3", "$", "", "true"]);
            opcode_mappings.insert("B0", ["BCS", "2", "$", "", "false"]);
            opcode_mappings.insert("B1", ["LDA", "2", "($", "),Y", "false"]);
            opcode_mappings.insert("B2", ["JAM", "1", "", "", "true"]);
            opcode_mappings.insert("B3", ["LAX", "2", "($", "),Y", "true"]);
            opcode_mappings.insert("B4", ["LDY", "2", "$", ",X", "false"]);
            opcode_mappings.insert("B5", ["LDA", "2", "$", ",X", "false"]);
            opcode_mappings.insert("B6", ["LDX", "2", "$", ",Y", "false"]);
            opcode_mappings.insert("B7", ["LAX", "2", "$", ",Y", "true"]);
            opcode_mappings.insert("B8", ["CLV", "1", "($", ",X)", "false"]);
            opcode_mappings.insert("B9", ["LDA", "3", "$", ",Y", "false"]);
            opcode_mappings.insert("BA", ["TSX", "1", "", "", "false"]);
            opcode_mappings.insert("BB", ["LAX", "3", "$", ",Y", "true"]);
            opcode_mappings.insert("BC", ["LDY", "3", "$", ",X", "false"]);
            opcode_mappings.insert("BD", ["LDA", "3", "$", ",X", "false"]);
            opcode_mappings.insert("BE", ["LDX", "3", "$", ",Y", "false"]);
            opcode_mappings.insert("BF", ["LAX", "3", "$", ",Y", "true"]);
            opcode_mappings.insert("C0", ["CPY", "2", "#$", "", "false"]);
            opcode_mappings.insert("C1", ["CMP", "2", "($", ",X)", "false"]);
            opcode_mappings.insert("C2", ["NOP", "2", "#$", "", "true"]);
            opcode_mappings.insert("C3", ["DCP", "2", "($", ",X)", "true"]);
            opcode_mappings.insert("C4", ["CPY", "2", "$", "", "false"]);
            opcode_mappings.insert("C5", ["CMP", "2", "$", "", "false"]);
            opcode_mappings.insert("C6", ["DEC", "2", "$", "", "false"]);
            opcode_mappings.insert("C7", ["DCP", "2", "$", "", "true"]);
            opcode_mappings.insert("C8", ["INY", "1", "", "", "false"]);
            opcode_mappings.insert("C9", ["CMP", "2", "#$", "", "false"]);
            opcode_mappings.insert("CA", ["DEX", "1", "", "", "false"]);
            opcode_mappings.insert("CB", ["SBX", "2", "#$", "", "true"]);
            opcode_mappings.insert("CC", ["CPY", "3", "$", "", "false"]);
            opcode_mappings.insert("CD", ["CMP", "3", "$", "", "false"]);
            opcode_mappings.insert("CE", ["DEC", "3", "$", "", "false"]);
            opcode_mappings.insert("CF", ["DCP", "3", "$", "", "true"]);
            opcode_mappings.insert("D0", ["BNE", "2", "$", "", "false"]);
            opcode_mappings.insert("D1", ["CMP", "1", "($", "),Y", "false"]);
            opcode_mappings.insert("D2", ["JAM", "1", "", "", "true"]);
            opcode_mappings.insert("D3", ["DCP", "2", "($", "),Y", "true"]);
            opcode_mappings.insert("D4", ["NOP", "2", "$", ",X", "true"]);
            opcode_mappings.insert("D5", ["CMP", "2", "$", ",X", "false"]);
            opcode_mappings.insert("D6", ["DEC", "2", "$", ",X", "false"]);
            opcode_mappings.insert("D7", ["DCP", "2", "", ",X", "true"]);
            opcode_mappings.insert("D8", ["CLD", "1", "", "", "false"]);
            opcode_mappings.insert("D9", ["CMP", "3", "$", ",Y", "false"]);
            opcode_mappings.insert("DA", ["NOP", "1", "", "", "true"]);
            opcode_mappings.insert("DB", ["DCP", "3", "$", ",Y", "true"]);
            opcode_mappings.insert("DC", ["NOP", "3", "$", ",X", "true"]);
            opcode_mappings.insert("DD", ["CMP", "3", "$", ",X", "false"]);
            opcode_mappings.insert("DE", ["DEC", "3", "$", ",X", "false"]);
            opcode_mappings.insert("DF", ["DCP", "3", "$", ",X", "true"]);
            opcode_mappings.insert("E0", ["CPX", "2", "#$", "", "false"]);
            opcode_mappings.insert("E1", ["SBC", "2", "($", ",X)", "false"]);
            opcode_mappings.insert("E2", ["NOP", "2", "#$", "", "true"]);
            opcode_mappings.insert("E3", ["ISB", "2", "($", ",X)", "true"]);
            opcode_mappings.insert("E4", ["CPX", "2", "$", "", "false"]);
            opcode_mappings.insert("E5", ["SBC", "2", "$", "", "false"]);
            opcode_mappings.insert("E6", ["INC", "2", "$", "", "false"]);
            opcode_mappings.insert("E7", ["ISB", "2", "$", "", "true"]);
            opcode_mappings.insert("E8", ["INX", "1", "", "", "false"]);
            opcode_mappings.insert("E9", ["SBC", "2", "#$", "", "false"]);
            opcode_mappings.insert("EA", ["NOP", "1", "", "", "false"]);
            opcode_mappings.insert("EB", ["SBC", "2", "#$", "", "true"]);
            opcode_mappings.insert("EC", ["CPX", "3", "$", "", "false"]);
            opcode_mappings.insert("ED", ["SBC", "3", "$", "", "false"]);
            opcode_mappings.insert("EE", ["INC", "3", "$", "", "false"]);
            opcode_mappings.insert("EF", ["ISB", "3", "$", "", "true"]);
            opcode_mappings.insert("F0", ["BEQ", "2", "$", "", "false"]);
            opcode_mappings.insert("F1", ["SBC", "2", "($", "),Y", "false"]);
            opcode_mappings.insert("F2", ["JAM", "1", "", "", "true"]);
            opcode_mappings.insert("F3", ["ISB", "2", "($", "),Y", "true"]);
            opcode_mappings.insert("F4", ["NOP", "2", "$", ",X", "true"]);
            opcode_mappings.insert("F5", ["SBC", "2", "$", ",X", "false"]);
            opcode_mappings.insert("F6", ["INC", "2", "$", ",X", "false"]);
            opcode_mappings.insert("F7", ["ISB", "2", "$", ",X", "true"]);
            opcode_mappings.insert("F8", ["SED", "1", "", "", "false"]);
            opcode_mappings.insert("F9", ["SBC", "3", "$", ",Y", "false"]);
            opcode_mappings.insert("FA", ["NOP", "1", "", "", "true"]);
            opcode_mappings.insert("FB", ["ISB", "3", "$", ",Y", "true"]);
            opcode_mappings.insert("FC", ["NOP", "3", "$", ",X", "true"]);
            opcode_mappings.insert("FD", ["SBC", "3", "$", ",X", "false"]);
            opcode_mappings.insert("FE", ["INC", "3", "$", ",X", "false"]);
            opcode_mappings.insert("FF", ["ISB", "3", "$", ",X", "true"]);

            return opcode_mappings;
        }

        // Method to look for a match in the opcodes map and return the values array
        pub(crate) fn get_match<'a>(
            self,
            opcode_mappings: HashMap<&str, [&'a str; 5]>,
            value: &str,
        ) -> [&'a str; 5] {
            let mut opcode_value: [&str; 5] = ["", "", "", "", ""];
            match opcode_mappings.get(value) {
                Some(&row) => opcode_value = row,
                _ => {}
            };
            return opcode_value;
        }
    }
}

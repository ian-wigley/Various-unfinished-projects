extern crate hex;

use fltk::{
    app,
    button::Button,
    enums::{Font, FrameType, Shortcut},
    menu,
    prelude::*,
    text::{TextBuffer, TextDisplay},
    window::Window,
};

use std::collections::HashMap;
use std::env;
use std::io::Read;
use std::str::FromStr;

mod opcode;

#[derive(Copy, Clone)]
pub struct Opcode {}

#[derive(Copy, Clone)]
pub enum Message {
    Changed,
    SaveAs,
}

//https://www.reddit.com/r/rust/comments/q58q2n/fltkrs_textdisplay_how_to_update/

fn main() {
    env::set_var("RUST_BACKTRACE", "full");

    let app = app::App::default().load_system_fonts();
    Font::set_font(Font::Helvetica, "Monospace");
    app::set_font_size(10);

    let mut wind = Window::new(100, 100, 820, 620, "C64 Binary to Assembly Converter");
    let left_display = TextDisplay::new(5, 35, 400, 550, None);
    let _right_display = TextDisplay::new(415, 35, 400, 550, None);

    let (s, _r) = app::channel::<Message>();
    let mut menu = menu::SysMenuBar::default().with_size(800, 35);
    menu.set_frame(FrameType::FlatBox);
    menu.add_emit(
        "&File/Save as...\t",
        Shortcut::Ctrl | 'w',
        menu::MenuFlag::Normal,
        s,
        Message::SaveAs,
    );
    let mut but = Button::new(380, 590, 80, 20, "Add labels");

    wind.end();
    wind.show();

    but.set_callback(move |_| click(wind.to_owned()));

    // Create a new OpCode Object
    let opcode = Opcode::new();

    // Populate the OpCode Map
    let opcodes = opcode.populate_opcodes();

    // Load the external binary file
    let file_content: Vec<u8> = load_bin_file().unwrap();

    let hex_content = parse_content(file_content.clone());

    convert_to_assembly(
        hex_content,
        opcode,
        opcodes.clone(),
        file_content,
        left_display,
    );

    but.activate();

    app.run().unwrap();
}

fn click(wind: Window) {
    wind.clone().set_label("TODO Add labels!");
    add_labels("1000", "2000", true, 1, 2);
}

fn convert_to_assembly(
    hex_content: Vec<String>,
    opcode: Opcode,
    opcodes: HashMap<&str, [&str; 5]>,
    file_content: Vec<u8>,
    disp: TextDisplay,
) {
    let mut diplay_text = disp;
    let mut buf = TextBuffer::default();

    let mut file_position = 0;
    let mut pc: usize = 0;

    while file_position < 1000
    //hex.len()
    {
        let op_code = hex_content[file_position].clone().to_uppercase();
        let values = opcode.get_match(opcodes.clone(), op_code.as_str());
        let nmenonic = values[0];
        let incrementer = i32::from_str(values[1]).unwrap_or(1);

        let mut _two: String = String::from("  ");
        let mut _three: String = String::from("  ");
        let mut _padding: String = String::new();

        if incrementer == 2 {
            if is_branch(nmenonic) {
                let mut _u: u8 = file_content[pc + 1];
                let mut _v: i8 = _u as i8;
                let _w = (_v + 2) as i32;
                let mut _s = (pc as i32) + _w;

                let mut _vv: i8 = ((file_content[pc + 1]) as i8) + 2;
                let mut _ss = (pc as i32) + _vv as i32;

                _two = "".to_owned();
                _three = format!("{:04X}", _s);
            } else {
                _three = hex_content[pc + 1].clone().to_uppercase();
            }
        }
        if incrementer == 3 {
            _two = hex_content[pc + 2].to_uppercase().as_str().parse().unwrap();
            _padding = _two.clone();
            _three = hex_content[pc + 1].to_uppercase().as_str().parse().unwrap();
        }

        // increment the pc
        pc += incrementer as usize;

        let code = format!(
            "{:04X} {} {} {}        {} {}{}{}{}\n",
            file_position, op_code, _three, _two, nmenonic, values[2], _padding, _three, values[3]
        );
        buf.append(&code);

        file_position += incrementer as usize;
    }
    diplay_text.set_buffer(buf.clone());
}

fn is_branch(nmenonic: &str) -> bool {
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

fn load_bin_file() -> std::io::Result<Vec<u8>> {
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

fn parse_content(bin: Vec<u8>) -> Vec<String> {
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

fn add_labels(
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
    let first_pass = true;
    let count = 0;

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

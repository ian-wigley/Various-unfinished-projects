import { Convert } from "./convert.js";

export class PopulateOpCodeList {

    private readonly m_OpCodes = [];
    public GetOpCodes() { return this.m_OpCodes; }

    public Init(): void {
        this.m_OpCodes.push(
            new OpCode("00", "BRK", 1, "", "", false),
            new OpCode("01", "ORA", 2, "($", ",X)", false),
            new OpCode("02", "JAM", 1, "", "", true),
            new OpCode("03", "SLO", 2, "($", ",X)", true),
            new OpCode("04", "NOP", 2, "$", "", true),
            new OpCode("05", "ORA", 2, "$", "", false),
            new OpCode("06", "ASL", 2, "$", "", false),
            new OpCode("07", "SLO", 2, "$", "", true),
            new OpCode("08", "PHP", 1, "", "", false),
            new OpCode("09", "ORA", 2, "#$", "", false),
            new OpCode("0A", "ASL", 1, "", "", false),
            new OpCode("0B", "ANC", 2, "#$", "", true),
            new OpCode("0C", "NOP", 3, "$", "", true),
            new OpCode("0D", "ORA", 3, "$", "", false),
            new OpCode("0E", "ASL", 3, "$", "", false),
            new OpCode("0F", "SLO", 3, "$", "", true),
            new OpCode("10", "BPL", 2, "$", "", false),
            new OpCode("11", "ORA", 2, "($", "),Y", false),
            new OpCode("12", "JAM", 1, "", "", true),
            new OpCode("13", "SLO", 2, "($", "),Y", true),
            new OpCode("14", "NOP", 2, "$", ",X", true),
            new OpCode("15", "ORA", 2, "$", ",X", false),
            new OpCode("16", "ASL", 2, "$", ",X", false),
            new OpCode("17", "SLO", 2, "$", ",X", true),
            new OpCode("18", "CLC", 1, "", "", false),
            new OpCode("19", "ORA", 3, "$", ",Y", false),
            new OpCode("1A", "NOP", 1, "", "", true),
            new OpCode("1B", "SLO", 3, "$", ",Y", true),
            new OpCode("1C", "NOP", 3, "$", ",X", true),
            new OpCode("1D", "ORA", 3, "$", ",X", false),
            new OpCode("1E", "ASL", 3, "$", ",X", false),
            new OpCode("1F", "SLO", 3, "", ",X", true),
            new OpCode("20", "JSR", 3, "$", "", false),
            new OpCode("21", "AND", 2, "($", ",X)", false),
            new OpCode("22", "JAM", 1, "", "", true),
            new OpCode("23", "RLA", 2, "($", ",X)", true),
            new OpCode("24", "BIT", 2, "$", "", false),
            new OpCode("25", "AND", 2, "$", "", false),
            new OpCode("26", "ROL", 2, "$", "", false),
            new OpCode("27", "RLA", 2, "", "", true),
            new OpCode("28", "PLP", 1, "", "", false),
            new OpCode("29", "AND", 2, "#$", "", false),
            new OpCode("2A", "ROL", 1, "", "", false),
            new OpCode("2B", "ANC", 2, "#$", "", true),
            new OpCode("2C", "BIT", 3, "$", "", false),
            new OpCode("2D", "AND", 3, "$", "", false),
            new OpCode("2E", "ROL", 3, "$", "", false),
            new OpCode("2F", "RLA", 3, "", "", true),
            new OpCode("30", "BMI", 2, "$", "", false),
            new OpCode("31", "AND", 2, "($", "),Y", false),
            new OpCode("32", "JAM", 1, "", "", true),
            new OpCode("33", "RLA", 2, "($", "),Y", true),
            new OpCode("34", "NOP", 2, "$", ",X", true),
            new OpCode("35", "AND", 2, "$", ",X", false),
            new OpCode("36", "ROL", 2, "$", ",X", false),
            new OpCode("37", "RLA", 2, "$", ",X", true),
            new OpCode("38", "SEC", 1, "", "", false),
            new OpCode("39", "AND", 3, "$", ",Y", false),
            new OpCode("3A", "NOP", 1, "", "", true),
            new OpCode("3B", "RLA", 3, "$", ",Y", true),
            new OpCode("3C", "NOP", 3, "$", ",X", true),
            new OpCode("3D", "AND", 3, "$", ",X", false),
            new OpCode("3E", "ROL", 3, "$", ",X", false),
            new OpCode("3F", "RLA", 3, "$", ",X", true),
            new OpCode("40", "RTI", 1, "", "", false),
            new OpCode("41", "EOR", 2, "($", ",X)", false),
            new OpCode("42", "JAM", 1, "", "", true),
            new OpCode("43", "SRE", 2, "($", ",X)", true),
            new OpCode("44", "NOP", 2, "$", "", true),
            new OpCode("45", "EOR", 2, "$", "", false),
            new OpCode("46", "LSR", 2, "$", "", false),
            new OpCode("47", "SRE", 2, "$", "", true),
            new OpCode("48", "PHA", 1, "", "", false),
            new OpCode("49", "EOR", 2, "#$", "", false),
            new OpCode("4A", "LSR", 1, "", "", false),
            new OpCode("4B", "ASR", 2, "#$", "", true),
            new OpCode("4C", "JMP", 3, "$", "", false),
            new OpCode("4D", "EOR", 3, "$", "", false),
            new OpCode("4E", "LSR", 3, "$", "", false),
            new OpCode("4F", "SRE", 3, "$", "", true),
            new OpCode("50", "BVC", 2, "$", "", false),
            new OpCode("51", "EOR", 2, "($", "),Y", false),
            new OpCode("52", "JAM", 1, "", "", true),
            new OpCode("53", "SRE", 2, "($", "),Y", true),
            new OpCode("54", "NOP", 2, "$", ",X", true),
            new OpCode("55", "EOR", 2, "$", ",X", false),
            new OpCode("56", "LSR", 2, "$", ",X", false),
            new OpCode("57", "SRE", 2, "$", ",X", true),
            new OpCode("58", "CLI", 1, "", "", false),
            new OpCode("59", "EOR", 2, "$", ",Y", false),
            new OpCode("5A", "NOP", 1, "", "", true),
            new OpCode("5B", "SRE", 3, "$", ",Y", true),
            new OpCode("5C", "NOP", 3, "$", ",X", true),
            new OpCode("5D", "EOR", 2, "$", ",X", false),
            new OpCode("5E", "LSR", 3, "$", ",X", false),
            new OpCode("5F", "SRE", 3, "$", ",X", true),
            new OpCode("60", "RTS", 1, "", "", false),
            new OpCode("61", "ADC", 2, "($", ",X)", false),
            new OpCode("62", "JAM", 1, "", "", true),
            new OpCode("63", "RRA", 2, "($", ",X)", true),
            new OpCode("64", "NOP", 2, "$", "", true),
            new OpCode("65", "ADC", 2, "$", "", false),
            new OpCode("66", "ROR", 2, "$", "", false),
            new OpCode("67", "RRA", 2, "$", "", true),
            new OpCode("68", "PLA", 1, "", "", false),
            new OpCode("69", "ADC", 2, "#$", "", false),
            new OpCode("6A", "ROR", 1, "", "", false),
            new OpCode("6B", "ARR", 2, "#$", "", true),
            new OpCode("6C", "JMP", 3, "($", ")", false),
            new OpCode("6D", "ADC", 3, "$", "", false),
            new OpCode("6E", "ROR", 3, "$", "", false),
            new OpCode("6F", "RRA", 3, "$", "", true),
            new OpCode("70", "BVS", 2, "$", "", false),
            new OpCode("71", "ADC", 2, "($", ",Y)", false),
            new OpCode("72", "JAM", 1, "", "", true),
            new OpCode("73", "RRA", 2, "($", "),Y", true),
            new OpCode("74", "NOP", 2, "$", ",X", true),
            new OpCode("75", "ADC", 2, "$", ",X", false),
            new OpCode("76", "ROR", 2, "$", ",X", false),
            new OpCode("77", "RRA", 2, "$", ",X", true),
            new OpCode("78", "SEI", 1, "", "", false),
            new OpCode("79", "ADC", 3, "$", ",Y", false),
            new OpCode("7A", "NOP", 1, "", "", true),
            new OpCode("7B", "RRA", 3, "$", ",Y", true),
            new OpCode("7C", "NOP", 3, "$", ",X", true),
            new OpCode("7D", "ADC", 3, "$", ",X", false),
            new OpCode("7E", "ROR", 3, "$", ",X", false),
            new OpCode("7F", "RRA", 3, "$", ",X", true),
            new OpCode("80", "NOP", 2, "#$", "", true),
            new OpCode("81", "STA", 2, "($", ",X)", false),
            new OpCode("82", "NOP", 2, "#$", "", true),
            new OpCode("83", "SAX", 2, "($", ",X)", true),
            new OpCode("84", "STY", 2, "$", "", false),
            new OpCode("85", "STA", 2, "$", "", false),
            new OpCode("86", "STX", 2, "$", "", false),
            new OpCode("87", "SAX", 2, "$", "", true),
            new OpCode("88", "DEY", 1, "", "", false),
            new OpCode("89", "NOP", 2, "#$", "", true),
            new OpCode("8A", "TXA", 1, "", "", false),
            new OpCode("8B", "ANE", 2, "#$", "", true),
            new OpCode("8C", "STY", 3, "$", "", false),
            new OpCode("8D", "STA", 3, "$", "", false),
            new OpCode("8E", "STX", 3, "$", "", false),
            new OpCode("8F", "SAX", 3, "$", "", true),
            new OpCode("90", "BCC", 2, "$", "", false),
            new OpCode("91", "STA", 2, "($", "),Y", false),
            new OpCode("92", "JAM", 1, "", "", true),
            new OpCode("93", "SHA", 2, "($", "),Y", true),
            new OpCode("94", "STY", 2, "$", ",X", false),
            new OpCode("95", "STA", 2, "$", ",X", false),
            new OpCode("96", "STX", 2, "$", ",Y", false),
            new OpCode("97", "SAX", 2, "$", "", true),
            new OpCode("98", "TYA", 1, "", "", false),
            new OpCode("99", "STA", 3, "$", ",Y", false),
            new OpCode("9A", "TXS", 1, "", "", false),
            new OpCode("9B", "SHS", 3, "$", ",Y", true),
            new OpCode("9C", "SHY", 3, "$", ",X", true),
            new OpCode("9D", "STA", 3, "$", ",X", false),
            new OpCode("9E", "SHX", 3, "$", ",Y", true),
            new OpCode("9F", "SHA", 3, "$", ",Y", true),
            new OpCode("A0", "LDY", 2, "#$", "", false),
            new OpCode("A1", "LDA", 2, "($", ",X)", false),
            new OpCode("A2", "LDX", 2, "#$", "", false),
            new OpCode("A3", "LAX", 2, "($", ",X)", true),
            new OpCode("A4", "LDY", 2, "$", "", false),
            new OpCode("A5", "LDA", 2, "$", "", false),
            new OpCode("A6", "LDX", 2, "$", "", false),
            new OpCode("A7", "LAX", 2, "$", "", true),
            new OpCode("A8", "TAY", 1, "", "", false),
            new OpCode("A9", "LDA", 2, "#$", "", false),
            new OpCode("AA", "TAX", 1, "", "", false),
            new OpCode("AB", "LXA", 2, "#$", "", true),
            new OpCode("AC", "LDY", 3, "$", "", false),
            new OpCode("AD", "LDA", 3, "$", "", false),
            new OpCode("AE", "LDX", 3, "$", "", false),
            new OpCode("AF", "LAX", 3, "$", "", true),
            new OpCode("B0", "BCS", 2, "$", "", false),
            new OpCode("B1", "LDA", 2, "($", "),Y", false),
            new OpCode("B2", "JAM", 1, "", "", true),
            new OpCode("B3", "LAX", 2, "($", "),Y", true),
            new OpCode("B4", "LDY", 2, "$", ",X", false),
            new OpCode("B5", "LDA", 2, "$", ",X", false),
            new OpCode("B6", "LDX", 2, "$", ",Y", false),
            new OpCode("B7", "LAX", 2, "$", ",Y", true),
            new OpCode("B8", "CLV", 1, "($", ",X)", false),
            new OpCode("B9", "LDA", 3, "$", ",Y", false),
            new OpCode("BA", "TSX", 1, "", "", false),
            new OpCode("BB", "LAX", 3, "$", ",Y", true),
            new OpCode("BC", "LDY", 3, "$", ",X", false),
            new OpCode("BD", "LDA", 3, "$", ",X", false),
            new OpCode("BE", "LDX", 3, "$", ",Y", false),
            new OpCode("BF", "LAX", 3, "$", ",Y", true),
            new OpCode("C0", "CPY", 2, "#$", "", false),
            new OpCode("C1", "CMP", 2, "($", ",X)", false),
            new OpCode("C2", "NOP", 2, "#$", "", true),
            new OpCode("C3", "DCP", 2, "($", ",X)", true),
            new OpCode("C4", "CPY", 2, "$", "", false),
            new OpCode("C5", "CMP", 2, "$", "", false),
            new OpCode("C6", "DEC", 2, "$", "", false),
            new OpCode("C7", "DCP", 2, "$", "", true),
            new OpCode("C8", "INY", 1, "", "", false),
            new OpCode("C9", "CMP", 2, "#$", "", false),
            new OpCode("CA", "DEX", 1, "", "", false),
            new OpCode("CB", "SBX", 2, "#$", "", true),
            new OpCode("CC", "CPY", 3, "$", "", false),
            new OpCode("CD", "CMP", 3, "$", "", false),
            new OpCode("CE", "DEC", 3, "$", "", false),
            new OpCode("CF", "DCP", 3, "$", "", true),
            new OpCode("D0", "BNE", 2, "$", "", false),
            new OpCode("D1", "CMP", 1, "($", "),Y", false),
            new OpCode("D2", "JAM", 1, "", "", true),
            new OpCode("D3", "DCP", 2, "($", "),Y", true),
            new OpCode("D4", "NOP", 2, "$", ",X", true),
            new OpCode("D5", "CMP", 2, "$", ",X", false),
            new OpCode("D6", "DEC", 2, "$", ",X", false),
            new OpCode("D7", "DCP", 2, "", ",X", true),
            new OpCode("D8", "CLD", 1, "", "", false),
            new OpCode("D9", "CMP", 3, "$", ",Y", false),
            new OpCode("DA", "NOP", 1, "", "", true),
            new OpCode("DB", "DCP", 3, "$", ",Y", true),
            new OpCode("DC", "NOP", 3, "$", ",X", true),
            new OpCode("DD", "CMP", 3, "$", ",X", false),
            new OpCode("DE", "DEC", 3, "$", ",X", false),
            new OpCode("DF", "DCP", 3, "$", ",X", true),
            new OpCode("E0", "CPX", 2, "#$", "", false),
            new OpCode("E1", "SBC", 2, "($", ",X)", false),
            new OpCode("E2", "NOP", 2, "#$", "", true),
            new OpCode("E3", "ISB", 2, "($", ",X)", true),
            new OpCode("E4", "CPX", 2, "$", "", false),
            new OpCode("E5", "SBC", 2, "$", "", false),
            new OpCode("E6", "INC", 2, "$", "", false),
            new OpCode("E7", "ISB", 2, "$", "", true),
            new OpCode("E8", "INX", 1, "", "", false),
            new OpCode("E9", "SBC", 2, "#$", "", false),
            new OpCode("EA", "NOP", 1, "", "", false),
            new OpCode("EB", "SBC", 2, "#$", "", true),
            new OpCode("EC", "CPX", 3, "$", "", false),
            new OpCode("ED", "SBC", 3, "$", "", false),
            new OpCode("EE", "INC", 3, "$", "", false),
            new OpCode("EF", "ISB", 3, "$", "", true),
            new OpCode("F0", "BEQ", 2, "$", "", false),
            new OpCode("F1", "SBC", 2, "($", "),Y", false),
            new OpCode("F2", "JAM", 1, "", "", true),
            new OpCode("F3", "ISB", 2, "($", "),Y", true),
            new OpCode("F4", "NOP", 2, "$", ",X", true),
            new OpCode("F5", "SBC", 2, "$", ",X", false),
            new OpCode("F6", "INC", 2, "$", ",X", false),
            new OpCode("F7", "ISB", 2, "$", ",X", true),
            new OpCode("F8", "SED", 1, "", "", false),
            new OpCode("F9", "SBC", 3, "$", ",Y", false),
            new OpCode("FA", "NOP", 1, "", "", true),
            new OpCode("FB", "ISB", 3, "$", ",Y", true),
            new OpCode("FC", "NOP", 3, "$", ",X", true),
            new OpCode("FD", "SBC", 3, "$", ",X", false),
            new OpCode("FE", "INC", 3, "$", ",X", false),
            new OpCode("FF", "ISB", 3, "$", ",X", true));
    }
}

class OpCode {
    public m_code;
    public m_illegal: boolean;
    private readonly m_name: string = "";
    private readonly m_numberOfBytes: number = 0;
    private readonly m_prefix: string = "";
    private readonly m_suffix: string = "";

    constructor(code: string, name: string, numberOfBytes: number, prefix: string, suffix: string, illegal: boolean) {
        this.m_code = code;
        this.m_name = name;
        this.m_numberOfBytes = numberOfBytes;
        this.m_prefix = prefix;
        this.m_suffix = suffix;
        this.m_illegal = illegal;
    }

    public GetCode(line: string, filePosition: number, bytes: Uint8Array, lineNumber: number, pc: number, dataStatements: any, illegalOpCodes: any) {
        let temp = [];
        // const padded = line.padEnd(16);
        if (this.m_numberOfBytes == 1) {
            // if (this.m_illegal) { //Add the programme counter location to the list of illegal opcodes found //illegalOpCodes.Add(pc.ToString("X4")); }
            temp.push("!byte $" + this.m_code);
            dataStatements.push(pc.toString(), temp);
            const padded = line.padEnd(16);
            line = padded + this.m_name;
            filePosition += 1;
        }
        if (this.m_numberOfBytes == 2) {
            // if (this.m_illegal) {  //illegalOpCodes.Add(pc.ToString("X4")); }
            temp.push("!byte $" + this.m_code, "!byte $" + bytes[filePosition + 1].toString(16));
            dataStatements.push(pc.toString(), temp);
            line += " " + Convert.X2(bytes[filePosition + 1]);
            const padded = line.padEnd(16);

            if (this.m_name == "BCC" || this.m_name == "BCS" ||
                this.m_name == "BEQ" || this.m_name == "BMI" ||
                this.m_name == "BNE" || this.m_name == "BPL" ||
                this.m_name == "BVC" || this.m_name == "BVS") {
                let s = bytes[filePosition + 1];
                if (s > 127) { s = s - 256; }
                s += 2;
                line = padded + this.m_name + " " + this.m_prefix + Convert.X4(pc + s);
            }
            else {
                line = padded + this.m_name + " " + this.m_prefix + Convert.X2(bytes[filePosition + 1]) + this.m_suffix;
            }
            filePosition += 2;
        }
        else if (this.m_numberOfBytes == 3) {
            // if (this.m_illegal) { //illegalOpCodes.Add(pc.ToString("X4")); }
            temp.push(
                "!byte $" + this.m_code,
                "!byte $" + bytes[filePosition + 1].toString(16),
                "!byte $" + bytes[filePosition + 2].toString(16));
            dataStatements.push(pc, temp);
            line += " " + Convert.X2(bytes[filePosition + 1]) + " " + Convert.X2(bytes[filePosition + 2]);
            const padded = line.padEnd(16);
            line = padded + this.m_name + " " + this.m_prefix + Convert.X2(bytes[filePosition + 2]) + Convert.X2(bytes[filePosition + 1]) + this.m_suffix;
            filePosition += 3;
        }

        let object = {
            line: line, filePosition: filePosition, dataStatements: dataStatements, illegalOpCodes: illegalOpCodes
        };
        return object;
    }
}
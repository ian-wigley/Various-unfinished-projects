const std = @import("std");

pub const CPU = struct {

    var m_rom: []u8 = undefined;
    var m_PC: u16 = 0; //Program Counter: This is the current instruction pointer. 16-bit register.
    var SP: u16 = 0; // Stack Pointer. 16-bit register
    var A: u8 = 0; // Accumulator. 8-bit register
    var B: u8 = 0; // Register B. 8-bit register
    var C: u8 = 0; // Register C. 8-bit register
    var D: u8 = 0; // Register D. 8-bit register
    var E: u8 = 0; // Register E. 8-bit register
    var H: u8 = 0; // Register H. 8-bit register
    var L: u8 = 0; // Register L. 8-bit register
    var BC: u16 = 0; // Virtual register BC (16-bit) combinaison of registers B and C
    var DE: u16 = 0; // Virtual register DE (16-bit) combinaison of registers D and E
    pub var HL: u16 = 0; // Virtual register HL (16-bit) combinaison of registers H and L

    var SIGN: u1 = 0; // Sign flag
    var ZERO: u1 = 0; // Zero flag
    var HALFCARRY: u1 = 0; //Half-carry (or Auxiliary Carry) flag
    var PARITY: bool = false; //Parity flag
    var CARRY: u16 = 0; //Carry flag

    var INTERRUPT: bool = false; //Interrupt Enabled flag
    var CRASHED: bool = false; //Special flag that tells if the CPU is currently crashed (stopped)

    var instruction_per_frame: u16 = 4000; // Approximate real machine speed

    // Interrupt handling
    var interrupt_alternate: u16 = 0;
    var half_instruction_per_frame: u16 = 0;

    // Addionnal debug fields, not used by CPU
    var BIT0: u8 = 1;
    var BIT4: u8 = 16;
    var BIT5: u8 = 32;
    var BIT6: u8 = 64;
    var BIT7: u8 = 128;

    var m_source: u16 = 0;
    var m_value: u8 = 0;
    var m_byte: u8 = 0;

    var m_instructionCounter: u16 = 0;

    // var IO m_io;

    pub fn New(rom: []u8) void {
        m_rom = rom;
        half_instruction_per_frame = instruction_per_frame / 2;
        Reset();
    }

    pub fn Run() void {
        std.log.info("Programme Counter: {any}", .{m_PC});
        var count: usize = 0;
        while (count < instruction_per_frame) {
            ExecuteInstruction();
            count += 1;
            if (count > 3000){
                std.log.info("Count: {any}", .{count});
            }
        }
        std.log.info("Count: {any}", .{count});
    }

    // All opcodes are 1 byte wide
    pub fn ExecuteInstruction() void {
        if (!CRASHED) {
            m_byte = FetchRomByte();
            // std.log.info("m_byte: {any}", .{m_byte});
            switch (m_byte) {
                0x00 => {
                    std.log.info("NOP\n", .{});
                    NOP();
                },
                0xc2, 0xc3, 0xca, 0xd2, 0xda, 0xf2, 0xfa => {
                    std.log.info("JMP\n", .{});
                    Instruction_JMP(m_byte);
                },
                0x01, 0x11, 0x21, 0x31 => {
                    std.log.info("LXI\n", .{});
                    Instruction_LXI(m_byte);
                },

                0x3e, 0x06, 0x0e, 0x16, 0x1e, 0x26, 0x2e, 0x36 => {
                    std.log.info("MVI\n", .{});
                    Instruction_MVI(m_byte);
                },

                0xcd, 0xc4, 0xcc, 0xd4, 0xdc => {
                    std.log.info("CALL\n", .{});
                    Instruction_CALL(m_byte);
                },

                0x0a, 0x1a, 0x3a => {
                    std.log.info("LDA\n", .{});
                    Instruction_LDA(m_byte);
                },

                0x77, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75 => {
                    std.log.info("MOVHL\n", .{});
                    Instruction_MOVHL(m_byte);
                },

                0x03, 0x13, 0x23, 0x33 => {
                    std.log.info("INX\n", .{});
                    Instruction_INX(m_byte);
                },

                0x0b, 0x1b, 0x2b, 0x3b => {
                    std.log.info("DCX\n", .{});
                    Instruction_DCX(m_byte);
                },

                0x3d, 0x05, 0x0d, 0x15, 0x1d, 0x25, 0x2d, 0x35 => {
                    std.log.info("DEC\n", .{});
                    Instruction_DEC(m_byte);
                },

                0x3c, 0x04, 0x0c, 0x14, 0x1c, 0x24, 0x2c, 0x34 => {
                    std.log.info("INC\n", .{});
                    Instruction_INC(m_byte);
                },

                0xc9, 0xc0, 0xc8, 0xd0, 0xd8 => {
                    std.log.info("RET\n", .{});
                    Instruction_RET(m_byte);
                },

                0x7F, 0x78, 0x79, 0x7A, 0x7B, 0x7C, 0x7D, 0x7E => {
                    std.log.info("MOV\n", .{});
                    Instruction_MOV(m_byte);
                },

                0x47, 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46 => {
                    std.log.info("MOV\n", .{});
                    Instruction_MOV(m_byte);
                },

                0x4f, 0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e => {
                    std.log.info("MOV\n", .{});
                    Instruction_MOV(m_byte);
                },

                0x57, 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56 => {
                    std.log.info("MOV\n", .{});
                    Instruction_MOV(m_byte);
                },

                0x5f, 0x58, 0x59, 0x5a, 0x5b, 0x5c, 0x5d, 0x5e => {
                    std.log.info("MOV\n", .{});
                    Instruction_MOV(m_byte);
                },

                0x67, 0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66 => {
                    std.log.info("MOV\n", .{});
                    Instruction_MOV(m_byte);
                },

                0x6f, 0x68, 0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e => {
                    std.log.info("MOV\n", .{});
                    Instruction_MOV(m_byte);
                },

                0xbf, 0xb8, 0xb9, 0xba, 0xbb, 0xbc, 0xbd, 0xbe, 0xfe => {
                    std.log.info("CMP\n", .{});
                    Instruction_CMP(m_byte);
                },

                0xc5, 0xd5, 0xe5, 0xf5 => {
                    std.log.info("PUSH\n", .{});
                    Instruction_PUSH(m_byte);
                },

                0xc1, 0xd1, 0xe1, 0xf1 => {
                    std.log.info("POP\n", .{});
                    Instruction_POP(m_byte);
                },

                0x09, 0x19, 0x29, 0x39 => {
                    std.log.info("DAD\n", .{});
                    Instruction_DAD(m_byte);
                },

                0xeb => {
                    std.log.info("XCHG\n", .{});
                    Instruction_XCHG();
                },

                0xe3 => {
                    std.log.info("XTHL\n", .{});
                    Instruction_XTHL();
                },

                0xd3 => {
                    std.log.info("OUTP\n", .{});
                    Instruction_OUTP();
                },

                0xdb => {
                    std.log.info("INP\n", .{});
                    Instruction_INP();
                },

                0xe9 => {
                    std.log.info("PCHL\n", .{});
                    Instruction_PCHL();
                },

                0xc7, 0xcf, 0xd7, 0xdf, 0xe7, 0xef, 0xf7, 0xff => {
                    std.log.info("RST\n", .{});
                    Instruction_RST(m_byte);
                },

                0x07 => {
                    std.log.info("RLC\n", .{});
                    Instruction_RLC();
                },

                0x17 => {
                    std.log.info("RAL\n", .{});
                    Instruction_RAL();
                },

                0x0f => {
                    std.log.info("RRC\n", .{});
                    Instruction_RRC();
                },

                0x1f => {
                    std.log.info("RAR\n", .{});
                    Instruction_RAR();
                },

                0xa7, 0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xe6 => {
                    std.log.info("AND\n", .{});
                    Instruction_AND(m_byte);
                },

                0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0xc6 => {
                    std.log.info("ADD\n", .{});
                    Instruction_ADD(m_byte);
                },

                0x02, 0x12, 0x32 => {
                    std.log.info("STA\n", .{});
                    Instruction_STA(m_byte);
                },

                0xaf, 0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad, 0xae, 0xee => {
                    std.log.info("XOR\n", .{});
                    Instruction_XOR(m_byte);
                },
                0xf3 => {
                    std.log.info("DI\n", .{});
                    Instruction_DI();
                },
                0xfb => {
                    std.log.info("E1\n", .{});
                    Instruction_EI();
                },
                0x37 => {
                    std.log.info("STC\n", .{});
                    Instruction_STC();
                },
                0x3f => {
                    std.log.info("CMC\n", .{});
                    Instruction_CMC();
                },
                0xb7, 0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xf6 => {
                    std.log.info("OR\n", .{});
                    Instruction_OR(m_byte);
                },
                0x97, 0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0xd6 => {
                    std.log.info("SUB\n", .{});
                    Instruction_SUB(m_byte);
                },
                0x2a => {
                    std.log.info("LHLD\n", .{});
                    Instruction_LHLD();
                },
                0x22 => {
                    std.log.info("SHLD\n", .{});
                    Instruction_SHLD();
                },
                0xde => {
                    std.log.info("SBBI\n", .{});
                    Instruction_SBBI();
                },
                0x27 => {
                    std.log.info("DAA\n", .{});
                    Instruction_DAA();
                },
                0x2f => {
                    std.log.info("CMA\n", .{});
                    Instruction_CMA();
                },
                0x8f, 0x88, 0x89, 0x8a, 0x8b, 0x8c, 0x8d, 0x8e, 0xce => {
                    std.log.info("ADC\n", .{});
                    Instruction_ADC(m_byte);
                },
                else => {
                    CRASHED = true;
                    std.log.info("Emulator Crashed @ instruction : {any}", .{m_instructionCounter});
                },
            }

            m_instructionCounter += 1;
            if (m_instructionCounter >= half_instruction_per_frame) {
                if (INTERRUPT) {
                    // There are two interrupts that occur every frame (address $08 and $10)
                    if (interrupt_alternate == 0) {
                        CallInterrupt(0x08);
                    } else {
                        CallInterrupt(0x10);
                    }
                }
                interrupt_alternate = 1 - interrupt_alternate;
                m_instructionCounter = 0;
            }
        }
    }

    fn CallInterrupt(inAddress: u16) void {
        // Call the interrupt by pushing current PC on the stack and then jump to interrupt address
        INTERRUPT = false;
        StackPush(m_PC);
        m_PC = inAddress;
    }

    fn NOP() void {
        // No Operation - Do nothing !
        // std.log.info("NOP", .{});
    }

    fn Instruction_JMP(byte: u8) void {
        var data16: u16 = FetchRomShort();
        std.log.info("Instruction_JMP data16: {any}", .{data16});
        var m_condition = true;

        switch (byte) {
            0xc3 => {
                // Do nothing apart from incrementing the Programme Counter
            },
            0xc2 => {
                m_condition = ZERO != ZERO;
            },
            0xca => {
                m_condition = ZERO == ZERO;
            },
            0xd2 => {
                m_condition = CARRY != CARRY;
            },
            0xda => {
                m_condition = CARRY == CARRY;
            },
            0xf2 => {
                m_condition = SIGN != SIGN;
            },
            0xfa => {
                m_condition = SIGN == SIGN;
            },
            else => {},
        }
        if (m_condition) {
            m_PC = data16;
        }
    }

    fn Instruction_LXI(byte: u8) void {
        switch (byte) {
            0x00 => {
                SetBC(FetchRomShort());
            },
            0x11 => {
                SetDE(FetchRomShort());
            },
            0x21 => {
                SetHL(FetchRomShort());
            },
            0x31 => {
                SetSP(FetchRomShort());
            },
            else => {},
        }
    }

    fn Instruction_MVI(byte: u8) void {
        switch (byte) {
            0x3e => {
                SetA(FetchRomByte());
            },
            0x06 => {
                SetB(FetchRomByte());
            },
            0x0e => {
                SetC(FetchRomByte());
            },
            0x16 => {
                SetD(FetchRomByte());
            },
            0x1e => {
                SetE(FetchRomByte());
            },
            0x26 => {
                SetH(FetchRomByte());
            },
            0x2e => {
                SetL(FetchRomByte());
            },
            0x36 => {
                WriteByte(HL, FetchRomByte());
            },
            else => {},
        }
    }

    fn Instruction_CALL(byte: u8) void {
        var data16: u16 = FetchRomShort();
        var m_condition = true;
        switch (byte) {
            0xcd => {},
            0xc4 => {
                m_condition = ZERO != ZERO;
            },
            0xcc => {
                m_condition = ZERO == ZERO;
            },
            0xd4 => {
                m_condition = CARRY != CARRY;
            },
            0xdc => {
                m_condition = CARRY == CARRY;
            },
            else => {},
        }
        if (m_condition) {
            StackPush(m_PC);
            m_PC = data16;
        }
    }

    fn Instruction_LDA(byte: u8) void {
        switch (byte) {
            0x0a => {
                m_source = BC;
            },
            0x1a => {
                m_source = DE;
            },
            0x3a => {
                m_source = FetchRomShort();
            },
            else => {},
        }
        SetA(ReadByte(m_source));
    }

    fn Instruction_MOVHL(byte: u8) void {
        switch (byte) {
            0x77 => {
                WriteByte(HL, A);
            },
            0x70 => {
                WriteByte(HL, B);
            },
            0x71 => {
                WriteByte(HL, C);
            },
            0x72 => {
                WriteByte(HL, D);
            },
            0x73 => {
                WriteByte(HL, E);
            },
            0x74 => {
                WriteByte(HL, H);
            },
            0x75 => {
                WriteByte(HL, L);
            },
            else => {},
        }
    }

    fn Instruction_INX(byte: u8) void {
        switch (byte) {
            0x03 => {
                SetBC(BC + 1);
            },
            0x13 => {
                SetDE(DE + 1);
            },
            0x23 => {
                SetHL(HL + 1);
            },
            0x33 => {
                SetSP(SP + 1);
            },
            else => {},
        }
    }

    fn Instruction_DCX(byte: u8) void {
        switch (byte) {
            0x0b => {
                SetBC(BC - 1);
            },
            0x1b => {
                SetDE(DE - 1);
            },
            0x2b => {
                SetHL(HL - 1);
            },
            0x3b => {
                SetSP(SP - 1);
            },
            else => {},
        }
    }

    fn Instruction_DEC(byte: u8) void {
        switch (byte) {
            0x3d => {
                SetA(PerformDec(A));
            },
            0x05 => {
                SetB(PerformDec(B));
            },
            0x0d => {
                SetC(PerformDec(C));
            },
            0x15 => {
                SetD(PerformDec(D));
            },
            0x1d => {
                SetE(PerformDec(E));
            },
            0x25 => {
                SetH(PerformDec(H));
            },
            0x2d => {
                SetL(PerformDec(L));
            },
            0x35 => {
                WriteByte(HL, PerformDec(ReadByte(HL)));
            },
            else => {},
        }
    }

    fn Instruction_INC(byte: u8) void {
        switch (byte) {
            0x3c => {
                SetA(PerformInc(A));
            },
            0x04 => {
                SetB(PerformInc(B));
            },
            0x0c => {
                SetC(PerformInc(C));
            },
            0x14 => {
                SetD(PerformInc(D));
            },
            0x1c => {
                SetE(PerformInc(E));
            },
            0x24 => {
                SetH(PerformInc(H));
            },
            0x2c => {
                SetL(PerformInc(L));
            },
            0x34 => {
                WriteByte(HL, PerformInc(ReadByte(HL)));
            },
            else => {},
        }
    }

    fn Instruction_RET(byte: u8) void {
        var m_condition = true;
        switch (byte) {
            0xc9 => {},
            0xc0 => {
                m_condition = ZERO != ZERO;
            },
            0xc8 => {
                m_condition = ZERO == ZERO;
            },
            0xd0 => {
                m_condition = CARRY != CARRY;
            },
            0xd8 => {
                m_condition = CARRY == CARRY;
            },
            else => {},
        }
        if (m_condition) {
            m_PC = StackPop();
        }
    }

    fn Instruction_MOV(byte: u8) void {
        switch (byte) {
            0x7F => {
                SetA(A);
            },
            0x78 => {
                SetA(B);
            },
            0x79 => {
                SetA(C);
            },
            0x7A => {
                SetA(D);
            },
            0x7B => {
                SetA(E);
            },
            0x7C => {
                SetA(H);
            },
            0x7D => {
                SetA(L);
            },
            0x7E => {
                SetA(ReadByte(HL));
            },
            0x47 => {
                SetB(A);
            },
            0x40 => {
                SetB(B);
            },
            0x41 => {
                SetB(C);
            },
            0x42 => {
                SetB(D);
            },
            0x43 => {
                SetB(E);
            },
            0x44 => {
                SetB(H);
            },
            0x45 => {
                SetB(L);
            },
            0x46 => {
                SetB(ReadByte(HL));
            },
            0x4f => {
                SetC(A);
            },
            0x48 => {
                SetC(B);
            },
            0x49 => {
                SetC(C);
            },
            0x4a => {
                SetC(D);
            },
            0x4b => {
                SetC(E);
            },
            0x4c => {
                SetC(H);
            },
            0x4d => {
                SetC(L);
            },
            0x4e => {
                SetC(ReadByte(HL));
            },
            0x57 => {
                SetD(A);
            },
            0x50 => {
                SetD(B);
            },
            0x51 => {
                SetD(C);
            },
            0x52 => {
                SetD(D);
            },
            0x53 => {
                SetD(E);
            },
            0x54 => {
                SetD(H);
            },
            0x55 => {
                SetD(L);
            },
            0x56 => {
                SetD(ReadByte(HL));
            },
            0x5f => {
                SetE(A);
            },
            0x58 => {
                SetE(B);
            },
            0x59 => {
                SetE(C);
            },
            0x5a => {
                SetE(D);
            },
            0x5b => {
                SetE(E);
            },
            0x5c => {
                SetE(H);
            },
            0x5d => {
                SetE(L);
            },
            0x5e => {
                SetE(ReadByte(HL));
            },
            0x67 => {
                SetH(A);
            },
            0x60 => {
                SetH(B);
            },
            0x61 => {
                SetH(C);
            },
            0x62 => {
                SetH(D);
            },
            0x63 => {
                SetH(E);
            },
            0x64 => {
                SetH(H);
            },
            0x65 => {
                SetH(L);
            },
            0x66 => {
                SetH(ReadByte(HL));
            },
            0x6f => {
                SetL(A);
            },
            0x68 => {
                SetL(B);
            },
            0x69 => {
                SetL(C);
            },
            0x6a => {
                SetL(D);
            },
            0x6b => {
                SetL(E);
            },
            0x6c => {
                SetL(H);
            },
            0x6d => {
                SetL(L);
            },
            0x6e => {
                SetL(ReadByte(HL));
            },
            else => {},
        }
    }

    fn Instruction_CMP(byte: u8) void {
        switch (byte) {
            0xbf => {
                m_value = A;
            },
            0xb8 => {
                m_value = B;
            },
            0xb9 => {
                m_value = C;
            },
            0xba => {
                m_value = D;
            },
            0xbb => {
                m_value = E;
            },
            0xbc => {
                m_value = H;
            },
            0xbd => {
                m_value = L;
            },
            0xbe => {
                m_value = ReadByte(HL);
            },
            0xfe => {
                m_value = FetchRomByte();
            },
            else => {},
        }
        PerformCompSub(m_value);
    }

    fn Instruction_PUSH(byte: u8) void {
        switch (byte) {
            0xc5 => {
                m_value = @truncate(u8, BC);
            },
            0xd5 => {
                m_value = @truncate(u8, DE);
            },
            0xe5 => {
                m_value = @truncate(u8, HL);
            },
            0xf5 => {
                m_value = std.math.shl(u8, A, 8);
                if (SIGN == 1) {
                    m_value = (m_value | BIT7);
                }
                if (ZERO == 1) {
                    m_value = (m_value | BIT6);
                }
                if (INTERRUPT) {
                    m_value = (m_value | BIT5);
                }
                if (HALFCARRY == 1) {
                    m_value = (m_value | BIT4);
                }
                if (CARRY == 1) {
                    m_value = (m_value | BIT0);
                }
            },
            else => {},
        }
        StackPush(m_value);
    }

    fn Instruction_POP(byte: u8) void {
        var value = StackPop();
        switch (byte) {
            0xc1 => {
                SetBC(value);
            },
            0xd1 => {
                SetDE(value);
            },
            0xe1 => {
                SetHL(value);
            },
            0xf1 => {
                // A = (value >> 8);
                SIGN = @truncate(u1, (value & 0x80));
                ZERO = @truncate(u1, (value & 0x40));
                // INTERRUPT = Convert.ToBoolean(value & 0x20);
                HALFCARRY = @truncate(u1, (value & BIT4));
                CARRY = (value & BIT0);
            },
            else => {},
        }
    }

    fn Instruction_DAD(byte: u8) void {
        switch (byte) {
            0x09 => {
                AddHL(BC);
            },
            0x19 => {
                AddHL(DE);
            },
            0x29 => {
                AddHL(HL);
            },
            0x39 => {
                AddHL(SP);
            },
            else => {},
        }
    }

    fn Instruction_XCHG() void {
        var temp = DE;
        SetDE(HL);
        SetHL(temp);
    }

    fn Instruction_XTHL() void {
        var temp = H;
        SetH(ReadByte(SP + 1));
        WriteByte((SP + 1), temp);
        temp = L;
        SetL(ReadByte(SP));
        WriteByte(SP, temp);
    }

    fn Instruction_OUTP() void {
        // var port = FetchRomByte();
        // m_io.OutputPort(port, (byte)A);
    }

    fn Instruction_INP() void {
        // var port = FetchRomByte();
        // SetA(m_io.InputPort(port));
    }

    fn Instruction_PCHL() void {
        m_PC = HL;
    }

    fn Instruction_RST(byte: u8) void {
        var address: u16 = 0;
        switch (byte) {
            0xc7 => {
                address = 0x00;
            },
            0xcf => {
                address = 0x08;
            },
            0xd7 => {
                address = 0x10;
            },
            0xdf => {
                address = 0x18;
            },
            0xe7 => {
                address = 0x20;
            },
            0xef => {
                address = 0x28;
            },
            0xf7 => {
                address = 0x30;
            },
            0xff => {
                address = 0x38;
            },
            else => {},
        }
        StackPush(m_PC);
        m_PC = address;
    }

    fn Instruction_RLC() void {
        SetA(((A << 1) | (A >> 7)));
        // var temp = (A & 1);
        // bool testCarry = Convert.ToBoolean(temp);
        CARRY = (A & BIT0);
    }

    fn Instruction_RAL() void {
        var temp: u8 = A;
        SetA(A << 1);
        // if (Convert.ToBoolean(CARRY))
        // {
        //     SetA((ushort)(A | BIT0));
        // }

        CARRY = temp & 0x80;
    }

    fn Instruction_RRC() void {
        SetA(((A >> 1) | (A << 7)));
        CARRY = (A & BIT7);
    }

    fn Instruction_RAR() void {
        var temp = A;
        SetA((A >> 1));
        // if (Convert.ToBoolean(CARRY))
        // {
        //     SetA((ushort)(A | BIT7));
        // }
        CARRY = (temp & 1);
    }

    fn Instruction_AND(byte: u8) void {
        switch (byte) {
            0xa7 => {
                PerformAnd(A);
            },
            0xa0 => {
                PerformAnd(B);
            },
            0xa1 => {
                PerformAnd(C);
            },
            0xa2 => {
                PerformAnd(D);
            },
            0xa3 => {
                PerformAnd(E);
            },
            0xa4 => {
                PerformAnd(H);
            },
            0xa5 => {
                PerformAnd(L);
            },
            0xa6 => {
                PerformAnd(ReadByte(HL));
            },
            0xe6 => {
                var immediate = FetchRomByte();
                PerformAnd(immediate);
            },
            else => {},
        }
    }

    fn Instruction_ADD(byte: u8) void {
        switch (byte) {
            0x87 => {
                PerformByteAdd(A, 0);
            },
            0x80 => {
                PerformByteAdd(B, 0);
            },
            0x81 => {
                PerformByteAdd(C, 0);
            },
            0x82 => {
                PerformByteAdd(D, 0);
            },
            0x83 => {
                PerformByteAdd(E, 0);
            },
            0x84 => {
                PerformByteAdd(H, 0);
            },
            0x85 => {
                PerformByteAdd(L, 0);
            },
            0x86 => {
                PerformByteAdd(ReadByte(HL), 0);
            },
            0xc6 => {
                var immediate = FetchRomByte();
                PerformByteAdd(immediate, 0);
            },
            else => {},
        }
    }

    fn Instruction_STA(byte: u8) void {
        switch (byte) {
            0x02 => {
                WriteByte(BC, A);
            },
            0x12 => {
                WriteByte(DE, A);
            },
            0x32 => {
                var immediate = FetchRomShort();
                WriteByte(immediate, A);
            },
            else => {},
        }
    }

    fn Instruction_XOR(byte: u8) void {
        switch (byte) {
            0xaf => {
                PerformXor(A);
            },
            0xa8 => {
                PerformXor(B);
            },
            0xa9 => {
                PerformXor(C);
            },
            0xaa => {
                PerformXor(D);
            },
            0xab => {
                PerformXor(E);
            },
            0xac => {
                PerformXor(H);
            },
            0xad => {
                PerformXor(L);
            },
            0xae => {
                PerformXor(ReadByte(HL));
            },
            0xee => {
                var immediate = FetchRomByte();
                PerformXor(immediate);
            },
            else => {},
        }
    }

    fn Instruction_DI() void {
        INTERRUPT = false;
    }

    fn Instruction_EI() void {
        INTERRUPT = true;
    }

    fn Instruction_STC() void {
        CARRY = 1;
    }

    fn Instruction_CMC() void {
        CARRY = 0;
    }

    fn Instruction_OR(byte: u8) void {
        switch (byte) {
            0xb7 => {
                PerformOr(A);
            },
            0xb0 => {
                PerformOr(B);
            },
            0xb1 => {
                PerformOr(C);
            },
            0xb2 => {
                PerformOr(D);
            },
            0xb3 => {
                PerformOr(E);
            },
            0xb4 => {
                PerformOr(H);
            },
            0xb5 => {
                PerformOr(L);
            },
            0xb6 => {
                PerformOr(ReadByte(HL));
            },
            0xf6 => {
                var immediate = FetchRomByte();
                PerformOr(immediate);
            },
            else => {},
        }
    }

    fn Instruction_SUB(byte: u8) void {
        switch (byte) {
            0x97 => {
                PerformByteSub(A, 0);
            },
            0x90 => {
                PerformByteSub(B, 0);
            },
            0x91 => {
                PerformByteSub(C, 0);
            },
            0x92 => {
                PerformByteSub(D, 0);
            },
            0x93 => {
                PerformByteSub(E, 0);
            },
            0x94 => {
                PerformByteSub(H, 0);
            },
            0x95 => {
                PerformByteSub(L, 0);
            },
            0x96 => {
                PerformByteSub(ReadByte(HL), 0);
            },
            0xd6 => {
                var immediate = FetchRomByte();
                PerformByteSub(immediate, 0);
            },
            else => {},
        }
    }

    fn Instruction_LHLD() void {
        var immediate = FetchRomShort();
        SetHL(ReadShort(immediate));
    }

    fn Instruction_SHLD() void {
        var immediate = FetchRomShort();
        WriteShort(immediate, HL);
    }

    fn Instruction_SBBI() void {
        var immediate = FetchRomByte();
        var carryvalue: u8 = 0;
        // TO-DO check
        if (CARRY != 0) {
            carryvalue = 1;
        }
        PerformByteSub(immediate, carryvalue);
    }

    fn Instruction_DAA() void {
        // TO-DO check
        if (((A & 0x0F) > 9) or HALFCARRY != 0) {
            A += 0x06;
            HALFCARRY = 1;
        } else {
            HALFCARRY = 0;
        }
        // TO-DO check
        if ((A > 0x9F) or CARRY != 0) {
            A += 0x60;
            CARRY = 1;
        } else {
            CARRY = 0;
        }
        setFlagZeroSign();
    }

    fn Instruction_CMA() void {
        SetA(A ^ 0xff);
    }

    fn Instruction_ADC(byte: u8) void {
        var carryvalue: u8 = 0;
        if (CARRY != 0) {
            carryvalue = 1;
        }
        switch (byte) {
            0x8f => {
                PerformByteAdd(A, carryvalue);
            },
            0x88 => {
                PerformByteAdd(B, carryvalue);
            },
            0x89 => {
                PerformByteAdd(C, carryvalue);
            },
            0x8a => {
                PerformByteAdd(D, carryvalue);
            },
            0x8b => {
                PerformByteAdd(E, carryvalue);
            },
            0x8c => {
                PerformByteAdd(H, carryvalue);
            },
            0x8d => {
                PerformByteAdd(L, carryvalue);
            },
            0x8e => {
                PerformByteAdd(ReadByte(HL), carryvalue);
            },
            0xce => {
                var immediate = FetchRomByte();
                PerformByteAdd(immediate, carryvalue);
            },
            else => {},
        }
    }

    fn SetA(inByte: u8) void {
        A = inByte & 0xFF;
    }

    fn SetB(inByte: u8) void {
        B = inByte & 0xFF;
        BC = std.math.shl(u16, B, 8) | C;
    }

    fn SetC(inByte: u8) void {
        C = inByte & 0xFF;
        BC = std.math.shl(u16, B, 8) | C;
    }

    fn SetD(inByte: u8) void {
        D = inByte;
        DE = std.math.shl(u16, D, 8) + E;
    }

    fn SetE(inByte: u8) void {
        E = inByte;
        DE = std.math.shl(u16, D, 8) + E;
    }

    fn SetH(inByte: u8) void {
        H = inByte;
        HL = std.math.shl(u16, H, 8) + L;
    }

    fn SetL(inByte: u8) void {
        L = inByte;
        HL = std.math.shl(u16, H, 8) + L;
    }

    fn SetBC(inShort: u16) void {
        BC = inShort;
        B = @truncate(u8, (BC >> 8));
        C = @truncate(u8, (BC & 0xFF));
    }

    fn SetDE(inShort: u16) void {
        DE = inShort;
        D = @truncate(u8, (DE >> 8));
        E = @truncate(u8, (DE & 0xFF));
    }

    fn SetHL(inShort: u16) void {
        HL = inShort;
        H = @truncate(u8, (HL >> 8));
        L = @truncate(u8, (HL & 0xFF));
    }

    fn SetSP(inShort: u16) void {
        SP = inShort;
    }

    fn FetchRomByte() u8 {
        var value = m_rom[m_PC];
        std.log.info("FetchRomByte m_rom[m_PC]: {any}", .{value});
        m_PC += 1;
        std.log.info("FetchRomByte PC: {any}", .{m_PC});
        return value;
    }

    fn FetchRomShort() u16 {
        var bytes: [2]u8 = [_]u8{ 0, 0 };
        bytes[0] = m_rom[m_PC + 0];
        std.log.info("bytes[0]: {any}", .{bytes[0]});
        bytes[1] = m_rom[m_PC + 1];
        std.log.info("bytes[1]: {any}", .{bytes[1]});
        m_PC += 2;
        return std.math.shl(u16, (bytes[1] & 0xFF), 8) | (bytes[0] & 0xFF);
    }

    fn ReadByte(count: usize) u8 {
        std.log.info("Read Byte: {any}", .{m_rom[count]});
        return m_rom[count];
    }

    fn ReadShort(inAddress: u16) u16 {
        return std.math.shl(u8, m_rom[inAddress + 1], 8) + (m_rom[inAddress + 0]);
    }

    fn WriteShort(inAddress: u16, inWord: u16) void {
        m_rom[inAddress + 1] = @intCast(u8, inWord);
        m_rom[inAddress + 0] = @truncate(u8, inWord);
    }

    fn WriteByte(inAddress: u16, inByte: u8) void {
        m_rom[inAddress] = inByte;
    }

    fn StackPush(inValue: u16) void {
        std.log.info("Stack Pointer: {any}", .{SP});
        if (SP > 1) {
            SP -= 2;
            WriteShort(SP, inValue);
        }
    }

    fn StackPop() u16 {
        var temp = ReadShort(SP);
        SP += 2;
        return temp;
    }

    fn PerformDec(inSource: u8) u8 {
        var value = ((inSource - 1) & 0xFF);
        HALFCARRY = @truncate(u1, (value & 0x0F));
        ZERO = @boolToInt((value & 255) == 0);
        SIGN = @truncate(u1, (value & 128));
        return value;
    }

    fn PerformInc(inSource: u8) u8 {
        var value = inSource + 1;
        // HALFCARRY = @truncate(u1,((value & 0xF) < 0 | (value & 0xF) > 0));
        ZERO = @boolToInt((value & 255) == 0);
        SIGN = @truncate(u1, (value & 128));
        return value;
    }

    fn setFlagZeroSign() void {
        ZERO = @boolToInt(A == 0);
        SIGN = @truncate(u1, (A & 128));
    }

    fn PerformAnd(inValue: u8) void {
        SetA(A & inValue);
        CARRY = 0;
        HALFCARRY = 0;
        setFlagZeroSign();
    }

    fn PerformXor(inValue: u8) void {
        SetA(A ^ inValue);
        CARRY = 0;
        HALFCARRY = 0;
        setFlagZeroSign();
    }

    fn PerformOr(inValue: u8) void {
        SetA(A | inValue);
        CARRY = 0;
        HALFCARRY = 0;
        setFlagZeroSign();
    }

    fn PerformByteAdd(inValue: u8, inCarryValue: u8) void {
        var value = A + inValue + inCarryValue;
        HALFCARRY = @truncate(u1, (A ^ inValue ^ value) & 0x10);
        SetA(value);
        if (value > 255) {
            CARRY = 1;
        } else {
            CARRY = 0;
        }
        setFlagZeroSign();
    }

    fn PerformByteSub(inValue: u8, inCarryValue: u8) void {
        var value: u8 = (A - inValue - inCarryValue);
        if ((value >= A) and (inValue | inCarryValue) > 0) {
            CARRY = 1;
        } else {
            CARRY = 0;
        }
        HALFCARRY = @truncate(u1, (A ^ inValue ^ value) & 0x10);
        SetA(value);
        setFlagZeroSign();
    }

    fn PerformCompSub(inValue: u8) void {
        var value = (A - inValue) & 0xFF;
        if ((value >= A) and inValue != 0) {
            CARRY = inValue;
        } else {
            CARRY = 0;
        }
        HALFCARRY = @truncate(u1, ((A ^ inValue ^ value) & 0x10));
        ZERO = @boolToInt(value == 0);
        SIGN = @truncate(u1, (value & 128));
    }

    pub fn AddHL(inValue: u16) void {
        var value = HL + inValue;
        SetHL(value);
        CARRY = @boolToInt(value > 65535);
    }

    fn Reset() void {
        m_PC = 0;
        A = 0;
        BC = 0;
        DE = 0;
        HL = 0;
        SIGN = 0;
        ZERO = 0;
        HALFCARRY = 0;
        PARITY = false;
        CARRY = 0;
        INTERRUPT = false;
        CRASHED = false;
    }
};

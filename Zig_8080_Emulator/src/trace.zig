const std = @import("std");

pub const TraceEntry = struct {
    iteration: usize,
    opcode: [*:0]const u8,
    m_byte: u8,
    pc: u16,
    sp: u16,
    a: u8,
    b: u8,
    c: u8,
    d: u8,
    e: u8,
    h: u8,
    l: u8,
    bc: u16,
    de: u16,
    hl: u16,
    sign: u8,
    zero: u8,
    carry: u16,
    halfcarry: u16,
    parity: bool,
    interrupt: bool,
    memory: std.AutoHashMap(u16, u8),

    pub fn init(allocator: std.mem.Allocator, rom: []const u8) !TraceEntry {
        var memory = std.AutoHashMap(u16, u8).init(allocator);

        try memory.put(9206, rom[9206]);
        try memory.put(9207, rom[9207]);
        try memory.put(9210, rom[9210]);
        try memory.put(9211, rom[9211]);
        try memory.put(9212, rom[9212]);
        try memory.put(9213, rom[9213]);
        try memory.put(9214, rom[9214]);
        try memory.put(9215, rom[9215]);

        return .{
            .iteration = 0,
            .opcode = "",
            .m_byte = 0,
            .pc = 0,
            .sp = 0,
            .a = 0,
            .b = 0,
            .c = 0,
            .d = 0,
            .e = 0,
            .h = 0,
            .l = 0,
            .bc = 0,
            .de = 0,
            .hl = 0,
            .sign = 0,
            .zero = 0,
            .carry = 0,
            .halfcarry = 0,
            .parity = false,
            .interrupt = false,
            .memory = memory,
        };
    }

    pub fn deinit(self: *TraceEntry) void {
        self.memory.deinit();
    }

    pub fn write(
        self: TraceEntry,
        writer: *std.Io.Writer,
        rom: []const u8,
    ) !void {
        try writer.print(
            //  "Count={d} PC={X:0>4} Opcode={X:0>2} A={X:0>2} B={X:0>2} C={X:0>2}\n",
            "Iteration: {any}, Opcode: {s}, Byte: {any}, PC: {any}, SP: {any}, A: {any}, B: {any}, C: {any}, D: {any}, E: {any}, H: {any}, L: {any}, " ++
                "BC: {any}, DE: {any}, HL: {any}, SIGN: {any}, ZERO: {any}, HALFCARRY: {any}, PARITY: {any}, CARRY: {any}, INTERRUPT: {any}, " ++
                "9206: {any}, 9207: {any}, 9210: {any}, 9211: {any}, 9212: {any}, 9213: {any}, 9214: {any}, 9215: {any}\n",
            .{
                self.iteration, self.opcode, self.m_byte, self.pc,   self.sp,        self.a,      self.b,     self.c,         self.d,    self.e,    self.h,    self.l,    self.bc,
                self.de,        self.hl,     self.sign,   self.zero, self.halfcarry, self.parity, self.carry, self.interrupt, rom[9206], rom[9207], rom[9210], rom[9211], rom[9212],
                rom[9213],      rom[9214],   rom[9215],
            },
        );
    }
};

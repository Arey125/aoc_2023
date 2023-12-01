const std = @import("std");

fn getLine(buffer: []u8) !?[]u8 {
    const stdin = std.io.getStdIn().reader();
    return try stdin.readUntilDelimiterOrEof(buffer, '\n');
}

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    _ = stdin;
    const stdout = std.io.getStdOut().writer();
    _ = stdout;
}

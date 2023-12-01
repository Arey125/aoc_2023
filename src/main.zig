const std = @import("std");

fn getLine(buffer: []u8) !?[]u8 {
    const stdin = std.io.getStdIn().reader();
    return try stdin.readUntilDelimiterOrEof(buffer, '\n');
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var result: u32 = 0;

    var buffer: [1024]u8 = undefined;
    while (try getLine(&buffer)) |line| {
        result += for (line) |c| {
            if (std.ascii.isDigit(c))
                break (c - '0') * 10;
        } else 0;

        var second_digit: ?u32 = null;
        for (line) |c| {
            if (std.ascii.isDigit(c))
                second_digit = c - '0';
        }

        result += second_digit orelse 0;
    }

    try stdout.print("{}\n", .{result});
}

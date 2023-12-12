const std = @import("std");

const ParsingError = error{
    CharNotFound,
};

fn getLine(buffer: []u8) !?[]u8 {
    const stdin = std.io.getStdIn().reader();
    return try stdin.readUntilDelimiterOrEof(buffer, '\n');
}

const Node = struct {
    value: u32,
    left: u32,
    right: u32,
};

fn nodeNameToValue(name: []const u8) u32 {
    var res: u32 = 0;
    for (name) |c|
        res = (res * 26) + (c - 'A');
    return res;
}

fn parseNode(line: []const u8) !Node {
    const equalSignPos = std.mem.indexOf(u8, line, " = ") orelse return ParsingError.CharNotFound;
    const node_value = nodeNameToValue(line[0..equalSignPos]);

    const commaPos = std.mem.indexOf(u8, line, ",") orelse return ParsingError.CharNotFound;
    const left = nodeNameToValue(line[equalSignPos + 4 .. commaPos]);
    const right = nodeNameToValue(line[commaPos + 2 .. commaPos + 5]);

    return Node{ .value = node_value, .left = left, .right = right };
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    _ = stdout;

    var command_buffer: [1024]u8 = undefined;
    const commands = try getLine(&command_buffer);
    _ = commands;

    var node_buffer: [256]u8 = undefined;
    _ = try getLine(&node_buffer);
    while (try getLine(&node_buffer)) |line| {
        const node = try parseNode(line);
        std.debug.print("{x} {x} {x}\n", .{ node.value, node.left, node.right });
    }
}

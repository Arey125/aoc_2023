const std = @import("std");

const AppError = error{
    CharNotFound,
    NoCommands,
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
    const equalSignPos = std.mem.indexOf(u8, line, " = ") orelse return AppError.CharNotFound;
    const node_value = nodeNameToValue(line[0..equalSignPos]);

    const commaPos = std.mem.indexOf(u8, line, ",") orelse return AppError.CharNotFound;
    const left = nodeNameToValue(line[equalSignPos + 4 .. commaPos]);
    const right = nodeNameToValue(line[commaPos + 2 .. commaPos + 5]);

    return Node{ .value = node_value, .left = left, .right = right };
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var nodes: [26 * 26 * 26]Node = undefined;

    var command_buffer: [1024]u8 = undefined;
    const commands = try getLine(&command_buffer) orelse return AppError.NoCommands;

    var node_buffer: [256]u8 = undefined;
    _ = try getLine(&node_buffer);
    while (try getLine(&node_buffer)) |line| {
        const node = try parseNode(line);
        nodes[node.value] = node;
    }

    var step: u32 = 0;
    var currentNode: u32 = 0;
    while (currentNode != 26 * 26 * 26 - 1) {
        currentNode = if (commands[step % commands.len] == 'L')
            nodes[currentNode].left
        else
            nodes[currentNode].right;

        step += 1;
    }

    try stdout.print("{}\n", .{step});
}

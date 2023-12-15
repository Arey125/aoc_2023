const std = @import("std");
var gpa_struct = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_struct.allocator();

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

fn allOnZ(currentNodes: []u32) bool {
    for (currentNodes) |node| {
        if (node % 26 != 25) {
            return false;
        }
    }
    return true;
}

fn findCycleLen(position: u32, nodes: []Node, commands: []u8) !u32 {
    var iterations = try gpa.alloc(?u32, nodes.len * commands.len);
    for (iterations) |*pos| {
        pos.* = null;
    }

    var currentPosition = position;
    var step: u32 = 0;
    while (iterations[currentPosition + nodes.len * (step % commands.len)] == null) {
        if (currentPosition % 26 == 25) {
            std.log.debug("has a z in postion {}", .{step});
        }
        iterations[currentPosition + nodes.len * (step % commands.len)] = step;
        currentPosition = if (commands[step % commands.len] == 'L')
            nodes[currentPosition].left
        else
            nodes[currentPosition].right;
        step += 1;
    }

    std.log.debug("tail is {} nodes long", .{iterations[currentPosition + nodes.len * (step % commands.len)].?});
    std.log.debug("step number is {}", .{step});
    return step - iterations[currentPosition + nodes.len * (step % commands.len)].?;
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
    var currentNodes = std.ArrayList(u32).init(gpa);

    var command_buffer: [1024]u8 = undefined;
    const commands = try getLine(&command_buffer) orelse return AppError.NoCommands;

    var node_buffer: [256]u8 = undefined;
    _ = try getLine(&node_buffer);
    while (try getLine(&node_buffer)) |line| {
        const node = try parseNode(line);
        nodes[node.value] = node;

        if (node.value % 26 == 0) {
            try currentNodes.append(node.value);
        }
    }

    var step: u64 = 0;

    for (currentNodes.items) |node| {
        std.log.debug("{}", .{try findCycleLen(node, &nodes, commands)});
    }

    while (!allOnZ(currentNodes.items)) {
        for (currentNodes.items) |*currentNode| {
            currentNode.* = if (commands[step % commands.len] == 'L')
                nodes[currentNode.*].left
            else
                nodes[currentNode.*].right;
        }
        step += 1;
    }

    try stdout.print("{}\n", .{step});
}

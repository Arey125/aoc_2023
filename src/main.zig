const std = @import("std");
const page_allocator = std.heap.page_allocator;

fn getLine(buffer: []u8) !?[]u8 {
    const stdin = std.io.getStdIn().reader();
    return try stdin.readUntilDelimiterOrEof(buffer, '\n');
}

const Gear = struct {
    value: u32,
    numberCount: u32,
};

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    const input = try stdin.readAllAlloc(page_allocator, 2 << 30);
    const width = std.mem.indexOf(u8, input, "\n").? + 1;
    const height = std.mem.count(u8, input, "\n");

    var adjacent = try page_allocator.alloc(std.ArrayList(usize), input.len);
    for (adjacent) |*v|
        v.* = std.ArrayList(usize).init(page_allocator);
    defer page_allocator.free(adjacent);

    var gears = std.ArrayList(Gear).init(page_allocator);

    for (0..height) |y| {
        for (0..width) |x| {
            const c = input[x + width * y];
            if (c != '*') {
                continue;
            }
            try gears.append(Gear{ .value = 1, .numberCount = 0 });
            for (x -| 1..@min(x + 2, width)) |x_pos| {
                for (y -| 1..@min(y + 2, height)) |y_pos| {
                    try adjacent[x_pos + width * y_pos].append(gears.items.len - 1);
                }
            }
        }
    }

    var currentValue: u32 = 0;
    var currentGears = std.ArrayList(usize).init(page_allocator);

    for (0..height) |y| {
        for (0..width) |x| {
            const c = input[x + width * y];
            if (!std.ascii.isDigit(c)) {
                for (currentGears.items) |gear| {
                    gears.items[gear].value *= currentValue;
                    gears.items[gear].numberCount += 1;
                }
                currentValue = 0;
                currentGears.clearRetainingCapacity();
                continue;
            }
            currentValue = currentValue * 10 + (c - '0');
            outer: for (adjacent[x + width * y].items) |gear| {
                for (currentGears.items) |currentGear| {
                    if (currentGear == gear) {
                        break :outer;
                    }
                }
                try currentGears.append(gear);
            }
        }
    }
    var result: u32 = 0;
    for (gears.items) |gear| {
        if (gear.numberCount > 1)
            result += gear.value;
    }

    try stdout.print("{}\n", .{result});
}

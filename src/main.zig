const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // Check if help is requested or no arguments
    if (args.len < 2) {
        try printHelp();
        return;
    }

    if (std.mem.eql(u8, args[1], "--help") or std.mem.eql(u8, args[1], "-h")) {
        try printHelp();
        return;
    }

    // Parse the number
    const num = std.fmt.parseInt(u32, args[1], 10) catch {
        std.debug.print("Error: '{s}' is not a valid integer\n", .{args[1]});
        std.debug.print("Run 'zli-factor --help' for usage information\n", .{});
        std.process.exit(1);
    };

    // Check if number is within 6 digits (1 to 999999)
    if (num > 999999) {
        std.debug.print("Error: number/integer too large for current scope\n", .{});
        std.debug.print("Maximum allowed: 999999 (6 digits)\n", .{});
        std.process.exit(1);
    }

    if (num == 0 or num == 1) {
        std.debug.print("Number {d} has no factors (excluding 1 and itself)\n", .{num});
        return;
    }

    // Find all factors (excluding 1 and the number itself)
    var factors: std.ArrayList(u32) = .empty;
    defer factors.deinit(allocator);

    var i: u32 = 2;
    while (i * i <= num) : (i += 1) {
        if (num % i == 0) {
            try factors.append(allocator, i);
            const other = num / i;
            if (other != i and other != num) {
                try factors.append(allocator, other);
            }
        }
    }

    // Sort factors
    std.mem.sort(u32, factors.items, {}, comptime std.sort.asc(u32));

    // Check if prime
    if (factors.items.len == 0) {
        std.debug.print("✨ {d} is PRIME! ✨\n", .{num});
        std.debug.print("A prime number is only divisible by 1 and itself - how special!\n", .{});
        return;
    }

    // Print factors
    std.debug.print("Factors of {d} (excluding 1 and {d}):\n", .{ num, num });
    for (factors.items) |factor| {
        std.debug.print("  {d}\n", .{factor});
    }
}

fn printHelp() !void {
    std.debug.print(
        \\zli-factor - A simple integer factorization tool
        \\
        \\USAGE:
        \\  zli-factor <number>
        \\  zli-factor --help
        \\
        \\DESCRIPTION:
        \\  Displays all factors of a given integer (excluding 1 and the number itself).
        \\  Supports numbers up to 6 digits (999,999).
        \\  Detects and celebrates prime numbers!
        \\
        \\EXAMPLES:
        \\  zli-factor 6565       # List factors of 6565
        \\  zli-factor 17         # Detects that 17 is prime
        \\  zli-factor 100        # Shows: 2, 4, 5, 10, 20, 25, 50
        \\
        \\OPTIONS:
        \\  -h, --help            Show this help message
        \\
    , .{});
}

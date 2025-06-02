const std = @import("std");
const builtin = @import("builtin");

/// In `ReleaseFast` and `ReleaseSmall` builds: It is **undefined behavior**.
///
/// In `Debug` and `ReleaseSafe` builds: Panics with an error message defined by `fail_fmt` and `fail_fmt_args`.
///
/// In `comptime`: This function evaluates to a `@compileError(...)` with an error message defined by `fail_fmt` and `fail_fmt_args`.
pub fn fail(comptime fail_fmt: []const u8, fail_fmt_args: anytype) void {
    if (@inComptime()) {
        @compileError(std.fmt.comptimePrint(fail_fmt, fail_fmt_args));
    } else if (builtin.mode == .Debug or builtin.mode == .ReleaseSafe) {
        std.debug.panic(fail_fmt, fail_fmt_args);
    } else {
        unreachable; // Undefined behavior
    }
}

/// In `ReleaseFast` and `ReleaseSmall` builds: If `ok` is `false`, it is **undefined behavior**.
///
/// In `Debug` and `ReleaseSafe` builds: If `ok` is `false`, panics with an error message defined by `fail_fmt` and `fail_fmt_args`.
///
/// In `comptime`: If `ok` is `false`, this function evaluates to a `@compileError(...)` with an error message defined by `fail_fmt` and `fail_fmt_args`.
///
/// This function is basically `std.debug.assert`, but with custom assertion failed message.
pub fn assert(ok: bool, comptime fail_fmt: []const u8, fail_fmt_args: anytype) void {
    if (@inComptime()) {
        if (!ok) @compileError(std.fmt.comptimePrint(fail_fmt, fail_fmt_args));
    } else if (builtin.mode == .Debug or builtin.mode == .ReleaseSafe) {
        if (!ok) std.debug.panic(fail_fmt, fail_fmt_args);
    } else {
        if (!ok) unreachable; // Undefined behavior
    }
}

pub fn assertEql(comptime T: type, lhs: T, rhs: T) void {
    assert(
        lhs == rhs,
        "`ghdbg.assertEql({}, {}, {})` failed: {} != {}.",
        .{ T, lhs, rhs, lhs, rhs },
    );
}

pub fn assertNotEql(comptime T: type, lhs: T, rhs: T) void {
    assert(
        lhs != rhs,
        "`ghdbg.assertNotEql({}, {}, {})` failed: {} == {}.",
        .{ T, lhs, rhs, lhs, rhs },
    );
}

pub fn assertGreaterThan(comptime T: type, lhs: T, rhs: T) void {
    assert(
        lhs > rhs,
        "`ghdbg.assertGreaterThan({}, {d}, {d})` failed: {d} <= {d}.",
        .{ T, lhs, rhs, lhs, rhs },
    );
}

pub fn assertLessThan(comptime T: type, lhs: T, rhs: T) void {
    assert(
        lhs < rhs,
        "`ghdbg.assertLessThan({}, {d}, {d})` failed: {d} >= {d}.",
        .{ T, lhs, rhs, lhs, rhs },
    );
}

pub fn assertGreaterThanOrEql(comptime T: type, lhs: T, rhs: T) void {
    assert(
        lhs >= rhs,
        "`ghdbg.assertGreaterThanOrEql({}, {d}, {d})` failed: {d} < {d}.",
        .{ T, lhs, rhs, lhs, rhs },
    );
}

pub fn assertLessThanOrEql(comptime T: type, lhs: T, rhs: T) void {
    assert(
        lhs <= rhs,
        "`ghdbg.assertLessThanOrEql({}, {d}, {d})` failed: {d} > {d}.",
        .{ T, lhs, rhs, lhs, rhs },
    );
}

pub fn assertIncludes(comptime T: type, slice: []const T, item: T) void {
    for (slice) |element| {
        if (element == item) return;
    }

    fail(
        "`ghdbg.assertIncludes(T: {}, slice: {}, item: {})` failed: `slice` does not include `item`.",
        .{ T, slice, item },
    );
}

pub fn assertNotIncludes(comptime T: type, slice: []const T, item: T) void {
    for (slice) |element| {
        if (element == item) fail(
            "`ghdbg.assertNotIncludes(T: {}, slice: {}, item: {})` failed: `slice` includes `item`.",
            .{ T, slice, item },
        );
    }
}

pub fn assertNoDuplicates(comptime T: type, slice: []const T) void {
    for (0..slice.len) |x| {
        for (0..slice.len) |y| {
            if (x == y) continue;

            if (slice[x] == slice[y]) fail(
                "`ghdbg.assertNoDuplicates(T: {}, slice: {})` failed: Duplicate {} at indices {} and {}.",
                .{ T, slice, slice[x], x, y },
            );
        }
    }
}

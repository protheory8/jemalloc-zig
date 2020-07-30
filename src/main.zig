const std = @import("std");
const testing = std.testing;
const debug = std.debug;
const mem = std.mem;
const Allocator = mem.Allocator;
const c = @cImport(@cInclude("jemalloc_zig_macro_glue.h"));

pub export const jemalloc_allocator: *Allocator = &jemalloc_allocator_state;
var jemalloc_allocator_state = Allocator{
    .allocFn = jemallocAllocFn,
    .resizeFn = jemallocResizeFn,
};

fn jemallocAllocFn(self: *Allocator, len: usize, ptr_align: u29, len_align: u29) Allocator.Error![]u8 {
    var ptr: [*]u8 = undefined;
    if (ptr_align <= @alignOf(c_longdouble) and ptr_align <= len) {
        ptr = @ptrCast([*]u8, c.malloc(len) orelse return error.OutOfMemory);
    } else {
        ptr = @ptrCast([*]u8, c.mallocx(len, c.jemalloc_mallocx_align_fn(ptr_align)) orelse return error.OutOfMemory);
    }

    if (len_align == 0) {
        return ptr[0..len];
    }

    const full_len = c.malloc_usable_size(ptr);
    debug.assert(full_len >= len);
    return ptr[0..mem.alignBackwardAnyAlign(full_len, len_align)];
}

fn jemallocResizeFn(self: *Allocator, buf: []u8, new_len: usize, len_align: u29) Allocator.Error!usize {
    if (new_len == 0) {
        c.free(buf.ptr);
        return 0;
    }

    if (new_len <= buf.len) {
        return mem.alignAllocLen(buf.len, new_len, len_align);
    }

    const full_len = c.malloc_usable_size(buf.ptr);
    if (new_len <= full_len) {
        return mem.alignAllocLen(full_len, new_len, len_align);
    }

    return error.OutOfMemory;
}

test "allocate memory and free" {
    const TestStruct = struct {
        title: []const u8,
        width: i32,
        height: i32,
        index: usize,
    };
    
    const memory: []TestStruct = jemalloc_allocator.alloc(TestStruct, 1) catch @panic("test failure");
    jemalloc_allocator.free(memory);
}

test "allocate memory, use it and free" {
    const TestStruct = struct {
        width: i32,
        height: i32,
        title: []const u8,
        index: usize,
    };
    
    const memory: []TestStruct = jemalloc_allocator.alloc(TestStruct, 1) catch @panic("test failure");

    memory[0] = TestStruct{
        .width = 1280,
        .height = 720,
        .title = "Should work fine!",
        .index = 12,
    };

    testing.expect(memory[0].width == 1280);
    testing.expect(memory[0].height == 720);
    testing.expect(memory[0].index == 12);

    jemalloc_allocator.free(memory);
}

test "allocate memory, use it, reallocate memory, use it and free" {
    const TestStruct = struct {
        width: i32,
        height: i32,
        title: []const u8,
        index: usize,
    };

    var memory: []TestStruct = jemalloc_allocator.alloc(TestStruct, 2) catch @panic("test failure");

    memory[0] = TestStruct{
        .width = 1280,
        .height = 720,
        .title = "Should work fine!",
        .index = 12,
    };

    memory[1] = TestStruct{
        .width = 1230,
        .height = 820,
        .title = "Cool game",
        .index = 120,
    };

    memory = jemalloc_allocator.realloc(memory, 4) catch @panic("test failure");

    memory[2] = TestStruct{
        .width = 12612,
        .height = 45,
        .title = "Window title",
        .index = 31,
    };

    memory[3] = TestStruct{
        .width = 125,
        .height = 1,
        .title = "Game title",
        .index = 21,
    };

    testing.expect(memory[0].width == 1280);
    testing.expect(memory[0].height == 720);
    testing.expect(memory[0].index == 12);

    testing.expect(memory[1].width == 1230);
    testing.expect(memory[1].height == 820);
    testing.expect(memory[1].index == 120);

    testing.expect(memory[2].width == 12612);
    testing.expect(memory[2].height == 45);
    testing.expect(memory[2].index == 31);

    testing.expect(memory[3].width == 125);
    testing.expect(memory[3].height == 1);
    testing.expect(memory[3].index == 21);

    jemalloc_allocator.free(memory);
}

const std = @import("std");
const mem = std.mem;
const math = std.math;
const assert = std.debug.assert;
const Allocator = mem.Allocator;
const c = @cImport(@cInclude("jemalloc_zig_glue.h"));

pub export const jemalloc_allocator: *Allocator = &jemalloc_allocator_state;
var jemalloc_allocator_state = Allocator{
    .allocFn = jemallocAllocFn,
    .resizeFn = jemallocResizeFn,
};

fn jemallocAllocFn(self: *Allocator, len: usize, ptr_align: u29, len_align: u29, ret_addr: usize) Allocator.Error![]u8 {
    assert(len > 0);
    assert(ptr_align > 0);
    assert(math.isPowerOfTwo(ptr_align));

    var ptr: [*]u8 = @ptrCast([*]u8, c.mallocx(len, c.jemalloc_mallocx_align_fn(ptr_align)) orelse return error.OutOfMemory);
    if (len_align == 0) {
        return ptr[0..len];
    }

    const full_len = c.malloc_usable_size(ptr);
    return ptr[0..mem.alignBackwardAnyAlign(full_len, len_align)];
}

fn jemallocResizeFn(self: *Allocator, buf: []u8, buf_align: u29, new_len: usize, len_align: u29, ret_addr: usize) Allocator.Error!usize {
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

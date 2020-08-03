const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;
const c = @cImport(@cInclude("jemalloc_zig_glue.h"));

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

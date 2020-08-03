#ifndef __JEMALLOC_ZIG_GLUE_H__
#define __JEMALLOC_ZIG_GLUE_H__

#include <jemalloc/jemalloc.h>
#include <stddef.h>
#include <stdalign.h>

size_t get_align_of_max_align_t() {
    return alignof(max_align_t);
}

int jemalloc_mallocx_align_fn(size_t a) {
    return MALLOCX_ALIGN(a);
}

#endif

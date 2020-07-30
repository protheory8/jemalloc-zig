#ifndef __JEMALLOC_ZIG_MACRO_GLUE_H__
#define __JEMALLOC_ZIG_MACRO_GLUE_H__

#include <jemalloc/jemalloc.h>

int jemalloc_mallocx_align_fn(size_t a) {
    return MALLOCX_ALIGN(a);
}

#endif

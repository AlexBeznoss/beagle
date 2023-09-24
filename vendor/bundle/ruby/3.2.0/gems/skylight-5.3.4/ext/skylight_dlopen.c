#include "skylight_dlopen.h"
#include "dlfcn.h"

sky_main_fn sky_main = 0;
sky_init_fn sky_init = 0;
sky_hrtime_fn sky_hrtime = 0;
sky_instrumenter_new_fn sky_instrumenter_new = 0;
sky_instrumenter_start_fn sky_instrumenter_start = 0;
sky_instrumenter_stop_fn sky_instrumenter_stop = 0;
sky_instrumenter_submit_trace_fn sky_instrumenter_submit_trace = 0;
sky_instrumenter_free_fn sky_instrumenter_free = 0;
sky_trace_new_fn sky_trace_new = 0;
sky_trace_free_fn sky_trace_free = 0;
sky_trace_start_fn sky_trace_start = 0;
sky_trace_endpoint_fn sky_trace_endpoint = 0;
sky_trace_set_endpoint_fn sky_trace_set_endpoint = 0;
sky_trace_component_fn sky_trace_component = 0;
sky_trace_set_component_fn sky_trace_set_component = 0;
sky_trace_use_pruning_fn sky_trace_use_pruning = 0;
sky_trace_uuid_fn sky_trace_uuid = 0;
sky_trace_set_uuid_fn sky_trace_set_uuid = 0;
sky_trace_instrument_fn sky_trace_instrument = 0;
sky_trace_span_get_category_fn sky_trace_span_get_category = 0;
sky_trace_span_set_title_fn sky_trace_span_set_title = 0;
sky_trace_span_get_title_fn sky_trace_span_get_title = 0;
sky_trace_span_set_desc_fn sky_trace_span_set_desc = 0;
sky_trace_span_add_uint_annotation_fn sky_trace_span_add_uint_annotation = 0;
sky_trace_span_add_string_annotation_fn sky_trace_span_add_string_annotation = 0;
sky_trace_span_done_fn sky_trace_span_done = 0;

#define BIND_FN(SRC, DST)           \
  do {                             \
    fnptr = dlsym(SRC, #DST);       \
    if (!fnptr) {                  \
      return -1;                    \
    }                              \
    *(void**) (&DST) = fnptr;       \
  } while(0)

// Loads libskylight at the specified file location and binds the function
// pointers.
int sky_load_libskylight(const char* filename) {
    void* fnptr;
    void* libskylight;

    if (sky_init != 0) {
        return 0;
    }

    libskylight = dlopen(filename, RTLD_NOW | RTLD_LOCAL);

    if (!libskylight) {
        return -1;
    }

    BIND_FN(libskylight, sky_main);
    BIND_FN(libskylight, sky_init);
    BIND_FN(libskylight, sky_hrtime);
    BIND_FN(libskylight, sky_instrumenter_new);
    BIND_FN(libskylight, sky_instrumenter_start);
    BIND_FN(libskylight, sky_instrumenter_stop);
    BIND_FN(libskylight, sky_instrumenter_submit_trace);
    BIND_FN(libskylight, sky_instrumenter_free);
    BIND_FN(libskylight, sky_trace_new);
    BIND_FN(libskylight, sky_trace_free);
    BIND_FN(libskylight, sky_trace_start);
    BIND_FN(libskylight, sky_trace_endpoint);
    BIND_FN(libskylight, sky_trace_set_endpoint);
    BIND_FN(libskylight, sky_trace_component);
    BIND_FN(libskylight, sky_trace_set_component);
    BIND_FN(libskylight, sky_trace_use_pruning);
    BIND_FN(libskylight, sky_trace_uuid);
    BIND_FN(libskylight, sky_trace_set_uuid);
    BIND_FN(libskylight, sky_trace_instrument);
    BIND_FN(libskylight, sky_trace_span_get_category);
    BIND_FN(libskylight, sky_trace_span_set_title);
    BIND_FN(libskylight, sky_trace_span_get_title);
    BIND_FN(libskylight, sky_trace_span_set_desc);
    BIND_FN(libskylight, sky_trace_span_add_uint_annotation);
    BIND_FN(libskylight, sky_trace_span_add_string_annotation);
    BIND_FN(libskylight, sky_trace_span_done);

    sky_init();

    return 0;
}

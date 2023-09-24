#ifndef __SKYLIGHT_H__
#define __SKYLIGHT_H__

#include "stddef.h"
#include "stdint.h"

/*
 *
 * ===== Skylight types =====
 *
 */

typedef struct {
    void* data;
    size_t len;
} sky_buf_t;

typedef void sky_instrumenter_t;
typedef void sky_trace_t;


/*
 *
 * ====== Skylight functions =====
 *
 */

int sky_load_libskylight(const char* filename);
typedef int (*sky_main_fn)(int argc, char** argv);
typedef int (*sky_init_fn)();
typedef uint64_t (*sky_hrtime_fn)();
typedef int (*sky_instrumenter_new_fn)(sky_buf_t id, sky_buf_t* env, int envc, sky_instrumenter_t** out);
typedef int (*sky_instrumenter_start_fn)(const sky_instrumenter_t* inst);
typedef int (*sky_instrumenter_stop_fn)(sky_instrumenter_t* inst);
typedef int (*sky_instrumenter_submit_trace_fn)(const sky_instrumenter_t* inst, sky_trace_t* trace);
typedef void (*sky_instrumenter_free_fn)(sky_instrumenter_t* val);
typedef int (*sky_trace_new_fn)(uint64_t start, sky_buf_t uuid, sky_buf_t endpoint, sky_trace_t** out);
typedef void (*sky_trace_free_fn)(sky_trace_t* val);
typedef int (*sky_trace_start_fn)(sky_trace_t* trace, uint64_t* out);
typedef int (*sky_trace_endpoint_fn)(sky_trace_t* trace, sky_buf_t* out);
typedef int (*sky_trace_set_endpoint_fn)(const sky_trace_t* trace, sky_buf_t endpoint);
typedef int (*sky_trace_component_fn)(sky_trace_t* trace, sky_buf_t* out);
typedef int (*sky_trace_set_component_fn)(const sky_trace_t* trace, sky_buf_t component);
typedef int (*sky_trace_use_pruning_fn)(const sky_trace_t* trace);
typedef int (*sky_trace_uuid_fn)(sky_trace_t* trace, sky_buf_t* out);
typedef int (*sky_trace_set_uuid_fn)(const sky_trace_t* trace, sky_buf_t uuid);
typedef int (*sky_trace_instrument_fn)(const sky_trace_t* trace, uint64_t time, sky_buf_t category, uint32_t* out);
typedef int (*sky_trace_span_get_category_fn)(sky_trace_t* trace, uint32_t handle, sky_buf_t* out);
typedef int (*sky_trace_span_set_title_fn)(const sky_trace_t* trace, uint32_t handle, sky_buf_t title);
typedef int (*sky_trace_span_get_title_fn)(sky_trace_t* trace, uint32_t handle, sky_buf_t* out);
typedef int (*sky_trace_span_set_desc_fn)(const sky_trace_t* trace, uint32_t handle, sky_buf_t desc);
typedef int (*sky_trace_span_add_uint_annotation_fn)(const sky_trace_t* trace, uint32_t handle, uint32_t key, uint64_t value);
typedef int (*sky_trace_span_add_string_annotation_fn)(const sky_trace_t* trace, uint32_t handle, uint32_t key, sky_buf_t value);
typedef int (*sky_trace_span_done_fn)(const sky_trace_t* trace, uint32_t handle, uint64_t time);

extern sky_main_fn sky_main;
extern sky_init_fn sky_init;
extern sky_hrtime_fn sky_hrtime;
extern sky_instrumenter_new_fn sky_instrumenter_new;
extern sky_instrumenter_start_fn sky_instrumenter_start;
extern sky_instrumenter_stop_fn sky_instrumenter_stop;
extern sky_instrumenter_submit_trace_fn sky_instrumenter_submit_trace;
extern sky_instrumenter_free_fn sky_instrumenter_free;
extern sky_trace_new_fn sky_trace_new;
extern sky_trace_free_fn sky_trace_free;
extern sky_trace_start_fn sky_trace_start;
extern sky_trace_endpoint_fn sky_trace_endpoint;
extern sky_trace_set_endpoint_fn sky_trace_set_endpoint;
extern sky_trace_component_fn sky_trace_component;
extern sky_trace_set_component_fn sky_trace_set_component;
extern sky_trace_use_pruning_fn sky_trace_use_pruning;
extern sky_trace_uuid_fn sky_trace_uuid;
extern sky_trace_set_uuid_fn sky_trace_set_uuid;
extern sky_trace_instrument_fn sky_trace_instrument;
extern sky_trace_span_get_category_fn sky_trace_span_get_category;
extern sky_trace_span_set_title_fn sky_trace_span_set_title;
extern sky_trace_span_get_title_fn sky_trace_span_get_title;
extern sky_trace_span_set_desc_fn sky_trace_span_set_desc;
extern sky_trace_span_add_uint_annotation_fn sky_trace_span_add_uint_annotation;
extern sky_trace_span_add_string_annotation_fn sky_trace_span_add_string_annotation;
extern sky_trace_span_done_fn sky_trace_span_done;

#endif

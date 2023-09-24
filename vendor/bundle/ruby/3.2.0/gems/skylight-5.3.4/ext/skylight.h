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
int sky_main(int argc, char** argv);
int sky_init();
uint64_t sky_hrtime();
int sky_instrumenter_new(sky_buf_t id, sky_buf_t* env, int envc, sky_instrumenter_t** out);
int sky_instrumenter_start(const sky_instrumenter_t* inst);
int sky_instrumenter_stop(sky_instrumenter_t* inst);
int sky_instrumenter_submit_trace(const sky_instrumenter_t* inst, sky_trace_t* trace);
void sky_instrumenter_free(sky_instrumenter_t* val);
int sky_trace_new(uint64_t start, sky_buf_t uuid, sky_buf_t endpoint, sky_trace_t** out);
void sky_trace_free(sky_trace_t* val);
int sky_trace_start(sky_trace_t* trace, uint64_t* out);
int sky_trace_endpoint(sky_trace_t* trace, sky_buf_t* out);
int sky_trace_set_endpoint(const sky_trace_t* trace, sky_buf_t endpoint);
int sky_trace_component(sky_trace_t* trace, sky_buf_t* out);
int sky_trace_set_component(const sky_trace_t* trace, sky_buf_t component);
int sky_trace_use_pruning(const sky_trace_t* trace);
int sky_trace_uuid(sky_trace_t* trace, sky_buf_t* out);
int sky_trace_set_uuid(const sky_trace_t* trace, sky_buf_t uuid);
int sky_trace_instrument(const sky_trace_t* trace, uint64_t time, sky_buf_t category, uint32_t* out);
int sky_trace_span_get_category(sky_trace_t* trace, uint32_t handle, sky_buf_t* out);
int sky_trace_span_set_title(const sky_trace_t* trace, uint32_t handle, sky_buf_t title);
int sky_trace_span_get_title(sky_trace_t* trace, uint32_t handle, sky_buf_t* out);
int sky_trace_span_set_desc(const sky_trace_t* trace, uint32_t handle, sky_buf_t desc);
int sky_trace_span_add_uint_annotation(const sky_trace_t* trace, uint32_t handle, uint32_t key, uint64_t value);
int sky_trace_span_add_string_annotation(const sky_trace_t* trace, uint32_t handle, uint32_t key, sky_buf_t value);
int sky_trace_span_done(const sky_trace_t* trace, uint32_t handle, uint64_t time);

#endif

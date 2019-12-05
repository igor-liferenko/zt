@ @c
#include "freetdm.h"

#if !defined(_XOPEN_SOURCE)
#define _XOPEN_SOURCE 600
#endif

#ifndef HAVE_STRINGS_H
#define HAVE_STRINGS_H 1
#endif
#ifndef HAVE_SYS_SOCKET_H
#define HAVE_SYS_SOCKET_H 1
#endif

#define FTDM_THREAD_STACKSIZE 240 * 1024
#define FTDM_ENUM_NAMES(_NAME, _STRINGS) static const char * _NAME [] = { _STRINGS , NULL };
	
#define ftdm_true(expr)							\
	(expr && ( !strcasecmp(expr, "yes") ||		\
			   !strcasecmp(expr, "on") ||		\
			   !strcasecmp(expr, "true") ||		\
			   !strcasecmp(expr, "enabled") ||	\
			   !strcasecmp(expr, "active") ||	\
			   atoi(expr))) ? FTDM_TRUE : FTDM_FALSE

#include <time.h>
#include <sys/time.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef HAVE_STRINGS_H
#include <strings.h>
#endif
#include <assert.h>

#include "ftdm_types.h"
#include "hashtable.h"
#include "ftdm_config.h"
#include "g711.h"
#include "libteletone.h"
#include "ftdm_buffer.h"
#include "ftdm_threadmutex.h"
#include "ftdm_sched.h"
#include "ftdm_call_utils.h"

#define SPAN_PENDING_CHANS_QUEUE_SIZE 1000
#define SPAN_PENDING_SIGNALS_QUEUE_SIZE 1000

#define GOTO_STATUS(label,st) status = st; goto label ;

#define ftdm_copy_string(x,y,z) strncpy(x, y, z - 1) 

#define ftdm_strlen_zero(s) (!s || *s == '\0')
#define ftdm_strlen_zero_buf(s) (*s == '\0')


@ Test for the existance of a flag on an arbitary object.
Returns true if the object has the flags defined.
{\settabs\+\hskip100pt&\cr
\+\.{obj}& the object to test\cr
\+\.{flag}& the or'd list of flags to test\cr
}

@c
#define ftdm_test_flag(obj, flag) ((obj)->flags & flag)
#define ftdm_test_pflag(obj, flag) ((obj)->pflags & flag) /* Physical (IO) module specific flags */
#define ftdm_test_sflag(obj, flag) ((obj)->sflags & flag) /* signaling module specific flags */

#define ftdm_set_alarm_flag(obj, flag) (obj)->alarm_flags |= (flag)
#define ftdm_clear_alarm_flag(obj, flag) (obj)->alarm_flags &= ~(flag)
#define ftdm_test_alarm_flag(obj, flag) ((obj)->alarm_flags & flag)

#define ftdm_set_io_flag(obj, flag) (obj)->io_flags |= (flag)
#define ftdm_clear_io_flag(obj, flag) (obj)->io_flags &= ~(flag)
#define ftdm_test_io_flag(obj, flag) ((obj)->io_flags & flag)

@ Set a flag on an arbitrary object.
{\settabs\+\hskip100pt&\cr
\+\.{obj}& the object to set the flags on\cr
\+\.{flag}& the or'd list of flags to set\cr
}

@c
#define ftdm_set_flag(obj, flag) (obj)->flags |= (flag)
#define ftdm_set_flag_locked(obj, flag) assert(obj->mutex != NULL); \
	ftdm_mutex_lock(obj->mutex); \
	(obj)->flags |= (flag);      \
	ftdm_mutex_unlock(obj->mutex);

#define ftdm_set_pflag(obj, flag) (obj)->pflags |= (flag)
#define ftdm_set_pflag_locked(obj, flag) assert(obj->mutex != NULL);	\
	ftdm_mutex_lock(obj->mutex); \
	(obj)->pflags |= (flag); \
	ftdm_mutex_unlock(obj->mutex);

#define ftdm_set_sflag(obj, flag) (obj)->sflags |= (flag)
#define ftdm_set_sflag_locked(obj, flag) assert(obj->mutex != NULL);	\
	ftdm_mutex_lock(obj->mutex); \
	(obj)->sflags |= (flag); \
	ftdm_mutex_unlock(obj->mutex);

/*!
  \brief Clear a flag on an arbitrary object while locked
  \command obj the object to test
  \command flag the or'd list of flags to clear
*/
#define ftdm_clear_flag(obj, flag) (obj)->flags &= ~(flag)

#define ftdm_clear_flag_locked(obj, flag) assert(obj->mutex != NULL); \
  ftdm_mutex_lock(obj->mutex); (obj)->flags &= ~(flag); ftdm_mutex_unlock(obj->mutex);

#define ftdm_clear_pflag(obj, flag) (obj)->pflags &= ~(flag)

#define ftdm_clear_sflag(obj, flag) (obj)->sflags &= ~(flag)

/* this macro assumes obj is locked! */
#define ftdm_wait_for_flag_cleared(obj, flag, time) 					\
	do {										\
		int __safety = time;							\
		while(__safety-- && ftdm_test_flag(obj, flag)) { 			\
			ftdm_mutex_unlock(obj->mutex);					\
			ftdm_sleep(10);							\
			ftdm_mutex_lock(obj->mutex);					\
		}									\
		if(!__safety) {								\
			ftdm_log(FTDM_LOG_CRIT, "flag %"FTDM_UINT64_FMT" was never cleared\n", (uint64_t)flag);	\
		}									\
	} while(0);

#define ftdm_print_stack(level) \
	do { \
		void *__stacktrace[100] = { 0 }; \
		char **__symbols = NULL; \
		int __size = 0; \
		int __i = 0; \
		__size = backtrace(__stacktrace, ftdm_array_len(__stacktrace)); \
		__symbols = backtrace_symbols(__stacktrace, __size); \
		if (__symbols) { \
			for (__i = 0; __i < __size; __i++) { \
				ftdm_log(__level, "%s\n", __symbols[i]); \
			} \
		free(__symbols); \
		} \
	} while (0);


struct ftdm_stream_handle {
	ftdm_stream_handle_write_function_t write_function;
	ftdm_stream_handle_raw_write_function_t raw_write_function;
	void *data;
	void *end;
	ftdm_size_t data_size;
	ftdm_size_t data_len;
	ftdm_size_t alloc_len;
	ftdm_size_t alloc_chunk;
};

/*! brief create a new queue */
#define ftdm_queue_create(queue, capacity) g_ftdm_queue_handler.create(queue, capacity)

/*! Enqueue an object */
#define ftdm_queue_enqueue(queue, obj) g_ftdm_queue_handler.enqueue(queue, obj)

/*! dequeue an object from the queue */
#define ftdm_queue_dequeue(queue) g_ftdm_queue_handler.dequeue(queue)

/*! wait ms milliseconds for a queue to have available objects, -1 to wait forever */
#define ftdm_queue_wait(queue, ms) g_ftdm_queue_handler.wait(queue, ms)

/*! destroy the queue */ 
#define ftdm_queue_destroy(queue) g_ftdm_queue_handler.destroy(queue)

FT_DECLARE_DATA extern ftdm_queue_handler_t g_ftdm_queue_handler;

#define FTDM_TOKEN_STRLEN 128
#define FTDM_MAX_TOKENS 10

static __inline__ char *ftdm_clean_string(char *s)
{
	char *p;

	for (p = s; p && *p; p++) {
		uint8_t x = (uint8_t) *p;
		if (x < 32 || x > 127) {
			*p = ' ';
		}
	}

	return s;
}

struct ftdm_bitstream {
	uint8_t *data;
	uint32_t datalen;
	uint32_t byte_index;
	uint8_t bit_index;
	int8_t endian;
	uint8_t top;
	uint8_t bot;
	uint8_t ss;
	uint8_t ssv;
};

struct ftdm_fsk_data_state {
	dsp_fsk_handle_t *fsk1200_handle;
	uint8_t init;
	uint8_t *buf;
	size_t bufsize;
	ftdm_size_t blen;
	ftdm_size_t bpos;
	ftdm_size_t dlen;
	ftdm_size_t ppos;
	int checksum;
};

struct ftdm_fsk_modulator {
	teletone_dds_state_t dds;
	ftdm_bitstream_t bs;
	uint32_t carrier_bits_start;
	uint32_t carrier_bits_stop;
	uint32_t chan_sieze_bits;
	uint32_t bit_factor;
	uint32_t bit_accum;
	uint32_t sample_counter;
	int32_t samples_per_bit;
	int32_t est_bytes;
	fsk_modem_types_t modem_type;
	ftdm_fsk_data_state_t *fsk_data;
	ftdm_fsk_write_sample_t write_sample_callback;
	void *user_data;
	int16_t sample_buffer[64];
};


typedef enum {
	FTDM_TYPE_NONE,
	FTDM_TYPE_SPAN = 0xFF,
	FTDM_TYPE_CHANNEL
} ftdm_data_type_t;

/* number of bytes for the IO dump circular buffer (5 seconds worth of audio by default) */
#define FTDM_IO_DUMP_DEFAULT_BUFF_SIZE 8 * 5000
typedef struct {
	char *buffer;
	ftdm_size_t size;
	int windex;
	int wrapped;
} ftdm_io_dump_t;

typedef struct {
	uint8_t enabled;
	uint8_t requested;
	FILE *file;
	int32_t closetimeout;
	ftdm_mutex_t *mutex;
} ftdm_dtmf_debug_t;

typedef struct {
	uint32_t duration_ms;
	ftdm_time_t start_time;
	/* If set to 1, we will send DTMF event the the tone starts, instead of waiting for end */
	uint8_t trigger_on_start; 
} ftdm_dtmf_detect_t;

/* 2^8 table size, one for each byte (sample) value */
#define FTDM_GAINS_TABLE_SIZE 256
struct ftdm_channel {
	ftdm_data_type_t data_type;
	uint32_t span_id;
	uint32_t chan_id;
	uint32_t physical_span_id;
	uint32_t physical_chan_id;
	uint32_t rate;
	uint32_t extra_id;
	ftdm_chan_type_t type;
	ftdm_socket_t sockfd;
	uint64_t flags;
	uint32_t pflags;
	uint32_t sflags;
	uint8_t	 io_flags;
	ftdm_alarm_flag_t alarm_flags;
	ftdm_channel_feature_t features;
	ftdm_codec_t effective_codec;
	ftdm_codec_t native_codec;
	uint32_t effective_interval;
	uint32_t native_interval;
	uint32_t packet_len;
	ftdm_channel_state_t state;
	ftdm_state_status_t state_status;
	ftdm_channel_state_t last_state;
	ftdm_channel_state_t init_state;
	ftdm_channel_indication_t indication;
	ftdm_state_history_entry_t history[10];
	uint8_t hindex;
	ftdm_mutex_t *mutex;
	teletone_dtmf_detect_state_t dtmf_detect;
	uint32_t buffer_delay;
	ftdm_event_t event_header;
	char last_error[256];
	fio_event_cb_t event_callback;
	uint32_t skip_read_frames;
	ftdm_buffer_t *dtmf_buffer;
	ftdm_buffer_t *gen_dtmf_buffer;
	ftdm_buffer_t *pre_buffer;
	ftdm_buffer_t *digit_buffer;
	ftdm_buffer_t *fsk_buffer;
	ftdm_mutex_t *pre_buffer_mutex;
	uint32_t dtmf_on;
	uint32_t dtmf_off;
	char *dtmf_hangup_buf;
	teletone_generation_session_t tone_session;
	ftdm_time_t last_event_time;
	ftdm_time_t ring_time;
	char tokens[FTDM_MAX_TOKENS+1][FTDM_TOKEN_STRLEN];
	uint8_t needed_tones[FTDM_TONEMAP_INVALID];
	uint8_t detected_tones[FTDM_TONEMAP_INVALID];
	ftdm_tonemap_t last_detected_tone;	
	uint32_t token_count;
	char chan_name[128];
	char chan_number[32];
	ftdm_filehandle_t fds[2];
	ftdm_fsk_data_state_t fsk;
	uint8_t fsk_buf[80];
	uint32_t ring_count;
	ftdm_polarity_t polarity;
	/* Private I/O data. Do not touch unless you are an I/O module */
	void *io_data;
	/* Private signaling data. Do not touch unless you are a signaling module */
	void *call_data;
	struct ftdm_caller_data caller_data;
	struct ftdm_span *span;
	struct ftdm_io_interface *fio;
	unsigned char rx_cas_bits;
	uint32_t pre_buffer_size;
	uint8_t rxgain_table[FTDM_GAINS_TABLE_SIZE];
	uint8_t txgain_table[FTDM_GAINS_TABLE_SIZE];
	float rxgain;
	float txgain;
	int availability_rate;
	void *user_private;
	ftdm_timer_id_t hangup_timer;
	ftdm_channel_iostats_t iostats;
	ftdm_dtmf_debug_t dtmfdbg;
	ftdm_dtmf_detect_t dtmfdetect;
	ftdm_io_dump_t rxdump;
	ftdm_io_dump_t txdump;
	ftdm_interrupt_t *state_completed_interrupt; /*!< Notify when a state change is completed */
	int32_t txdrops;
	int32_t rxdrops;
	ftdm_usrmsg_t *usrmsg;
	ftdm_time_t last_state_change_time;
	ftdm_time_t last_release_time;
};

struct ftdm_span {
	ftdm_data_type_t data_type;
	char *name;
	uint32_t span_id;
	uint32_t chan_count;
	ftdm_span_flag_t flags;
	struct ftdm_io_interface *fio;
	fio_event_cb_t event_callback;
	ftdm_mutex_t *mutex;
	ftdm_trunk_type_t trunk_type;
	ftdm_trunk_mode_t trunk_mode;
	ftdm_analog_start_type_t start_type;
	ftdm_signal_type_t signal_type;
	uint32_t last_used_index;
	@<Private signaling data@>@;
  @<Private I/O data@>@;
};

@ Do not touch unless you are a signaling module.

@<Private signaling data@>=
        void *signal_data;
        fio_signal_cb_t signal_cb;
        ftdm_event_t event_header;
        char last_error[256];
        char tone_map[FTDM_TONEMAP_INVALID+1][FTDM_TONEMAP_LEN];
        teletone_tone_map_t tone_detect_map[FTDM_TONEMAP_INVALID+1];
        teletone_multi_tone_t tone_finder[FTDM_TONEMAP_INVALID+1];
        ftdm_channel_t *channels[FTDM_MAX_CHANNELS_SPAN+1];
        fio_channel_outgoing_call_t outgoing_call;
        fio_channel_indicate_t indicate;
        fio_channel_set_sig_status_t set_channel_sig_status;
        fio_channel_get_sig_status_t get_channel_sig_status;
        fio_span_set_sig_status_t set_span_sig_status;
        fio_span_get_sig_status_t get_span_sig_status;
        fio_channel_request_t channel_request;
        ftdm_span_start_t start;
        ftdm_span_stop_t stop;
        ftdm_span_destroy_t destroy;
        ftdm_channel_sig_read_t sig_read;
        ftdm_channel_sig_write_t sig_write;
        ftdm_channel_sig_dtmf_t sig_queue_dtmf;
        ftdm_channel_sig_dtmf_t sig_send_dtmf;
        uint32_t sig_release_guard_time_ms;
        ftdm_channel_state_processor_t state_processor; /* this guy is called whenever
          state processing is required */

@ Do not touch unless you are an I/O module.

@<Private I/O data@>=
        void *io_data;
        char *type;
        char *dtmf_hangup;
        size_t dtmf_hangup_len;
        ftdm_state_map_t *state_map;
        ftdm_caller_data_t default_caller_data;
        ftdm_queue_t *pendingchans; /* channels pending of state processing */
        ftdm_queue_t *pendingsignals; /* signals pending from being delivered to the user */
        struct ftdm_span *next;

@ @c
struct ftdm_group {
	char *name;
	uint32_t group_id;
	uint32_t chan_count;
	ftdm_channel_t *channels[FTDM_MAX_CHANNELS_GROUP];
	uint32_t last_used_index;
	ftdm_mutex_t *mutex;
	struct ftdm_group *next;
};

FT_DECLARE_DATA extern ftdm_crash_policy_t g_ftdm_crash_policy;

ftdm_size_t ftdm_fsk_modulator_generate_bit(ftdm_fsk_modulator_t *fsk_trans, int8_t bit,
  int16_t *buf, ftdm_size_t buflen);
int32_t ftdm_fsk_modulator_generate_carrier_bits(ftdm_fsk_modulator_t *fsk_trans, uint32_t bits);
void ftdm_fsk_modulator_generate_chan_sieze(ftdm_fsk_modulator_t *fsk_trans);
void ftdm_fsk_modulator_send_data(ftdm_fsk_modulator_t *fsk_trans);
#define ftdm_fsk_modulator_send_all(_it) ftdm_fsk_modulator_generate_chan_sieze(_it); \
	ftdm_fsk_modulator_generate_carrier_bits(_it, _it->carrier_bits_start); \
	ftdm_fsk_modulator_send_data(_it); \
	ftdm_fsk_modulator_generate_carrier_bits(_it, _it->carrier_bits_stop)

ftdm_status_t ftdm_fsk_modulator_init(ftdm_fsk_modulator_t *fsk_trans,
						fsk_modem_types_t modem_type,
						uint32_t sample_rate,
						ftdm_fsk_data_state_t *fsk_data,
						float db_level,
						uint32_t carrier_bits_start,
						uint32_t carrier_bits_stop,
						uint32_t chan_sieze_bits,
						ftdm_fsk_write_sample_t write_sample_callback,
						void *user_data);
int8_t ftdm_bitstream_get_bit(ftdm_bitstream_t *bsp);
void ftdm_bitstream_init(ftdm_bitstream_t *bsp, uint8_t *data, uint32_t datalen,
  ftdm_endian_t endian, uint8_t ss);
ftdm_status_t ftdm_fsk_data_parse(ftdm_fsk_data_state_t *state, ftdm_size_t *type, char **data,
  ftdm_size_t *len);
ftdm_status_t ftdm_fsk_demod_feed(ftdm_fsk_data_state_t *state, int16_t *data, size_t samples);
ftdm_status_t ftdm_fsk_demod_destroy(ftdm_fsk_data_state_t *state);
int ftdm_fsk_demod_init(ftdm_fsk_data_state_t *state, int rate, uint8_t *buf, size_t bufsize);
ftdm_status_t ftdm_fsk_data_init(ftdm_fsk_data_state_t *state, uint8_t *data, uint32_t datalen);
ftdm_status_t ftdm_fsk_data_add_mdmf(ftdm_fsk_data_state_t *state, ftdm_mdmf_type_t type,
  const uint8_t *data, uint32_t datalen);
ftdm_status_t ftdm_fsk_data_add_checksum(ftdm_fsk_data_state_t *state);
ftdm_status_t ftdm_fsk_data_add_sdmf(ftdm_fsk_data_state_t *state, const char *date, char *number);
ftdm_status_t ftdm_channel_send_fsk_data(ftdm_channel_t *ftdmchan, ftdm_fsk_data_state_t *fsk_data,
  float db_level);

ftdm_status_t ftdm_span_load_tones(ftdm_span_t *span, const char *mapname);

ftdm_status_t ftdm_channel_use(ftdm_channel_t *ftdmchan);

void ftdm_generate_sln_silence(int16_t *data, uint32_t samples, uint32_t divisor);

uint32_t ftdm_separate_string(char *buf, char delim, char **array, int arraylen);
void print_bits(uint8_t *b, int bl, char *buf, int blen, int e, uint8_t ss);
void print_hex_bytes(uint8_t *data, ftdm_size_t dlen, char *buf, ftdm_size_t blen);

int ftdm_hash_equalkeys(void *k1, void *k2);
uint32_t ftdm_hash_hashfromstring(void *ky);

int ftdm_load_modules(void);

ftdm_status_t ftdm_unload_modules(void);

ftdm_status_t ftdm_span_send_signal(ftdm_span_t *span, ftdm_sigmsg_t *sigmsg);

void ftdm_channel_clear_needed_tones(ftdm_channel_t *ftdmchan);
void ftdm_channel_rotate_tokens(ftdm_channel_t *ftdmchan);

int ftdm_load_module(const char *name);
int ftdm_load_module_assume(const char *name);
int ftdm_vasprintf(char **ret, const char *fmt, va_list ap);

ftdm_status_t ftdm_span_close_all(void);
ftdm_status_t ftdm_channel_open_chan(ftdm_channel_t *ftdmchan);
void ftdm_ack_indication(ftdm_channel_t *ftdmchan, ftdm_channel_indication_t indication,
  ftdm_status_t status);

ftdm_iterator_t * ftdm_get_iterator(ftdm_iterator_type_t type, ftdm_iterator_t *iter);

ftdm_status_t ftdm_channel_process_media(ftdm_channel_t *ftdmchan, void *data,
  ftdm_size_t *datalen);

ftdm_status_t ftdm_raw_read (ftdm_channel_t *ftdmchan, void *data, ftdm_size_t *datalen);
ftdm_status_t ftdm_raw_write (ftdm_channel_t *ftdmchan, void *data, ftdm_size_t *datalen);

/*! 
 * \brief Retrieves an event from the span
 *
 * \note
 * 	This function is non-reentrant and not thread-safe. 
 * 	The event returned may be modified if the function is called again 
 * 	from a different thread or even the same. It is recommended to
 * 	handle events from the same span in a single thread.
 * 	WARNING: this function used to be public ( in freetdm.h )
 * 	but since is really of no use to users better keep it here
 *
 * \param span The span to retrieve the event from
 * \param event Pointer to store the pointer to the event
 *
 * \retval FTDM_SUCCESS success (at least one event available)
 * \retval FTDM_TIMEOUT Timed out waiting for events
 * \retval FTDM_FAIL failure
 */
ftdm_status_t ftdm_span_next_event(ftdm_span_t *span, ftdm_event_t **event);

/*! 
 * \brief Enqueue a DTMF string into the channel
 *
 * \param ftdmchan The channel to enqueue the dtmf string to
 * \param dtmf null-terminated DTMF string
 *
 * \retval FTDM_SUCCESS success
 * \retval FTDM_FAIL failure
 */
ftdm_status_t ftdm_channel_queue_dtmf(ftdm_channel_t *ftdmchan, const char *dtmf);

/* dequeue pending signals and notify the user via the span signal callback */
ftdm_status_t ftdm_span_trigger_signals(const ftdm_span_t *span);

/*! \brief clear the tone detector state */
void ftdm_channel_clear_detected_tones(ftdm_channel_t *ftdmchan);

/*!
  \brief Socket the given socket
  \command it the socket
*/
#define ftdm_socket_close(it) if (it > -1) { close(it); it = -1;}

#define ftdm_channel_lock(chan) ftdm_mutex_lock((chan)->mutex)
#define ftdm_channel_unlock(chan) ftdm_mutex_unlock((chan)->mutex)

#define ftdm_log_chan(fchan, level, format, ...) ftdm_log(level, "[s%dc%d][%d:%d] " format, fchan->span_id, fchan->chan_id, fchan->physical_span_id, fchan->physical_chan_id, __VA_ARGS__)

#define ftdm_log_chan_msg(fchan, level, msg) ftdm_log(level, "[s%dc%d][%d:%d] " msg, fchan->span_id, fchan->chan_id, fchan->physical_span_id, fchan->physical_chan_id)

#define ftdm_span_lock(span) ftdm_mutex_lock(span->mutex)
#define ftdm_span_unlock(span) ftdm_mutex_unlock(span->mutex)

FT_DECLARE_DATA extern const char *FTDM_LEVEL_NAMES[9];

static __inline__ void ftdm_abort(void)
{
#ifdef __cplusplus
	::abort();
#else
	abort();
#endif
}

static __inline__ int16_t ftdm_saturated_add(int16_t sample1, int16_t sample2)
{
	int addres;

	addres = sample1 + sample2;
	if (addres > 32767)
		addres = 32767;
	else if (addres < -32767)
		addres = -32767;
	return (int16_t)addres;
}

/* Bitmap helper functions */
typedef long ftdm_bitmap_t;
#define FTDM_BITMAP_NBITS (sizeof(ftdm_bitmap_t) * 8)
#define ftdm_map_set_bit(map, bit) (map[(bit/FTDM_BITMAP_NBITS)] |= ((ftdm_bitmap_t)1 << (bit % FTDM_BITMAP_NBITS)))
#define ftdm_map_clear_bit(map, bit) (map[(bit/FTDM_BITMAP_NBITS)] &= ~((ftdm_bitmap_t)1 << (bit % FTDM_BITMAP_NBITS)))
#define ftdm_map_test_bit(map, bit) (map[(bit/FTDM_BITMAP_NBITS)] & ((ftdm_bitmap_t)1 << (bit % FTDM_BITMAP_NBITS)))


#include <sys/ioctl.h>
#include <poll.h>

@ Hardware interface structures and defines.

@c
struct zt_params { /* used with ioctl: \.{DAHDI\_GET\_PARAMS} and \.{DAHDI\_SET\_PARAMS} */
       int chan_no;                    /* Channel Number */
       int span_no;                    /* Span Number */
       int chan_position;              /* Channel Position */
       int sig_type;                   /* Signal Type (read-only) */
       int sig_cap;                    /* Signal Cap (read-only) */
       int receive_offhook;    /* Receive is offhook (read-only)                       */
       int receive_bits;               /* Number of bits in receive (read-only)        */
       int transmit_bits;              /* Number of bits in transmit (read-only)       */
       int transmit_hook_sig;  /* Transmit Hook Signal (read-only)                     */
       int receive_hook_sig;   /* Receive Hook Signal (read-only)                      */
       int g711_type;                  /* Member of |zt_g711_t| (read-only)                      */
       int idlebits;                   /* bits for the idle state (read-only)          */
       char chan_name[40];             /* Channel Name */
       int prewink_time;
       int preflash_time;
       int wink_time;
       int flash_time;
       int start_time;
       int receive_wink_time;
       int receive_flash_time;
       int debounce_time;
       int pulse_break_time;
       int pulse_make_time;
       int pulse_after_time;
    uint32_t chan_alarms;
};

typedef struct zt_params zt_params_t;

struct zt_gains { /* used with ioctl: \.{DAHDI\_GETGAINS} and \.{DAHDI\_SETGAINS} */
  int chan_no; /* channel Number, 0 for current */
  unsigned char receive_gain[256]; /* receive gain table */
  unsigned char transmit_gain[256]; /* transmit gain table */
};

struct zt_chanconfig { /* used in \.{DAHDI\_CHANCONFIG} */
  int chan; /* Channel we're applying this to (0 to use name) */
  char name[40]; /* Name of channel to use */
  int sigtype; /* Signal type */
  int deflaw;  /* Default law (|DAHDI_LAW_DEFAULT|, |DAHDI_LAW_MULAW|, or
    |DAHDI_LAW_ALAW| */
  int master; /* Master channel if sigtype is |DAHDI_SLAVE| */
  int idlebits; /* Idle bits (if this is a CAS channel) or channel to monitor
    (if this is DACS channel) */
  char netdev_name[16]; /* name for the hdlc network device */
};

struct zt_bufferinfo { /* used in \.{DAHDI\_SET\_BUFINFO} and \.{DAHDI\_GET\_BUFINFO} */
  int txbufpolicy; /* Policy for handling receive buffers */
  int rxbufpolicy; /* Policy for handling receive buffers */
  int numbufs; /* How many buffers to use */
  int bufsize; /* How big each buffer is */
  int readbufs; /* How many read buffers are full (read-only)   */
  int writebufs; /* How many write buffers are full (read-only)  */
};

struct zt_spaninfo { /* used with ioctl: \.{DAHDI\_SPANSTAT} */
  int span_no;                                            /* span number (-1 to use name) */
  char name[20];                                         /* Name of span */
  char description[40];            /* Description of span */
  int alarms;      /* alarms status */
  int transmit_level;           /* Transmit level */
  int receive_level;      /* Receive level */
  int bpv_count;                /* Current BPV count            */
  int crc4_count;           /* Current CRC4 error count                    */
  int ebit_count;       /* Current E-bit error count                            */
  int fas_count;                                          /* Current FAS error count         */
  int irq_misses;                         /* Current IRQ misses                */
  int sync_src;                   /* Span number of sync source (0 = free run)         */
  int configured_chan_count;        /* Count of channels configured on the span   */
  int channel_count;         /* Total count of channels on the span          */
  int span_count;           /* Total count of ftdmtel spans on the system*/

    int lbo;                            /* Line Build Out */
    int lineconfig;                     /* framing/coding */

    char lboname[40];                   /* Line Build Out in text form */
    char location[40];                  /* span's device location in system */
    char manufacturer[40];              /* manufacturer of span's device */
    char devicetype[40];                /* span's device type */
    int irq;                            /* span's device IRQ */
    int linecompat;                     /* signaling modes possible on this span */
    char spantype[6];                   /* type of span in text form */
};

typedef enum { /* Values in |zt_params| structure for member |g711_type| */
  @! ZT_G711_DEFAULT         = 0,    /* Default mulaw/alaw from the span */
  @! ZT_G711_MULAW           = 1 @[,@] @;
  @! ZT_G711_ALAW            = 2
} zt_g711_t;

typedef enum {
  @! ZT_EVENT_NONE                   = 0 @[,@] @;
  @! ZT_EVENT_ONHOOK                 = 1 @[,@] @;
  @! ZT_EVENT_RINGOFFHOOK    = 2 @[,@] @;
  @! ZT_EVENT_WINKFLASH              = 3 @[,@] @;
  @! ZT_EVENT_ALARM                  = 4 @[,@] @;
  @! ZT_EVENT_NOALARM                = 5 @[,@] @;
  @! ZT_EVENT_ABORT                  = 6 @[,@] @;
  @! ZT_EVENT_OVERRUN                = 7 @[,@] @;
  @! ZT_EVENT_BADFCS                 = 8 @[,@] @;
  @! ZT_EVENT_DIALCOMPLETE   = 9 @[,@] @;
  @! ZT_EVENT_RINGERON               = 10 @[,@] @;
  @! ZT_EVENT_RINGEROFF              = 11 @[,@] @;
  @! ZT_EVENT_HOOKCOMPLETE   = 12 @[,@] @;
  @! ZT_EVENT_BITSCHANGED    = 13 @[,@] @;
  @! ZT_EVENT_PULSE_START    = 14 @[,@] @;
  @! ZT_EVENT_TIMER_EXPIRED  = 15 @[,@] @;
  @! ZT_EVENT_TIMER_PING             = 16 @[,@] @;
  @! ZT_EVENT_POLARITY               = 17 @[,@] @;
  @! ZT_EVENT_RINGBEGIN              = 18 @[,@] @;
  @! ZT_EVENT_DTMFDOWN               = (1 << 17) @[,@] @;
  @! ZT_EVENT_DTMFUP                 = (1 << 18) @[,@] @;
} zt_event_t;

typedef enum {
  @! ZT_FLUSH_READ                   = 1 @[,@] @;
  @! ZT_FLUSH_WRITE                  = 2 @[,@] @;
  @! ZT_FLUSH_BOTH                   = (ZT_FLUSH_READ | ZT_FLUSH_WRITE) @[,@] @;
  @! ZT_FLUSH_EVENT                  = 4 @[,@] @;
  @! ZT_FLUSH_ALL                    = (ZT_FLUSH_READ | ZT_FLUSH_WRITE | ZT_FLUSH_EVENT)
} zt_flush_t;

typedef enum { /* Signalling type */
  @! ZT_SIG_NONE = 0, /* chan not configured */
  @! ZT_SIG_FXSLS                           = ((1 << 0) | (1 << 13)),       /* FXS, Loopstart */
  @! ZT_SIG_FXSGS                           = ((1 << 1) | (1 << 13)),       /* FXS, Groundstart */
  @! ZT_SIG_FXSKS                           = ((1 << 2) | (1 << 13)),       /* FXS, Kewlstart */
  @! ZT_SIG_FXOLS                           = ((1 << 3) | (1 << 12)),       /* FXO, Loopstart */
  @! ZT_SIG_FXOGS                           = ((1 << 4) | (1 << 12)),       /* FXO, Groupstart */
  @! ZT_SIG_FXOKS                           = ((1 << 5) | (1 << 12)),       /* FXO, Kewlstart */
  @! ZT_SIG_CLEAR                           = (1 << 7) @[,@] @;
  @! ZT_SIG_HDLCRAW                         = ((1 << 8)  | ZT_SIG_CLEAR) @[,@] @;
  @! ZT_SIG_HDLCFCS                         = ((1 << 9)  | ZT_SIG_HDLCRAW) @[,@] @;
  @! ZT_SIG_CAS                             = (1 << 15) @[,@] @;
  @! ZT_SIG_HARDHDLC                        = ((1 << 19) | ZT_SIG_CLEAR)
} zt_sigtype_t;

typedef enum {
  @! ZT_ONHOOK                               = 0 @[,@] @;
  @! ZT_OFFHOOK                              = 1 @[,@] @;
  @! ZT_WINK                                 = 2 @[,@] @;
  @! ZT_FLASH                                = 3 @[,@] @;
  @! ZT_START                                = 4 @[,@] @;
  @! ZT_RING                                 = 5 @[,@] @;
  @! ZT_RINGOFF                              = 6
} zt_hookstate_t;

typedef enum { /* Tone Detection */
  @! ZT_TONEDETECT_ON = (1 << 0), /* Detect tones */
  @! ZT_TONEDETECT_MUTE = (1 << 1) /* Mute audio in received channel */
} zt_tone_mode_t;

#define DAHDI_CODE 0xDA

#define	DAHDI_GET_BLOCKSIZE @,@,@,@,@, _IOR(DAHDI_CODE, 1, int) /* Get Transfer Block Size */
#define	DAHDI_SET_BLOCKSIZE @,@,@,@,@, _IOW(DAHDI_CODE, 1, int) /* Set Transfer Block Size */
#define	DAHDI_FLUSH @,@,@,@,@, _IOW(DAHDI_CODE, 3, int) /* Flush Buffer(s) and stop I/O */
#define	DAHDI_SYNC @,@,@,@,@, _IO(DAHDI_CODE, 4) /* Wait for Write to Finish */
#define	DAHDI_GET_PARAMS @,@,@,@,@, _IOR(DAHDI_CODE, 5, struct zt_params)
  /* Get channel parameters */
#define	DAHDI_SET_PARAMS @,@,@,@,@, _IOW(DAHDI_CODE, 5, struct zt_params)
  /* Set channel parameters */
#define	DAHDI_HOOK _IOW (DAHDI_CODE, 7, int) /* Set Hookswitch Status */
#define	DAHDI_GETEVENT _IOR (DAHDI_CODE, 8, int) /* Get Signalling Event */
#define	DAHDI_IOMUX _IOWR (DAHDI_CODE, 9, int) /* Wait for something to happen (IO Mux) */
#define	DAHDI_SPANSTAT _IOWR (DAHDI_CODE, 10, struct zt_spaninfo)  /* Get Span Status */

#define	DAHDI_GETGAINS _IOR (DAHDI_CODE, 16, struct zt_gains) /* Get Channel audio gains */
#define	DAHDI_SETGAINS _IOW (DAHDI_CODE, 16, struct zt_gains) /* Set Channel audio gains */
#define	DAHDI_CHANCONFIG _IOW (DAHDI_CODE, 19, struct zt_chanconfig)
  /* Set Channel Configuration  */
#define	DAHDI_SET_BUFINFO _IOW (DAHDI_CODE, 27, struct zt_bufferinfo) /* Set buffer policy */
#define	DAHDI_GET_BUFINFO _IOR (DAHDI_CODE, 27, struct zt_bufferinfo) /* Get current buffer info */
#define	DAHDI_AUDIOMODE	_IOW (DAHDI_CODE, 32, int) /* Set a clear channel into audio mode */
#define	DAHDI_ECHOCANCEL _IOW (DAHDI_CODE, 33, int) /* Control Echo Canceller */
#define	DAHDI_HDLCRAWMODE_IOW (DAHDI_CODE, 36, int) /* Set a clear channel into HDLC w/out FCS
  checking/calculation mode */
#define DAHDI_HDLCFCSMODE _IOW (DAHDI_CODE, 37, int) /* Set a clear channel into HDLC w/ FCS
  mode */

#define		DAHDI_ALARM_YELLOW (1 << 2) /* channel alarm */
#define		DAHDI_ALARM_BLUE (1 << 4) /* channel alarm */

#define DAHDI_SPECIFY _IOW (DAHDI_CODE, 38, int) /* Specify a channel on /dev/dahdi/chan --- must
  be done before any other ioctl's and is only valid on /dev/dahdi/chan */

#define         DAHDI_SETLAW            _IOW  (DAHDI_CODE, 39, int) /* Temporarily set the law on
  a channel to \.{DAHDI\_LAW\_DEFAULT}, \.{DAHDI\_LAW\_ALAW}, or \.{DAHDI\_LAW\_MULAW}. Is reset
  on close. */

#define DAHDI_SETLINEAR         _IOW  (DAHDI_CODE, 40, int) /* Temporarily set the channel
  to operate in linear mode when non-zero or default law if 0 */

#define	DAHDI_ECHOTRAIN		_IOW  (DAHDI_CODE, 50, int)	/* Control Echo Trainer */

#define DAHDI_SETTXBITS _IOW (DAHDI_CODE, 43, int) /* set CAS bits */
#define DAHDI_GETRXBITS _IOR (DAHDI_CODE, 43, int) /* get CAS bits */

@ Attach the desired echo canceler module (or none) to a channel in an
audio-supporting mode, so that when the channel needs an echo canceler
that module will be used to supply one.

@c
struct dahdi_attach_echocan {
        int     chan;           /* Channel we're applying this to */
        char    echocan[16];    /* Name of echo canceler to attach to this channel
                                   (leave empty to have no echocan attached */
};
#define DAHDI_ATTACH_ECHOCAN _IOW(DAHDI_CODE, 59, struct dahdi_attach_echocan)

@ @c
#define DAHDI_SETPOLARITY _IOW (DAHDI_CODE, 92, int) /* Polarity setting for FXO lines */

#define DAHDI_TONEDETECT _IOW(DAHDI_CODE, 91, int) /* Enable tone detection --- implemented by low
  level driver */

#define ELAST 500 /* used by dahdi to indicate there is no data available, but events to read */

@ Zaptel globals.

@c
struct {
  uint32_t codec_ms;
  uint32_t wink_ms;
  uint32_t flash_ms;
  uint32_t eclevel;
  uint32_t etlevel;
  float rxgain;
  float txgain;
} zt_globals;

@ @c
#define ZT_INVALID_SOCKET -1

static ftdm_socket_t CONTROL_FD = ZT_INVALID_SOCKET;

@<Function prototypes@>@;

@ Initialises codec, and rx/tx gains.

@c
static void zt_build_gains(struct zt_gains *g, float rxgain, float txgain, int codec)
{
  int j;
  int k;
  float linear_rxgain = pow(10.0, rxgain / 20.0);
  float linear_txgain = pow(10.0, txgain / 20.0);

  switch (codec) {
  case FTDM_CODEC_ALAW:
		for (j = 0; j < (sizeof g->receive_gain / sizeof g->receive_gain[0]); j++) {
			if (rxgain) {
				k = (int) (((float) alaw_to_linear(j)) * linear_rxgain);
				if (k > 32767) k = 32767;
				if (k < -32767) k = -32767;
				g->receive_gain[j] = linear_to_alaw(k);
			}
			else
				g->receive_gain[j] = j;
			if (txgain) {
				k = (int) (((float) alaw_to_linear(j)) * linear_txgain);
				if (k > 32767) k = 32767;
				if (k < -32767) k = -32767;
				g->transmit_gain[j] = linear_to_alaw(k);
			}
			else
				g->transmit_gain[j] = j;
		}
		break;
	case FTDM_CODEC_ULAW:
		for (j = 0; j < (sizeof g->receive_gain / sizeof g->receive_gain[0]); j++) {
			if (rxgain) {
				k = (int) (((float) ulaw_to_linear(j)) * linear_rxgain);
				if (k > 32767) k = 32767;
				if (k < -32767) k = -32767;
				g->receive_gain[j] = linear_to_ulaw(k);
			}
			else
				g->receive_gain[j] = j;
			if (txgain) {
				k = (int) (((float) ulaw_to_linear(j)) * linear_txgain);
				if (k > 32767) k = 32767;
				if (k < -32767) k = -32767;
				g->transmit_gain[j] = linear_to_ulaw(k);
			}
			else
				g->transmit_gain[j] = j;
		}
		break;
	}
}

@ Initialises a range of DAHDI channels.
Returns number of configured spans.
{\settabs\+\hskip100pt&\cr
\+ * \.{span}& FreeTDM span\cr
\+ * \.{start}& Initial wanpipe channel number\cr
\+ * \.{end}& Final wanpipe channel number\cr
\+ * \.{type}& FreeTDM channel type\cr
\+ * \.{name}& FreeTDM span name\cr
\+ * \.{number}& FreeTDM span number\cr
\+ * \.{cas\_bits}& CAS bits\cr
}

This function is called from |zt_configure_span| which is called from
function |load_config| in \.{ftdm\_io.c}.

@c
static unsigned zt_open_range(ftdm_span_t *span, unsigned start, unsigned end,
  ftdm_chan_type_t type, char *name, char *number, unsigned char cas_bits)
{
  unsigned configured = 0, x;

  for (x = start; x < end; x++) {
    @<Configure channel@>@;

    ftdm_channel_t *ftdmchan;

    ftdm_socket_t sockfd = ZT_INVALID_SOCKET;
    sockfd = open("/dev/dahdi/channel", O_RDWR);
    if (sockfd != ZT_INVALID_SOCKET &&
        ftdm_span_add_channel(span, sockfd, type, &ftdmchan) == FTDM_SUCCESS) {
      if (ioctl(sockfd, DAHDI_SPECIFY, &x) == -1) {
        ftdm_log(FTDM_LOG_ERROR,
          "DAHDI_SPECIFY failed: chan %d fd %d (%s)\n",
          x, sockfd, strerror(errno));
        close(sockfd);
        continue;
      }

      int len = zt_globals.codec_ms * 8;
      if (ioctl(sockfd, DAHDI_SET_BLOCKSIZE, &len) == -1) {
        ftdm_log(FTDM_LOG_ERROR,
          "failure configuring device /dev/dahdi/channel as FreeTDM device %d:%d fd:%d err:%s\n",
          ftdmchan->span_id, ftdmchan->chan_id, sockfd, strerror(errno));
        close(sockfd);
        continue;
      }

      ftdmchan->packet_len = len;
      ftdmchan->effective_interval = ftdmchan->native_interval = ftdmchan->packet_len / 8;
			
      if (ftdmchan->effective_codec == FTDM_CODEC_SLIN)
        ftdmchan->packet_len *= 2;
			
      ftdmchan->rate = 8000;
      ftdmchan->physical_span_id = 1;
      ftdmchan->physical_chan_id = x;
			
      ftdmchan->native_codec = ftdmchan->effective_codec = FTDM_CODEC_ULAW;

      configured++;
    }
    else
      ftdm_log(FTDM_LOG_ERROR, "failure configuring device /dev/dahdi/channel\n");
  }

  return configured;
}

@ @<Configure channel@>=
    struct zt_chanconfig cc;
    memset(&cc, 0, sizeof cc);
    cc.chan = x;
    cc.sigtype = ZT_SIG_FXOKS; /* reversed */
    if (ioctl(CONTROL_FD, DAHDI_CHANCONFIG, &cc) == -1) {
      ftdm_log(FTDM_LOG_ERROR,
        "DAHDI_CHANCONFIG failed: chan %d fd %d (%s)]\n", x, CONTROL_FD, strerror(errno));
      continue;
    }

    struct dahdi_attach_echocan ae;
    memset(&ae, 0, sizeof ae);
    ae.chan = x;
    strcpy(ae.echocan, "oslec");
    if (ioctl(CONTROL_FD, DAHDI_ATTACH_ECHOCAN, &ae) == -1) {
      ftdm_log(FTDM_LOG_ERROR,
        "DAHDI_ATTACH_ECHOCAN failed: chan %d fd %d (%s)]\n", x, CONTROL_FD, strerror(errno));
      continue;
    }

@ Initialises a freetdm DAHDI span from a configuration string.
Returns success or failure.
{\settabs\+\hskip100pt&\cr
\+ * \.{span}& FreeTDM span\cr
\+ * \.{str}& Configuration string\cr
\+ * \.{type}& FreeTDM span type\cr
\+ * \.{name}& FreeTDM span name\cr
\+ * \.{number}& FreeTDM span number\cr
}

@c
static ftdm_status_t zt_configure_span(ftdm_span_t *span, const char *str, ftdm_chan_type_t type, char *name, char *number)
{

	int items, i;
	char *mydata, *item_list[10];
	char *ch, *mx;
	unsigned char cas_bits = 0;
	int channo;
	int top = 0;
	unsigned configured = 0;

	assert(str != NULL);
	

	mydata = ftdm_strdup(str);
	assert(mydata != NULL);


	items = ftdm_separate_string(mydata, ',', item_list, (sizeof item_list / sizeof item_list[0]));

	for(i = 0; i < items; i++) {
		ch = item_list[i];

		if (!(ch)) {
			ftdm_log(FTDM_LOG_ERROR, "Invalid input\n");
			continue;
		}

		channo = atoi(ch);
		
		if (channo < 0) {
			ftdm_log(FTDM_LOG_ERROR, "Invalid channel number %d\n", channo);
			continue;
		}

		if ((mx = strchr(ch, '-'))) {
			mx++;
			top = atoi(mx) + 1;
		}
		else
			top = channo + 1;
		
		
		if (top < 0) {
			ftdm_log(FTDM_LOG_ERROR, "Invalid range number %d\n", top);
			continue;
		}
		configured += zt_open_range(span, channo, top, type, name, number, cas_bits);

	}
	
	ftdm_safe_free(mydata);

	return configured;

}

@ Process configuration variable for a DAHDI profile.
{\settabs\+\hskip100pt&\cr
\+ * \.{category}& Wanpipe profile name\cr
\+ * \.{var}& Variable name\cr
\+ * \.{val}& Variable value\cr
\+ * \.{lineno}& Line number from configuration file\cr
}

@c
static ftdm_status_t zt_configure(const char *category, const char *var, const char *val, int lineno)
{
  int num;
  float fnum;

  if (strcasecmp(category, "defaults") == 0) {
    if (strcasecmp(var, "codec_ms") == 0) {
      num = atoi(val);
      if (num < 10 || num > 60)
        ftdm_log(FTDM_LOG_WARNING, "invalid codec ms at line %d\n", lineno);
      else
	zt_globals.codec_ms = num;
    }
    else if (strcasecmp(var, "wink_ms") == 0) {
      num = atoi(val);
      if (num < 50 || num > 3000)
        ftdm_log(FTDM_LOG_WARNING, "invalid wink ms at line %d\n", lineno);
      else
	zt_globals.wink_ms = num;
    }
    else if (strcasecmp(var, "flash_ms") == 0) {
      num = atoi(val);
      if (num < 50 || num > 3000)
        ftdm_log(FTDM_LOG_WARNING, "invalid flash ms at line %d\n", lineno);
      else
	zt_globals.flash_ms = num;
    }
    else if (strcasecmp(var, "echo_cancel_level") == 0) {
      num = atoi(val);
      if (num < 0 || num > 1024)
	ftdm_log(FTDM_LOG_WARNING, "invalid echo can val at line %d\n", lineno);
      else
	zt_globals.eclevel = num;
    }
    else if (strcasecmp(var, "echo_train_level") == 0) {
      if (zt_globals.eclevel < 1)
	ftdm_log(FTDM_LOG_WARNING,
          "can't set echo train level without setting echo cancel level first at line %d\n",
          lineno);
      else {
	num = atoi(val);
	if (num < 0 || num > 256)
	  ftdm_log(FTDM_LOG_WARNING, "invalid echo train val at line %d\n", lineno);
	else
	  zt_globals.etlevel = num;
      }
    }
    else if (strcasecmp(var, "rxgain") == 0) {
      fnum = (float)atof(val);
      if (fnum < -100.0 || fnum > 100.0)
	ftdm_log(FTDM_LOG_WARNING, "invalid rxgain val at line %d\n", lineno);
      else {
	zt_globals.rxgain = fnum;
	ftdm_log(FTDM_LOG_INFO, "Setting rxgain val to %f\n", fnum);
      }
    }
    else if (strcasecmp(var, "txgain") == 0) {
      fnum = (float)atof(val);
      if (fnum < -100.0 || fnum > 100.0)
	ftdm_log(FTDM_LOG_WARNING, "invalid txgain val at line %d\n", lineno);
      else {
	zt_globals.txgain = fnum;
	ftdm_log(FTDM_LOG_INFO, "Setting txgain val to %f\n", fnum);
      }
    }
    else
      ftdm_log(FTDM_LOG_WARNING, "Ignoring unknown setting '%s'\n", var);
  }

  return FTDM_SUCCESS;
}

@ Opens a DAHDI channel. Returns success or failure.

* \.{ftdmchan}\quad Channel to open

@c
static ftdm_status_t zt_open(ftdm_channel_t *ftdmchan)
{
  ftdmchan->features =
    (ftdm_channel_feature_t) (ftdmchan->features | FTDM_CHANNEL_FEATURE_INTERVAL);

  int blocksize = zt_globals.codec_ms * (ftdmchan->rate / 1000);
  int err;
  if ((err = ioctl(ftdmchan->sockfd, DAHDI_SET_BLOCKSIZE, &blocksize))) {
    snprintf(ftdmchan->last_error, sizeof ftdmchan->last_error, "%s", strerror(errno));
    return FTDM_FAIL;
  }
  else {
    ftdmchan->effective_interval = ftdmchan->native_interval;
    ftdmchan->packet_len = blocksize;
    ftdmchan->native_codec = ftdmchan->effective_codec;
  }
		
  if (zt_globals.rxgain || zt_globals.txgain) {
    struct zt_gains gains;
    memset(&gains, 0, sizeof gains);

    gains.chan_no = ftdmchan->physical_chan_id;
    zt_build_gains(&gains, zt_globals.rxgain, zt_globals.txgain, ftdmchan->native_codec);

    if (zt_globals.rxgain)
      ftdm_log(FTDM_LOG_INFO, "Setting rxgain to %f on channel %d\n", zt_globals.rxgain,
        gains.chan_no);

    if (zt_globals.txgain)
      ftdm_log(FTDM_LOG_INFO, "Setting txgain to %f on channel %d\n", zt_globals.txgain,
        gains.chan_no);

    if (ioctl(ftdmchan->sockfd, DAHDI_SETGAINS, &gains) < 0)
      ftdm_log(FTDM_LOG_ERROR,
        "failure configuring device /dev/dahdi/channel as FreeTDM device %d:%d fd:%d\n",
        ftdmchan->span_id, ftdmchan->chan_id, ftdmchan->sockfd);
  }

  int len = zt_globals.eclevel;
  if (len)
    ftdm_log(FTDM_LOG_INFO, "Setting echo cancel to %d taps for %d:%d\n", len, ftdmchan->span_id,
      ftdmchan->chan_id);
  else
    ftdm_log(FTDM_LOG_INFO, "Disable echo cancel for %d:%d\n", ftdmchan->span_id,
      ftdmchan->chan_id);
  if (ioctl(ftdmchan->sockfd, DAHDI_ECHOCANCEL, &len))
    ftdm_log(FTDM_LOG_WARNING, "Echo cancel not available for %d:%d\n", ftdmchan->span_id,
      ftdmchan->chan_id);
  else if (zt_globals.etlevel > 0) {
    len = zt_globals.etlevel;
    if (ioctl(ftdmchan->sockfd, DAHDI_ECHOTRAIN, &len))
      ftdm_log(FTDM_LOG_WARNING, "Echo training not available for %d:%d\n", ftdmchan->span_id,
        ftdmchan->chan_id);
  }

  return FTDM_SUCCESS;
}

@ Closes DAHDI channel.

 * \.{ftdmchan}\quad Channel to close

@c
static ftdm_status_t zt_close(ftdm_channel_t *ftdmchan)
{
	if (ftdmchan->type == FTDM_CHAN_TYPE_B) {
		int value = 0;	/* disable audio mode */
		if (ioctl(ftdmchan->sockfd, DAHDI_AUDIOMODE, &value)) {
			snprintf(ftdmchan->last_error, sizeof ftdmchan->last_error, "%s", strerror(errno));
			ftdm_log(FTDM_LOG_ERROR, "%s\n", ftdmchan->last_error);
			return FTDM_FAIL;
		}
	}
	return FTDM_SUCCESS;
}

@ Executes a FreeTDM command on a DAHDI channel. Return success or failure.
{\settabs\+\hskip100pt&\cr
\+ * \.{ftdmchan}& Channel to execute command on\cr
\+ * \.{command}& FreeTDM command to execute\cr
\+ * \.{obj} Object (unused)\cr
}

@c
static ftdm_status_t zt_command(ftdm_channel_t *ftdmchan, ftdm_command_t command, void *obj)
{
	zt_params_t ztp;
	int err = 0;

	memset(&ztp, 0, sizeof ztp);

	switch(command) {
	case FTDM_COMMAND_ENABLE_ECHOCANCEL:
		{
			int level = FTDM_COMMAND_OBJ_INT;
			err = ioctl(ftdmchan->sockfd, DAHDI_ECHOCANCEL, &level);
			FTDM_COMMAND_OBJ_INT = level;
		}
	case FTDM_COMMAND_DISABLE_ECHOCANCEL:
		{
			int level = 0;
			err = ioctl(ftdmchan->sockfd, DAHDI_ECHOCANCEL, &level);
			FTDM_COMMAND_OBJ_INT = level;
		}
		break;
	case FTDM_COMMAND_ENABLE_ECHOTRAIN:
		{
			int level = FTDM_COMMAND_OBJ_INT;
			err = ioctl(ftdmchan->sockfd, DAHDI_ECHOTRAIN, &level);
			FTDM_COMMAND_OBJ_INT = level;
		}
	case FTDM_COMMAND_DISABLE_ECHOTRAIN:
		{
			int level = 0;
			err = ioctl(ftdmchan->sockfd, DAHDI_ECHOTRAIN, &level);
			FTDM_COMMAND_OBJ_INT = level;
		}
		break;
	case FTDM_COMMAND_OFFHOOK:
		{
			int command = ZT_OFFHOOK;
			if (ioctl(ftdmchan->sockfd, DAHDI_HOOK, &command)) {
				ftdm_log_chan_msg(ftdmchan, FTDM_LOG_ERROR, "OFFHOOK Failed");
				return FTDM_FAIL;
			}
			ftdm_log_chan_msg(ftdmchan, FTDM_LOG_DEBUG, "Channel is now offhook\n");
			ftdm_set_flag_locked(ftdmchan, FTDM_CHANNEL_OFFHOOK);
		}
		break;
	case FTDM_COMMAND_ONHOOK:
		{
			int command = ZT_ONHOOK;
			if (ioctl(ftdmchan->sockfd, DAHDI_HOOK, &command)) {
				ftdm_log_chan_msg(ftdmchan, FTDM_LOG_ERROR, "ONHOOK Failed");
				return FTDM_FAIL;
			}
			ftdm_log_chan_msg(ftdmchan, FTDM_LOG_DEBUG, "Channel is now onhook\n");
			ftdm_clear_flag_locked(ftdmchan, FTDM_CHANNEL_OFFHOOK);
		}
		break;
	case FTDM_COMMAND_FLASH:
		{
			int command = ZT_FLASH;
			if (ioctl(ftdmchan->sockfd, DAHDI_HOOK, &command)) {
				ftdm_log_chan_msg(ftdmchan, FTDM_LOG_ERROR, "FLASH Failed");
				return FTDM_FAIL;
			}
		}
		break;
	case FTDM_COMMAND_WINK:
		{
			int command = ZT_WINK;
			if (ioctl(ftdmchan->sockfd, DAHDI_HOOK, &command)) {
				ftdm_log_chan_msg(ftdmchan, FTDM_LOG_ERROR, "WINK Failed");
				return FTDM_FAIL;
			}
		}
		break;
	case FTDM_COMMAND_GENERATE_RING_ON:
		{
			int command = ZT_RING;
			if (ioctl(ftdmchan->sockfd, DAHDI_HOOK, &command)) {
				ftdm_log_chan_msg(ftdmchan, FTDM_LOG_ERROR, "RING Failed");
				return FTDM_FAIL;
			}
			ftdm_set_flag_locked(ftdmchan, FTDM_CHANNEL_RINGING);
		}
		break;
	case FTDM_COMMAND_GENERATE_RING_OFF:
		{
			int command = ZT_RINGOFF;
			if (ioctl(ftdmchan->sockfd, DAHDI_HOOK, &command)) {
				ftdm_log_chan_msg(ftdmchan, FTDM_LOG_ERROR, "Ring-off Failed");
				return FTDM_FAIL;
			}
			ftdm_clear_flag_locked(ftdmchan, FTDM_CHANNEL_RINGING);
		}
		break;
	case FTDM_COMMAND_GET_INTERVAL:
		{

			if (!(err = ioctl(ftdmchan->sockfd, DAHDI_GET_BLOCKSIZE, &ftdmchan->packet_len))) {
				ftdmchan->native_interval = ftdmchan->packet_len / 8;
				if (ftdmchan->effective_codec == FTDM_CODEC_SLIN) {
					ftdmchan->packet_len *= 2;
				}
				FTDM_COMMAND_OBJ_INT = ftdmchan->native_interval;
			} 			
		}
		break;
	case FTDM_COMMAND_SET_INTERVAL: 
		{
			int interval = FTDM_COMMAND_OBJ_INT;
			int len = interval * 8;

			if (!(err = ioctl(ftdmchan->sockfd, DAHDI_SET_BLOCKSIZE, &len))) {
				ftdmchan->packet_len = len;
				ftdmchan->effective_interval = ftdmchan->native_interval = ftdmchan->packet_len / 8;

				if (ftdmchan->effective_codec == FTDM_CODEC_SLIN) {
					ftdmchan->packet_len *= 2;
				}
			}
		}
		break;
	case FTDM_COMMAND_SET_CAS_BITS:
		{
			int bits = FTDM_COMMAND_OBJ_INT;
			err = ioctl(ftdmchan->sockfd, DAHDI_SETTXBITS, &bits);
		}
		break;
	case FTDM_COMMAND_GET_CAS_BITS:
		{
			err = ioctl(ftdmchan->sockfd, DAHDI_GETRXBITS, &ftdmchan->rx_cas_bits);
			if (!err) {
				FTDM_COMMAND_OBJ_INT = ftdmchan->rx_cas_bits;
			}
		}
		break;
	case FTDM_COMMAND_FLUSH_TX_BUFFERS:
		{
			int flushmode = ZT_FLUSH_WRITE;
			err = ioctl(ftdmchan->sockfd, DAHDI_FLUSH, &flushmode);
		}
		break;
	case FTDM_COMMAND_SET_POLARITY:
		{
			ftdm_polarity_t polarity = FTDM_COMMAND_OBJ_INT;
			err = ioctl(ftdmchan->sockfd, DAHDI_SETPOLARITY, polarity);
			if (!err) {
				ftdmchan->polarity = polarity;
			}
		}
		break;
	case FTDM_COMMAND_FLUSH_RX_BUFFERS:
		{
			int flushmode = ZT_FLUSH_READ;
			err = ioctl(ftdmchan->sockfd, DAHDI_FLUSH, &flushmode);
		}
		break;
	case FTDM_COMMAND_FLUSH_BUFFERS:
		{
			int flushmode = ZT_FLUSH_BOTH;
			err = ioctl(ftdmchan->sockfd, DAHDI_FLUSH, &flushmode);
		}
		break;
	case FTDM_COMMAND_SET_RX_QUEUE_SIZE: @;
	case FTDM_COMMAND_SET_TX_QUEUE_SIZE:
		/* little white lie ... eventually we can implement this, in the meantime, not worth the effort
		   and this is only used by some sig modules such as ftmod\_r2 to behave bettter under load */
		err = 0;
		break;
	case FTDM_COMMAND_ENABLE_DTMF_DETECT:
		{
			zt_tone_mode_t mode = ZT_TONEDETECT_ON | ZT_TONEDETECT_MUTE;
			err = ioctl(ftdmchan->sockfd, DAHDI_TONEDETECT, &mode);
		}
		break;
	case FTDM_COMMAND_DISABLE_DTMF_DETECT:
		{
			zt_tone_mode_t mode = 0;
			err = ioctl(ftdmchan->sockfd, DAHDI_TONEDETECT, &mode);
		}
		break;
	default:
		err = FTDM_NOTIMPL;
		break;
	}

	if (err && err != FTDM_NOTIMPL) {
		snprintf(ftdmchan->last_error, sizeof ftdmchan->last_error, "%s", strerror(errno));
		return FTDM_FAIL;
	}

	return err == 0 ? FTDM_SUCCESS : err;
}

@ Gets alarms from a DAHDI channel. Returns success or failure.

* \.{ftdmchan}\quad Channel to get alarms from

@c
static ftdm_status_t zt_get_alarms(ftdm_channel_t *ftdmchan)
{
  struct zt_spaninfo info;
  zt_params_t params;

  memset(&info, 0, sizeof info);
  info.span_no = ftdmchan->physical_span_id;

  memset(&params, 0, sizeof params);

  if (ioctl(CONTROL_FD, DAHDI_SPANSTAT, &info)) {
    snprintf(ftdmchan->last_error, sizeof ftdmchan->last_error, "ioctl failed (%m)");
    snprintf(ftdmchan->span->last_error, sizeof ftdmchan->span->last_error, "ioctl failed (%m)");
    return FTDM_FAIL;
  }

  ftdmchan->alarm_flags = info.alarms;

  if (info.alarms == FTDM_ALARM_NONE) { /* get channel alarms if span has no alarms */
    if (ioctl(ftdmchan->sockfd, DAHDI_GET_PARAMS, &params)) {
      snprintf(ftdmchan->last_error, sizeof ftdmchan->last_error, "ioctl failed (%m)");
      snprintf(ftdmchan->span->last_error, sizeof ftdmchan->span->last_error,
        "ioctl failed (%m)");
      return FTDM_FAIL;
    }

    if (params.chan_alarms > 0) {
      if (params.chan_alarms == DAHDI_ALARM_YELLOW)
        ftdmchan->alarm_flags = FTDM_ALARM_YELLOW;
      else if (params.chan_alarms == DAHDI_ALARM_BLUE)
        ftdmchan->alarm_flags = FTDM_ALARM_BLUE;
      else
	ftdmchan->alarm_flags = FTDM_ALARM_RED;
    }
  }

  return FTDM_SUCCESS;
}

#define ftdm_zt_set_event_pending(fchan) \
	do { \
		ftdm_set_io_flag(fchan, FTDM_CHANNEL_IO_EVENT); \
		fchan->last_event_time = ftdm_current_time_in_ms(); \
	} while (0);

#define ftdm_zt_store_chan_event(fchan, revent) \
  do { \
    if (fchan->io_data) \
	ftdm_log_chan(fchan, FTDM_LOG_WARNING, "Dropping event %d, not retrieved on time\n", revent); \
    fchan->io_data = (void *)zt_event_id; \
    ftdm_zt_set_event_pending(fchan); \
  } while (0);

@ Waits for an event on a DAHDI channel. Returns success, failure or timeout.
{\settabs\+\hskip100pt&\cr
\+ * \.{ftdmchan}& Channel to open\cr
\+ * \.{flags}& Type of event to wait for\cr
\+ * \.{to}& Time to wait (in ms)\cr
}

@c
static ftdm_status_t zt_wait(ftdm_channel_t *ftdmchan, ftdm_wait_flag_t *flags, int32_t to)
{
	int32_t inflags = 0;
	int result;
	struct pollfd pfds[1];

	if (*flags & FTDM_READ)
		inflags |= POLLIN;

	if (*flags & FTDM_WRITE)
		inflags |= POLLOUT;

	if (*flags & FTDM_EVENTS)
		inflags |= POLLPRI;

pollagain: @/
	memset(&pfds[0], 0, sizeof pfds[0]);
	pfds[0].fd = ftdmchan->sockfd;
	pfds[0].events = inflags;
	result = poll(pfds, 1, to);
	*flags = FTDM_NO_FLAGS;

	if (result < 0 && errno == EINTR) {
		ftdm_log_chan_msg(ftdmchan, FTDM_LOG_DEBUG, "DAHDI wait got interrupted, trying again\n");
		goto pollagain;
	}

	if (pfds[0].revents & POLLERR) {
		ftdm_log_chan_msg(ftdmchan, FTDM_LOG_ERROR, "DAHDI device got POLLERR\n");
		result = -1;
	}

	if (result > 0)
		inflags = pfds[0].revents;

	if (result < 0){
		snprintf(ftdmchan->last_error, sizeof ftdmchan->last_error, "Poll failed");
		ftdm_log_chan(ftdmchan, FTDM_LOG_ERROR, "Failed to poll DAHDI device: %s\n", strerror(errno));
		return FTDM_FAIL;
	}

	if (result == 0)
		return FTDM_TIMEOUT;

	if (inflags & POLLIN)
		*flags |= FTDM_READ;

	if (inflags & POLLOUT)
		*flags |= FTDM_WRITE;

	if ((inflags & POLLPRI) || (ftdmchan->io_data && (*flags & FTDM_EVENTS)))
		*flags |= FTDM_EVENTS;

	return FTDM_SUCCESS;

}

@ Checks for events on a DAHDI span. Returns success if event is waiting or failure if not.
{\settabs\+\hskip100pt&\cr
\+ * \.{span}& Span to check for events\cr
\+ * \.{ms}& Time to wait for event\cr
}

@<Function prototypes@>=
ftdm_status_t zt_poll_event(ftdm_span_t *span, uint32_t ms, short *poll_events);

@ @c
ftdm_status_t zt_poll_event(ftdm_span_t *span, uint32_t ms, short *poll_events)
{
	struct pollfd pfds[FTDM_MAX_CHANNELS_SPAN];
	uint32_t i, j = 0, k = 0;
	int r;

	ftdm_unused_arg(poll_events);

	for(i = 1; i <= span->chan_count; i++) {
		memset(&pfds[j], 0, sizeof pfds[j]);
		pfds[j].fd = span->channels[i]->sockfd;
		pfds[j].events = POLLPRI;
		j++;
	}

	r = poll(pfds, j, ms);

	if (r == 0)
		return FTDM_TIMEOUT;
	else if (r < 0) {
		snprintf(span->last_error, sizeof span->last_error, "%s", strerror(errno));
		return FTDM_FAIL;
	}

	for(i = 1; i <= span->chan_count; i++) {

		ftdm_channel_lock(span->channels[i]);

 		if (pfds[i-1].revents & POLLERR) {
			ftdm_log_chan(span->channels[i], FTDM_LOG_ERROR, "POLLERR, flags=%d\n", pfds[i-1].events);

			ftdm_channel_unlock(span->channels[i]);

			continue;
		}
		if ((pfds[i-1].revents & POLLPRI) || (span->channels[i]->io_data)) {
			ftdm_zt_set_event_pending(span->channels[i]);
			k++;
		}
		if (pfds[i-1].revents & POLLIN)
			ftdm_set_io_flag(span->channels[i], FTDM_CHANNEL_IO_READ);
		if (pfds[i-1].revents & POLLOUT)
			ftdm_set_io_flag(span->channels[i], FTDM_CHANNEL_IO_WRITE);

		ftdm_channel_unlock(span->channels[i]);

	}

	if (!k)
		snprintf(span->last_error, sizeof span->last_error, "no matching descriptor");

	return k ? FTDM_SUCCESS : FTDM_FAIL;
}

__inline__ int handle_dtmf_event(ftdm_channel_t *fchan, zt_event_t zt_event_id)
{
  if ((zt_event_id & ZT_EVENT_DTMFUP)) {
    int digit = (zt_event_id & (~ZT_EVENT_DTMFUP));
    char tmp_dtmf[2] = { digit, 0 };
    ftdm_log_chan(fchan, FTDM_LOG_DEBUG, "DTMF UP [%d]\n", digit);
    ftdm_channel_queue_dtmf(fchan, tmp_dtmf);
    return 1;
  }
  else if ((zt_event_id & ZT_EVENT_DTMFDOWN)) {
    int digit = (zt_event_id & (~ZT_EVENT_DTMFDOWN));
    ftdm_log_chan(fchan, FTDM_LOG_DEBUG, "DTMF DOWN [%d]\n", digit);
    return 1;
  }
  else
    return 0;
}

@ Process an event from a ftdmchan and set the proper OOB event\_id. The channel must be locked.
{\settabs\+\hskip100pt&\cr
\+ * \.{fchan}& Channel to retrieve event from\cr
\+ * \.{event\_id}& Pointer to OOB event id\cr
\+ * \.{zt\_event\_id}& Zaptel event id\cr
}

@c
static __inline__ ftdm_status_t zt_channel_process_event(ftdm_channel_t *fchan,
  ftdm_oob_event_t *event_id, zt_event_t zt_event_id)
{
  ftdm_log_chan(fchan, FTDM_LOG_DEBUG, "Processing zap hardware event %d\n", zt_event_id);
  switch(zt_event_id) {
    case ZT_EVENT_RINGEROFF:
      ftdm_log_chan_msg(fchan, FTDM_LOG_DEBUG, "ZT RINGER OFF\n");
      *event_id = FTDM_OOB_NOOP;
      break;
    case ZT_EVENT_RINGERON:
      ftdm_log_chan_msg(fchan, FTDM_LOG_DEBUG, "ZT RINGER ON\n");
      *event_id = FTDM_OOB_NOOP;
      break;
    case ZT_EVENT_RINGBEGIN:
      *event_id = FTDM_OOB_RING_START;
      break;
    case ZT_EVENT_ONHOOK:
      *event_id = FTDM_OOB_ONHOOK;
      break;
    case ZT_EVENT_WINKFLASH:
      if (fchan->state == FTDM_CHANNEL_STATE_DOWN || fchan->state == FTDM_CHANNEL_STATE_DIALING)
        *event_id = FTDM_OOB_WINK;
      else
        *event_id = FTDM_OOB_FLASH;
      break;
    case ZT_EVENT_RINGOFFHOOK:
      *event_id = FTDM_OOB_NOOP;
      if (fchan->type == FTDM_CHAN_TYPE_FXS) {
        ftdm_set_flag_locked(fchan, FTDM_CHANNEL_OFFHOOK);
        *event_id = FTDM_OOB_OFFHOOK;
      }
      else if (fchan->type == FTDM_CHAN_TYPE_FXO)
        *event_id = FTDM_OOB_RING_START;
      break;
    case ZT_EVENT_ALARM:
      *event_id = FTDM_OOB_ALARM_TRAP;
      break;
    case ZT_EVENT_NOALARM:
      *event_id = FTDM_OOB_ALARM_CLEAR;
      break;
    case ZT_EVENT_BITSCHANGED:
      {
        *event_id = FTDM_OOB_CAS_BITS_CHANGE;
        int bits = 0;
        int err = ioctl(fchan->sockfd, DAHDI_GETRXBITS, &bits);
        if (err)
          return FTDM_FAIL;
        fchan->rx_cas_bits = bits;
      }
      break;
    case ZT_EVENT_BADFCS:
      ftdm_log_chan_msg(fchan, FTDM_LOG_ERROR, "Bad frame checksum (ZT_EVENT_BADFCS)\n");
      *event_id = FTDM_OOB_NOOP; /* What else could we do? */
      break;
    case ZT_EVENT_OVERRUN:
      ftdm_log_chan_msg(fchan, FTDM_LOG_ERROR, "HDLC frame overrun (ZT_EVENT_OVERRUN)\n");
      *event_id = FTDM_OOB_NOOP;	/* What else could we do? */
      break;
    case ZT_EVENT_ABORT:
      ftdm_log_chan_msg(fchan, FTDM_LOG_ERROR, "HDLC abort frame received (ZT_EVENT_ABORT)\n");
      *event_id = FTDM_OOB_NOOP; /* What else could we do? */
      break;
    case ZT_EVENT_POLARITY:
      ftdm_log_chan_msg(fchan, FTDM_LOG_ERROR, "Got polarity reverse (ZT_EVENT_POLARITY)\n");
      *event_id = FTDM_OOB_POLARITY_REVERSE;
      break;
    case ZT_EVENT_NONE:
      ftdm_log_chan_msg(fchan, FTDM_LOG_DEBUG, "No event\n");
      *event_id = FTDM_OOB_NOOP;
      break;
    default:
      if (handle_dtmf_event(fchan, zt_event_id))
        *event_id = FTDM_OOB_NOOP;
      else {
        ftdm_log_chan(fchan, FTDM_LOG_WARNING, "Unhandled event %d\n", zt_event_id);
        *event_id = FTDM_OOB_INVALID;
      }
      break;
  }
  return FTDM_SUCCESS;
}

@ Retrieves an event from a ftdm channel. Returns success or failure.
{\settabs\+\hskip100pt&\cr
\+ * \.{ftdmchan}& Channel to retrieve event from\cr
\+ * \.{event}& FreeTDM event to return\cr
}

@<Function prototypes@>=
ftdm_status_t zt_channel_next_event(ftdm_channel_t *ftdmchan, ftdm_event_t **event);

@ @c
ftdm_status_t zt_channel_next_event(ftdm_channel_t *ftdmchan, ftdm_event_t **event)
{
  uint32_t event_id = FTDM_OOB_INVALID;
  zt_event_t zt_event_id = 0;
  ftdm_span_t *span = ftdmchan->span;

  if (ftdm_test_io_flag(ftdmchan, FTDM_CHANNEL_IO_EVENT))
    ftdm_clear_io_flag(ftdmchan, FTDM_CHANNEL_IO_EVENT);

  if (ftdmchan->io_data) {
    zt_event_id = (zt_event_t)ftdmchan->io_data;
    ftdmchan->io_data = NULL;
  }
  else if (ioctl(ftdmchan->sockfd, DAHDI_GETEVENT, &zt_event_id) == -1) {
    ftdm_log_chan(ftdmchan, FTDM_LOG_ERROR, "Failed retrieving event from channel: %s\n",
      strerror(errno));
    return FTDM_FAIL;
  }

  if ((zt_channel_process_event(ftdmchan, &event_id, zt_event_id)) != FTDM_SUCCESS) {
    /* the core already locked the channel for us, so it's safe to call
       |zt_channel_process_event| here */
    ftdm_log_chan(ftdmchan, FTDM_LOG_ERROR, "Failed to process DAHDI event %d from channel\n",
      zt_event_id);
    return FTDM_FAIL;
  }

  ftdmchan->last_event_time = 0;
  span->event_header.e_type = FTDM_EVENT_OOB;
  span->event_header.enum_id = event_id;
  span->event_header.channel = ftdmchan;
  *event = &span->event_header;
  return FTDM_SUCCESS;
}

@ Retrieves an event from a DAHDI span. Returns success or failure.
{\settabs\+\hskip100pt&\cr
\+ * \.{span}& Span to retrieve event from\cr
\+ * \.{event}& FreeTDM event to return\cr
}

@<Function prototypes@>=
ftdm_status_t zt_next_event(ftdm_span_t *span, ftdm_event_t **event);

@ @c
ftdm_status_t zt_next_event(ftdm_span_t *span, ftdm_event_t **event)
{
  uint32_t i, event_id = FTDM_OOB_INVALID;
  zt_event_t zt_event_id = 0;

  for (i = 1; i <= span->chan_count; i++) {
    ftdm_channel_t *fchan = span->channels[i];

    ftdm_channel_lock(fchan);

    if (!ftdm_test_io_flag(fchan, FTDM_CHANNEL_IO_EVENT)) {
      ftdm_channel_unlock(fchan);
      continue;
    }

    ftdm_clear_io_flag(fchan, FTDM_CHANNEL_IO_EVENT);

    if (fchan->io_data) {
      zt_event_id = (zt_event_t)fchan->io_data;
      fchan->io_data = NULL;
    }
    else if (ioctl(fchan->sockfd, DAHDI_GETEVENT, &zt_event_id) == -1) {
      ftdm_log_chan(fchan, FTDM_LOG_ERROR, "Failed to retrieve DAHDI event from channel: %s\n",
        strerror(errno));
      ftdm_channel_unlock(fchan);
      continue;
    }

    if ((zt_channel_process_event(fchan, &event_id, zt_event_id)) != FTDM_SUCCESS) {
      ftdm_log_chan(fchan, FTDM_LOG_ERROR, "Failed to process DAHDI event %d from channel\n",
        zt_event_id);
      ftdm_channel_unlock(fchan);
      return FTDM_FAIL;
    }

    fchan->last_event_time = 0;
    span->event_header.e_type = FTDM_EVENT_OOB;
    span->event_header.enum_id = event_id;
    span->event_header.channel = fchan;
    *event = &span->event_header;

    ftdm_channel_unlock(fchan);

    return FTDM_SUCCESS;
  }

  return FTDM_FAIL;
}

@ Reads data from a DAHDI channel. Returns success, failure or timeout.
{\settabs\+\hskip100pt&\cr
\+ * \.{ftdmchan}& Channel to read from\cr
\+ * \.{data}& Data buffer\cr
\+ * \.{datalen}& Size of data buffer\cr
}

@c
static ftdm_status_t zt_read(ftdm_channel_t *ftdmchan, void *data, ftdm_size_t *datalen)
{
  ftdm_ssize_t r = 0;
  int read_errno = 0;
  int errs = 0;

  while (errs++ < 30) {
    r = read(ftdmchan->sockfd, data, *datalen);
    if (r > 0) break; /* successful read, bail out now */
    if (r == 0) { /* timeout, retry after a bit */
      ftdm_sleep(10);
      if (errs) errs--;
      continue;
    }

    read_errno = errno; /* save errno in case we do operations which may reset it */
    if (read_errno == EAGAIN || read_errno == EINTR)
      continue; /* Reasonable to retry under those errors */

    if (read_errno == ELAST) { /* when \.{ELAST} is returned, it means DAHDI has an out of band
        event ready and we won't be able to read anything until we retrieve the event using an
        |ioctl|, so we try to retrieve it here */
      zt_event_t zt_event_id = 0;
      if (ioctl(ftdmchan->sockfd, DAHDI_GETEVENT, &zt_event_id) == -1) {
        ftdm_log_chan(ftdmchan, FTDM_LOG_ERROR,
          "Failed retrieving event after ELAST on read: %s\n", strerror(errno));
        r = -1;
        break;
      }

      if (handle_dtmf_event(ftdmchan, zt_event_id))
        ftdm_log_chan_msg(ftdmchan, FTDM_LOG_DEBUG,
          "Skipping one IO read cycle due to DTMF event processing\n");
      else {
        ftdm_log_chan(ftdmchan, FTDM_LOG_DEBUG,
          "Deferring event %d to be able to read data\n", zt_event_id);
        ftdm_zt_store_chan_event(ftdmchan, zt_event_id); /* enqueue this event for later */
      }

      break;
    }

    ftdm_log(FTDM_LOG_ERROR, "IO read failed: %s\n", strerror(read_errno));
      /* read error, keep going unless to many errors force us to abort ...*/
  }

  if (r > 0) {
    *datalen = r;
    return FTDM_SUCCESS;
  }
  else if (read_errno == ELAST)
    return FTDM_SUCCESS;
  return r == 0 ? FTDM_TIMEOUT : FTDM_FAIL;
}

@ Writes data to a DAHDI channel. Returns success or failure.
{\settabs\+\hskip100pt&\cr
\+ * \.{ftdmchan}& Channel to write to\cr
\+ * \.{data}& Data buffer\cr
\+ * \.{datalen}& Size of data buffer\cr
}

@c
static ftdm_status_t zt_write(ftdm_channel_t *ftdmchan, void *data, ftdm_size_t *datalen)
{
  ftdm_ssize_t w = 0;
  ftdm_size_t bytes = *datalen;

  if (ftdmchan->type == FTDM_CHAN_TYPE_DQ921) {
    memset(data+bytes, 0, 2);
    bytes += 2;
  }

tryagain: @/
  w = write(ftdmchan->sockfd, data, bytes);
	
  if (w >= 0) {
    *datalen = w;
    return FTDM_SUCCESS;
  }

  if (errno == ELAST) {
    zt_event_t zt_event_id = 0;
    if (ioctl(ftdmchan->sockfd, DAHDI_GETEVENT, &zt_event_id) == -1) {
      ftdm_log_chan(ftdmchan, FTDM_LOG_ERROR,
        "Failed retrieving event after ELAST on write: %s\n", strerror(errno));
      return FTDM_FAIL;
    }

    if (!handle_dtmf_event(ftdmchan, zt_event_id)) {
      ftdm_log_chan(ftdmchan, FTDM_LOG_DEBUG,
        "Deferring event %d to be able to write data\n", zt_event_id);
      ftdm_zt_store_chan_event(ftdmchan, zt_event_id); /* enqueue this event for later */
    }

    goto tryagain;
  }

  return FTDM_FAIL;
}

@ Destroys a DAHDI Channel.

* \.{ftdmchan} Channel to destroy

@c
static ftdm_status_t zt_channel_destroy(ftdm_channel_t *ftdmchan)
{
  close(ftdmchan->sockfd);
  ftdmchan->sockfd = ZT_INVALID_SOCKET;
  return FTDM_SUCCESS;
}

@ Global FreeTDM IO interface for DAHDI.

@c
ftdm_io_interface_t zt_interface;

@ Loads DAHDI IO module. Returns success or failure.

* \.{fio}\quad FreeTDM IO interface

@c
static ftdm_status_t zt_init(ftdm_io_interface_t **fio)
{
  assert(fio != NULL);
  struct stat statbuf;
  memset(&zt_interface, 0, sizeof zt_interface);
  memset(&zt_globals, 0, sizeof zt_globals);

  if (stat("/dev/dahdi/ctl", &statbuf) != 0) {
    ftdm_log(FTDM_LOG_ERROR, "No DAHDI control device found in /dev/\n");
    return FTDM_FAIL;
  }
  if ((CONTROL_FD = open("/dev/dahdi/ctl", O_RDWR)) < 0) {
    ftdm_log(FTDM_LOG_ERROR, "Cannot open control device /dev/dahdi/ctl: %s\n", strerror(errno));
    return FTDM_FAIL;
  }

  zt_globals.codec_ms = 20;
  zt_globals.wink_ms = 150;
  zt_globals.flash_ms = 750;
  zt_globals.eclevel = 0;
  zt_globals.etlevel = 0;
	
  zt_interface.name = "zt";
  zt_interface.configure = zt_configure;
  zt_interface.configure_span = zt_configure_span;
  zt_interface.open = zt_open;
  zt_interface.close = zt_close;
  zt_interface.command = zt_command;
  zt_interface.wait = zt_wait;
  zt_interface.read = zt_read;
  zt_interface.write = zt_write;
  zt_interface.poll_event = zt_poll_event;
  zt_interface.next_event = zt_next_event;
  zt_interface.channel_next_event = zt_channel_next_event;
  zt_interface.channel_destroy = zt_channel_destroy;
  zt_interface.get_alarms = zt_get_alarms;
  *fio = &zt_interface;

  return FTDM_SUCCESS;
}

@ Unloads DAHDI IO module.

@c
static ftdm_status_t zt_destroy(void)
{
  close(CONTROL_FD);
  memset(&zt_interface, 0, sizeof zt_interface);
  return FTDM_SUCCESS;
}

@ FreeTDM DAHDI IO module definition.
@s ftdm_module_t int
@c
ftdm_module_t ftdm_module = { @t\1@> @/
  "zt", @/
  zt_init, @/
@t\2@> zt_destroy @/
};

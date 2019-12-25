@ @c
#if !defined(_XOPEN_SOURCE)
#define _XOPEN_SOURCE 600
#endif
#include <errno.h>
#include <fcntl.h>
#include <math.h>
#include <poll.h> /* |POLLERR|, |POLLIN|, |POLLOUT| */
#include <stdio.h>
#include <stdint.h>
#include <stdarg.h>
#include <stdlib.h>
#include <strings.h>
#include <sys/ioctl.h>
#include <time.h>
#include <wchar.h>
#include <stddef.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <dahdi/user.h>

#define FTDM_PRE __FILE__, __func__, __LINE__
#define FTDM_LOG_DEBUG FTDM_PRE, 7
#define FTDM_LOG_INFO FTDM_PRE, 6
#define FTDM_LOG_WARNING FTDM_PRE, 4
#define FTDM_LOG_ERROR FTDM_PRE, 3
#define FTDM_LOG_EMERG FTDM_PRE, 0

typedef enum {
  FTDM_SUCCESS,
  FTDM_FAIL,
  FTDM_MEMERR,
  FTDM_ENOMEM = FTDM_MEMERR,
  FTDM_TIMEOUT,
  FTDM_ETIMEDOUT = FTDM_TIMEOUT,
  FTDM_NOTIMPL,
  FTDM_ENOSYS = FTDM_NOTIMPL,
  FTDM_BREAK,
  FTDM_EINVAL,
  FTDM_ECANCELED,
  FTDM_EBUSY,
} ftdm_status_t;

typedef enum {
  FTDM_FALSE,
  FTDM_TRUE
} ftdm_bool_t;

typedef enum {
  FTDM_NO_FLAGS = 0,
  FTDM_READ = (1 << 0),
  FTDM_WRITE = (1 << 1),
  FTDM_EVENTS = (1 << 2)
} ftdm_wait_flag_t;

typedef struct ftdm_channel ftdm_channel_t;
typedef struct ftdm_span ftdm_span_t;

typedef struct ftdm_event ftdm_event_t;
typedef struct ftdm_conf_node ftdm_conf_node_t;
typedef struct ftdm_sigmsg ftdm_sigmsg_t;
typedef struct ftdm_usrmsg ftdm_usrmsg_t;
typedef struct ftdm_io_interface ftdm_io_interface_t;
typedef struct ftdm_stream_handle ftdm_stream_handle_t;
typedef struct ftdm_queue ftdm_queue_t;
typedef struct ftdm_memory_handler ftdm_memory_handler_t;

typedef struct ftdm_mutex ftdm_mutex_t;
typedef struct ftdm_interrupt ftdm_interrupt_t;

ftdm_status_t _ftdm_mutex_lock(const char *file, int line, const char *func, ftdm_mutex_t *mutex);
ftdm_status_t _ftdm_mutex_unlock(const char *file, int line, const char *func, ftdm_mutex_t *mutex);
typedef uint64_t ftdm_time_t;
ftdm_time_t ftdm_current_time_in_ms(void);

typedef enum {
  FTDM_HUNT_TOP_DOWN,
  FTDM_HUNT_BOTTOM_UP,
  FTDM_HUNT_RR_DOWN,
  FTDM_HUNT_RR_UP,
} ftdm_hunt_direction_t;

typedef enum {
  FTDM_BOTTOM_UP,
  FTDM_TOP_DOWN,
  FTDM_RR_UP,
  FTDM_RR_DOWN,
} ftdm_direction_t;

typedef void (*ftdm_logger_t)(const char *file, const char *func, int line,
                              int level, const char *fmt, ...)
    __attribute__ ( (format(printf, 5, 6)));

typedef ftdm_status_t(*ftdm_queue_create_func_t) (ftdm_queue_t ** queue,
                                                  size_t capacity);
typedef ftdm_status_t(*ftdm_queue_enqueue_func_t) (ftdm_queue_t * queue,
                                                   void *obj);
typedef void *(*ftdm_queue_dequeue_func_t)(ftdm_queue_t * queue);
typedef ftdm_status_t(*ftdm_queue_wait_func_t) (ftdm_queue_t * queue,
                                                int ms);
typedef ftdm_status_t(*ftdm_queue_get_interrupt_func_t) (ftdm_queue_t *
                                                         queue,
                                                         ftdm_interrupt_t
                                                         ** interrupt);
typedef ftdm_status_t(*ftdm_queue_destroy_func_t) (ftdm_queue_t ** queue);

typedef struct ftdm_queue_handler {
  ftdm_queue_create_func_t create;
  ftdm_queue_enqueue_func_t enqueue;
  ftdm_queue_dequeue_func_t dequeue;
  ftdm_queue_wait_func_t wait;
  ftdm_queue_get_interrupt_func_t get_interrupt;
  ftdm_queue_destroy_func_t destroy;
} ftdm_queue_handler_t;

typedef enum {
  FTDM_CPC_UNKNOWN,
  FTDM_CPC_OPERATOR,
  FTDM_CPC_OPERATOR_FRENCH,
  FTDM_CPC_OPERATOR_ENGLISH,
  FTDM_CPC_OPERATOR_GERMAN,
  FTDM_CPC_OPERATOR_RUSSIAN,
  FTDM_CPC_OPERATOR_SPANISH,
  FTDM_CPC_ORDINARY,
  FTDM_CPC_PRIORITY,
  FTDM_CPC_DATA,
  FTDM_CPC_TEST,
  FTDM_CPC_PAYPHONE,
  FTDM_CPC_INVALID
} ftdm_calling_party_category_t;

typedef enum {
  FTDM_TRANSFER_RESPONSE_OK,
  FTDM_TRANSFER_RESPONSE_CP_DROP_OFF,
  FTDM_TRANSFER_RESPONSE_LIMITS_EXCEEDED,
  FTDM_TRANSFER_RESPONSE_INVALID_NUM,
  FTDM_TRANSFER_RESPONSE_INVALID_COMMAND,
  FTDM_TRANSFER_RESPONSE_TIMEOUT,
  FTDM_TRANSFER_RESPONSE_INVALID,
} ftdm_transfer_response_t;

typedef struct {
  char digits[64];
  uint8_t type;
  uint8_t plan;
} ftdm_number_t;

typedef struct ftdm_caller_data {
  char cid_date[8];
  char cid_name[80];
  ftdm_number_t cid_num;
  ftdm_number_t ani;
  ftdm_number_t dnis;
  ftdm_number_t rdnis;
  ftdm_number_t loc;
  char aniII[64];
  uint8_t screen;
  uint8_t pres;
  char collected[64];
  int hangup_cause;
  ftdm_calling_party_category_t cpc;
  uint32_t call_reference;
  ftdm_channel_t *fchan;
  uint32_t call_id;
  void *priv;
} ftdm_caller_data_t;

typedef enum {
  FTDM_TONE_DTMF = (1 << 0)
} ftdm_tone_type_t;

typedef enum {
  FTDM_SIGEVENT_START,
  FTDM_SIGEVENT_STOP,
  FTDM_SIGEVENT_RELEASED,
  FTDM_SIGEVENT_UP,
  FTDM_SIGEVENT_FLASH,
  FTDM_SIGEVENT_PROCEED,
  FTDM_SIGEVENT_RINGING,
  FTDM_SIGEVENT_PROGRESS,
  FTDM_SIGEVENT_PROGRESS_MEDIA,
  FTDM_SIGEVENT_ALARM_TRAP,
  FTDM_SIGEVENT_ALARM_CLEAR,
  FTDM_SIGEVENT_COLLECTED_DIGIT,
  FTDM_SIGEVENT_ADD_CALL,
  FTDM_SIGEVENT_RESTART,
  FTDM_SIGEVENT_SIGSTATUS_CHANGED,
  FTDM_SIGEVENT_FACILITY,
  FTDM_SIGEVENT_TRACE,
  FTDM_SIGEVENT_TRACE_RAW,
  FTDM_SIGEVENT_INDICATION_COMPLETED,
  FTDM_SIGEVENT_DIALING,
  FTDM_SIGEVENT_TRANSFER_COMPLETED,
  FTDM_SIGEVENT_SMS,
  FTDM_SIGEVENT_INVALID,
} ftdm_signal_event_t;

typedef struct ftdm_channel_config {
  char name[128];
  char number[32];
  char group_name[128];
  float rxgain;
  float txgain;
  uint8_t debugdtmf;
  uint8_t dtmf_on_start;
  uint32_t dtmfdetect_ms;
  uint32_t dtmf_time_on;
  uint32_t dtmf_time_off;
  uint8_t iostats;
} ftdm_channel_config_t;

typedef enum {
  FTDM_SIG_STATE_DOWN,
  FTDM_SIG_STATE_SUSPENDED,
  FTDM_SIG_STATE_UP,
  FTDM_SIG_STATE_INVALID
} ftdm_signaling_status_t;

typedef struct {
  ftdm_signaling_status_t status;
} ftdm_event_sigstatus_t;

typedef enum {
  FTDM_TRACE_DIR_INCOMING,
  FTDM_TRACE_DIR_OUTGOING,
  FTDM_TRACE_DIR_INVALID,
} ftdm_trace_dir_t;

typedef enum {
  FTDM_TRACE_TYPE_Q931,
  FTDM_TRACE_TYPE_Q921,
  FTDM_TRACE_TYPE_INVALID,
} ftdm_trace_type_t;

typedef struct {
  ftdm_trace_dir_t dir;
  ftdm_trace_type_t type;
} ftdm_event_trace_t;

typedef struct {
  char digits[64];
} ftdm_event_collected_t;

typedef enum {
  FTDM_CHANNEL_INDICATE_NONE,
  FTDM_CHANNEL_INDICATE_RINGING,
  FTDM_CHANNEL_INDICATE_PROCEED,
  FTDM_CHANNEL_INDICATE_PROGRESS,
  FTDM_CHANNEL_INDICATE_PROGRESS_MEDIA,
  FTDM_CHANNEL_INDICATE_BUSY,

  FTDM_CHANNEL_INDICATE_ANSWER,
  FTDM_CHANNEL_INDICATE_FACILITY,
  FTDM_CHANNEL_INDICATE_TRANSFER,
  FTDM_CHANNEL_INDICATE_INVALID,
} ftdm_channel_indication_t;

typedef struct {
  ftdm_channel_indication_t indication;
  ftdm_status_t status;
} ftdm_event_indication_completed_t;

typedef struct {
  ftdm_transfer_response_t response;
} ftdm_event_transfer_completed_t;

typedef void *ftdm_variable_container_t;

typedef struct {
  size_t len;
  void *data;
} ftdm_raw_data_t;

struct ftdm_sigmsg {
  ftdm_signal_event_t event_id;
  ftdm_channel_t *channel;
  uint32_t chan_id;
  uint32_t span_id;
  uint32_t call_id;
  void *call_priv;
  ftdm_variable_container_t variables;
  union {
    ftdm_event_sigstatus_t sigstatus;
    ftdm_event_trace_t trace;
    ftdm_event_collected_t collected;
    ftdm_event_indication_completed_t indication_completed;
    ftdm_event_transfer_completed_t transfer_completed;
  } ev_data;
  ftdm_raw_data_t raw;
};

struct ftdm_usrmsg {
  ftdm_variable_container_t variables;
  ftdm_raw_data_t raw;
};

typedef enum {
  FTDM_CRASH_NEVER = 0,
  FTDM_CRASH_ON_ASSERT
} ftdm_crash_policy_t;

typedef struct ftdm_conf_parameter {
  const char *var;
  const char *val;
  void *ptr;
} ftdm_conf_parameter_t;

typedef enum {
  FTDM_COMMAND_NOOP = 0,
  FTDM_COMMAND_SET_INTERVAL = 1,
  FTDM_COMMAND_GET_INTERVAL = 2,
  FTDM_COMMAND_SET_CODEC = 3,
  FTDM_COMMAND_GET_CODEC = 4,
  FTDM_COMMAND_SET_NATIVE_CODEC = 5,
  FTDM_COMMAND_GET_NATIVE_CODEC = 6,
  FTDM_COMMAND_ENABLE_DTMF_DETECT = 7,
  FTDM_COMMAND_DISABLE_DTMF_DETECT = 8,
  FTDM_COMMAND_SEND_DTMF = 9,
  FTDM_COMMAND_SET_DTMF_ON_PERIOD = 10,
  FTDM_COMMAND_GET_DTMF_ON_PERIOD = 11,
  FTDM_COMMAND_SET_DTMF_OFF_PERIOD = 12,
  FTDM_COMMAND_GET_DTMF_OFF_PERIOD = 13,
  FTDM_COMMAND_GENERATE_RING_ON = 14,
  FTDM_COMMAND_GENERATE_RING_OFF = 15,
  FTDM_COMMAND_OFFHOOK = 16,
  FTDM_COMMAND_ONHOOK = 17,
  FTDM_COMMAND_FLASH = 18,
  FTDM_COMMAND_WINK = 19,
  FTDM_COMMAND_ENABLE_PROGRESS_DETECT = 20,
  FTDM_COMMAND_DISABLE_PROGRESS_DETECT = 21,
  FTDM_COMMAND_TRACE_INPUT = 22,
  FTDM_COMMAND_TRACE_OUTPUT = 23,
  FTDM_COMMAND_TRACE_END_ALL = 24,
  FTDM_COMMAND_ENABLE_DEBUG_DTMF = 25,

  FTDM_COMMAND_DISABLE_DEBUG_DTMF = 26,

  FTDM_COMMAND_ENABLE_INPUT_DUMP = 27,

  FTDM_COMMAND_DISABLE_INPUT_DUMP = 28,

  FTDM_COMMAND_ENABLE_OUTPUT_DUMP = 29,

  FTDM_COMMAND_DISABLE_OUTPUT_DUMP = 30,

  FTDM_COMMAND_DUMP_INPUT = 31,

  FTDM_COMMAND_DUMP_OUTPUT = 32,

  FTDM_COMMAND_ENABLE_CALLERID_DETECT = 33,
  FTDM_COMMAND_DISABLE_CALLERID_DETECT = 34,
  FTDM_COMMAND_ENABLE_ECHOCANCEL = 35,
  FTDM_COMMAND_DISABLE_ECHOCANCEL = 36,
  FTDM_COMMAND_ENABLE_ECHOTRAIN = 37,
  FTDM_COMMAND_DISABLE_ECHOTRAIN = 38,
  FTDM_COMMAND_SET_CAS_BITS = 39,
  FTDM_COMMAND_GET_CAS_BITS = 40,
  FTDM_COMMAND_SET_RX_GAIN = 41,
  FTDM_COMMAND_GET_RX_GAIN = 42,
  FTDM_COMMAND_SET_TX_GAIN = 43,
  FTDM_COMMAND_GET_TX_GAIN = 44,
  FTDM_COMMAND_FLUSH_TX_BUFFERS = 45,
  FTDM_COMMAND_FLUSH_RX_BUFFERS = 46,
  FTDM_COMMAND_FLUSH_BUFFERS = 47,

  FTDM_COMMAND_FLUSH_IOSTATS = 48,

  FTDM_COMMAND_SET_PRE_BUFFER_SIZE = 49,
  FTDM_COMMAND_SET_LINK_STATUS = 50,
  FTDM_COMMAND_GET_LINK_STATUS = 51,
  FTDM_COMMAND_ENABLE_LOOP = 52,
  FTDM_COMMAND_DISABLE_LOOP = 53,
  FTDM_COMMAND_SET_RX_QUEUE_SIZE = 54,
  FTDM_COMMAND_SET_TX_QUEUE_SIZE = 55,
  FTDM_COMMAND_SET_POLARITY = 56,
  FTDM_COMMAND_START_MF_PLAYBACK = 57,
  FTDM_COMMAND_STOP_MF_PLAYBACK = 58,

  FTDM_COMMAND_GET_IOSTATS = 59,

  FTDM_COMMAND_SWITCH_IOSTATS = 60,

  FTDM_COMMAND_ENABLE_DTMF_REMOVAL = 61,
  FTDM_COMMAND_DISABLE_DTMF_REMOVAL = 62,

  FTDM_COMMAND_COUNT,
} ftdm_command_t;

#define FTDM_POLARITY_FORWARD 0
#define FTDM_POLARITY_REVERSE 1

typedef void *(*ftdm_malloc_func_t)(void *pool, size_t len);
typedef void *(*ftdm_calloc_func_t)(void *pool, size_t elements,
                                    size_t len);
typedef void *(*ftdm_realloc_func_t)(void *pool, void *buff, size_t len);
typedef void (*ftdm_free_func_t)(void *pool, void *ptr);
struct ftdm_memory_handler {
  void *pool;
  ftdm_malloc_func_t malloc;
  ftdm_calloc_func_t calloc;
  ftdm_realloc_func_t realloc;
  ftdm_free_func_t free;
};

typedef ftdm_status_t(*fio_channel_request_t) (ftdm_span_t * span,
                                               uint32_t chan_id,
                                               ftdm_hunt_direction_t
                                               direction,
                                               ftdm_caller_data_t *
                                               caller_data,
                                               ftdm_channel_t ** ftdmchan);
typedef ftdm_status_t(*fio_channel_outgoing_call_t) (ftdm_channel_t *
                                                     ftdmchan);
typedef ftdm_status_t(*fio_channel_indicate_t) (ftdm_channel_t * ftdmchan,
                                                ftdm_channel_indication_t
                                                indication);
typedef ftdm_status_t(*fio_channel_set_sig_status_t) (ftdm_channel_t *
                                                      ftdmchan,
                                                      ftdm_signaling_status_t
                                                      status);
typedef ftdm_status_t(*fio_channel_get_sig_status_t) (ftdm_channel_t *
                                                      ftdmchan,
                                                      ftdm_signaling_status_t
                                                      * status);
typedef ftdm_status_t(*fio_span_set_sig_status_t) (ftdm_span_t * span,
                                                   ftdm_signaling_status_t
                                                   status);
typedef ftdm_status_t(*fio_span_get_sig_status_t) (ftdm_span_t * span,
                                                   ftdm_signaling_status_t
                                                   * status);
typedef ftdm_status_t(*fio_span_poll_event_t) (ftdm_span_t * span,
                                               uint32_t ms,
                                               short *poll_events);
typedef ftdm_status_t(*fio_span_next_event_t) (ftdm_span_t * span,
                                               ftdm_event_t ** event);
typedef ftdm_status_t(*fio_channel_next_event_t) (ftdm_channel_t *
                                                  ftdmchan,
                                                  ftdm_event_t ** event);
typedef ftdm_status_t(*fio_signal_cb_t) (ftdm_sigmsg_t * sigmsg);

typedef ftdm_status_t(*fio_event_cb_t) (ftdm_channel_t * ftdmchan,
                                        ftdm_event_t * event);
typedef ftdm_status_t(*fio_configure_span_t) (ftdm_span_t * span);

typedef ftdm_status_t(*fio_open_t) (ftdm_channel_t * ftdmchan);
typedef ftdm_status_t(*fio_close_t) (ftdm_channel_t * ftdmchan);
typedef ftdm_status_t(*fio_channel_destroy_t) (ftdm_channel_t * ftdmchan);
typedef ftdm_status_t(*fio_span_destroy_t) (ftdm_span_t * span);
typedef ftdm_status_t(*fio_get_alarms_t) (ftdm_channel_t * ftdmchan);
typedef ftdm_status_t(*fio_command_t) (ftdm_channel_t * ftdmchan,
                                       ftdm_command_t command, void *obj);
typedef ftdm_status_t(*fio_wait_t) (ftdm_channel_t * ftdmchan,
                                    ftdm_wait_flag_t * flags, int32_t to);
typedef ftdm_status_t(*fio_read_t) (ftdm_channel_t * ftdmchan, void *data,
                                    size_t *datalen);
typedef ftdm_status_t(*fio_write_t) (ftdm_channel_t * ftdmchan, void *data,
                                     size_t *datalen);
typedef ftdm_status_t(*fio_io_load_t) (ftdm_io_interface_t ** fio);
typedef ftdm_status_t(*fio_sig_load_t) (void);
typedef ftdm_status_t(*fio_sig_configure_t) (ftdm_span_t * span,
                                             fio_signal_cb_t sig_cb,
                                             va_list ap);
typedef ftdm_status_t(*fio_configure_span_signaling_t) (ftdm_span_t * span,
                                                        fio_signal_cb_t
                                                        sig_cb,
                                                        ftdm_conf_parameter_t
                                                        * ftdm_parameters);
typedef ftdm_status_t(*fio_io_unload_t) (void);
typedef ftdm_status_t(*fio_sig_unload_t) (void);
typedef ftdm_status_t(*fio_api_t) (ftdm_stream_handle_t * stream,
                                   const char *data);
typedef ftdm_status_t(*fio_span_start_t) (ftdm_span_t * span);
typedef ftdm_status_t(*fio_span_stop_t) (ftdm_span_t * span);

struct ftdm_io_interface {
  const char *name;
  fio_configure_span_t configure_span;
  fio_open_t open;
  fio_close_t close;
  fio_channel_destroy_t channel_destroy;
  fio_span_destroy_t span_destroy;
  fio_get_alarms_t get_alarms;
  fio_command_t command;
  fio_wait_t wait;
  fio_read_t read;
  fio_write_t write;
  fio_span_poll_event_t poll_event;
  fio_span_next_event_t next_event;
  fio_channel_next_event_t channel_next_event;
  fio_api_t api;
  fio_span_start_t span_start;
  fio_span_stop_t span_stop;
};

typedef enum {
  FTDM_ALARM_NONE = 0,
  FTDM_ALARM_RED = (1 << 0),
  FTDM_ALARM_YELLOW = (1 << 1),
  FTDM_ALARM_RAI = (1 << 2),
  FTDM_ALARM_BLUE = (1 << 3),
  FTDM_ALARM_AIS = (1 << 4),
  FTDM_ALARM_GENERAL = (1 << 30)
} ftdm_alarm_flag_t;

typedef struct {
  struct {
    uint64_t packets;
    uint32_t errors;
    uint16_t flags;
    uint8_t queue_size;
    uint8_t queue_len;
  } rx;

  struct {
    uint64_t idle_packets;
    uint64_t packets;
    uint32_t errors;
    uint16_t flags;
    uint8_t queue_size;
    uint8_t queue_len;
  } tx;
} ftdm_channel_iostats_t;

ftdm_status_t ftdm_span_add_channel(ftdm_span_t * span, int sockfd, ftdm_channel_t ** chan);

extern ftdm_logger_t ftdm_log;

typedef ftdm_status_t(*fio_codec_t) (void *data, size_t max, size_t *datalen);

typedef void (*bytehandler_func_t)(void *, int);
typedef void (*bithandler_func_t)(void *, int);

typedef enum {
  FSK_STATE_CHANSEIZE = 0,
  FSK_STATE_CARRIERSIG,
  FSK_STATE_DATA
} fsk_state_t;

typedef struct dsp_fsk_attr_s {
  int sample_rate;
  bithandler_func_t bithandler;
  void *bithandler_arg;
  bytehandler_func_t bytehandler;
  void *bytehandler_arg;
} dsp_fsk_attr_t;

typedef struct {
  fsk_state_t state;
  dsp_fsk_attr_t attr;
  double *correlates[4];
  int corrsize;
  double *buffer;
  int ringstart;
  double cellpos;
  double celladj;
  int previous_bit;
  int current_bit;
  int last_bit;
  int downsampling_count;
  int current_downsample;
  int conscutive_state_bits;
} dsp_fsk_handle_t;

typedef ssize_t ftdm_ssize_t;
typedef int ftdm_filehandle_t;

typedef enum {
  FTDM_ENDIAN_BIG = 1,
  FTDM_ENDIAN_LITTLE = -1
} ftdm_endian_t;

typedef enum {
  FTDM_CID_TYPE_SDMF = 0x04,
  FTDM_CID_TYPE_MDMF = 0x80
} ftdm_cid_type_t;

typedef enum {
  MDMF_DATETIME = 1,
  MDMF_PHONE_NUM = 2,
  MDMF_DDN = 3,
  MDMF_NO_NUM = 4,
  MDMF_PHONE_NAME = 7,
  MDMF_NO_NAME = 8,
  MDMF_ALT_ROUTE = 9,
  MDMF_INVALID = 10
} ftdm_mdmf_type_t;
ftdm_mdmf_type_t ftdm_str2ftdm_mdmf_type(const char *name);
const char *ftdm_mdmf_type2str(ftdm_mdmf_type_t type);

typedef enum {
  FTDM_TONEMAP_NONE,
  FTDM_TONEMAP_DIAL,
  FTDM_TONEMAP_RING,
  FTDM_TONEMAP_BUSY,
  FTDM_TONEMAP_FAIL1,
  FTDM_TONEMAP_FAIL2,
  FTDM_TONEMAP_FAIL3,
  FTDM_TONEMAP_ATTN,
  FTDM_TONEMAP_CALLWAITING_CAS,
  FTDM_TONEMAP_CALLWAITING_SAS,
  FTDM_TONEMAP_CALLWAITING_ACK,
  FTDM_TONEMAP_INVALID
} ftdm_tonemap_t;
ftdm_tonemap_t ftdm_str2ftdm_tonemap(const char *name);
const char *ftdm_tonemap2str(ftdm_tonemap_t type);

typedef enum {
  FTDM_OOB_NOOP,
  FTDM_OOB_ONHOOK,
  FTDM_OOB_OFFHOOK,
  FTDM_OOB_WINK,
  FTDM_OOB_FLASH,
  FTDM_OOB_RING_START,
  FTDM_OOB_RING_STOP,
  FTDM_OOB_ALARM_TRAP,
  FTDM_OOB_ALARM_CLEAR,
  FTDM_OOB_CAS_BITS_CHANGE,
  FTDM_OOB_POLARITY_REVERSE,
  FTDM_OOB_INVALID
} ftdm_oob_event_t;
ftdm_oob_event_t ftdm_str2ftdm_oob_event(const char *name);
const char *ftdm_oob_event2str(ftdm_oob_event_t type);

typedef enum {
  FTDM_EVENT_NONE,

  FTDM_EVENT_DTMF,

  FTDM_EVENT_OOB,
  FTDM_EVENT_COUNT
} ftdm_event_type_t;

struct ftdm_event {
  ftdm_event_type_t e_type;
  uint32_t enum_id;
  ftdm_channel_t *channel;
  void *data;
};

typedef enum {
  FTDM_SIGTYPE_NONE,
  FTDM_SIGTYPE_ISDN,
  FTDM_SIGTYPE_RBS,
  FTDM_SIGTYPE_ANALOG,
  FTDM_SIGTYPE_SANGOMABOOST,
  FTDM_SIGTYPE_M3UA,
  FTDM_SIGTYPE_M2UA,
  FTDM_SIGTYPE_R2,
  FTDM_SIGTYPE_SS7,
  FTDM_SIGTYPE_GSM
} ftdm_signal_type_t;

typedef enum {
  FTDM_SPAN_CONFIGURED = (1 << 0),
  FTDM_SPAN_STARTED = (1 << 1),
  FTDM_SPAN_STATE_CHANGE = (1 << 2),
  FTDM_SPAN_SUSPENDED = (1 << 3),
  FTDM_SPAN_IN_THREAD = (1 << 4),
  FTDM_SPAN_STOP_THREAD = (1 << 5),

  FTDM_SPAN_USE_CHAN_QUEUE = (1 << 6),
  FTDM_SPAN_SUGGEST_CHAN_ID = (1 << 7),
  FTDM_SPAN_USE_AV_RATE = (1 << 8),
  FTDM_SPAN_PWR_SAVING = (1 << 9),

  FTDM_SPAN_USE_SIGNALS_QUEUE = (1 << 10),

  FTDM_SPAN_USE_PROCEED_STATE = (1 << 11),

  FTDM_SPAN_USE_SKIP_STATES = (1 << 12),

  FTDM_SPAN_NON_STOPPABLE = (1 << 13),

  FTDM_SPAN_USE_TRANSFER = (1 << 14),

  FTDM_SPAN_MAX_FLAG = (1 << 15),
} ftdm_span_flag_t;

typedef enum {
  FTDM_CHANNEL_FEATURE_DTMF_GENERATE = (1 << 1),
  FTDM_CHANNEL_FEATURE_CODECS = (1 << 2),
  FTDM_CHANNEL_FEATURE_INTERVAL = (1 << 3),
  FTDM_CHANNEL_FEATURE_CALLERID = (1 << 4),
  FTDM_CHANNEL_FEATURE_PROGRESS = (1 << 5),
  FTDM_CHANNEL_FEATURE_CALLWAITING = (1 << 6),
  FTDM_CHANNEL_FEATURE_HWEC = (1 << 7),
  FTDM_CHANNEL_FEATURE_HWEC_DISABLED_ON_IDLE = (1 << 8),
  FTDM_CHANNEL_FEATURE_IO_STATS = (1 << 9),
  FTDM_CHANNEL_FEATURE_MF_GENERATE = (1 << 10),
} ftdm_channel_feature_t;

#define FTDM_CHANNEL_IO_EVENT (1 << 0)

#define FTDM_CHANNEL_OFFHOOK (1ULL << 14)
#define FTDM_CHANNEL_RINGING (1ULL << 15)

typedef enum {
  FTDM_CHANNEL_STATE_ANY = -1,
  FTDM_CHANNEL_STATE_END = -1,
  FTDM_CHANNEL_STATE_DOWN,
  FTDM_CHANNEL_STATE_HOLD,
  FTDM_CHANNEL_STATE_SUSPENDED,
  FTDM_CHANNEL_STATE_DIALTONE,
  FTDM_CHANNEL_STATE_COLLECT,
  FTDM_CHANNEL_STATE_RING,
  FTDM_CHANNEL_STATE_RINGING,
  FTDM_CHANNEL_STATE_BUSY,
  FTDM_CHANNEL_STATE_ATTN,
  FTDM_CHANNEL_STATE_GENRING,
  FTDM_CHANNEL_STATE_DIALING,
  FTDM_CHANNEL_STATE_GET_CALLERID,
  FTDM_CHANNEL_STATE_CALLWAITING,
  FTDM_CHANNEL_STATE_RESTART,
  FTDM_CHANNEL_STATE_PROCEED,
  FTDM_CHANNEL_STATE_PROGRESS,
  FTDM_CHANNEL_STATE_PROGRESS_MEDIA,
  FTDM_CHANNEL_STATE_UP,
  FTDM_CHANNEL_STATE_TRANSFER,
  FTDM_CHANNEL_STATE_IDLE,
  FTDM_CHANNEL_STATE_TERMINATING,
  FTDM_CHANNEL_STATE_CANCEL,
  FTDM_CHANNEL_STATE_HANGUP,
  FTDM_CHANNEL_STATE_HANGUP_COMPLETE,
  FTDM_CHANNEL_STATE_IN_LOOP,
  FTDM_CHANNEL_STATE_RESET,
  FTDM_CHANNEL_STATE_INVALID
} ftdm_channel_state_t;

ftdm_channel_state_t ftdm_str2ftdm_channel_state(const char *name);
const char *ftdm_channel_state2str(ftdm_channel_state_t type);

typedef struct {
  const char *file;
  const char *func;
  int line;
  ftdm_channel_state_t state;
  ftdm_channel_state_t last_state;
  ftdm_time_t time;
  ftdm_time_t end_time;
} ftdm_state_history_entry_t;

typedef ftdm_status_t(*ftdm_channel_state_processor_t) (ftdm_channel_t *
                                                        fchan);

ftdm_status_t ftdm_channel_advance_states(ftdm_channel_t * fchan);

int ftdm_check_state_all(ftdm_span_t * span, ftdm_channel_state_t state);
typedef enum {
  FTDM_STATE_STATUS_NEW,
  FTDM_STATE_STATUS_PROCESSED,
  FTDM_STATE_STATUS_COMPLETED,
  FTDM_STATE_STATUS_INVALID
} ftdm_state_status_t;
ftdm_state_status_t ftdm_str2ftdm_state_status(const char *name);
const char *ftdm_state_status2str(ftdm_state_status_t type);

typedef enum {
  ZSM_NONE,
  ZSM_UNACCEPTABLE,
  ZSM_ACCEPTABLE
} ftdm_state_map_type_t;

typedef enum {
  ZSD_INBOUND,
  ZSD_OUTBOUND,
} ftdm_state_direction_t;

struct ftdm_state_map_node {
  ftdm_state_direction_t direction;
  ftdm_state_map_type_t type;
  ftdm_channel_state_t check_states[FTDM_CHANNEL_STATE_INVALID + 2];
  ftdm_channel_state_t states[FTDM_CHANNEL_STATE_INVALID + 2];
};
typedef struct ftdm_state_map_node ftdm_state_map_node_t;

struct ftdm_state_map {
  ftdm_state_map_node_t nodes[512];
};
typedef struct ftdm_state_map ftdm_state_map_t;

typedef ftdm_status_t(*ftdm_stream_handle_raw_write_function_t)
 (ftdm_stream_handle_t * handle, uint8_t * data, size_t datalen);
typedef
ftdm_status_t(*ftdm_stream_handle_write_function_t) (ftdm_stream_handle_t *
                                                     handle,
                                                     const char *fmt, ...);

typedef void *ftdm_dso_lib_t;

typedef struct ftdm_fsk_data_state ftdm_fsk_data_state_t;
typedef ftdm_status_t(*ftdm_fsk_write_sample_t) (int16_t * buf,
                                                 size_t buflen,
                                                 void *user_data);

typedef ftdm_status_t(*ftdm_span_start_t) (ftdm_span_t * span);
typedef ftdm_status_t(*ftdm_span_stop_t) (ftdm_span_t * span);
typedef ftdm_status_t(*ftdm_span_destroy_t) (ftdm_span_t * span);
typedef ftdm_status_t(*ftdm_channel_sig_read_t) (ftdm_channel_t * ftdmchan,
                                                 void *data, size_t size);
typedef ftdm_status_t(*ftdm_channel_sig_write_t) (ftdm_channel_t *
                                                  ftdmchan, void *data,
                                                  size_t size);
typedef ftdm_status_t(*ftdm_channel_sig_dtmf_t) (ftdm_channel_t * ftdmchan,
                                                 const char *dtmf);

typedef double teletone_process_t;
typedef struct {
  teletone_process_t freqs[18];
} teletone_tone_map_t;

struct teletone_dds_state {
  uint32_t phase_rate[4];
  uint32_t scale_factor;
  uint32_t phase_accumulator;
  teletone_process_t tx_level;
};
typedef struct teletone_dds_state teletone_dds_state_t;

typedef int16_t teletone_audio_t;
struct teletone_generation_session;
typedef int (*tone_handler)(struct teletone_generation_session * ts,
                            teletone_tone_map_t * map);

struct teletone_generation_session {
  teletone_tone_map_t TONES[127];
  int channels;
  int rate;
  int duration;
  int wait;
  int tmp_duration;
  int tmp_wait;
  int loops;
  int LOOPS;
  float decay_factor;
  int decay_direction;
  int decay_step;
  float volume;
  int debug;
  FILE *debug_stream;
  void *user_data;
  teletone_audio_t *buffer;
  int datalen;
  int samples;
  int dynamic;
  tone_handler handler;
};
typedef struct teletone_generation_session teletone_generation_session_t;

typedef enum {
  TT_HIT_NONE = 0,
  TT_HIT_BEGIN = 1,
  TT_HIT_MIDDLE = 2,
  TT_HIT_END = 3
} teletone_hit_type_t;

typedef struct {
  float v2;
  float v3;
  double fac;
} teletone_goertzel_state_t;

typedef struct {
  int hit1;
  int hit2;
  int hit3;
  int hit4;
  int dur;
  int zc;

  teletone_goertzel_state_t row_out[4];
  teletone_goertzel_state_t col_out[4];
  teletone_goertzel_state_t row_out2nd[4];
  teletone_goertzel_state_t col_out2nd[4];
  float energy;
  float lenergy;

  int current_sample;
  char digit;
  int current_digits;
  int detected_digits;
  int lost_digits;
  int digit_hits[16];
} teletone_dtmf_detect_state_t;

typedef struct {
  float fac;
} teletone_detection_descriptor_t;

typedef struct {
  int sample_rate;

  teletone_detection_descriptor_t tdd[18];
  teletone_goertzel_state_t gs[18];
  teletone_goertzel_state_t gs2[18];
  int tone_count;

  float energy;
  int current_sample;

  int min_samples;
  int total_samples;

  int positives;
  int negatives;
  int hits;

  int positive_factor;
  int negative_factor;
  int hit_factor;

} teletone_multi_tone_t;

void teletone_multi_tone_init(teletone_multi_tone_t * mt,
                              teletone_tone_map_t * map);
int teletone_multi_tone_detect(teletone_multi_tone_t * mt,
                               int16_t sample_buffer[], int samples);

void teletone_dtmf_detect_init(teletone_dtmf_detect_state_t *
                               dtmf_detect_state, int sample_rate);
teletone_hit_type_t teletone_dtmf_detect(teletone_dtmf_detect_state_t *
                                         dtmf_detect_state,
                                         int16_t sample_buffer[],
                                         int samples);

int teletone_dtmf_get(teletone_dtmf_detect_state_t * dtmf_detect_state,
                      char *buf, unsigned int *dur);

void teletone_goertzel_update(teletone_goertzel_state_t * goertzel_state,
                              int16_t sample_buffer[], int samples);
struct ftdm_buffer;
typedef struct ftdm_buffer ftdm_buffer_t;
ftdm_status_t ftdm_buffer_create(ftdm_buffer_t ** buffer, size_t blocksize,
                                 size_t start_len, size_t max_len);

size_t ftdm_buffer_len(ftdm_buffer_t * buffer);

size_t ftdm_buffer_freespace(ftdm_buffer_t * buffer);

size_t ftdm_buffer_inuse(ftdm_buffer_t * buffer);

size_t ftdm_buffer_read(ftdm_buffer_t * buffer, void *data,
                        size_t datalen);
size_t ftdm_buffer_read_loop(ftdm_buffer_t * buffer, void *data,
                             size_t datalen);

void ftdm_buffer_set_loops(ftdm_buffer_t * buffer, int32_t loops);

size_t ftdm_buffer_write(ftdm_buffer_t * buffer, const void *data,
                         size_t datalen);

size_t ftdm_buffer_toss(ftdm_buffer_t * buffer, size_t datalen);

void ftdm_buffer_zero(ftdm_buffer_t * buffer);

void ftdm_buffer_destroy(ftdm_buffer_t ** buffer);

size_t ftdm_buffer_seek(ftdm_buffer_t * buffer, size_t datalen);

size_t ftdm_buffer_zwrite(ftdm_buffer_t * buffer, const void *data,
                          size_t datalen);

typedef struct ftdm_sched ftdm_sched_t;
typedef void (*ftdm_sched_callback_t)(void *data);
typedef uint64_t ftdm_timer_id_t;

struct ftdm_stream_handle {
  ftdm_stream_handle_write_function_t write_function;
  ftdm_stream_handle_raw_write_function_t raw_write_function;
  void *data;
  void *end;
  size_t data_size;
  size_t data_len;
  size_t alloc_len;
  size_t alloc_chunk;
};

struct ftdm_fsk_data_state {
  dsp_fsk_handle_t *fsk1200_handle;
  uint8_t init;
  uint8_t *buf;
  size_t bufsize;
  size_t blen;
  size_t bpos;
  size_t dlen;
  size_t ppos;
  int checksum;
};

typedef enum {
  FTDM_TYPE_NONE,
  FTDM_TYPE_SPAN = 0xFF,
  FTDM_TYPE_CHANNEL
} ftdm_data_type_t;

typedef struct {
  char *buffer;
  size_t size;
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

  uint8_t trigger_on_start;
} ftdm_dtmf_detect_t;

struct ftdm_channel {
  ftdm_data_type_t data_type;
  uint32_t span_id;
  uint32_t chan_id;
  uint32_t physical_span_id;
  uint32_t physical_chan_id;
  uint32_t rate;
  uint32_t extra_id;
  int sockfd;
  uint64_t flags;
  uint32_t pflags;
  uint32_t sflags;
  uint8_t io_flags;
  ftdm_alarm_flag_t alarm_flags;
  ftdm_channel_feature_t features;
  int effective_codec;
  int native_codec;
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
  char tokens[10 + 1][128];
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
  int polarity;

  int last_event_id;

  void *call_data;
  struct ftdm_caller_data caller_data;
  struct ftdm_span *span;
  struct ftdm_io_interface *fio;
  unsigned char rx_cas_bits;
  uint32_t pre_buffer_size;
  uint8_t rxgain_table[256];
  uint8_t txgain_table[256];
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
  ftdm_interrupt_t *state_completed_interrupt;
  int32_t txdrops;
  int32_t rxdrops;
  ftdm_usrmsg_t *usrmsg;
  ftdm_time_t last_state_change_time;
  ftdm_time_t last_release_time;
};

@ @d FTDM_MAX_CHANNELS 4

@c
struct ftdm_span {
  ftdm_data_type_t data_type;
  char *name;
  uint32_t span_id;
  uint32_t chan_count;
  ftdm_span_flag_t flags;
  struct ftdm_io_interface *fio;
  fio_event_cb_t event_callback;
  ftdm_mutex_t *mutex;
  ftdm_signal_type_t signal_type;
  uint32_t last_used_index;

  void *signal_data;
  fio_signal_cb_t signal_cb;
  ftdm_event_t event_header;
  char last_error[256];
  char tone_map[FTDM_TONEMAP_INVALID + 1][128];
  teletone_tone_map_t tone_detect_map[FTDM_TONEMAP_INVALID + 1];
  teletone_multi_tone_t tone_finder[FTDM_TONEMAP_INVALID + 1];
  ftdm_channel_t *channels[FTDM_MAX_CHANNELS + 1];
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
  ftdm_channel_state_processor_t state_processor;
  char *type;
  char *dtmf_hangup;
  size_t dtmf_hangup_len;
  ftdm_state_map_t *state_map;
  ftdm_caller_data_t default_caller_data;
  ftdm_queue_t *pendingchans;
  ftdm_queue_t *pendingsignals;
  struct ftdm_span *next;
};

static int CONTROL_FD = -1;

ftdm_status_t zt_next_event(ftdm_span_t * span, ftdm_event_t ** event);
ftdm_status_t zt_poll_event(ftdm_span_t * span, uint32_t ms,
                            short *poll_events);
ftdm_status_t zt_channel_next_event(ftdm_channel_t * ftdmchan,
                                    ftdm_event_t ** event);

@ @d FTDM_CODEC_ULAW 0

@c
static ftdm_status_t zt_configure_span(ftdm_span_t *span)
{
  for (int channel = 2; channel <= 4; channel++) {
    int sockfd;
    if ((sockfd = open("/dev/dahdi/channel", O_RDWR)) == -1) {
      ftdm_log(FTDM_LOG_ERROR, "failed to open /dev/dahdi/channel\n");
      return 0;
    }

    if (ioctl(sockfd, DAHDI_SPECIFY, &channel) == -1) {
      ftdm_log(FTDM_LOG_ERROR, "DAHDI_SPECIFY failed\n");
      return 0;
    }

    int blocksize = 160;              /* each 20ms */
    if (ioctl(sockfd, DAHDI_SET_BLOCKSIZE, &blocksize) == -1) {
      ftdm_log(FTDM_LOG_ERROR, "DAHDI_SET_BLOCKSIZE failed\n");
      return 0;
    }

    ftdm_channel_t *ftdmchan;
    if (ftdm_span_add_channel(span, sockfd, &ftdmchan) != FTDM_SUCCESS) {
      ftdm_log(FTDM_LOG_ERROR, "failed to add channel to span\n");
      return 0;
    }
    ftdmchan->rate = 8000;
    ftdmchan->physical_span_id = 1;
    ftdmchan->physical_chan_id = channel;
    ftdmchan->native_codec = ftdmchan->effective_codec = FTDM_CODEC_ULAW;
    ftdmchan->packet_len = blocksize;
    ftdmchan->native_interval = ftdmchan->effective_interval = blocksize / 8;
  }

  return 1;
}

static ftdm_status_t zt_open(ftdm_channel_t * ftdmchan)
{
  int echo_cancel_level = 16; /* number of samples of echo cancellation (0--256); 0 = disabled */
    /* The problem is that if ec is disabled, keys are not always recognized.
       Test this parameter separately from freeswitch when you factor-out teletone from freetdm
       and see oslec page - there was tool to analyze ec graphically. */
  if (ioctl(ftdmchan->sockfd, DAHDI_ECHOCANCEL, &echo_cancel_level) == -1)
    ftdm_log(FTDM_LOG_EMERG, "DAHDI_ECHOCANCEL failed\n");
  
  return FTDM_SUCCESS;
}

static ftdm_status_t zt_close(ftdm_channel_t * ftdmchan)
{
  return FTDM_SUCCESS;
}

static ftdm_status_t zt_command(ftdm_channel_t * ftdmchan, ftdm_command_t command, void *obj)
{
  int err = 0;

  switch (command) {
  case FTDM_COMMAND_ENABLE_ECHOCANCEL:
    {
      int level = *((int *) obj);
      err = ioctl(ftdmchan->sockfd, DAHDI_ECHOCANCEL, &level);
      *((int *) obj) = level;
    }
  case FTDM_COMMAND_DISABLE_ECHOCANCEL:
    {
      int level = 0;
      err = ioctl(ftdmchan->sockfd, DAHDI_ECHOCANCEL, &level);
      *((int *) obj) = level;
    }
    break;
  case FTDM_COMMAND_OFFHOOK:
    {
      int command = DAHDI_OFFHOOK;
      ftdm_log(FTDM_LOG_EMERG, "ioctl DAHDI_HOOK - DAHDI_OFFHOOK\n");
      if (ioctl(ftdmchan->sockfd, DAHDI_HOOK, &command) == -1) {
        ftdm_log(FTDM_LOG_EMERG, "Fail\n");
        return FTDM_FAIL;
      }

      _ftdm_mutex_lock(__FILE__, __LINE__, (const char *) __func__, ftdmchan->mutex);
      ftdmchan->flags |= FTDM_CHANNEL_OFFHOOK;
      _ftdm_mutex_unlock(__FILE__, __LINE__, (const char *) __func__, ftdmchan->mutex);
    }
    break;
  case FTDM_COMMAND_ONHOOK:
    {
      int command = DAHDI_ONHOOK;
      ftdm_log(FTDM_LOG_EMERG, "ioctl DAHDI_HOOK - DAHDI_ONHOOK\n");
      if (ioctl(ftdmchan->sockfd, DAHDI_HOOK, &command) == -1) {
        ftdm_log(FTDM_LOG_EMERG, "Fail\n");
        return FTDM_FAIL;
      }

      _ftdm_mutex_lock(__FILE__, __LINE__, (const char *) __func__, ftdmchan->mutex);
      ftdmchan->flags &= ~FTDM_CHANNEL_OFFHOOK;
      _ftdm_mutex_unlock(__FILE__, __LINE__, (const char *) __func__, ftdmchan->mutex);
    }
    break;
  case FTDM_COMMAND_GENERATE_RING_ON:
    {
      int command = DAHDI_RING;
      ftdm_log(FTDM_LOG_EMERG, "ioctl DAHDI_HOOK - DAHDI_RING\n");
      if (ioctl(ftdmchan->sockfd, DAHDI_HOOK, &command) == -1) {
        ftdm_log(FTDM_LOG_EMERG, "Fail\n");
        return FTDM_FAIL;
      }

      _ftdm_mutex_lock(__FILE__, __LINE__, (const char *) __func__, ftdmchan->mutex);
      ftdmchan->flags |= FTDM_CHANNEL_RINGING;
      _ftdm_mutex_unlock(__FILE__, __LINE__, (const char *) __func__, ftdmchan->mutex);
    }
    break;
  case FTDM_COMMAND_GENERATE_RING_OFF:
    {
      int command = DAHDI_RINGOFF;
      ftdm_log(FTDM_LOG_EMERG, "ioctl DAHDI_HOOK - DAHDI_RINGOFF\n");
      if (ioctl(ftdmchan->sockfd, DAHDI_HOOK, &command) == -1) {
        ftdm_log(FTDM_LOG_EMERG, "Fail\n");
        return FTDM_FAIL;
      }

      _ftdm_mutex_lock(__FILE__, __LINE__, (const char *) __func__, ftdmchan->mutex);
      ftdmchan->flags &= ~FTDM_CHANNEL_RINGING;
      _ftdm_mutex_unlock(__FILE__, __LINE__, (const char *) __func__, ftdmchan->mutex);
    }
    break;
  case FTDM_COMMAND_GET_INTERVAL:
    if ((err = ioctl(ftdmchan->sockfd, DAHDI_GET_BLOCKSIZE, &ftdmchan->packet_len)) == 0) {
      ftdmchan->native_interval = ftdmchan->packet_len / 8;
      *((int *) obj) = ftdmchan->native_interval;
    }
    break;
  case FTDM_COMMAND_FLUSH_TX_BUFFERS:
    {
      int flushmode = DAHDI_FLUSH_WRITE;
      err = ioctl(ftdmchan->sockfd, DAHDI_FLUSH, &flushmode);
    }
    break;
  case FTDM_COMMAND_SET_POLARITY:
    {
      int polarity = *((int *) obj);
      err = ioctl(ftdmchan->sockfd, DAHDI_SETPOLARITY, polarity);
      if (err == 0) ftdmchan->polarity = polarity;
    }
    break;
  case FTDM_COMMAND_FLUSH_RX_BUFFERS:
    {
      int flushmode = DAHDI_FLUSH_READ;
      err = ioctl(ftdmchan->sockfd, DAHDI_FLUSH, &flushmode);
    }
    break;
  case FTDM_COMMAND_FLUSH_BUFFERS:
    {
      int flushmode = DAHDI_FLUSH_BOTH;
      err = ioctl(ftdmchan->sockfd, DAHDI_FLUSH, &flushmode);
    }
    break;
  case FTDM_COMMAND_SET_RX_QUEUE_SIZE:
  case FTDM_COMMAND_SET_TX_QUEUE_SIZE:
    err = 0;
    break;
  default:
    err = FTDM_NOTIMPL;
    break;
  };

  if (err && err != FTDM_NOTIMPL) {
    snprintf(ftdmchan->last_error, sizeof ftdmchan->last_error, "%m");
    return FTDM_FAIL;
  }

  return err == 0 ? FTDM_SUCCESS : err;
}

@ @d DAHDI_ALARM_YELLOW (1 << 2)
@d DAHDI_ALARM_BLUE (1 << 4)

@c
static ftdm_status_t zt_get_alarms(ftdm_channel_t * ftdmchan)
{
  struct dahdi_spaninfo info;
  struct dahdi_params params;

  memset(&info, 0, sizeof info);
  info.spanno = ftdmchan->physical_span_id;

  memset(&params, 0, sizeof(params));

  if (ioctl(CONTROL_FD, DAHDI_SPANSTAT, &info) == -1) {
    snprintf(ftdmchan->last_error, sizeof ftdmchan->last_error, "ioctl failed (%m)");
    snprintf(ftdmchan->span->last_error, sizeof ftdmchan->span->last_error, "ioctl failed (%m)");
    return FTDM_FAIL;
  }

  ftdmchan->alarm_flags = info.alarms;

  if (info.alarms == FTDM_ALARM_NONE) {
    if (ioctl(ftdmchan->sockfd, DAHDI_GET_PARAMS, &params) == -1) {
      snprintf(ftdmchan->last_error, sizeof ftdmchan->last_error, "ioctl failed (%m)");
      snprintf(ftdmchan->span->last_error, sizeof ftdmchan->span->last_error, "ioctl failed (%m)");
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

@ Waits for an event on a channel.
\.{flags} = type of event to wait for, \.{to} = time to wait (ms).

@c
static ftdm_status_t zt_wait(ftdm_channel_t *ftdmchan, ftdm_wait_flag_t *flags, int32_t to)
{
  int32_t inflags = 0;
  int result;
  struct pollfd pfds[1];

  if (*flags & FTDM_READ) inflags |= POLLIN;
  if (*flags & FTDM_WRITE) inflags |= POLLOUT;
  if (*flags & FTDM_EVENTS) inflags |= POLLPRI;

pollagain:
  memset(&pfds[0], 0, sizeof pfds[0]);
  pfds[0].fd = ftdmchan->sockfd;
  pfds[0].events = inflags;
  result = poll(pfds, 1, to);
  *flags = FTDM_NO_FLAGS;

  if (result < 0 && errno == EINTR) {
    ftdm_log(FTDM_LOG_DEBUG, "DAHDI wait got interrupted, trying again\n");
    goto pollagain;
  }

  if (pfds[0].revents & POLLERR) {
    ftdm_log(FTDM_LOG_ERROR, "DAHDI device got POLLERR\n");
    result = -1;
  }

  if (result > 0) inflags = pfds[0].revents;

  if (result < 0) {
    snprintf(ftdmchan->last_error, sizeof ftdmchan->last_error, "Poll failed");
    ftdm_log(FTDM_LOG_ERROR, "Failed to poll DAHDI device: %s", strerror(errno));
    return FTDM_FAIL;
  }

  if (result == 0) return FTDM_TIMEOUT;
  if (inflags & POLLIN) *flags |= FTDM_READ;
  if (inflags & POLLOUT) *flags |= FTDM_WRITE;
  if ((inflags & POLLPRI) || (ftdmchan->last_event_id && (*flags & FTDM_EVENTS))) *flags |= FTDM_EVENTS;

  return FTDM_SUCCESS;
}

@ @d FTDM_CHANNEL_IO_READ (1 << 1)
@d FTDM_CHANNEL_IO_WRITE (1 << 2)

@c
ftdm_status_t zt_poll_event(ftdm_span_t *span, uint32_t ms, short *poll_events)
{
  struct pollfd pfds[FTDM_MAX_CHANNELS];
  uint32_t i, j = 0, k = 0;
  int r;

  for (i = 1; i <= span->chan_count; i++) {
    memset(&pfds[j], 0, sizeof pfds[j]);
    pfds[j].fd = span->channels[i]->sockfd;
    pfds[j].events = POLLPRI;
    j++;
  }

  r = poll(pfds, j, ms);

  if (r == 0) return FTDM_TIMEOUT;
  else if (r < 0) {
    snprintf(span->last_error, sizeof span->last_error, "%m");
    return FTDM_FAIL;
  }

  for (i = 1; i <= span->chan_count; i++) {
    _ftdm_mutex_lock(__FILE__, __LINE__, (const char *) __func__, span->channels[i]->mutex);
      /* lock channel */

    if (pfds[i-1].revents & POLLERR) {
      ftdm_log(FTDM_LOG_ERROR, "POLLERR, flags=%d\n", pfds[i-1].events);
      _ftdm_mutex_unlock(__FILE__, __LINE__, (const char *) __func__, span->channels[i]->mutex);
        /* unlock channel */
      continue;
    }
    if ((pfds[i-1].revents & POLLPRI) || span->channels[i]->last_event_id) {
      @<Set event pending on the channel |span->channels[i]|@>@;
      k++;
    }
    if (pfds[i-1].revents & POLLIN)
      span->channels[i]->io_flags |= FTDM_CHANNEL_IO_READ;
    if (pfds[i-1].revents & POLLOUT)
      span->channels[i]->io_flags |= FTDM_CHANNEL_IO_WRITE;

    _ftdm_mutex_unlock(__FILE__, __LINE__, (const char *) __func__, span->channels[i]->mutex);
      /* unlock channel */
  }

  if (!k)
    snprintf(span->last_error, sizeof span->last_error, "no matching descriptor");

  return k ? FTDM_SUCCESS : FTDM_FAIL;
}

@ @<Set event pending on the channel |span->channels[i]|@>=
span->channels[i]->io_flags |= FTDM_CHANNEL_IO_EVENT;
span->channels[i]->last_event_time = ftdm_current_time_in_ms();

@ @c
static __inline__ ftdm_status_t zt_channel_process_event(ftdm_channel_t *fchan,
                                                         ftdm_oob_event_t *event_id,
                                                         int zt_event_id)
{
  ftdm_log(FTDM_LOG_DEBUG, "Processing zap hardware event %d", zt_event_id);
  switch (zt_event_id) {
  case DAHDI_EVENT_RINGEROFF:
    ftdm_log(FTDM_LOG_DEBUG, "ZT RINGER OFF\n");
    *event_id = FTDM_OOB_NOOP;
    break;
  case DAHDI_EVENT_RINGERON:
    ftdm_log(FTDM_LOG_DEBUG, "ZT RINGER ON\n");
    *event_id = FTDM_OOB_NOOP;
    break;
  case DAHDI_EVENT_RINGBEGIN:
    *event_id = FTDM_OOB_RING_START;
    break;
  case DAHDI_EVENT_ONHOOK:
    ftdm_log(FTDM_LOG_EMERG, "ONHOOK\n");
    *event_id = FTDM_OOB_ONHOOK;
    break;
  case DAHDI_EVENT_WINKFLASH:
    if (fchan->state == FTDM_CHANNEL_STATE_DOWN || fchan->state == FTDM_CHANNEL_STATE_DIALING)
      *event_id = FTDM_OOB_WINK;
    else
      *event_id = FTDM_OOB_FLASH;
    break;
  case DAHDI_EVENT_RINGOFFHOOK:
    ftdm_log(FTDM_LOG_EMERG, "OFFHOOK\n");
    @<Set |FTDM_CHANNEL_OFFHOOK| flag to true, channel locked whil doing this@>@;
    *event_id = FTDM_OOB_OFFHOOK;
    break;
  case DAHDI_EVENT_ALARM:
    *event_id = FTDM_OOB_ALARM_TRAP;
    break;
  case DAHDI_EVENT_NOALARM:
    *event_id = FTDM_OOB_ALARM_CLEAR;
    break;
  case DAHDI_EVENT_BADFCS:
    ftdm_log(FTDM_LOG_ERROR, "Bad frame checksum (DAHDI_EVENT_BADFCS)\n");
    *event_id = FTDM_OOB_NOOP;
    break;
  case DAHDI_EVENT_OVERRUN:
    ftdm_log(FTDM_LOG_ERROR, "HDLC frame overrun (DAHDI_EVENT_OVERRUN)\n");
    *event_id = FTDM_OOB_NOOP;
    break;
  case DAHDI_EVENT_ABORT:
    ftdm_log(FTDM_LOG_ERROR, "HDLC abort frame received (DAHDI_EVENT_ABORT)\n");
    *event_id = FTDM_OOB_NOOP;
    break;
  case DAHDI_EVENT_POLARITY:
    ftdm_log(FTDM_LOG_ERROR, "Got polarity reverse (DAHDI_EVENT_POLARITY)\n");
    *event_id = FTDM_OOB_POLARITY_REVERSE;
    break;
  case DAHDI_EVENT_NONE:
    ftdm_log(FTDM_LOG_DEBUG, "No event\n");
    *event_id = FTDM_OOB_NOOP;
    break;
  default:
    ftdm_log(FTDM_LOG_WARNING, "Unhandled event %d\n", zt_event_id);
    *event_id = FTDM_OOB_INVALID;
    break;
  }
  return FTDM_SUCCESS;
}

@ @<Set |FTDM_CHANNEL_OFFHOOK| flag to true, channel locked whil doing this@>=
_ftdm_mutex_lock(__FILE__, __LINE__, (const char *) __func__, fchan->mutex);
fchan->flags |= FTDM_CHANNEL_OFFHOOK;
_ftdm_mutex_unlock(__FILE__, __LINE__, (const char *) __func__, fchan->mutex);

@ @c
ftdm_status_t zt_channel_next_event(ftdm_channel_t * ftdmchan, ftdm_event_t ** event)
{
  uint32_t event_id = FTDM_OOB_INVALID;
  int zt_event_id = 0;
  ftdm_span_t *span = ftdmchan->span;

  if ((ftdmchan->io_flags & FTDM_CHANNEL_IO_EVENT)) {
    ftdmchan->io_flags &= ~FTDM_CHANNEL_IO_EVENT;
  }

  if (ftdmchan->last_event_id) {
    zt_event_id = ftdmchan->last_event_id;
    ftdmchan->last_event_id = 0;
  }
  else if (ioctl(ftdmchan->sockfd, DAHDI_GETEVENT, &zt_event_id) == -1) {
    ftdm_log(FTDM_LOG_ERROR, "Failed retrieving event from channel: %s\n", strerror(errno));
    return FTDM_FAIL;
  }

  if (zt_channel_process_event(ftdmchan, &event_id, zt_event_id) != FTDM_SUCCESS) {
    ftdm_log(FTDM_LOG_ERROR, "Failed to process DAHDI event %d from channel", zt_event_id);
    return FTDM_FAIL;
  }

  ftdmchan->last_event_time = 0;
  span->event_header.e_type = FTDM_EVENT_OOB;
  span->event_header.enum_id = event_id;
  span->event_header.channel = ftdmchan;
  *event = &span->event_header;
  return FTDM_SUCCESS;
}

ftdm_status_t zt_next_event(ftdm_span_t * span, ftdm_event_t ** event)
{
  uint32_t i, event_id = FTDM_OOB_INVALID;
  int zt_event_id = 0;

  for (i = 1; i <= span->chan_count; i++) {
    ftdm_channel_t *fchan = span->channels[i];
    _ftdm_mutex_lock(__FILE__, __LINE__, (const char *) __func__, fchan->mutex);

    if (!(fchan->io_flags & FTDM_CHANNEL_IO_EVENT)) {
      _ftdm_mutex_unlock(__FILE__, __LINE__, (const char *) __func__, fchan->mutex);
      continue;
    }

    fchan->io_flags &= ~FTDM_CHANNEL_IO_EVENT;

    if (fchan->last_event_id) {
      zt_event_id = fchan->last_event_id;
      fchan->last_event_id = 0;
    }
    else if (ioctl(fchan->sockfd, DAHDI_GETEVENT, &zt_event_id) == -1) {
      ftdm_log(FTDM_LOG_ERROR, "Failed to retrieve DAHDI event from channel: %s",
        strerror(errno));
      _ftdm_mutex_unlock(__FILE__, __LINE__, (const char *) __func__, fchan->mutex);
      continue;
    }

    if ((zt_channel_process_event(fchan, &event_id, zt_event_id)) != FTDM_SUCCESS) {
      ftdm_log(FTDM_LOG_ERROR, "Failed to process DAHDI event %d from channel", zt_event_id);
      _ftdm_mutex_unlock(__FILE__, __LINE__, (const char *) __func__, fchan->mutex);
      return FTDM_FAIL;
    }

    fchan->last_event_time = 0;
    span->event_header.e_type = FTDM_EVENT_OOB;
    span->event_header.enum_id = event_id;
    span->event_header.channel = fchan;
    *event = &span->event_header;

    _ftdm_mutex_unlock(__FILE__, __LINE__, (const char *) __func__, fchan->mutex);

    return FTDM_SUCCESS;
  }

  return FTDM_FAIL;
}

static ftdm_status_t zt_read(ftdm_channel_t * ftdmchan, void *data, size_t *datalen)
{
  ftdm_ssize_t r = 0;
  int read_errno = 0;
  int errs = 0;

  while (errs++ < 30) {
    r = read(ftdmchan->sockfd, data, *datalen);
    if (r > 0) break;

    if (r == 0) {
      usleep(10 * 1000);
      if (errs) errs--;
      continue;
    }

    read_errno = errno;
    if (read_errno == EAGAIN || read_errno == EINTR)
      continue;

    if (read_errno == ELAST) {
      int zt_event_id = 0;
      if (ioctl(ftdmchan->sockfd, DAHDI_GETEVENT, &zt_event_id) == -1) {
        ftdm_log(FTDM_LOG_ERROR, "Failed retrieving event after ELAST on read: %s",
          strerror(errno));
        r = -1;
        break;
      }

      ftdm_log(FTDM_LOG_DEBUG, "Deferring event %d to be able to read data", zt_event_id);
      @<Store channel event@>@;
      break;
    }

    ftdm_log(FTDM_LOG_ERROR, "IO read failed: %s\n", strerror(read_errno));
  }

  if (r > 0) {
    *datalen = r;
    return FTDM_SUCCESS;
  }
  else if (read_errno == 500)
    return FTDM_SUCCESS;
  return r == 0 ? FTDM_TIMEOUT : FTDM_FAIL;
}

@ @<Store channel event@>=
if (ftdmchan->last_event_id)
  ftdm_log(FTDM_LOG_WARNING, "Dropping event %d, not retrieved on time", ftdmchan->last_event_id);
ftdmchan->last_event_id = zt_event_id;
@<Set event pending on the channel |ftdmchan|@>@;

@ @<Set event pending on the channel |ftdmchan|@>=
ftdmchan->io_flags |= FTDM_CHANNEL_IO_EVENT;
ftdmchan->last_event_time = ftdm_current_time_in_ms();

@ @c
static ftdm_status_t zt_write(ftdm_channel_t * ftdmchan, void *data, size_t *datalen)
{
  ftdm_ssize_t w = 0;
  size_t bytes = *datalen;

tryagain:
  w = write(ftdmchan->sockfd, data, bytes);

  if (w >= 0) {
    *datalen = w;
    return FTDM_SUCCESS;
  }

  if (errno == ELAST) {
    int zt_event_id = 0;
    if (ioctl(ftdmchan->sockfd, DAHDI_GETEVENT, &zt_event_id) == -1) {
      ftdm_log(FTDM_LOG_ERROR, "Failed retrieving event after ELAST on write: %s\n",
        strerror(errno));
      return FTDM_FAIL;
    }

    ftdm_log(FTDM_LOG_DEBUG, "Deferring event %d to be able to write data", zt_event_id);
    if (ftdmchan->last_event_id)
      ftdm_log(FTDM_LOG_WARNING, "Dropping event %d, not retrieved on time", ftdmchan->last_event_id);
    ftdmchan->last_event_id = zt_event_id;
    @<Set event pending on the channel |ftdmchan|@>@;

    goto tryagain;
  }

  return FTDM_FAIL;
}

static ftdm_status_t zt_channel_destroy(ftdm_channel_t * ftdmchan)
{
  close(ftdmchan->sockfd);
  ftdmchan->sockfd = -1;
  return FTDM_SUCCESS;
}

static ftdm_io_interface_t zt_interface;

static ftdm_status_t zt_init(ftdm_io_interface_t ** fio)
{
  memset(&zt_interface, 0, sizeof(zt_interface));

  if ((CONTROL_FD = open("/dev/dahdi/ctl", O_RDWR)) < 0) {
    ftdm_log(FTDM_LOG_ERROR,
             "Cannot open control device /dev/dahdi/ctl: %s\n",
             strerror(errno));
    return FTDM_FAIL;
  }

  zt_interface.name = "zt";
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

static ftdm_status_t zt_destroy(void)
{
  close(CONTROL_FD);
  memset(&zt_interface, 0, sizeof(zt_interface));
  return FTDM_SUCCESS;
}

struct ftdm_module {
  char name[256];
  fio_io_load_t io_load;
  fio_io_unload_t io_unload;
  fio_sig_load_t sig_load;
  fio_sig_configure_t sig_configure;
  fio_sig_unload_t sig_unload;
  fio_configure_span_signaling_t configure_span_signaling;
  ftdm_dso_lib_t lib;
  char path[256];
} ftdm_module = {
  "zt",
  zt_init,
  zt_destroy,
};

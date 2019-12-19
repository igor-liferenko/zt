@ @c
#if !defined(_XOPEN_SOURCE)
#define _XOPEN_SOURCE 600
#endif
#include <errno.h>
#include <fcntl.h>
#include <math.h>
#include <poll.h>
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

#define DAHDI_CODE 0xDA

#define DAHDI_GET_BLOCKSIZE @,@,@,@,@, _IOR(DAHDI_CODE, 1, int) /* Get Transfer Block Size */
#define DAHDI_SET_BLOCKSIZE @,@,@,@,@, _IOW(DAHDI_CODE, 1, int) /* Set Transfer Block Size */
#define DAHDI_FLUSH @,@,@,@,@, _IOW(DAHDI_CODE, 3, int) /* Flush Buffer(s) and stop I/O */
#define DAHDI_SYNC @,@,@,@,@, _IO(DAHDI_CODE, 4)        /* Wait for Write to Finish */
#define DAHDI_GET_PARAMS @,@,@,@,@, _IOR(DAHDI_CODE, 5, struct zt_params)
  /* Get channel parameters */
#define DAHDI_SET_PARAMS @,@,@,@,@, _IOW(DAHDI_CODE, 5, struct zt_params)
  /* Set channel parameters */
#define DAHDI_HOOK _IOW (DAHDI_CODE, 7, int)    /* Set Hookswitch Status */
#define DAHDI_GETEVENT _IOR (DAHDI_CODE, 8, int)        /* Get Signalling Event */
#define DAHDI_IOMUX _IOWR (DAHDI_CODE, 9, int)  /* Wait for something to happen (IO Mux) */
#define DAHDI_SPANSTAT _IOWR (DAHDI_CODE, 10, struct zt_spaninfo)       /* Get Span Status */

#define DAHDI_GETGAINS _IOR (DAHDI_CODE, 16, struct zt_gains)   /* Get Channel audio gains */
#define DAHDI_SETGAINS _IOW (DAHDI_CODE, 16, struct zt_gains)   /* Set Channel audio gains */
#define DAHDI_CHANCONFIG _IOW (DAHDI_CODE, 19, struct zt_chanconfig)
  /* Set Channel Configuration  */
#define DAHDI_SET_BUFINFO _IOW (DAHDI_CODE, 27, struct zt_bufferinfo)   /* Set buffer policy */
#define DAHDI_GET_BUFINFO _IOR (DAHDI_CODE, 27, struct zt_bufferinfo)   /* Get current buffer info */
#define DAHDI_AUDIOMODE _IOW (DAHDI_CODE, 32, int)      /* Set a clear channel into audio mode */
#define DAHDI_ECHOCANCEL _IOW (DAHDI_CODE, 33, int)     /* Control Echo Canceller */
#define DAHDI_HDLCRAWMODE _IOW (DAHDI_CODE, 36, int)    /* Set a clear channel into HDLC w/out FCS
                                                           checking/calculation mode */
#define DAHDI_HDLCFCSMODE _IOW (DAHDI_CODE, 37, int)    /* Set a clear channel into HDLC w/ FCS
                                                           mode */

#define         DAHDI_ALARM_YELLOW (1 << 2)     /* channel alarm */
#define         DAHDI_ALARM_BLUE (1 << 4)       /* channel alarm */

#define DAHDI_SPECIFY _IOW (DAHDI_CODE, 38, int)        /* Specify a channel on /dev/dahdi/chan --- must
                                                           be done before any other ioctl's and is only valid on /dev/dahdi/channel */

#define DAHDI_SETLAW     _IOW  (DAHDI_CODE, 39, int)    /* Temporarily set the law on
                                                           a channel to \.{DAHDI\_LAW\_DEFAULT}, \.{DAHDI\_LAW\_ALAW}, or \.{DAHDI\_LAW\_MULAW}. Is reset
                                                           on close. */

#define DAHDI_SETLINEAR         _IOW  (DAHDI_CODE, 40, int)     /* Temporarily set the channel
                                                                   to operate in linear mode when non-zero or default law if 0 */

#define DAHDI_ECHOTRAIN         _IOW  (DAHDI_CODE, 50, int)     /* Control Echo Trainer */

#define DAHDI_SETTXBITS _IOW (DAHDI_CODE, 43, int)      /* set CAS bits */
#define DAHDI_GETRXBITS _IOR (DAHDI_CODE, 43, int)      /* get CAS bits */

#define DAHDI_SETPOLARITY _IOW (DAHDI_CODE, 92, int)    /* Polarity setting for FXO lines */

#define DAHDI_TONEDETECT _IOW(DAHDI_CODE, 91, int)      /* Enable tone detection --- implemented by low
                                                           level driver */

#define ELAST 500               /* used by dahdi to indicate there is no data available, but events to read */

#define FTDM_PRE __FILE__, __func__, __LINE__

#define FTDM_LOG_DEBUG FTDM_PRE, 7
#define FTDM_LOG_INFO FTDM_PRE, 6
#define FTDM_LOG_WARNING FTDM_PRE, 4
#define FTDM_LOG_ERROR FTDM_PRE, 3

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
typedef struct ftdm_group ftdm_group_t;
typedef struct ftdm_sigmsg ftdm_sigmsg_t;
typedef struct ftdm_usrmsg ftdm_usrmsg_t;
typedef struct ftdm_io_interface ftdm_io_interface_t;
typedef struct ftdm_stream_handle ftdm_stream_handle_t;
typedef struct ftdm_queue ftdm_queue_t;
typedef struct ftdm_memory_handler ftdm_memory_handler_t;
ftdm_status_t ftdm_set_npi(const char *npi_string, uint8_t * target);
ftdm_status_t ftdm_set_ton(const char *ton_string, uint8_t * target);
ftdm_status_t ftdm_set_bearer_capability(const char *bc_string,
                                         uint8_t * target);
ftdm_status_t ftdm_set_bearer_layer1(const char *bc_string,
                                     uint8_t * target);
ftdm_status_t ftdm_set_screening_ind(const char *string, uint8_t * target);
ftdm_status_t ftdm_set_presentation_ind(const char *string,
                                        uint8_t * target);
ftdm_status_t ftdm_is_number(const char *number);
ftdm_status_t ftdm_set_calling_party_category(const char *string,
                                              uint8_t * target);
char *ftdm_url_encode(const char *url, char *buf, size_t len);

char *ftdm_url_decode(char *s, size_t *len);

typedef struct ftdm_mutex ftdm_mutex_t;
typedef struct ftdm_thread ftdm_thread_t;
typedef struct ftdm_interrupt ftdm_interrupt_t;
typedef void *(*ftdm_thread_function_t)(ftdm_thread_t *, void *);

ftdm_status_t ftdm_thread_create_detached(ftdm_thread_function_t func,
                                          void *data);
ftdm_status_t ftdm_thread_create_detached_ex(ftdm_thread_function_t func,
                                             void *data,
                                             size_t stack_size);
void ftdm_thread_override_default_stacksize(size_t size);

ftdm_status_t ftdm_mutex_create(ftdm_mutex_t ** mutex);
ftdm_status_t ftdm_mutex_destroy(ftdm_mutex_t ** mutex);

ftdm_status_t _ftdm_mutex_lock(const char *file, int line,
                               const char *func, ftdm_mutex_t * mutex);
ftdm_status_t _ftdm_mutex_unlock(const char *file, int line,
                                 const char *func, ftdm_mutex_t * mutex);
ftdm_status_t ftdm_interrupt_create(ftdm_interrupt_t ** cond, int device,
                                    ftdm_wait_flag_t device_flags);
ftdm_status_t ftdm_interrupt_destroy(ftdm_interrupt_t ** cond);
ftdm_status_t ftdm_interrupt_signal(ftdm_interrupt_t * cond);
ftdm_status_t ftdm_interrupt_wait(ftdm_interrupt_t * cond, int ms);
ftdm_status_t ftdm_interrupt_multiple_wait(ftdm_interrupt_t * interrupts[],
                                           size_t size, int ms);
ftdm_wait_flag_t ftdm_interrupt_device_ready(ftdm_interrupt_t * interrupt);

typedef uint64_t ftdm_time_t;

extern ftdm_memory_handler_t g_ftdm_mem_handler;

char *ftdm_strdup(const char *str);

char *ftdm_strndup(const char *str, size_t inlen);

ftdm_time_t ftdm_current_time_in_ms(void);

typedef enum {
  FTDM_CAUSE_NONE = 0,
  FTDM_CAUSE_UNALLOCATED = 1,
  FTDM_CAUSE_NO_ROUTE_TRANSIT_NET = 2,
  FTDM_CAUSE_NO_ROUTE_DESTINATION = 3,
  FTDM_CAUSE_SEND_SPECIAL_INFO_TONE = 4,
  FTDM_CAUSE_MISDIALED_TRUNK_PREFIX = 5,
  FTDM_CAUSE_CHANNEL_UNACCEPTABLE = 6,
  FTDM_CAUSE_CALL_AWARDED_DELIVERED = 7,
  FTDM_CAUSE_PREEMPTION = 8,
  FTDM_CAUSE_PREEMPTION_CIRCUIT_RESERVED = 9,
  FTDM_CAUSE_NORMAL_CLEARING = 16,
  FTDM_CAUSE_USER_BUSY = 17,
  FTDM_CAUSE_NO_USER_RESPONSE = 18,
  FTDM_CAUSE_NO_ANSWER = 19,
  FTDM_CAUSE_SUBSCRIBER_ABSENT = 20,
  FTDM_CAUSE_CALL_REJECTED = 21,
  FTDM_CAUSE_NUMBER_CHANGED = 22,
  FTDM_CAUSE_REDIRECTION_TO_NEW_DESTINATION = 23,
  FTDM_CAUSE_EXCHANGE_ROUTING_ERROR = 25,
  FTDM_CAUSE_DESTINATION_OUT_OF_ORDER = 27,
  FTDM_CAUSE_INVALID_NUMBER_FORMAT = 28,
  FTDM_CAUSE_FACILITY_REJECTED = 29,
  FTDM_CAUSE_RESPONSE_TO_STATUS_ENQUIRY = 30,
  FTDM_CAUSE_NORMAL_UNSPECIFIED = 31,
  FTDM_CAUSE_NORMAL_CIRCUIT_CONGESTION = 34,
  FTDM_CAUSE_NETWORK_OUT_OF_ORDER = 38,
  FTDM_CAUSE_PERMANENT_FRAME_MODE_CONNECTION_OOS = 39,
  FTDM_CAUSE_PERMANENT_FRAME_MODE_OPERATIONAL = 40,
  FTDM_CAUSE_NORMAL_TEMPORARY_FAILURE = 41,
  FTDM_CAUSE_SWITCH_CONGESTION = 42,
  FTDM_CAUSE_ACCESS_INFO_DISCARDED = 43,
  FTDM_CAUSE_REQUESTED_CHAN_UNAVAIL = 44,
  FTDM_CAUSE_PRE_EMPTED = 45,
  FTDM_CAUSE_PRECEDENCE_CALL_BLOCKED = 46,
  FTDM_CAUSE_RESOURCE_UNAVAILABLE_UNSPECIFIED = 47,
  FTDM_CAUSE_QOS_NOT_AVAILABLE = 49,
  FTDM_CAUSE_FACILITY_NOT_SUBSCRIBED = 50,
  FTDM_CAUSE_OUTGOING_CALL_BARRED = 53,
  FTDM_CAUSE_INCOMING_CALL_BARRED = 55,
  FTDM_CAUSE_BEARERCAPABILITY_NOTAUTH = 57,
  FTDM_CAUSE_BEARERCAPABILITY_NOTAVAIL = 58,
  FTDM_CAUSE_INCONSISTENCY_IN_INFO = 62,
  FTDM_CAUSE_SERVICE_UNAVAILABLE = 63,
  FTDM_CAUSE_BEARERCAPABILITY_NOTIMPL = 65,
  FTDM_CAUSE_CHAN_NOT_IMPLEMENTED = 66,
  FTDM_CAUSE_FACILITY_NOT_IMPLEMENTED = 69,
  FTDM_CAUSE_ONLY_DIGITAL_INFO_BC_AVAIL = 70,
  FTDM_CAUSE_SERVICE_NOT_IMPLEMENTED = 79,
  FTDM_CAUSE_INVALID_CALL_REFERENCE = 81,
  FTDM_CAUSE_IDENTIFIED_CHAN_NOT_EXIST = 82,
  FTDM_CAUSE_SUSPENDED_CALL_EXISTS_BUT_CALL_ID_DOES_NOT = 83,
  FTDM_CAUSE_CALL_ID_IN_USE = 84,
  FTDM_CAUSE_NO_CALL_SUSPENDED = 85,
  FTDM_CAUSE_CALL_WITH_CALL_ID_CLEARED = 86,
  FTDM_CAUSE_USER_NOT_CUG = 87,
  FTDM_CAUSE_INCOMPATIBLE_DESTINATION = 88,
  FTDM_CAUSE_NON_EXISTENT_CUG = 90,
  FTDM_CAUSE_INVALID_TRANSIT_NETWORK_SELECTION = 91,
  FTDM_CAUSE_INVALID_MSG_UNSPECIFIED = 95,
  FTDM_CAUSE_MANDATORY_IE_MISSING = 96,
  FTDM_CAUSE_MESSAGE_TYPE_NONEXIST = 97,
  FTDM_CAUSE_WRONG_MESSAGE = 98,
  FTDM_CAUSE_IE_NONEXIST = 99,
  FTDM_CAUSE_INVALID_IE_CONTENTS = 100,
  FTDM_CAUSE_WRONG_CALL_STATE = 101,
  FTDM_CAUSE_RECOVERY_ON_TIMER_EXPIRE = 102,
  FTDM_CAUSE_MANDATORY_IE_LENGTH_ERROR = 103,
  FTDM_CAUSE_MSG_WITH_UNRECOGNIZED_PARAM_DISCARDED = 110,
  FTDM_CAUSE_PROTOCOL_ERROR = 111,
  FTDM_CAUSE_INTERWORKING = 127,
  FTDM_CAUSE_SUCCESS = 142,
  FTDM_CAUSE_ORIGINATOR_CANCEL = 487,
  FTDM_CAUSE_CRASH = 500,
  FTDM_CAUSE_SYSTEM_SHUTDOWN = 501,
  FTDM_CAUSE_LOSE_RACE = 502,
  FTDM_CAUSE_MANAGER_REQUEST = 503,
  FTDM_CAUSE_BLIND_TRANSFER = 600,
  FTDM_CAUSE_ATTENDED_TRANSFER = 601,
  FTDM_CAUSE_ALLOTTED_TIMEOUT = 602,
  FTDM_CAUSE_USER_CHALLENGE = 603,
  FTDM_CAUSE_MEDIA_TIMEOUT = 604
} ftdm_call_cause_t;

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

typedef enum {
  FTDM_CHAN_TYPE_B,
  FTDM_CHAN_TYPE_DQ921,
  FTDM_CHAN_TYPE_DQ931,
  FTDM_CHAN_TYPE_FXS,
  FTDM_CHAN_TYPE_FXO,
  FTDM_CHAN_TYPE_EM,
  FTDM_CHAN_TYPE_CAS,
  FTDM_CHAN_TYPE_COUNT
} ftdm_chan_type_t;

ftdm_chan_type_t ftdm_str2ftdm_chan_type(const char *name);
const char *ftdm_chan_type2str(ftdm_chan_type_t type);

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
  FTDM_BEARER_CAP_SPEECH = 0x00,
  FTDM_BEARER_CAP_UNRESTRICTED,
  FTDM_BEARER_CAP_RESTRICTED,
  FTDM_BEARER_CAP_3_1KHZ_AUDIO,
  FTDM_BEARER_CAP_7KHZ_AUDIO,
  FTDM_BEARER_CAP_15KHZ_AUDIO,
  FTDM_BEARER_CAP_VIDEO,
  FTDM_BEARER_CAP_INVALID
} ftdm_bearer_cap_t;

typedef enum {
  FTDM_USER_LAYER1_PROT_V110 = 0x01,
  FTDM_USER_LAYER1_PROT_ULAW = 0x02,
  FTDM_USER_LAYER1_PROT_ALAW = 0x03,
  FTDM_USER_LAYER1_PROT_INVALID
} ftdm_user_layer1_prot_t;

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
  ftdm_bearer_cap_t bearer_capability;
  ftdm_user_layer1_prot_t bearer_layer1;
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

typedef enum {
  FTDM_TRUNK_E1,
  FTDM_TRUNK_T1,
  FTDM_TRUNK_J1,
  FTDM_TRUNK_BRI,
  FTDM_TRUNK_BRI_PTMP,
  FTDM_TRUNK_FXO,
  FTDM_TRUNK_FXS,
  FTDM_TRUNK_EM,
  FTDM_TRUNK_GSM,
  FTDM_TRUNK_NONE
} ftdm_trunk_type_t;

typedef enum {
  FTDM_TRUNK_MODE_CPE,
  FTDM_TRUNK_MODE_NET,
  FTDM_TRUNK_MODE_INVALID
} ftdm_trunk_mode_t;

typedef struct ftdm_channel_config {
  char name[128];
  char number[32];
  char group_name[128];
  ftdm_chan_type_t type;
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

typedef struct ftdm_iterator ftdm_iterator_t;

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

typedef enum {
  FTDM_POLARITY_FORWARD = 0,
  FTDM_POLARITY_REVERSE = 1
} ftdm_polarity_t;

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
typedef ftdm_status_t(*fio_configure_span_t) (ftdm_span_t * span,
                                              const char *str,
                                              ftdm_chan_type_t type,
                                              char *name, char *number);
typedef ftdm_status_t(*fio_configure_t) (const char *category,
                                         const char *var, const char *val,
                                         int lineno);
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
  fio_configure_t configure;
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
  FTDM_CODEC_ULAW = 0,
  FTDM_CODEC_ALAW = 8,
  FTDM_CODEC_SLIN = 10,
  FTDM_CODEC_NONE = (1 << 30)
} ftdm_codec_t;

typedef enum {
  FTDM_ALARM_NONE = 0,
  FTDM_ALARM_RED = (1 << 0),
  FTDM_ALARM_YELLOW = (1 << 1),
  FTDM_ALARM_RAI = (1 << 2),
  FTDM_ALARM_BLUE = (1 << 3),
  FTDM_ALARM_AIS = (1 << 4),
  FTDM_ALARM_GENERAL = (1 << 30)
} ftdm_alarm_flag_t;

typedef enum {
  FTDM_MF_DIRECTION_FORWARD = (1 << 8),
  FTDM_MF_DIRECTION_BACKWARD = (1 << 9)
} ftdm_mf_direction_flag_t;

typedef enum {
  FTDM_IOSTATS_ERROR_CRC = (1 << 0),
  FTDM_IOSTATS_ERROR_FRAME = (1 << 1),
  FTDM_IOSTATS_ERROR_ABORT = (1 << 2),
  FTDM_IOSTATS_ERROR_FIFO = (1 << 3),
  FTDM_IOSTATS_ERROR_DMA = (1 << 4),
  FTDM_IOSTATS_ERROR_QUEUE_THRES = (1 << 5),
  FTDM_IOSTATS_ERROR_QUEUE_FULL = (1 << 6),
} ftdm_iostats_error_type_t;

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

ftdm_status_t ftdm_global_set_queue_handler(ftdm_queue_handler_t *
                                            handler);

int ftdm_channel_get_availability(ftdm_channel_t * ftdmchan);

ftdm_bool_t ftdm_channel_call_check_answered(const ftdm_channel_t *
                                             ftdmchan);

ftdm_bool_t ftdm_channel_call_check_busy(const ftdm_channel_t * ftdmchan);

ftdm_bool_t ftdm_channel_call_check_hangup(const ftdm_channel_t *
                                           ftdmchan);

ftdm_bool_t ftdm_channel_call_check_done(const ftdm_channel_t * ftdmchan);

ftdm_bool_t ftdm_channel_call_check_hold(const ftdm_channel_t * ftdmchan);

ftdm_status_t ftdm_channel_set_sig_status(ftdm_channel_t * ftdmchan,
                                          ftdm_signaling_status_t status);

ftdm_status_t ftdm_channel_get_sig_status(ftdm_channel_t * ftdmchan,
                                          ftdm_signaling_status_t *
                                          status);

ftdm_status_t ftdm_span_set_sig_status(ftdm_span_t * span,
                                       ftdm_signaling_status_t status);

ftdm_status_t ftdm_span_get_sig_status(ftdm_span_t * span,
                                       ftdm_signaling_status_t * status);
void ftdm_channel_set_private(ftdm_channel_t * ftdmchan, void *pvt);
void *ftdm_channel_get_private(const ftdm_channel_t * ftdmchan);
ftdm_status_t ftdm_channel_clear_token(ftdm_channel_t * ftdmchan,
                                       const char *token);
void ftdm_channel_replace_token(ftdm_channel_t * ftdmchan,
                                const char *old_token,
                                const char *new_token);
ftdm_status_t ftdm_channel_add_token(ftdm_channel_t * ftdmchan,
                                     char *token, int end);
const char *ftdm_channel_get_token(const ftdm_channel_t * ftdmchan,
                                   uint32_t tokenid);
uint32_t ftdm_channel_get_token_count(const ftdm_channel_t * ftdmchan);
uint32_t ftdm_channel_get_io_interval(const ftdm_channel_t * ftdmchan);
uint32_t ftdm_channel_get_io_packet_len(const ftdm_channel_t * ftdmchan);
ftdm_codec_t ftdm_channel_get_codec(const ftdm_channel_t * ftdmchan);
const char *ftdm_channel_get_last_error(const ftdm_channel_t * ftdmchan);
ftdm_status_t ftdm_channel_get_alarms(ftdm_channel_t * ftdmchan,
                                      ftdm_alarm_flag_t * alarmbits);
ftdm_chan_type_t ftdm_channel_get_type(const ftdm_channel_t * ftdmchan);
size_t ftdm_channel_dequeue_dtmf(ftdm_channel_t * ftdmchan, char *dtmf,
                                 size_t len);

void ftdm_channel_flush_dtmf(ftdm_channel_t * ftdmchan);
ftdm_status_t ftdm_span_poll_event(ftdm_span_t * span, uint32_t ms,
                                   short *poll_events);
ftdm_status_t ftdm_span_find(uint32_t id, ftdm_span_t ** span);
const char *ftdm_span_get_last_error(const ftdm_span_t * span);
ftdm_status_t ftdm_span_create(const char *iotype, const char *name,
                               ftdm_span_t ** span);
ftdm_status_t ftdm_span_add_channel(ftdm_span_t * span, int sockfd,
                                    ftdm_chan_type_t type,
                                    ftdm_channel_t ** chan);

ftdm_status_t ftdm_channel_add_to_group(const char *name,
                                        ftdm_channel_t * ftdmchan);

ftdm_status_t ftdm_channel_remove_from_group(ftdm_group_t * group,
                                             ftdm_channel_t * ftdmchan);
ftdm_status_t ftdm_channel_read_event(ftdm_channel_t * ftdmchan,
                                      ftdm_event_t ** event);

ftdm_status_t ftdm_group_find(uint32_t id, ftdm_group_t ** group);

ftdm_status_t ftdm_group_find_by_name(const char *name,
                                      ftdm_group_t ** group);

ftdm_status_t ftdm_group_create(ftdm_group_t ** group, const char *name);

ftdm_status_t ftdm_span_channel_use_count(ftdm_span_t * span,
                                          uint32_t * count);

ftdm_status_t ftdm_group_channel_use_count(ftdm_group_t * group,
                                           uint32_t * count);

uint32_t ftdm_group_get_id(const ftdm_group_t * group);
ftdm_status_t ftdm_channel_open(uint32_t span_id, uint32_t chan_id,
                                ftdm_channel_t ** ftdmchan);
ftdm_status_t ftdm_channel_open_ph(uint32_t span_id, uint32_t chan_id,
                                   ftdm_channel_t ** ftdmchan);
ftdm_status_t ftdm_channel_open_by_span(uint32_t span_id,
                                        ftdm_hunt_direction_t direction,
                                        ftdm_caller_data_t * caller_data,
                                        ftdm_channel_t ** ftdmchan);
ftdm_status_t ftdm_channel_open_by_group(uint32_t group_id,
                                         ftdm_hunt_direction_t direction,
                                         ftdm_caller_data_t * caller_data,
                                         ftdm_channel_t ** ftdmchan);
ftdm_status_t ftdm_channel_close(ftdm_channel_t ** ftdmchan);
ftdm_status_t ftdm_channel_command(ftdm_channel_t * ftdmchan,
                                   ftdm_command_t command, void *arg);
ftdm_status_t ftdm_channel_wait(ftdm_channel_t * ftdmchan,
                                ftdm_wait_flag_t * flags, int32_t timeout);
ftdm_status_t ftdm_channel_read(ftdm_channel_t * ftdmchan, void *data,
                                size_t *datalen);
ftdm_status_t ftdm_channel_write(ftdm_channel_t * ftdmchan, void *data,
                                 size_t datasize, size_t *datalen);

const char *ftdm_sigmsg_get_var(ftdm_sigmsg_t * sigmsg,
                                const char *var_name);
ftdm_iterator_t *ftdm_sigmsg_get_var_iterator(const ftdm_sigmsg_t * sigmsg,
                                              ftdm_iterator_t * iter);
ftdm_status_t ftdm_sigmsg_get_raw_data(ftdm_sigmsg_t * sigmsg, void **data,
                                       size_t *datalen);
ftdm_status_t ftdm_sigmsg_get_raw_data_detached(ftdm_sigmsg_t * sigmsg,
                                                void **data,
                                                size_t *datalen);

ftdm_status_t ftdm_usrmsg_add_var(ftdm_usrmsg_t * usrmsg,
                                  const char *var_name, const char *value);
ftdm_status_t ftdm_usrmsg_set_raw_data(ftdm_usrmsg_t * usrmsg, void *data,
                                       size_t datalen);

void *ftdm_iterator_current(ftdm_iterator_t * iter);

ftdm_status_t ftdm_get_current_var(ftdm_iterator_t * iter,
                                   const char **var_name,
                                   const char **var_val);

ftdm_iterator_t *ftdm_iterator_next(ftdm_iterator_t * iter);

ftdm_status_t ftdm_iterator_free(ftdm_iterator_t * iter);

ftdm_span_t *ftdm_channel_get_span(const ftdm_channel_t * ftdmchan);

uint32_t ftdm_channel_get_span_id(const ftdm_channel_t * ftdmchan);

uint32_t ftdm_channel_get_ph_span_id(const ftdm_channel_t * ftdmchan);

const char *ftdm_channel_get_span_name(const ftdm_channel_t * ftdmchan);

uint32_t ftdm_channel_get_id(const ftdm_channel_t * ftdmchan);

const char *ftdm_channel_get_name(const ftdm_channel_t * ftdmchan);

const char *ftdm_channel_get_number(const ftdm_channel_t * ftdmchan);

uint32_t ftdm_channel_get_ph_id(const ftdm_channel_t * ftdmchan);
ftdm_status_t ftdm_configure_span(ftdm_span_t * span, const char *type,
                                  fio_signal_cb_t sig_cb, ...);
ftdm_status_t ftdm_configure_span_signaling(ftdm_span_t * span,
                                            const char *type,
                                            fio_signal_cb_t sig_cb,
                                            ftdm_conf_parameter_t *
                                            parameters);
ftdm_status_t ftdm_span_register_signal_cb(ftdm_span_t * span,
                                           fio_signal_cb_t sig_cb);
ftdm_status_t ftdm_span_start(ftdm_span_t * span);
ftdm_status_t ftdm_span_stop(ftdm_span_t * span);
ftdm_status_t ftdm_global_add_io_interface(ftdm_io_interface_t *
                                           io_interface);
ftdm_io_interface_t *ftdm_global_get_io_interface(const char *iotype,
                                                  ftdm_bool_t autoload);

ftdm_status_t ftdm_span_find_by_name(const char *name,
                                     ftdm_span_t ** span);

uint32_t ftdm_span_get_id(const ftdm_span_t * span);

const char *ftdm_span_get_name(const ftdm_span_t * span);

ftdm_iterator_t *ftdm_span_get_chan_iterator(const ftdm_span_t * span,
                                             ftdm_iterator_t * iter);

ftdm_iterator_t *ftdm_get_span_iterator(ftdm_iterator_t * iter);

ftdm_status_t ftdm_conf_node_create(const char *name,
                                    ftdm_conf_node_t ** node,
                                    ftdm_conf_node_t * parent);
ftdm_status_t ftdm_conf_node_add_param(ftdm_conf_node_t * node,
                                       const char *param, const char *val);
ftdm_status_t ftdm_conf_node_destroy(ftdm_conf_node_t * node);
void ftdm_span_set_trunk_type(ftdm_span_t * span, ftdm_trunk_type_t type);
ftdm_trunk_type_t ftdm_span_get_trunk_type(const ftdm_span_t * span);

const char *ftdm_span_get_trunk_type_str(const ftdm_span_t * span);

void ftdm_span_set_trunk_mode(ftdm_span_t * span, ftdm_trunk_mode_t mode);

ftdm_trunk_mode_t ftdm_span_get_trunk_mode(const ftdm_span_t * span);

const char *ftdm_span_get_trunk_mode_str(const ftdm_span_t * span);
ftdm_channel_t *ftdm_span_get_channel(const ftdm_span_t * span,
                                      uint32_t chanid);
ftdm_channel_t *ftdm_span_get_channel_ph(const ftdm_span_t * span,
                                         uint32_t chanid);

uint32_t ftdm_span_get_chan_count(const ftdm_span_t * span);

ftdm_status_t ftdm_channel_set_caller_data(ftdm_channel_t * ftdmchan,
                                           ftdm_caller_data_t *
                                           caller_data);

ftdm_caller_data_t *ftdm_channel_get_caller_data(ftdm_channel_t * channel);

int ftdm_channel_get_state(const ftdm_channel_t * ftdmchan);

int ftdm_channel_get_last_state(const ftdm_channel_t * ftdmchan);

const char *ftdm_channel_get_state_str(const ftdm_channel_t * channel);

const char *ftdm_channel_get_last_state_str(const ftdm_channel_t *
                                            channel);

char *ftdm_channel_get_history_str(const ftdm_channel_t * channel);

ftdm_status_t ftdm_span_set_blocking_mode(const ftdm_span_t * span,
                                          ftdm_bool_t enabled);

ftdm_status_t ftdm_global_init(void);

ftdm_status_t ftdm_global_configuration(void);

ftdm_status_t ftdm_global_destroy(void);

ftdm_status_t ftdm_global_set_memory_handler(ftdm_memory_handler_t *
                                             handler);

void ftdm_global_set_crash_policy(ftdm_crash_policy_t policy);

void ftdm_global_set_logger(ftdm_logger_t logger);

void ftdm_global_set_default_logger(int level);

void ftdm_global_set_mod_directory(const char *path);

void ftdm_global_set_config_directory(const char *path);

ftdm_bool_t ftdm_running(void);
ftdm_status_t ftdm_backtrace_walk(void (*callback)
                                   (const int tid, const void *addr,
                                    const char *symbol, void *priv),
                                  void *priv);
ftdm_status_t ftdm_backtrace_span(ftdm_span_t * span);
ftdm_status_t ftdm_backtrace_chan(ftdm_channel_t * chan);

extern ftdm_logger_t ftdm_log;

typedef ftdm_status_t(*fio_codec_t) (void *data, size_t max,
                                     size_t *datalen);

ftdm_status_t fio_slin2ulaw(void *data, size_t max, size_t *datalen);
ftdm_status_t fio_ulaw2slin(void *data, size_t max, size_t *datalen);
ftdm_status_t fio_slin2alaw(void *data, size_t max, size_t *datalen);
ftdm_status_t fio_alaw2slin(void *data, size_t max, size_t *datalen);
ftdm_status_t fio_ulaw2alaw(void *data, size_t max, size_t *datalen);
ftdm_status_t fio_alaw2ulaw(void *data, size_t max, size_t *datalen);

typedef void (*bytehandler_func_t)(void *, int);
typedef void (*bithandler_func_t)(void *, int);

typedef struct dsp_uart_attr_s {
  bytehandler_func_t bytehandler;
  void *bytehandler_arg;
} dsp_uart_attr_t;

typedef struct {
  dsp_uart_attr_t attr;
  int have_start;
  int data;
  int nbits;
} dsp_uart_handle_t;
void dsp_uart_attr_init(dsp_uart_attr_t * attributes);

bytehandler_func_t dsp_uart_attr_get_bytehandler(dsp_uart_attr_t *
                                                 attributes,
                                                 void **bytehandler_arg);
void dsp_uart_attr_set_bytehandler(dsp_uart_attr_t * attributes,
                                   bytehandler_func_t bytehandler,
                                   void *bytehandler_arg);

dsp_uart_handle_t *dsp_uart_create(dsp_uart_attr_t * attributes);
void dsp_uart_destroy(dsp_uart_handle_t ** handle);

void dsp_uart_bit_handler(void *handle, int bit);

typedef struct {
  int freq_space;
  int freq_mark;
  int baud_rate;
} fsk_modem_definition_t;

typedef enum {
  FSK_V23_FORWARD_MODE1 = 0,
  FSK_V23_FORWARD_MODE2,
  FSK_V23_BACKWARD,
  FSK_BELL202
} fsk_modem_types_t;

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
void dsp_fsk_attr_init(dsp_fsk_attr_t * attributes);

bithandler_func_t dsp_fsk_attr_get_bithandler(dsp_fsk_attr_t * attributes,
                                              void **bithandler_arg);
void dsp_fsk_attr_set_bithandler(dsp_fsk_attr_t * attributes,
                                 bithandler_func_t bithandler,
                                 void *bithandler_arg);
bytehandler_func_t dsp_fsk_attr_get_bytehandler(dsp_fsk_attr_t *
                                                attributes,
                                                void **bytehandler_arg);
void dsp_fsk_attr_set_bytehandler(dsp_fsk_attr_t * attributes,
                                  bytehandler_func_t bytehandler,
                                  void *bytehandler_arg);
int dsp_fsk_attr_get_samplerate(dsp_fsk_attr_t * attributes);
int dsp_fsk_attr_set_samplerate(dsp_fsk_attr_t * attributes,
                                int samplerate);

dsp_fsk_handle_t *dsp_fsk_create(dsp_fsk_attr_t * attributes);
void dsp_fsk_destroy(dsp_fsk_handle_t ** handle);

void dsp_fsk_sample(dsp_fsk_handle_t * handle, double normalized_sample);

extern fsk_modem_definition_t fsk_modem_definitions[];

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
  FTDM_CHANNEL_FEATURE_DTMF_DETECT = (1 << 0),
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

typedef enum {
  FTDM_CHANNEL_IO_EVENT = (1 << 0),
  FTDM_CHANNEL_IO_READ = (1 << 1),
  FTDM_CHANNEL_IO_WRITE = (1 << 2),
} ftdm_channel_io_flags_t;

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

ftdm_status_t ftdm_channel_cancel_state(const char *file, const char *func,
                                        int line,
                                        ftdm_channel_t * ftdmchan);

ftdm_status_t ftdm_channel_set_state(const char *file, const char *func,
                                     int line, ftdm_channel_t * ftdmchan,
                                     ftdm_channel_state_t state, int wait,
                                     ftdm_usrmsg_t * usrmsg);

typedef enum ftdm_channel_hw_link_status {
  FTDM_HW_LINK_DISCONNECTED = 0,
  FTDM_HW_LINK_CONNECTED
} ftdm_channel_hw_link_status_t;

typedef ftdm_status_t(*ftdm_stream_handle_raw_write_function_t)
 (ftdm_stream_handle_t * handle, uint8_t * data, size_t datalen);
typedef
ftdm_status_t(*ftdm_stream_handle_write_function_t) (ftdm_stream_handle_t *
                                                     handle,
                                                     const char *fmt, ...);

typedef void (*ftdm_func_ptr_t)(void);
typedef void *ftdm_dso_lib_t;

ftdm_status_t ftdm_dso_destroy(ftdm_dso_lib_t * lib);
ftdm_dso_lib_t ftdm_dso_open(const char *path, char **err);
void *ftdm_dso_func_sym(ftdm_dso_lib_t lib, const char *sym, char **err);
char *ftdm_build_dso_path(const char *name, char *path, size_t len);

struct ftdm_conf_node {

  char name[50];

  unsigned int t_parameters;

  unsigned int n_parameters;

  ftdm_conf_parameter_t *parameters;

  struct ftdm_conf_node *child;

  struct ftdm_conf_node *last;

  struct ftdm_conf_node *next;

  struct ftdm_conf_node *prev;

  struct ftdm_conf_node *parent;
};

typedef struct ftdm_module {
  char name[256];
  fio_io_load_t io_load;
  fio_io_unload_t io_unload;
  fio_sig_load_t sig_load;
  fio_sig_configure_t sig_configure;
  fio_sig_unload_t sig_unload;
  fio_configure_span_signaling_t configure_span_signaling;
  ftdm_dso_lib_t lib;
  char path[256];
} ftdm_module_t;

typedef struct ftdm_fsk_data_state ftdm_fsk_data_state_t;
typedef int (*ftdm_fsk_data_decoder_t)(ftdm_fsk_data_state_t * state);
typedef ftdm_status_t(*ftdm_fsk_write_sample_t) (int16_t * buf,
                                                 size_t buflen,
                                                 void *user_data);
typedef struct hashtable ftdm_hash_t;
typedef struct hashtable_iterator ftdm_hash_iterator_t;
typedef struct key ftdm_hash_key_t;
typedef struct value ftdm_hash_val_t;
typedef struct ftdm_bitstream ftdm_bitstream_t;
typedef struct ftdm_fsk_modulator ftdm_fsk_modulator_t;
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

typedef enum {
  FTDM_ITERATOR_VARS = 1,
  FTDM_ITERATOR_CHANS,
  FTDM_ITERATOR_SPANS,
} ftdm_iterator_type_t;

struct ftdm_iterator {
  ftdm_iterator_type_t type;
  unsigned int allocated:1;
  union {
    struct {
      uint32_t index;
      const ftdm_span_t *span;
    } chaniter;
    ftdm_hash_iterator_t *hashiter;
  } pvt;
};

struct hashtable;
struct hashtable_iterator;
struct hashtable *create_hashtable(unsigned int minsize,
                                   unsigned int (*hashfunction)(void *),
                                   int(*key_eq_fn)(void *, void *));
typedef enum {
  HASHTABLE_FLAG_NONE = 0,
  HASHTABLE_FLAG_FREE_KEY = (1 << 0),
  HASHTABLE_FLAG_FREE_VALUE = (1 << 1)
} hashtable_flag_t;

int
hashtable_insert(struct hashtable *h, void *k, void *v,
                 hashtable_flag_t flags);

void *hashtable_search(struct hashtable *h, void *k);

void *hashtable_remove(struct hashtable *h, void *k);

unsigned int hashtable_count(struct hashtable *h);
void hashtable_destroy(struct hashtable *h);

struct hashtable_iterator *hashtable_first(struct hashtable *h);
struct hashtable_iterator *hashtable_next(struct hashtable_iterator *i);
void hashtable_this(struct hashtable_iterator *i, const void **key,
                    int *klen, void **val);

int ftdm_config_get_cas_bits(char *strvalue, unsigned char *outbits);
static __inline__ int top_bit(unsigned int bits)
{
  int res;

  __asm__ __volatile__(" movq $-1,%%rdx;\n"
                       " bsrq %%rax,%%rdx;\n":"=d"(res)
                       :"a"(bits));
  return res;
}

static __inline__ int bottom_bit(unsigned int bits)
{
  int res;

  __asm__ __volatile__(" movq $-1,%%rdx;\n"
                       " bsfq %%rax,%%rdx;\n":"=d"(res)
                       :"a"(bits));
  return res;
}

static __inline__ uint8_t linear_to_ulaw(int linear)
{
  uint8_t u_val;
  int mask;
  int seg;

  if (linear < 0) {
    linear = 0x84 - linear;
    mask = 0x7F;
  }
  else {
    linear = 0x84 + linear;
    mask = 0xFF;
  }

  seg = top_bit(linear | 0xFF) - 7;

  if (seg >= 8)
    u_val = (uint8_t) (0x7F ^ mask);
  else
    u_val =
        (uint8_t) (((seg << 4) | ((linear >> (seg + 3)) & 0xF)) ^ mask);

  return u_val;
}

static __inline__ int16_t ulaw_to_linear(uint8_t ulaw)
{
  int t;

  ulaw = ~ulaw;

  t = (((ulaw & 0x0F) << 3) + 0x84) << (((int) ulaw & 0x70) >> 4);
  return (int16_t) ((ulaw & 0x80) ? (0x84 - t) : (t - 0x84));
}

static __inline__ uint8_t linear_to_alaw(int linear)
{
  int mask;
  int seg;

  if (linear >= 0) {

    mask = 0x55 | 0x80;
  }
  else {

    mask = 0x55;
    linear = -linear - 8;
  }

  seg = top_bit(linear | 0xFF) - 7;
  if (seg >= 8) {
    if (linear >= 0) {

      return (uint8_t) (0x7F ^ mask);
    }

    return (uint8_t) (0x00 ^ mask);
  }

  return (uint8_t) (((seg << 4) |
                     ((linear >> ((seg) ? (seg + 3) : 4)) & 0x0F)) ^ mask);
}

static __inline__ int16_t alaw_to_linear(uint8_t alaw)
{
  int i;
  int seg;

  alaw ^= 0x55;
  i = ((alaw & 0x0F) << 4);
  seg = (((int) alaw & 0x70) >> 4);
  if (seg)
    i = (i + 0x108) << (seg - 1);
  else
    i += 8;
  return (int16_t) ((alaw & 0x80) ? i : -i);
}

uint8_t alaw_to_ulaw(uint8_t alaw);

uint8_t ulaw_to_alaw(uint8_t ulaw);

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

extern int16_t TELETONE_SINES[128];

static __inline__ int32_t teletone_dds_phase_rate(teletone_process_t tone,
                                                  uint32_t rate)
{
  return (int32_t) ((tone * 0x10000 * 0x10000) / rate);
}

static __inline__ int16_t
teletone_dds_state_modulate_sample(teletone_dds_state_t * dds,
                                   uint32_t pindex)
{
  int32_t bitmask = dds->phase_accumulator, sine_index =
      (bitmask >>= 23) & (128 - 1);
  int16_t sample;

  if (pindex >= 4) {
    pindex = 0;
  }

  if (bitmask & 128) {
    sine_index = (128 - 1) - sine_index;
  }

  sample = TELETONE_SINES[sine_index];

  if (bitmask & (128 * 2)) {
    sample *= -1;
  }

  dds->phase_accumulator += dds->phase_rate[pindex];
  return (int16_t) (sample * dds->scale_factor >> 15);
}

static __inline__ void teletone_dds_state_set_tx_level(teletone_dds_state_t
                                                       * dds,
                                                       float tx_level)
{
  dds->scale_factor =
      (int) (powf(10.0f, (tx_level - (3.14f + 3.02f)) / 20.0f) *
             (32767.0f * 1.414214f));
  dds->tx_level = tx_level;
}

static __inline__ void teletone_dds_state_reset_accum(teletone_dds_state_t
                                                      * dds)
{
  dds->phase_accumulator = 0;
}

static __inline__ int teletone_dds_state_set_tone(teletone_dds_state_t *
                                                  dds,
                                                  teletone_process_t tone,
                                                  uint32_t rate,
                                                  uint32_t pindex)
{
  if (pindex < 4) {
    dds->phase_rate[pindex] = teletone_dds_phase_rate(tone, rate);
    return 0;
  }

  return -1;
}

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
int teletone_set_tone(teletone_generation_session_t * ts, int index, ...);

int teletone_set_map(teletone_tone_map_t * map, ...);
int teletone_init_session(teletone_generation_session_t * ts, int buflen,
                          tone_handler handler, void *user_data);

int teletone_destroy_session(teletone_generation_session_t * ts);

int teletone_mux_tones(teletone_generation_session_t * ts,
                       teletone_tone_map_t * map);

int teletone_run(teletone_generation_session_t * ts, const char *cmd);

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

ftdm_status_t ftdm_sched_create(ftdm_sched_t ** sched, const char *name);

ftdm_status_t ftdm_sched_run(ftdm_sched_t * sched);

ftdm_status_t ftdm_sched_free_run(ftdm_sched_t * sched);
ftdm_status_t ftdm_sched_timer(ftdm_sched_t * sched, const char *name,
                               int ms, ftdm_sched_callback_t callback,
                               void *data, ftdm_timer_id_t * timer);
ftdm_status_t ftdm_sched_cancel_timer(ftdm_sched_t * sched,
                                      ftdm_timer_id_t timer);

ftdm_status_t ftdm_sched_destroy(ftdm_sched_t ** sched);

ftdm_status_t ftdm_sched_get_time_to_next_timer(const ftdm_sched_t * sched,
                                                int32_t * timeto);

ftdm_status_t ftdm_sched_global_init(void);

ftdm_status_t ftdm_sched_global_destroy(void);

ftdm_bool_t ftdm_free_sched_running(void);

ftdm_bool_t ftdm_free_sched_stop(void);

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

ftdm_status_t ftdm_console_stream_raw_write(ftdm_stream_handle_t * handle,
                                            uint8_t * data,
                                            size_t datalen);
ftdm_status_t ftdm_console_stream_write(ftdm_stream_handle_t * handle,
                                        const char *fmt, ...);

extern ftdm_queue_handler_t g_ftdm_queue_handler;

static __inline__ char *ftdm_clean_string(char *s)
{
  char *p;

  for (p = s; p && *p; p++) {
    uint8_t x = (uint8_t) * p;
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
  size_t blen;
  size_t bpos;
  size_t dlen;
  size_t ppos;
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
  ftdm_chan_type_t type;
  int sockfd;
  uint64_t flags;
  uint32_t pflags;
  uint32_t sflags;
  uint8_t io_flags;
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
  ftdm_polarity_t polarity;

  void *io_data;

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
  ftdm_signal_type_t signal_type;
  uint32_t last_used_index;

  void *signal_data;
  fio_signal_cb_t signal_cb;
  ftdm_event_t event_header;
  char last_error[256];
  char tone_map[FTDM_TONEMAP_INVALID + 1][128];
  teletone_tone_map_t tone_detect_map[FTDM_TONEMAP_INVALID + 1];
  teletone_multi_tone_t tone_finder[FTDM_TONEMAP_INVALID + 1];
  ftdm_channel_t *channels[32 * 128 + 1];
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
  void *io_data;
  char *type;
  char *dtmf_hangup;
  size_t dtmf_hangup_len;
  ftdm_state_map_t *state_map;
  ftdm_caller_data_t default_caller_data;
  ftdm_queue_t *pendingchans;
  ftdm_queue_t *pendingsignals;
  struct ftdm_span *next;
};

struct ftdm_group {
  char *name;
  uint32_t group_id;
  uint32_t chan_count;
  ftdm_channel_t *channels[2048];
  uint32_t last_used_index;
  ftdm_mutex_t *mutex;
  struct ftdm_group *next;
};

extern ftdm_crash_policy_t g_ftdm_crash_policy;

size_t ftdm_fsk_modulator_generate_bit(ftdm_fsk_modulator_t * fsk_trans,
                                       int8_t bit, int16_t * buf,
                                       size_t buflen);
int32_t ftdm_fsk_modulator_generate_carrier_bits(ftdm_fsk_modulator_t *
                                                 fsk_trans, uint32_t bits);
void ftdm_fsk_modulator_generate_chan_sieze(ftdm_fsk_modulator_t *
                                            fsk_trans);
void ftdm_fsk_modulator_send_data(ftdm_fsk_modulator_t * fsk_trans);

ftdm_status_t ftdm_fsk_modulator_init(ftdm_fsk_modulator_t * fsk_trans,
                                      fsk_modem_types_t modem_type,
                                      uint32_t sample_rate,
                                      ftdm_fsk_data_state_t * fsk_data,
                                      float db_level,
                                      uint32_t carrier_bits_start,
                                      uint32_t carrier_bits_stop,
                                      uint32_t chan_sieze_bits,
                                      ftdm_fsk_write_sample_t
                                      write_sample_callback,
                                      void *user_data);
int8_t ftdm_bitstream_get_bit(ftdm_bitstream_t * bsp);
void ftdm_bitstream_init(ftdm_bitstream_t * bsp, uint8_t * data,
                         uint32_t datalen, ftdm_endian_t endian,
                         uint8_t ss);
ftdm_status_t ftdm_fsk_data_parse(ftdm_fsk_data_state_t * state,
                                  size_t *type, char **data, size_t *len);
ftdm_status_t ftdm_fsk_demod_feed(ftdm_fsk_data_state_t * state,
                                  int16_t * data, size_t samples);
ftdm_status_t ftdm_fsk_demod_destroy(ftdm_fsk_data_state_t * state);
int ftdm_fsk_demod_init(ftdm_fsk_data_state_t * state, int rate,
                        uint8_t * buf, size_t bufsize);
ftdm_status_t ftdm_fsk_data_init(ftdm_fsk_data_state_t * state,
                                 uint8_t * data, uint32_t datalen);
ftdm_status_t ftdm_fsk_data_add_mdmf(ftdm_fsk_data_state_t * state,
                                     ftdm_mdmf_type_t type,
                                     const uint8_t * data,
                                     uint32_t datalen);
ftdm_status_t ftdm_fsk_data_add_checksum(ftdm_fsk_data_state_t * state);
ftdm_status_t ftdm_fsk_data_add_sdmf(ftdm_fsk_data_state_t * state,
                                     const char *date, char *number);
ftdm_status_t ftdm_channel_send_fsk_data(ftdm_channel_t * ftdmchan,
                                         ftdm_fsk_data_state_t * fsk_data,
                                         float db_level);

ftdm_status_t ftdm_span_load_tones(ftdm_span_t * span,
                                   const char *mapname);

ftdm_status_t ftdm_channel_use(ftdm_channel_t * ftdmchan);

void ftdm_generate_sln_silence(int16_t * data, uint32_t samples,
                               uint32_t divisor);

uint32_t ftdm_separate_string(char *buf, char delim, char **array,
                              int arraylen);
void print_bits(uint8_t * b, int bl, char *buf, int blen, int e,
                uint8_t ss);
void print_hex_bytes(uint8_t * data, size_t dlen, char *buf, size_t blen);

int ftdm_hash_equalkeys(void *k1, void *k2);
uint32_t ftdm_hash_hashfromstring(void *ky);

int ftdm_load_modules(void);

ftdm_status_t ftdm_unload_modules(void);

ftdm_status_t ftdm_span_send_signal(ftdm_span_t * span,
                                    ftdm_sigmsg_t * sigmsg);

void ftdm_channel_clear_needed_tones(ftdm_channel_t * ftdmchan);
void ftdm_channel_rotate_tokens(ftdm_channel_t * ftdmchan);

int ftdm_load_module(const char *name);
int ftdm_load_module_assume(const char *name);
int ftdm_vasprintf(char **ret, const char *fmt, va_list ap);

ftdm_status_t ftdm_span_close_all(void);
ftdm_status_t ftdm_channel_open_chan(ftdm_channel_t * ftdmchan);
void ftdm_ack_indication(ftdm_channel_t * ftdmchan,
                         ftdm_channel_indication_t indication,
                         ftdm_status_t status);

ftdm_iterator_t *ftdm_get_iterator(ftdm_iterator_type_t type,
                                   ftdm_iterator_t * iter);

ftdm_status_t ftdm_channel_process_media(ftdm_channel_t * ftdmchan,
                                         void *data, size_t *datalen);

ftdm_status_t ftdm_raw_read(ftdm_channel_t * ftdmchan, void *data,
                            size_t *datalen);
ftdm_status_t ftdm_raw_write(ftdm_channel_t * ftdmchan, void *data,
                             size_t *datalen);
ftdm_status_t ftdm_span_next_event(ftdm_span_t * span,
                                   ftdm_event_t ** event);
ftdm_status_t ftdm_channel_queue_dtmf(ftdm_channel_t * ftdmchan,
                                      const char *dtmf);

ftdm_status_t ftdm_span_trigger_signals(const ftdm_span_t * span);

void ftdm_channel_clear_detected_tones(ftdm_channel_t * ftdmchan);

void ftdm_set_echocancel_call_begin(ftdm_channel_t * chan);

void ftdm_set_echocancel_call_end(ftdm_channel_t * chan);

ftdm_status_t ftdm_channel_save_usrmsg(ftdm_channel_t * ftdmchan,
                                       ftdm_usrmsg_t * usrmsg);

ftdm_status_t ftdm_usrmsg_free(ftdm_usrmsg_t ** usrmsg);

const char *ftdm_usrmsg_get_var(ftdm_usrmsg_t * usrmsg,
                                const char *var_name);
ftdm_status_t ftdm_usrmsg_get_raw_data(ftdm_usrmsg_t * usrmsg, void **data,
                                       size_t *datalen);

ftdm_status_t ftdm_sigmsg_free(ftdm_sigmsg_t ** sigmsg);

ftdm_status_t ftdm_sigmsg_add_var(ftdm_sigmsg_t * sigmsg,
                                  const char *var_name, const char *value);

ftdm_status_t ftdm_sigmsg_remove_var(ftdm_sigmsg_t * sigmsg,
                                     const char *var_name);
ftdm_status_t ftdm_sigmsg_set_raw_data(ftdm_sigmsg_t * sigmsg, void *data,
                                       size_t datalen);

ftdm_status_t ftdm_get_channel_from_string(const char *string_id,
                                           ftdm_span_t ** out_span,
                                           ftdm_channel_t ** out_channel);

extern const char *FTDM_LEVEL_NAMES[9];

static __inline__ int16_t ftdm_saturated_add(int16_t sample1,
                                             int16_t sample2)
{
  int addres;

  addres = sample1 + sample2;
  if (addres > 32767)
    addres = 32767;
  else if (addres < -32767)
    addres = -32767;
  return (int16_t) addres;
}

typedef long ftdm_bitmap_t;

struct zt_params {
  int chan_no;
  int span_no;
  int chan_position;
  int sig_type;
  int sig_cap;
  int receive_offhook;
  int receive_bits;
  int transmit_bits;
  int transmit_hook_sig;
  int receive_hook_sig;
  int g711_type;
  int idlebits;
  char chan_name[40];
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

struct zt_confinfo {
  int chan_no;
  int conference_number;
  int conference_mode;
};

struct zt_gains {
  int chan_no;
  unsigned char receive_gain[256];
  unsigned char transmit_gain[256];
};

struct zt_spaninfo {
  int span_no;
  char name[20];
  char description[40];
  int alarms;
  int transmit_level;
  int receive_level;
  int bpv_count;
  int crc4_count;
  int ebit_count;
  int fas_count;
  int irq_misses;
  int sync_src;
  int configured_chan_count;
  int channel_count;
  int span_count;

  int lbo;
  int lineconfig;

  char lboname[40];
  char location[40];
  char manufacturer[40];
  char devicetype[40];
  int irq;
  int linecompat;
  char spantype[6];
};

struct zt_maintinfo {
  int span_no;
  int command;
};

struct zt_lineconfig {

  int span;
  char name[20];
  int lbo;
  int lineconfig;
  int sync;
};

struct zt_chanconfig {

  int chan;
  char name[40];
  int sigtype;
  int deflaw;
  int master;
  int idlebits;
  char netdev_name[16];
};

struct zt_bufferinfo {

  int txbufpolicy;
  int rxbufpolicy;
  int numbufs;
  int bufsize;
  int readbufs;
  int writebufs;
};

typedef enum {
  ZT_G711_DEFAULT = 0,
  ZT_G711_MULAW = 1,
  ZT_G711_ALAW = 2
} zt_g711_t;

typedef enum {
  ZT_EVENT_NONE = 0,
  ZT_EVENT_ONHOOK = 1,
  ZT_EVENT_RINGOFFHOOK = 2,
  ZT_EVENT_WINKFLASH = 3,
  ZT_EVENT_ALARM = 4,
  ZT_EVENT_NOALARM = 5,
  ZT_EVENT_ABORT = 6,
  ZT_EVENT_OVERRUN = 7,
  ZT_EVENT_BADFCS = 8,
  ZT_EVENT_DIALCOMPLETE = 9,
  ZT_EVENT_RINGERON = 10,
  ZT_EVENT_RINGEROFF = 11,
  ZT_EVENT_HOOKCOMPLETE = 12,
  ZT_EVENT_BITSCHANGED = 13,
  ZT_EVENT_PULSE_START = 14,
  ZT_EVENT_TIMER_EXPIRED = 15,
  ZT_EVENT_TIMER_PING = 16,
  ZT_EVENT_POLARITY = 17,
  ZT_EVENT_RINGBEGIN = 18,
  ZT_EVENT_DTMFDOWN = (1 << 17),
  ZT_EVENT_DTMFUP = (1 << 18),
} zt_event_t;

typedef enum {
  ZT_FLUSH_READ = 1,
  ZT_FLUSH_WRITE = 2,
  ZT_FLUSH_BOTH = (ZT_FLUSH_READ | ZT_FLUSH_WRITE),
  ZT_FLUSH_EVENT = 4,
  ZT_FLUSH_ALL = (ZT_FLUSH_READ | ZT_FLUSH_WRITE | ZT_FLUSH_EVENT)
} zt_flush_t;

typedef enum {
  ZT_IOMUX_READ = 1,
  ZT_IOMUX_WRITE = 2,
  ZT_IOMUX_WRITEEMPTY = 4,
  ZT_IOMUX_SIGEVENT = 8,
  ZT_IOMUX_NOWAIT = 256
} zt_iomux_t;

typedef enum {
  ZT_ONHOOK = 0,
  ZT_OFFHOOK = 1,
  ZT_WINK = 2,
  ZT_FLASH = 3,
  ZT_START = 4,
  ZT_RING = 5,
  ZT_RINGOFF = 6
} zt_hookstate_t;

typedef enum {
  ZT_MAINT_NONE = 0,
  ZT_MAINT_LOCALLOOP = 1,
  ZT_MAINT_REMOTELOOP = 2,
  ZT_MAINT_LOOPUP = 3,
  ZT_MAINT_LOOPDOWN = 4,
  ZT_MAINT_LOOPSTOP = 5
} zt_maintenance_mode_t;

typedef enum {

  ZT_SIG_NONE = 0,

  ZT_SIG_FXSLS = ((1 << 0) | (1 << 13)),
  ZT_SIG_FXSGS = ((1 << 1) | (1 << 13)),
  ZT_SIG_FXSKS = ((1 << 2) | (1 << 13)),
  ZT_SIG_FXOLS = ((1 << 3) | (1 << 12)),
  ZT_SIG_FXOGS = ((1 << 4) | (1 << 12)),
  ZT_SIG_FXOKS = ((1 << 5) | (1 << 12)),
  ZT_SIG_EM = (1 << 6),
  ZT_SIG_CLEAR = (1 << 7),
  ZT_SIG_HDLCRAW = ((1 << 8) | ZT_SIG_CLEAR),
  ZT_SIG_HDLCFCS = ((1 << 9) | ZT_SIG_HDLCRAW),
  ZT_SIG_CAS = (1 << 15),
  ZT_SIG_HARDHDLC = ((1 << 19) | ZT_SIG_CLEAR),
} zt_sigtype_t;

typedef enum {
  ZT_DBIT = 1,
  ZT_CBIT = 2,
  ZT_BBIT = 4,
  ZT_ABIT = 8
} zt_cas_bit_t;

typedef enum {

  ZT_TONEDETECT_ON = (1 << 0),
  ZT_TONEDETECT_MUTE = (1 << 1)
} zt_tone_mode_t;

static int CONTROL_FD = -1;

ftdm_status_t zt_next_event(ftdm_span_t * span, ftdm_event_t ** event);
ftdm_status_t zt_poll_event(ftdm_span_t * span, uint32_t ms,
                            short *poll_events);
ftdm_status_t zt_channel_next_event(ftdm_channel_t * ftdmchan,
                                    ftdm_event_t ** event);
static unsigned zt_open_range(ftdm_span_t * span, unsigned start,
                              unsigned end, ftdm_chan_type_t type,
                              char *name, char *number,
                              unsigned char cas_bits)
{
  unsigned configured = 0, x;
  zt_params_t ztp;
  zt_tone_mode_t mode = 0;
  memset(&ztp, 0, sizeof ztp);  /* is it necessary? */

  for (x = start; x < end; x++) {
    ftdm_channel_t *ftdmchan;
    int sockfd = -1;
    int len;

    sockfd = open("/dev/dahdi/channel", O_RDWR);
    if (sockfd != -1
        && ftdm_span_add_channel(span, sockfd, type,
                                 &ftdmchan) == FTDM_SUCCESS) {

      if (ioctl(sockfd, DAHDI_SPECIFY, &x)) {
        ftdm_log(FTDM_LOG_ERROR,
                 "failure configuring device /dev/dahdi/channel chan %d fd %d (%s)\n",
                 x, sockfd, strerror(errno));
        close(sockfd);
        continue;
      }

      if (ftdmchan->type == FTDM_CHAN_TYPE_DQ921) {
        struct zt_bufferinfo binfo;
        memset(&binfo, 0, sizeof(binfo));
        binfo.txbufpolicy = 0;
        binfo.rxbufpolicy = 0;
        binfo.numbufs = 32;
        binfo.bufsize = 1024;
        if (ioctl(sockfd, DAHDI_SET_BUFINFO, &binfo)) {
          ftdm_log(FTDM_LOG_ERROR,
                   "failure configuring device /dev/dahdi/channel as FreeTDM device %d:%d fd:%d\n",
                   ftdmchan->span_id, ftdmchan->chan_id, sockfd);
          close(sockfd);
          continue;
        }
      }

      if (type == FTDM_CHAN_TYPE_CAS) {
        struct zt_chanconfig cc;
        memset(&cc, 0, sizeof(cc));
        cc.chan = cc.master = x;
        cc.sigtype = ZT_SIG_CAS;
        cc.idlebits = cas_bits;
        if (ioctl(CONTROL_FD, DAHDI_CHANCONFIG, &cc)) {
          ftdm_log(FTDM_LOG_ERROR,
                   "failure configuring device /dev/dahdi/channel as FreeTDM device %d:%d fd:%d err:%s\n",
                   ftdmchan->span_id, ftdmchan->chan_id, sockfd,
                   strerror(errno));
          close(sockfd);
          continue;
        }
      }

      if (ftdmchan->type != FTDM_CHAN_TYPE_DQ921
          && ftdmchan->type != FTDM_CHAN_TYPE_DQ931) {
        len = 160;              /* each 20ms */
        if (ioctl(ftdmchan->sockfd, DAHDI_SET_BLOCKSIZE, &len)) {
          ftdm_log(FTDM_LOG_ERROR,
                   "failure configuring device /dev/dahdi/channel as FreeTDM device %d:%d fd:%d err:%s\n",
                   ftdmchan->span_id, ftdmchan->chan_id, sockfd,
                   strerror(errno));
          close(sockfd);
          continue;
        }

        ftdmchan->packet_len = len;
        ftdmchan->effective_interval = ftdmchan->native_interval =
            ftdmchan->packet_len / 8;

        if (ftdmchan->effective_codec == FTDM_CODEC_SLIN) {
          ftdmchan->packet_len *= 2;
        }
      }

      if (ioctl(sockfd, DAHDI_GET_PARAMS, &ztp) < 0) {
        ftdm_log(FTDM_LOG_ERROR,
                 "failure configuring device /dev/dahdi/channel as FreeTDM device %d:%d fd:%d\n",
                 ftdmchan->span_id, ftdmchan->chan_id, sockfd);
        close(sockfd);
        continue;
      }

      if (ftdmchan->type == FTDM_CHAN_TYPE_DQ921) {
        if ((ztp.sig_type != ZT_SIG_HDLCRAW) &&
            (ztp.sig_type != ZT_SIG_HDLCFCS) &&
            (ztp.sig_type != ZT_SIG_HARDHDLC)
            ) {
          ftdm_log(FTDM_LOG_ERROR,
                   "hardware signaling is not HDLC, fix your DAHDI configuration!\n");
          close(sockfd);
          continue;
        }
      }

      ftdm_log(FTDM_LOG_INFO,
               "configuring device /dev/dahdi/channel channel %d as FreeTDM device %d:%d fd:%d\n",
               x, ftdmchan->span_id, ftdmchan->chan_id, sockfd);

      ftdmchan->rate = 8000;
      ftdmchan->physical_span_id = ztp.span_no;
      ftdmchan->physical_chan_id = x;

      if (type == FTDM_CHAN_TYPE_FXS || type == FTDM_CHAN_TYPE_FXO
          || type == FTDM_CHAN_TYPE_EM || type == FTDM_CHAN_TYPE_B) {
        if (ztp.g711_type == ZT_G711_ALAW) {
          ftdmchan->native_codec = ftdmchan->effective_codec =
              FTDM_CODEC_ALAW;
        }
        else if (ztp.g711_type == ZT_G711_MULAW) {
          ftdmchan->native_codec = ftdmchan->effective_codec =
              FTDM_CODEC_ULAW;
        }
        else {
          int type;

          if (ftdmchan->span->trunk_type == FTDM_TRUNK_E1) {
            type = FTDM_CODEC_ALAW;
          }
          else {
            type = FTDM_CODEC_ULAW;
          }

          ftdmchan->native_codec = ftdmchan->effective_codec = type;

        }
      }

      ztp.receive_flash_time = 1;

      if (ioctl(sockfd, DAHDI_SET_PARAMS, &ztp) < 0) {
        ftdm_log(FTDM_LOG_ERROR,
                 "failure configuring device /dev/dahdi/channel as FreeTDM device %d:%d fd:%d\n",
                 ftdmchan->span_id, ftdmchan->chan_id, sockfd);
        close(sockfd);
        continue;
      }

      mode = ZT_TONEDETECT_ON | ZT_TONEDETECT_MUTE;
      if (ioctl(sockfd, DAHDI_TONEDETECT, &mode)) {
        ftdm_log(FTDM_LOG_DEBUG,
                 "HW DTMF not available on FreeTDM device %d:%d fd:%d\n",
                 ftdmchan->span_id, ftdmchan->chan_id, sockfd);
      }
      else {
        ftdm_log(FTDM_LOG_DEBUG,
                 "HW DTMF available on FreeTDM device %d:%d fd:%d\n",
                 ftdmchan->span_id, ftdmchan->chan_id, sockfd);
        (ftdmchan)->features =
            (ftdm_channel_feature_t) ((ftdmchan)->features |
                                      FTDM_CHANNEL_FEATURE_DTMF_DETECT);
        mode = 0;
        ioctl(sockfd, DAHDI_TONEDETECT, &mode);
      }

      if (!(!name || *name == '\0')) {
        strncpy(ftdmchan->chan_name, name,
                sizeof(ftdmchan->chan_name) - 1);
      }
      if (!(!number || *number == '\0')) {
        strncpy(ftdmchan->chan_number, number,
                sizeof(ftdmchan->chan_number) - 1);
      }

      configured++;
    }
    else
      ftdm_log(FTDM_LOG_ERROR,
               "failure configuring device /dev/dahdi/channel\n");
  }

  return configured;
}

static ftdm_status_t zt_configure_span(ftdm_span_t * span, const char *str,
                                       ftdm_chan_type_t type, char *name,
                                       char *number)
{

  int items, i;
  char *mydata, *item_list[10];
  char *ch, *mx;
  unsigned char cas_bits = 0;
  int channo;
  int top = 0;
  unsigned configured = 0;

  mydata = ftdm_strdup(str);

  items =
      ftdm_separate_string(mydata, ',', item_list,
                           (sizeof(item_list) / sizeof(item_list[0])));

  for (i = 0; i < items; i++) {
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
    else {
      top = channo + 1;
    }

    if (top < 0) {
      ftdm_log(FTDM_LOG_ERROR, "Invalid range number %d\n", top);
      continue;
    }

    if (FTDM_CHAN_TYPE_CAS == type
        && ftdm_config_get_cas_bits(ch, &cas_bits)) {
      ftdm_log(FTDM_LOG_ERROR, "Failed to get CAS bits in CAS channel\n");
      continue;
    }

    configured +=
        zt_open_range(span, channo, top, type, name, number, cas_bits);

  }

  if (mydata) {
    g_ftdm_mem_handler.free(g_ftdm_mem_handler.pool, mydata);
    mydata = ((void *) 0);
  };

  return configured;

}

static ftdm_status_t zt_configure(const char *category, const char *var,
                                  const char *val, int lineno)
{
  return FTDM_SUCCESS;
}

static ftdm_status_t zt_open(ftdm_channel_t * ftdmchan)
{
  (ftdmchan)->features =
      (ftdm_channel_feature_t) ((ftdmchan)->features |
                                FTDM_CHANNEL_FEATURE_INTERVAL);

  if (ftdmchan->type == FTDM_CHAN_TYPE_DQ921
      || ftdmchan->type == FTDM_CHAN_TYPE_DQ931) {
    ftdmchan->native_codec = ftdmchan->effective_codec = FTDM_CODEC_NONE;
  }
  else {
    int blocksize = 160;        /* each 20ms */
    int err;
    if ((err = ioctl(ftdmchan->sockfd, DAHDI_SET_BLOCKSIZE, &blocksize))) {
      snprintf(ftdmchan->last_error, sizeof(ftdmchan->last_error), "%m");
      return FTDM_FAIL;
    }
    else {
      ftdmchan->effective_interval = ftdmchan->native_interval;
      ftdmchan->packet_len = blocksize;
      ftdmchan->native_codec = ftdmchan->effective_codec;
    }

    if (ftdmchan->type == FTDM_CHAN_TYPE_B) {
      int one = 1;
      if (ioctl(ftdmchan->sockfd, DAHDI_AUDIOMODE, &one)) {
        snprintf(ftdmchan->last_error, sizeof(ftdmchan->last_error), "%m");
        ftdm_log(FTDM_LOG_ERROR, "%s\n", ftdmchan->last_error);
        return FTDM_FAIL;
      }
    }

    int echo_cancel_level = 16; /* number of samples of echo cancellation (0--1024);
                                   to disable, set to 0 */
/* The problem is that if ec is disabled, keys are not always recognized.
Test this parameter separately from freeswitch when you factor-out teletone from freetdm
and use audacity to view stream with and without ec enabled and vary this parameter and
see how it will differ */
    if (ioctl(ftdmchan->sockfd, DAHDI_ECHOCANCEL, &echo_cancel_level) ==
        -1)
      ftdm_log(FTDM_LOG_WARNING, "Echo cancel not available for %d:%d\n",
               ftdmchan->span_id, ftdmchan->chan_id);
  }
  return FTDM_SUCCESS;
}

static ftdm_status_t zt_close(ftdm_channel_t * ftdmchan)
{
  if (ftdmchan->type == FTDM_CHAN_TYPE_B) {
    int value = 0;
    if (ioctl(ftdmchan->sockfd, DAHDI_AUDIOMODE, &value)) {
      snprintf(ftdmchan->last_error, sizeof(ftdmchan->last_error), "%m");
      ftdm_log(FTDM_LOG_ERROR, "%s\n", ftdmchan->last_error);
      return FTDM_FAIL;
    }
  }
  return FTDM_SUCCESS;
}

static ftdm_status_t zt_command(ftdm_channel_t * ftdmchan,
                                ftdm_command_t command, void *obj)
{
  zt_params_t ztp;
  int err = 0;

  memset(&ztp, 0, sizeof(ztp));

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
  case FTDM_COMMAND_ENABLE_ECHOTRAIN:
    {
      int level = *((int *) obj);
      err = ioctl(ftdmchan->sockfd, DAHDI_ECHOTRAIN, &level);
      *((int *) obj) = level;
    }
  case FTDM_COMMAND_DISABLE_ECHOTRAIN:
    {
      int level = 0;
      err = ioctl(ftdmchan->sockfd, DAHDI_ECHOTRAIN, &level);
      *((int *) obj) = level;
    }
    break;
  case FTDM_COMMAND_OFFHOOK:
    {
      int command = ZT_OFFHOOK;
      if (ioctl(ftdmchan->sockfd, DAHDI_HOOK, &command)) {
        ftdm_log(FTDM_LOG_ERROR,
                 "[s%dc%d][%d:%d] " "OFFHOOK Failed",
                 ftdmchan->span_id, ftdmchan->chan_id,
                 ftdmchan->physical_span_id, ftdmchan->physical_chan_id);
        return FTDM_FAIL;
      }
      ftdm_log(FTDM_LOG_DEBUG,
               "[s%dc%d][%d:%d] " "Channel is now offhook\n",
               ftdmchan->span_id, ftdmchan->chan_id,
               ftdmchan->physical_span_id, ftdmchan->physical_chan_id);

      _ftdm_mutex_lock("./ftmod_zt.w", 752, (const char *) __func__,
                       ftdmchan->mutex);
      ftdmchan->flags |= 1ULL << 14;
      _ftdm_mutex_unlock(__FILE__, __LINE__,
                         (const char *) __func__, ftdmchan->mutex);
    }
    break;
  case FTDM_COMMAND_ONHOOK:
    {
      int command = ZT_ONHOOK;
      if (ioctl(ftdmchan->sockfd, DAHDI_HOOK, &command)) {
        ftdm_log(FTDM_LOG_ERROR,
                 "[s%dc%d][%d:%d] " "ONHOOK Failed",
                 ftdmchan->span_id, ftdmchan->chan_id,
                 ftdmchan->physical_span_id, ftdmchan->physical_chan_id);
        return FTDM_FAIL;
      }
      ftdm_log(FTDM_LOG_DEBUG,
               "[s%dc%d][%d:%d] " "Channel is now onhook\n",
               ftdmchan->span_id, ftdmchan->chan_id,
               ftdmchan->physical_span_id, ftdmchan->physical_chan_id);

      _ftdm_mutex_lock(__FILE__, __LINE__, (const char *) __func__,
                       ftdmchan->mutex);
      (ftdmchan)->flags &= ~((1ULL << 14));
      _ftdm_mutex_unlock(__FILE__, __LINE__,
                         (const char *) __func__, ftdmchan->mutex);
    }
    break;
  case FTDM_COMMAND_FLASH:
    {
      int command = ZT_FLASH;
      if (ioctl(ftdmchan->sockfd, DAHDI_HOOK, &command)) {
        ftdm_log(FTDM_LOG_ERROR, "[s%dc%d][%d:%d] " "FLASH Failed",
                 ftdmchan->span_id, ftdmchan->chan_id,
                 ftdmchan->physical_span_id, ftdmchan->physical_chan_id);
        return FTDM_FAIL;
      }
    }
    break;
  case FTDM_COMMAND_WINK:
    {
      int command = ZT_WINK;
      if (ioctl(ftdmchan->sockfd, DAHDI_HOOK, &command)) {
        ftdm_log(FTDM_LOG_ERROR, "[s%dc%d][%d:%d] " "WINK Failed",
                 ftdmchan->span_id, ftdmchan->chan_id,
                 ftdmchan->physical_span_id, ftdmchan->physical_chan_id);
        return FTDM_FAIL;
      }
    }
    break;
  case FTDM_COMMAND_GENERATE_RING_ON:
    {
      int command = ZT_RING;
      if (ioctl(ftdmchan->sockfd, DAHDI_HOOK, &command)) {
        ftdm_log(FTDM_LOG_ERROR, "[s%dc%d][%d:%d] " "RING Failed",
                 ftdmchan->span_id, ftdmchan->chan_id,
                 ftdmchan->physical_span_id, ftdmchan->physical_chan_id);
        return FTDM_FAIL;
      }

      _ftdm_mutex_lock(__FILE__, __LINE__, (const char *) __func__,
                       ftdmchan->mutex);
      ftdmchan->flags |= 1ULL << 15;
      _ftdm_mutex_unlock(__FILE__, __LINE__,
                         (const char *) __func__, ftdmchan->mutex);
    }
    break;
  case FTDM_COMMAND_GENERATE_RING_OFF:
    {
      int command = ZT_RINGOFF;
      if (ioctl(ftdmchan->sockfd, DAHDI_HOOK, &command)) {
        ftdm_log(FTDM_LOG_ERROR,
                 "[s%dc%d][%d:%d] " "Ring-off Failed",
                 ftdmchan->span_id, ftdmchan->chan_id,
                 ftdmchan->physical_span_id, ftdmchan->physical_chan_id);
        return FTDM_FAIL;
      }

      _ftdm_mutex_lock(__FILE__, __LINE__, (const char *) __func__,
                       ftdmchan->mutex);
      ftdmchan->flags &= ~(1ULL << 15);
      _ftdm_mutex_unlock(__FILE__, __LINE__,
                         (const char *) __func__, ftdmchan->mutex);
    }
    break;
  case FTDM_COMMAND_GET_INTERVAL:
    {

      if (!
          (err =
           ioctl(ftdmchan->sockfd, DAHDI_GET_BLOCKSIZE,
                 &ftdmchan->packet_len))) {
        ftdmchan->native_interval = ftdmchan->packet_len / 8;
        if (ftdmchan->effective_codec == FTDM_CODEC_SLIN) {
          ftdmchan->packet_len *= 2;
        }
        *((int *) obj) = ftdmchan->native_interval;
      }
    }
    break;
  case FTDM_COMMAND_SET_INTERVAL:
    {
      int interval = *((int *) obj);
      int len = interval * 8;

      if (!(err = ioctl(ftdmchan->sockfd, DAHDI_SET_BLOCKSIZE, &len))) {
        ftdmchan->packet_len = len;
        ftdmchan->effective_interval = ftdmchan->native_interval =
            ftdmchan->packet_len / 8;

        if (ftdmchan->effective_codec == FTDM_CODEC_SLIN) {
          ftdmchan->packet_len *= 2;
        }
      }
    }
    break;
  case FTDM_COMMAND_SET_CAS_BITS:
    {
      int bits = *((int *) obj);
      err = ioctl(ftdmchan->sockfd, DAHDI_SETTXBITS, &bits);
    }
    break;
  case FTDM_COMMAND_GET_CAS_BITS:
    {
      err =
          ioctl(ftdmchan->sockfd, DAHDI_GETRXBITS, &ftdmchan->rx_cas_bits);
      if (!err) {
        *((int *) obj) = ftdmchan->rx_cas_bits;
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
      ftdm_polarity_t polarity = *((int *) obj);
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
  case FTDM_COMMAND_SET_RX_QUEUE_SIZE:
  case FTDM_COMMAND_SET_TX_QUEUE_SIZE:

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
  };

  if (err && err != FTDM_NOTIMPL) {
    snprintf(ftdmchan->last_error, sizeof(ftdmchan->last_error), "%m");
    return FTDM_FAIL;
  }

  return err == 0 ? FTDM_SUCCESS : err;
}

static ftdm_status_t zt_get_alarms(ftdm_channel_t * ftdmchan)
{
  struct zt_spaninfo info;
  zt_params_t params;

  memset(&info, 0, sizeof(info));
  info.span_no = ftdmchan->physical_span_id;

  memset(&params, 0, sizeof(params));

  if (ioctl(CONTROL_FD, DAHDI_SPANSTAT, &info)) {
    snprintf(ftdmchan->last_error, sizeof(ftdmchan->last_error),
             "ioctl failed (%m)");
    snprintf(ftdmchan->span->last_error,
             sizeof(ftdmchan->span->last_error), "ioctl failed (%m)");
    return FTDM_FAIL;
  }

  ftdmchan->alarm_flags = info.alarms;

  if (info.alarms == FTDM_ALARM_NONE) {
    if (ioctl(ftdmchan->sockfd, DAHDI_GET_PARAMS, &params)) {
      snprintf(ftdmchan->last_error, sizeof(ftdmchan->last_error),
               "ioctl failed (%m)");
      snprintf(ftdmchan->span->last_error,
               sizeof(ftdmchan->span->last_error), "ioctl failed (%m)");

      return FTDM_FAIL;
    }

    if (params.chan_alarms > 0) {
      if (params.chan_alarms == (1 << 2)) {
        ftdmchan->alarm_flags = FTDM_ALARM_YELLOW;
      }
      else if (params.chan_alarms == (1 << 4)) {
        ftdmchan->alarm_flags = FTDM_ALARM_BLUE;
      }
      else {
        ftdmchan->alarm_flags = FTDM_ALARM_RED;
      }
    }
  }

  return FTDM_SUCCESS;
}

static ftdm_status_t zt_wait(ftdm_channel_t * ftdmchan,
                             ftdm_wait_flag_t * flags, int32_t to)
{
  int32_t inflags = 0;
  int result;
  struct pollfd pfds[1];

  if (*flags & FTDM_READ) {
    inflags |= 0x001;
  }

  if (*flags & FTDM_WRITE) {
    inflags |= 0x004;
  }

  if (*flags & FTDM_EVENTS) {
    inflags |= 0x002;
  }

pollagain:
  memset(&pfds[0], 0, sizeof(pfds[0]));
  pfds[0].fd = ftdmchan->sockfd;
  pfds[0].events = inflags;
  result = poll(pfds, 1, to);
  *flags = FTDM_NO_FLAGS;

  if (result < 0 && errno == EINTR) {
    ftdm_log(FTDM_LOG_DEBUG,
             "[s%dc%d][%d:%d] "
             "DAHDI wait got interrupted, trying again\n",
             ftdmchan->span_id, ftdmchan->chan_id,
             ftdmchan->physical_span_id, ftdmchan->physical_chan_id);
    goto pollagain;
  }

  if (pfds[0].revents & POLLERR) {
    ftdm_log(FTDM_LOG_ERROR,
             "[s%dc%d][%d:%d] " "DAHDI device got POLLERR\n",
             ftdmchan->span_id, ftdmchan->chan_id,
             ftdmchan->physical_span_id, ftdmchan->physical_chan_id);
    result = -1;
  }

  if (result > 0) {
    inflags = pfds[0].revents;
  }

  if (result < 0) {
    snprintf(ftdmchan->last_error, sizeof(ftdmchan->last_error),
             "Poll failed");
    ftdm_log(FTDM_LOG_ERROR,
             "[s%dc%d][%d:%d] " "Failed to poll DAHDI device: %s\n",
             ftdmchan->span_id, ftdmchan->chan_id,
             ftdmchan->physical_span_id, ftdmchan->physical_chan_id,
             strerror(errno));
    return FTDM_FAIL;
  }

  if (result == 0) {
    return FTDM_TIMEOUT;
  }

  if (inflags & 0x001) {
    *flags |= FTDM_READ;
  }

  if (inflags & 0x004) {
    *flags |= FTDM_WRITE;
  }

  if ((inflags & 0x002) || (ftdmchan->io_data && (*flags & FTDM_EVENTS))) {
    *flags |= FTDM_EVENTS;
  }

  return FTDM_SUCCESS;

}

ftdm_status_t zt_poll_event(ftdm_span_t * span, uint32_t ms,
                            short *poll_events)
{
  struct pollfd pfds[32 * 128];
  uint32_t i, j = 0, k = 0;
  int r;

  (void) (poll_events);

  for (i = 1; i <= span->chan_count; i++) {
    memset(&pfds[j], 0, sizeof(pfds[j]));
    pfds[j].fd = span->channels[i]->sockfd;
    pfds[j].events = 0x002;
    j++;
  }

  r = poll(pfds, j, ms);

  if (r == 0) {
    return FTDM_TIMEOUT;
  }
  else if (r < 0) {
    snprintf(span->last_error, sizeof(span->last_error), "%m");
    return FTDM_FAIL;
  }

  for (i = 1; i <= span->chan_count; i++) {

    _ftdm_mutex_lock("./ftmod_zt.w", 1070, (const char *) __func__,
                     (span->channels[i])->mutex);

    if (pfds[i - 1].revents & 0x008) {
      ftdm_log(FTDM_LOG_ERROR,
               "[s%dc%d][%d:%d] " "POLLERR, flags=%d\n",
               span->channels[i]->span_id,
               span->channels[i]->chan_id,
               span->channels[i]->physical_span_id,
               span->channels[i]->physical_chan_id, pfds[i - 1].events);

      _ftdm_mutex_unlock("./ftmod_zt.w", 1075,
                         (const char *) __func__,
                         (span->channels[i])->mutex);

      continue;
    }
    if ((pfds[i - 1].revents & 0x002) || (span->channels[i]->io_data)) {
      span->channels[i]->io_flags |= FTDM_CHANNEL_IO_EVENT;
      span->channels[i]->last_event_time = ftdm_current_time_in_ms();
      k++;
    }
    if (pfds[i - 1].revents & 0x001) {
      (span->channels[i])->io_flags |= (FTDM_CHANNEL_IO_READ);
    }
    if (pfds[i - 1].revents & 0x004) {
      (span->channels[i])->io_flags |= (FTDM_CHANNEL_IO_WRITE);
    }

    _ftdm_mutex_unlock("./ftmod_zt.w", 1090, (const char *) __func__,
                       (span->channels[i])->mutex);

  }

  if (!k) {
    snprintf(span->last_error, sizeof(span->last_error),
             "no matching descriptor");
  }

  return k ? FTDM_SUCCESS : FTDM_FAIL;
}

static __inline__ ftdm_status_t zt_channel_process_event(ftdm_channel_t *
                                                         fchan,
                                                         ftdm_oob_event_t *
                                                         event_id,
                                                         zt_event_t
                                                         zt_event_id)
{
  ftdm_log(FTDM_LOG_DEBUG,
           "[s%dc%d][%d:%d] " "Processing zap hardware event %d\n",
           fchan->span_id, fchan->chan_id, fchan->physical_span_id,
           fchan->physical_chan_id, zt_event_id);
  switch (zt_event_id) {
  case ZT_EVENT_RINGEROFF:
    {
      ftdm_log(FTDM_LOG_DEBUG, "[s%dc%d][%d:%d] " "ZT RINGER OFF\n",
               fchan->span_id, fchan->chan_id,
               fchan->physical_span_id, fchan->physical_chan_id);
      *event_id = FTDM_OOB_NOOP;
    }
    break;
  case ZT_EVENT_RINGERON:
    {
      ftdm_log(FTDM_LOG_DEBUG, "[s%dc%d][%d:%d] " "ZT RINGER ON\n",
               fchan->span_id, fchan->chan_id,
               fchan->physical_span_id, fchan->physical_chan_id);
      *event_id = FTDM_OOB_NOOP;
    }
    break;
  case ZT_EVENT_RINGBEGIN:
    {
      *event_id = FTDM_OOB_RING_START;
    }
    break;
  case ZT_EVENT_ONHOOK:
    {
      *event_id = FTDM_OOB_ONHOOK;
    }
    break;
  case ZT_EVENT_WINKFLASH:
    {
      if (fchan->state == FTDM_CHANNEL_STATE_DOWN
          || fchan->state == FTDM_CHANNEL_STATE_DIALING) {
        *event_id = FTDM_OOB_WINK;
      }
      else {
        *event_id = FTDM_OOB_FLASH;
      }
    }
    break;
  case ZT_EVENT_RINGOFFHOOK:
    {
      *event_id = FTDM_OOB_NOOP;
      if (fchan->type == FTDM_CHAN_TYPE_FXS
          || (fchan->type == FTDM_CHAN_TYPE_EM
              && fchan->state != FTDM_CHANNEL_STATE_UP)) {
        if (fchan->type != FTDM_CHAN_TYPE_EM) {

          _ftdm_mutex_lock(__FILE__, __LINE__,
                           (const char *) __func__, fchan->mutex);
          fchan->flags |= 1ULL << 14;
          _ftdm_mutex_unlock(__FILE__, __LINE__,
                             (const char *) __func__, fchan->mutex);
        }

        if (fchan->type == FTDM_CHAN_TYPE_EM
            && ((fchan)->flags & (1ULL << 18))) {
          fchan->ring_count++;

          if (fchan->ring_count == 2) {
            *event_id = FTDM_OOB_OFFHOOK;
          }
        }
        else {
          *event_id = FTDM_OOB_OFFHOOK;
        }
      }
      else if (fchan->type == FTDM_CHAN_TYPE_FXO) {
        *event_id = FTDM_OOB_RING_START;
      }
    }
    break;
  case ZT_EVENT_ALARM:
    {
      *event_id = FTDM_OOB_ALARM_TRAP;
    }
    break;
  case ZT_EVENT_NOALARM:
    {
      *event_id = FTDM_OOB_ALARM_CLEAR;
    }
    break;
  case ZT_EVENT_BITSCHANGED:
    {
      *event_id = FTDM_OOB_CAS_BITS_CHANGE;
      int bits = 0;
      int err = ioctl(fchan->sockfd, DAHDI_GETRXBITS, &bits);
      if (err) {
        return FTDM_FAIL;
      }
      fchan->rx_cas_bits = bits;
    }
    break;
  case ZT_EVENT_BADFCS:
    {
      ftdm_log(FTDM_LOG_ERROR,
               "[s%dc%d][%d:%d] "
               "Bad frame checksum (ZT_EVENT_BADFCS)\n",
               fchan->span_id, fchan->chan_id,
               fchan->physical_span_id, fchan->physical_chan_id);
      *event_id = FTDM_OOB_NOOP;
    }
    break;
  case ZT_EVENT_OVERRUN:
    {
      ftdm_log(FTDM_LOG_ERROR,
               "[s%dc%d][%d:%d] "
               "HDLC frame overrun (ZT_EVENT_OVERRUN)\n",
               fchan->span_id, fchan->chan_id,
               fchan->physical_span_id, fchan->physical_chan_id);
      *event_id = FTDM_OOB_NOOP;
    }
    break;
  case ZT_EVENT_ABORT:
    {
      ftdm_log(FTDM_LOG_ERROR,
               "[s%dc%d][%d:%d] "
               "HDLC abort frame received (ZT_EVENT_ABORT)\n",
               fchan->span_id, fchan->chan_id,
               fchan->physical_span_id, fchan->physical_chan_id);
      *event_id = FTDM_OOB_NOOP;
    }
    break;
  case ZT_EVENT_POLARITY:
    {
      ftdm_log(FTDM_LOG_ERROR,
               "[s%dc%d][%d:%d] "
               "Got polarity reverse (ZT_EVENT_POLARITY)\n",
               fchan->span_id, fchan->chan_id,
               fchan->physical_span_id, fchan->physical_chan_id);
      *event_id = FTDM_OOB_POLARITY_REVERSE;
    }
    break;
  case ZT_EVENT_NONE:
    {
      ftdm_log(FTDM_LOG_DEBUG, "[s%dc%d][%d:%d] " "No event\n",
               fchan->span_id, fchan->chan_id,
               fchan->physical_span_id, fchan->physical_chan_id);
      *event_id = FTDM_OOB_NOOP;
    }
    break;
  default:
    {
      ftdm_log(FTDM_LOG_WARNING,
               "[s%dc%d][%d:%d] " "Unhandled event %d\n",
               fchan->span_id, fchan->chan_id,
               fchan->physical_span_id, fchan->physical_chan_id,
               zt_event_id);
      *event_id = FTDM_OOB_INVALID;
    }
    break;
  }
  return FTDM_SUCCESS;
}

ftdm_status_t zt_channel_next_event(ftdm_channel_t * ftdmchan,
                                    ftdm_event_t ** event)
{
  uint32_t event_id = FTDM_OOB_INVALID;
  zt_event_t zt_event_id = 0;
  ftdm_span_t *span = ftdmchan->span;

  if (((ftdmchan)->io_flags & FTDM_CHANNEL_IO_EVENT)) {
    (ftdmchan)->io_flags &= ~(FTDM_CHANNEL_IO_EVENT);
  }

  if (ftdmchan->io_data) {
    zt_event_id = (zt_event_t) ftdmchan->io_data;
    ftdmchan->io_data = ((void *) 0);
  }
  else if (ioctl(ftdmchan->sockfd, DAHDI_GETEVENT, &zt_event_id) == -1) {
    ftdm_log(FTDM_LOG_ERROR,
             "[s%dc%d][%d:%d] "
             "Failed retrieving event from channel: %s\n",
             ftdmchan->span_id, ftdmchan->chan_id,
             ftdmchan->physical_span_id, ftdmchan->physical_chan_id,
             strerror(errno));
    return FTDM_FAIL;
  }

  if ((zt_channel_process_event(ftdmchan, &event_id, zt_event_id)) !=
      FTDM_SUCCESS) {
    ftdm_log(FTDM_LOG_ERROR,
             "[s%dc%d][%d:%d] "
             "Failed to process DAHDI event %d from channel\n",
             ftdmchan->span_id, ftdmchan->chan_id,
             ftdmchan->physical_span_id, ftdmchan->physical_chan_id,
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

ftdm_status_t zt_next_event(ftdm_span_t * span, ftdm_event_t ** event)
{
  uint32_t i, event_id = FTDM_OOB_INVALID;
  zt_event_t zt_event_id = 0;

  for (i = 1; i <= span->chan_count; i++) {
    ftdm_channel_t *fchan = span->channels[i];

    _ftdm_mutex_lock("./ftmod_zt.w", 1307, (const char *) __func__,
                     (fchan)->mutex);

    if (!((fchan)->io_flags & FTDM_CHANNEL_IO_EVENT)) {

      _ftdm_mutex_unlock("./ftmod_zt.w", 1311,
                         (const char *) __func__, (fchan)->mutex);

      continue;
    }

    (fchan)->io_flags &= ~(FTDM_CHANNEL_IO_EVENT);

    if (fchan->io_data) {
      zt_event_id = (zt_event_t) fchan->io_data;
      fchan->io_data = ((void *) 0);
    }
    else if (ioctl(fchan->sockfd, DAHDI_GETEVENT, &zt_event_id) == -1) {
      ftdm_log(FTDM_LOG_ERROR,
               "[s%dc%d][%d:%d] "
               "Failed to retrieve DAHDI event from channel: %s\n",
               fchan->span_id, fchan->chan_id,
               fchan->physical_span_id, fchan->physical_chan_id,
               strerror(errno));

      _ftdm_mutex_unlock("./ftmod_zt.w", 1324,
                         (const char *) __func__, (fchan)->mutex);

      continue;
    }

    if ((zt_channel_process_event(fchan, &event_id, zt_event_id)) !=
        FTDM_SUCCESS) {
      ftdm_log(FTDM_LOG_ERROR,
               "[s%dc%d][%d:%d] "
               "Failed to process DAHDI event %d from channel\n",
               fchan->span_id, fchan->chan_id,
               fchan->physical_span_id, fchan->physical_chan_id,
               zt_event_id);

      _ftdm_mutex_unlock("./ftmod_zt.w", 1332,
                         (const char *) __func__, (fchan)->mutex);

      return FTDM_FAIL;
    }

    fchan->last_event_time = 0;
    span->event_header.e_type = FTDM_EVENT_OOB;
    span->event_header.enum_id = event_id;
    span->event_header.channel = fchan;
    *event = &span->event_header;

    _ftdm_mutex_unlock("./ftmod_zt.w", 1343, (const char *) __func__,
                       (fchan)->mutex);

    return FTDM_SUCCESS;
  }

  return FTDM_FAIL;
}

static ftdm_status_t zt_read(ftdm_channel_t * ftdmchan, void *data,
                             size_t *datalen)
{
  ftdm_ssize_t r = 0;
  int read_errno = 0;
  int errs = 0;

  while (errs++ < 30) {
    r = read(ftdmchan->sockfd, data, *datalen);
    if (r > 0) {

      break;
    }

    if (r == 0) {
      usleep(10 * 1000);
      if (errs)
        errs--;
      continue;
    }

    read_errno = errno;
    if (read_errno == EAGAIN || read_errno == EINTR) {
      continue;
    }

    if (read_errno == ELAST) {
      zt_event_t zt_event_id = 0;
      if (ioctl(ftdmchan->sockfd, DAHDI_GETEVENT, &zt_event_id) == -1) {
        ftdm_log(FTDM_LOG_ERROR,
                 "[s%dc%d][%d:%d] "
                 "Failed retrieving event after ELAST on read: %s\n",
                 ftdmchan->span_id, ftdmchan->chan_id,
                 ftdmchan->physical_span_id,
                 ftdmchan->physical_chan_id, strerror(errno));
        r = -1;
        break;
      }

      ftdm_log(FTDM_LOG_DEBUG,
               "[s%dc%d][%d:%d] "
               "Deferring event %d to be able to read data\n",
               ftdmchan->span_id, ftdmchan->chan_id,
               ftdmchan->physical_span_id,
               ftdmchan->physical_chan_id, zt_event_id);
      if (ftdmchan->io_data) {
        ftdm_log(FTDM_LOG_WARNING,
                 "[s%dc%d][%d:%d] "
                 "Dropping event %d, not retrieved on time\n",
                 ftdmchan->span_id, ftdmchan->chan_id,
                 ftdmchan->physical_span_id,
                 ftdmchan->physical_chan_id, zt_event_id);
      }
      ftdmchan->io_data = (void *) zt_event_id;
      ftdmchan->io_flags |= FTDM_CHANNEL_IO_EVENT;
      ftdmchan->last_event_time = ftdm_current_time_in_ms();
      break;
    }

    ftdm_log(FTDM_LOG_ERROR, "IO read failed: %s\n", strerror(read_errno));
  }

  if (r > 0) {
    *datalen = r;
    if (ftdmchan->type == FTDM_CHAN_TYPE_DQ921) {
      *datalen -= 2;
    }
    return FTDM_SUCCESS;
  }
  else if (read_errno == 500) {
    return FTDM_SUCCESS;
  }
  return r == 0 ? FTDM_TIMEOUT : FTDM_FAIL;
}

static ftdm_status_t zt_write(ftdm_channel_t * ftdmchan, void *data,
                              size_t *datalen)
{
  ftdm_ssize_t w = 0;
  size_t bytes = *datalen;

  if (ftdmchan->type == FTDM_CHAN_TYPE_DQ921) {
    memset(data + bytes, 0, 2);
    bytes += 2;
  }

tryagain:
  w = write(ftdmchan->sockfd, data, bytes);

  if (w >= 0) {
    *datalen = w;
    return FTDM_SUCCESS;
  }

  if (errno == ELAST) {
    zt_event_t zt_event_id = 0;
    if (ioctl(ftdmchan->sockfd, DAHDI_GETEVENT, &zt_event_id) == -1) {
      ftdm_log(FTDM_LOG_ERROR,
               "[s%dc%d][%d:%d] "
               "Failed retrieving event after ELAST on write: %s\n",
               ftdmchan->span_id, ftdmchan->chan_id,
               ftdmchan->physical_span_id,
               ftdmchan->physical_chan_id, strerror(errno));
      return FTDM_FAIL;
    }

    ftdm_log(FTDM_LOG_DEBUG,
             "[s%dc%d][%d:%d] "
             "Deferring event %d to be able to write data\n",
             ftdmchan->span_id, ftdmchan->chan_id,
             ftdmchan->physical_span_id,
             ftdmchan->physical_chan_id, zt_event_id);
    if (ftdmchan->io_data) {
      ftdm_log(FTDM_LOG_WARNING,
               "[s%dc%d][%d:%d] "
               "Dropping event %d, not retrieved on time\n",
               ftdmchan->span_id, ftdmchan->chan_id,
               ftdmchan->physical_span_id,
               ftdmchan->physical_chan_id, zt_event_id);
    }
    ftdmchan->io_data = (void *) zt_event_id;
    ftdmchan->io_flags |= (FTDM_CHANNEL_IO_EVENT);
    ftdmchan->last_event_time = ftdm_current_time_in_ms();

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

static ftdm_status_t zt_destroy(void)
{
  close(CONTROL_FD);
  memset(&zt_interface, 0, sizeof(zt_interface));
  return FTDM_SUCCESS;
}

ftdm_module_t ftdm_module = {
  "zt",
  zt_init,
  zt_destroy,
};

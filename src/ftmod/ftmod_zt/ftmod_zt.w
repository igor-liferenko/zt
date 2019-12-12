@ @c
#include <assert.h>
#include <errno.h>
#include <poll.h>
#include <stdio.h>
#include <stdint.h>
#include <stdarg.h>
#include <stdlib.h>
#include <time.h>
#include <wchar.h>
#include <stddef.h>
#include <string.h>
#include <unistd.h>

typedef int ftdm_socket_t;

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
typedef size_t ftdm_size_t;
typedef struct ftdm_sigmsg ftdm_sigmsg_t;
typedef struct ftdm_usrmsg ftdm_usrmsg_t;
typedef struct ftdm_io_interface ftdm_io_interface_t;
typedef struct ftdm_stream_handle ftdm_stream_handle_t;
typedef struct ftdm_queue ftdm_queue_t;
typedef struct ftdm_memory_handler ftdm_memory_handler_t;
ftdm_status_t ftdm_set_npi(const char *npi_string, uint8_t *target);
ftdm_status_t ftdm_set_ton(const char *ton_string, uint8_t *target);
ftdm_status_t ftdm_set_bearer_capability(const char *bc_string, uint8_t *target);
ftdm_status_t ftdm_set_bearer_layer1(const char *bc_string, uint8_t *target);
ftdm_status_t ftdm_set_screening_ind(const char *string, uint8_t *target);
ftdm_status_t ftdm_set_presentation_ind(const char *string, uint8_t *target);
ftdm_status_t ftdm_is_number(const char *number);
ftdm_status_t ftdm_set_calling_party_category(const char *string, uint8_t *target);
char * ftdm_url_encode(const char *url, char *buf, ftdm_size_t len);

char * ftdm_url_decode(char *s, ftdm_size_t *len);

#define FTDM_MAX_CHANNELS_PHYSICAL_SPAN 32

#define FTDM_MAX_PHYSICAL_SPANS_PER_LOGICAL_SPAN 128

#define FTDM_MAX_CHANNELS_SPAN FTDM_MAX_CHANNELS_PHYSICAL_SPAN * FTDM_MAX_PHYSICAL_SPANS_PER_LOGICAL_SPAN

#define FTDM_MAX_SPANS_INTERFACE 128

#define FTDM_MAX_CHANNELS_GROUP 2048

#define FTDM_MAX_GROUPS_INTERFACE FTDM_MAX_SPANS_INTERFACE

#define FTDM_MAX_SIG_PARAMETERS 30

#define FTDM_INVALID_INT_PARM 0xFF

typedef struct ftdm_mutex ftdm_mutex_t;
typedef struct ftdm_thread ftdm_thread_t;
typedef struct ftdm_interrupt ftdm_interrupt_t;
typedef void *(*ftdm_thread_function_t) (ftdm_thread_t *, void *);

ftdm_status_t ftdm_thread_create_detached(ftdm_thread_function_t func, void *data);
ftdm_status_t ftdm_thread_create_detached_ex(ftdm_thread_function_t func, void *data, ftdm_size_t stack_size);
void ftdm_thread_override_default_stacksize(ftdm_size_t size);

ftdm_status_t ftdm_mutex_create(ftdm_mutex_t **mutex);
ftdm_status_t ftdm_mutex_destroy(ftdm_mutex_t **mutex);

#define ftdm_mutex_lock(_x) _ftdm_mutex_lock(__FILE__, __LINE__, __FTDM_FUNC__, _x)
ftdm_status_t _ftdm_mutex_lock(const char *file, int line, const char *func, ftdm_mutex_t *mutex);

#define ftdm_mutex_trylock(_x) _ftdm_mutex_trylock(__FILE__, __LINE__, __FTDM_FUNC__, _x)
ftdm_status_t _ftdm_mutex_trylock(const char *file, int line, const char *func, ftdm_mutex_t *mutex);

#define ftdm_mutex_unlock(_x) _ftdm_mutex_unlock(__FILE__, __LINE__, __FTDM_FUNC__, _x)
ftdm_status_t _ftdm_mutex_unlock(const char *file, int line, const char *func, ftdm_mutex_t *mutex);

ftdm_status_t ftdm_interrupt_create(ftdm_interrupt_t **cond, ftdm_socket_t device, ftdm_wait_flag_t device_flags);
ftdm_status_t ftdm_interrupt_destroy(ftdm_interrupt_t **cond);
ftdm_status_t ftdm_interrupt_signal(ftdm_interrupt_t *cond);
ftdm_status_t ftdm_interrupt_wait(ftdm_interrupt_t *cond, int ms);
ftdm_status_t ftdm_interrupt_multiple_wait(ftdm_interrupt_t *interrupts[], ftdm_size_t size, int ms);
ftdm_wait_flag_t ftdm_interrupt_device_ready(ftdm_interrupt_t *interrupt);

typedef uint64_t ftdm_time_t;

#define FTDM_TIME_FMT FTDM_UINT64_FMT

#define ftdm_sleep(x) usleep(x * 1000)

#define ftdm_copy_string(x,y,z) strncpy(x, y, z - 1)

#define ftdm_set_string(x,y) strncpy(x, y, sizeof(x)-1)

#define ftdm_strlen_zero(s) (!s || *s == '\0')

#define ftdm_strlen_zero_buf(s) (*s == '\0')

#define ftdm_array_len(array) sizeof(array)/sizeof(array[0])

#define ftdm_min(x,y) ((x) < (y) ? (x) : (y))

#define ftdm_max(x,y) ((x) > (y) ? (x) : (y))

#define ftdm_clamp(val,vmin,vmax) ftdm_max(vmin,ftdm_min(val,vmax))

#define ftdm_clamp_safe(val,vmin,vmax) ftdm_clamp(val, ftdm_min(vmin,vmax), ftdm_max(vmin,vmax))
#define ftdm_offset_of(type,member) (uintptr_t)&(((type *)0)->member)
#define ftdm_container_of(ptr,type,member) (type *)((uintptr_t)(ptr) - ftdm_offset_of(type, member))
#define ftdm_unused_arg(x) (void)(x)

extern ftdm_memory_handler_t g_ftdm_mem_handler;

#define ftdm_malloc(chunksize) g_ftdm_mem_handler.malloc(g_ftdm_mem_handler.pool, chunksize)

#define ftdm_realloc(buff,chunksize) g_ftdm_mem_handler.realloc(g_ftdm_mem_handler.pool, buff, chunksize)

#define ftdm_calloc(elements,chunksize) g_ftdm_mem_handler.calloc(g_ftdm_mem_handler.pool, elements, chunksize)

#define ftdm_free(chunk) g_ftdm_mem_handler.free(g_ftdm_mem_handler.pool, chunk)

#define ftdm_safe_free(it) if (it) { ftdm_free(it); it = NULL; }

char * ftdm_strdup(const char *str);

char * ftdm_strndup(const char *str, ftdm_size_t inlen);

ftdm_time_t ftdm_current_time_in_ms(void);

#define FTDM_MAX_NAME_STR_SZ 128

#define FTDM_MAX_NUMBER_STR_SZ 32

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
#define CHAN_TYPE_STRINGS "B", "DQ921", "DQ931", "FXS", "FXO", "EM", "CAS", "INVALID"

ftdm_chan_type_t ftdm_str2ftdm_chan_type (const char *name); const char * ftdm_chan_type2str (ftdm_chan_type_t type);

#define FTDM_IS_VOICE_CHANNEL(fchan) ((fchan)->type != FTDM_CHAN_TYPE_DQ921 && (fchan)->type != FTDM_CHAN_TYPE_DQ931)

#define FTDM_IS_DCHAN(fchan) ((fchan)->type == FTDM_CHAN_TYPE_DQ921 || (fchan)->type == FTDM_CHAN_TYPE_DQ931)

#define FTDM_IS_DIGITAL_CHANNEL(fchan) ((fchan)->span->trunk_type == FTDM_TRUNK_E1 || (fchan)->span->trunk_type == FTDM_TRUNK_T1 || (fchan)->span->trunk_type == FTDM_TRUNK_J1 || (fchan)->span->trunk_type == FTDM_TRUNK_BRI || (fchan)->span->trunk_type == FTDM_TRUNK_BRI_PTMP)

#define FTDM_SPAN_IS_DIGITAL(span) ((span)->trunk_type == FTDM_TRUNK_E1 || (span)->trunk_type == FTDM_TRUNK_T1 || (span)->trunk_type == FTDM_TRUNK_J1 || (span)->trunk_type == FTDM_TRUNK_GSM || (span)->trunk_type == FTDM_TRUNK_BRI || (span)->trunk_type == FTDM_TRUNK_BRI_PTMP)
typedef void (*ftdm_logger_t)(const char *file, const char *func, int line, int level, const char *fmt, ...) __attribute__((format (printf, 5, 6)));

typedef ftdm_status_t (*ftdm_queue_create_func_t)(ftdm_queue_t **queue, ftdm_size_t capacity);
typedef ftdm_status_t (*ftdm_queue_enqueue_func_t)(ftdm_queue_t *queue, void *obj);
typedef void *(*ftdm_queue_dequeue_func_t)(ftdm_queue_t *queue);
typedef ftdm_status_t (*ftdm_queue_wait_func_t)(ftdm_queue_t *queue, int ms);
typedef ftdm_status_t (*ftdm_queue_get_interrupt_func_t)(ftdm_queue_t *queue, ftdm_interrupt_t **interrupt);
typedef ftdm_status_t (*ftdm_queue_destroy_func_t)(ftdm_queue_t **queue);

typedef struct ftdm_queue_handler {
 ftdm_queue_create_func_t create;
 ftdm_queue_enqueue_func_t enqueue;
 ftdm_queue_dequeue_func_t dequeue;
 ftdm_queue_wait_func_t wait;
 ftdm_queue_get_interrupt_func_t get_interrupt;
 ftdm_queue_destroy_func_t destroy;
} ftdm_queue_handler_t;

typedef enum {
 FTDM_TON_UNKNOWN = 0,
 FTDM_TON_INTERNATIONAL,
 FTDM_TON_NATIONAL,
 FTDM_TON_NETWORK_SPECIFIC,
 FTDM_TON_SUBSCRIBER_NUMBER,
 FTDM_TON_ABBREVIATED_NUMBER,
 FTDM_TON_RESERVED,
 FTDM_TON_INVALID
} ftdm_ton_t;
#define TON_STRINGS "unknown", "international", "national", "network-specific", "subscriber-number", "abbreviated-number", "reserved", "invalid"
ftdm_ton_t ftdm_str2ftdm_ton (const char *name); const char * ftdm_ton2str (ftdm_ton_t type);

typedef enum {
 FTDM_NPI_UNKNOWN = 0,
 FTDM_NPI_ISDN,
 FTDM_NPI_DATA,
 FTDM_NPI_TELEX,
 FTDM_NPI_NATIONAL,
 FTDM_NPI_PRIVATE,
 FTDM_NPI_RESERVED,
 FTDM_NPI_INVALID
} ftdm_npi_t;
#define NPI_STRINGS "unknown", "ISDN", "data", "telex", "national", "private", "reserved", "invalid"
ftdm_npi_t ftdm_str2ftdm_npi (const char *name); const char * ftdm_npi2str (ftdm_npi_t type);

typedef enum {
 FTDM_PRES_ALLOWED,
 FTDM_PRES_RESTRICTED,
 FTDM_PRES_NOT_AVAILABLE,
 FTDM_PRES_RESERVED,
 FTDM_PRES_INVALID
} ftdm_presentation_t;
#define PRESENTATION_STRINGS "presentation-allowed", "presentation-restricted", "number-not-available", "reserved", "Invalid"
ftdm_presentation_t ftdm_str2ftdm_presentation (const char *name); const char * ftdm_presentation2str (ftdm_presentation_t type);

typedef enum {
 FTDM_SCREENING_NOT_SCREENED,
 FTDM_SCREENING_VERIFIED_PASSED,
 FTDM_SCREENING_VERIFIED_FAILED,
 FTDM_SCREENING_NETWORK_PROVIDED,
 FTDM_SCREENING_INVALID
} ftdm_screening_t;
#define SCREENING_STRINGS "user-provided-not-screened", "user-provided-verified-and-passed", "user-provided-verified-and-failed", "network-provided", "invalid"
ftdm_screening_t ftdm_str2ftdm_screening (const char *name); const char * ftdm_screening2str (ftdm_screening_t type);

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
#define BEARER_CAP_STRINGS "speech", "unrestricted-digital-information", "restricted-digital-information", "3.1-Khz-audio", "7-Khz-audio", "15-Khz-audio", "video", "invalid"
ftdm_bearer_cap_t ftdm_str2ftdm_bearer_cap (const char *name); const char * ftdm_bearer_cap2str (ftdm_bearer_cap_t type);

typedef enum {
 FTDM_USER_LAYER1_PROT_V110 = 0x01,
 FTDM_USER_LAYER1_PROT_ULAW = 0x02,
 FTDM_USER_LAYER1_PROT_ALAW = 0x03,
 FTDM_USER_LAYER1_PROT_INVALID
} ftdm_user_layer1_prot_t;
#define USER_LAYER1_PROT_STRINGS "V.110", "ulaw", "alaw", "Invalid"
ftdm_user_layer1_prot_t ftdm_str2ftdm_usr_layer1_prot (const char *name); const char * ftdm_user_layer1_prot2str (ftdm_user_layer1_prot_t type);

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
#define CALLING_PARTY_CATEGORY_STRINGS "unknown", "operator", "operator-french", "operator-english", "operator-german", "operator-russian", "operator-spanish", "ordinary", "priority", "data-call", "test-call", "payphone", "invalid"
ftdm_calling_party_category_t ftdm_str2ftdm_calling_party_category (const char *name); const char * ftdm_calling_party_category2str (ftdm_calling_party_category_t type);

typedef enum {
 FTDM_TRANSFER_RESPONSE_OK,
 FTDM_TRANSFER_RESPONSE_CP_DROP_OFF,
 FTDM_TRANSFER_RESPONSE_LIMITS_EXCEEDED,
 FTDM_TRANSFER_RESPONSE_INVALID_NUM,
 FTDM_TRANSFER_RESPONSE_INVALID_COMMAND,
 FTDM_TRANSFER_RESPONSE_TIMEOUT,
 FTDM_TRANSFER_RESPONSE_INVALID,
} ftdm_transfer_response_t;
#define TRANSFER_RESPONSE_STRINGS "transfer-ok", "cp-drop-off", "limits-exceeded", "invalid-num", "invalid-command", "timeout", "invalid"
ftdm_transfer_response_t ftdm_str2ftdm_transfer_response (const char *name); const char * ftdm_transfer_response2str (ftdm_transfer_response_t type);

#define FTDM_DIGITS_LIMIT 64

#define FTDM_SILENCE_VALUE(fchan) (fchan)->native_codec == FTDM_CODEC_ULAW ? 255 : (fchan)->native_codec == FTDM_CODEC_ALAW ? 0xD5 : 0x00

typedef struct {
 char digits[64];
 uint8_t type;
 uint8_t plan;
} ftdm_number_t;

typedef struct {
 char from[32];
 char body[128];
} ftdm_sms_data_t;

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
 FTDM_HUNT_SPAN,
 FTDM_HUNT_GROUP,
 FTDM_HUNT_CHAN,
} ftdm_hunt_mode_t;

typedef struct {
 uint32_t span_id;
 ftdm_hunt_direction_t direction;
} ftdm_span_hunt_t;

typedef struct {
 uint32_t group_id;
 ftdm_hunt_direction_t direction;
} ftdm_group_hunt_t;

typedef struct {
 uint32_t span_id;
 uint32_t chan_id;
} ftdm_chan_hunt_t;
typedef ftdm_status_t (*ftdm_hunt_result_cb_t)(ftdm_channel_t *fchan, ftdm_caller_data_t *caller_data);

typedef struct {
 ftdm_hunt_mode_t mode;
 union {
  ftdm_span_hunt_t span;
  ftdm_group_hunt_t group;
  ftdm_chan_hunt_t chan;
 } mode_data;
 ftdm_hunt_result_cb_t result_cb;
} ftdm_hunting_scheme_t;

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
#define SIGNAL_STRINGS "START", "STOP", "RELEASED", "UP", "FLASH", "PROCEED", "RINGING", "PROGRESS", "PROGRESS_MEDIA", "ALARM_TRAP", "ALARM_CLEAR", "COLLECTED_DIGIT", "ADD_CALL", "RESTART", "SIGSTATUS_CHANGED", "FACILITY", "TRACE", "TRACE_RAW", "INDICATION_COMPLETED", "DIALING", "TRANSFER_COMPLETED", "SMS", "INVALID"

ftdm_signal_event_t ftdm_str2ftdm_signal_event (const char *name); const char * ftdm_signal_event2str (ftdm_signal_event_t type);

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
#define TRUNK_TYPE_STRINGS "E1", "T1", "J1", "BRI", "BRI_PTMP", "FXO", "FXS", "EM", "GSM", "NONE"

ftdm_trunk_type_t ftdm_str2ftdm_trunk_type (const char *name); const char * ftdm_trunk_type2str (ftdm_trunk_type_t type);

typedef enum {
 FTDM_TRUNK_MODE_CPE,
 FTDM_TRUNK_MODE_NET,
 FTDM_TRUNK_MODE_INVALID
} ftdm_trunk_mode_t;
#define TRUNK_MODE_STRINGS "CPE", "NET", "INVALID"

ftdm_trunk_mode_t ftdm_str2ftdm_trunk_mode (const char *name); const char * ftdm_trunk_mode2str (ftdm_trunk_mode_t type);

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
#define SIGSTATUS_STRINGS "DOWN", "SUSPENDED", "UP", "INVALID"

ftdm_signaling_status_t ftdm_str2ftdm_signaling_status (const char *name); const char * ftdm_signaling_status2str (ftdm_signaling_status_t type);

typedef struct {
 ftdm_signaling_status_t status;
} ftdm_event_sigstatus_t;

typedef enum {

 FTDM_TRACE_DIR_INCOMING,

 FTDM_TRACE_DIR_OUTGOING,

  FTDM_TRACE_DIR_INVALID,
} ftdm_trace_dir_t;
#define TRACE_DIR_STRINGS "INCOMING", "OUTGOING", "INVALID"

ftdm_trace_dir_t ftdm_str2ftdm_trace_dir (const char *name); const char * ftdm_trace_dir2str (ftdm_trace_dir_t type);

typedef enum {
 FTDM_TRACE_TYPE_Q931,
 FTDM_TRACE_TYPE_Q921,
 FTDM_TRACE_TYPE_INVALID,
} ftdm_trace_type_t;
#define TRACE_TYPE_STRINGS "Q931", "Q921", "INVALID"

ftdm_trace_type_t ftdm_str2ftdm_trace_type (const char *name); const char * ftdm_trace_type2str (ftdm_trace_type_t type);

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
#define INDICATION_STRINGS "NONE", "RINGING", "PROCEED", "PROGRESS", "PROGRESS_MEDIA", "BUSY", "ANSWER", "FACILITY", "TRANSFER", "INVALID"

ftdm_channel_indication_t ftdm_str2ftdm_channel_indication (const char *name); const char * ftdm_channel_indication2str (ftdm_channel_indication_t type);

typedef struct {

 ftdm_channel_indication_t indication;

 ftdm_status_t status;
} ftdm_event_indication_completed_t;

typedef struct {
 ftdm_transfer_response_t response;
} ftdm_event_transfer_completed_t;

typedef void * ftdm_variable_container_t;

typedef struct {
 ftdm_size_t len;
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

typedef void *(*ftdm_malloc_func_t)(void *pool, ftdm_size_t len);
typedef void *(*ftdm_calloc_func_t)(void *pool, ftdm_size_t elements, ftdm_size_t len);
typedef void *(*ftdm_realloc_func_t)(void *pool, void *buff, ftdm_size_t len);
typedef void (*ftdm_free_func_t)(void *pool, void *ptr);
struct ftdm_memory_handler {
 void *pool;
 ftdm_malloc_func_t malloc;
 ftdm_calloc_func_t calloc;
 ftdm_realloc_func_t realloc;
 ftdm_free_func_t free;
};

#define FIO_CHANNEL_REQUEST_ARGS (ftdm_span_t *span, uint32_t chan_id, ftdm_hunt_direction_t direction, ftdm_caller_data_t *caller_data, ftdm_channel_t **ftdmchan)
#define FIO_CHANNEL_OUTGOING_CALL_ARGS (ftdm_channel_t *ftdmchan)
#define FIO_CHANNEL_INDICATE_ARGS (ftdm_channel_t *ftdmchan, ftdm_channel_indication_t indication)
#define FIO_CHANNEL_SET_SIG_STATUS_ARGS (ftdm_channel_t *ftdmchan, ftdm_signaling_status_t status)
#define FIO_CHANNEL_GET_SIG_STATUS_ARGS (ftdm_channel_t *ftdmchan, ftdm_signaling_status_t *status)
#define FIO_SPAN_SET_SIG_STATUS_ARGS (ftdm_span_t *span, ftdm_signaling_status_t status)
#define FIO_SPAN_GET_SIG_STATUS_ARGS (ftdm_span_t *span, ftdm_signaling_status_t *status)
#define FIO_SPAN_POLL_EVENT_ARGS (ftdm_span_t *span, uint32_t ms, short *poll_events)
#define FIO_SPAN_NEXT_EVENT_ARGS (ftdm_span_t *span, ftdm_event_t **event)
#define FIO_CHANNEL_NEXT_EVENT_ARGS (ftdm_channel_t *ftdmchan, ftdm_event_t **event)
#define FIO_SIGNAL_CB_ARGS (ftdm_sigmsg_t *sigmsg)
#define FIO_EVENT_CB_ARGS (ftdm_channel_t *ftdmchan, ftdm_event_t *event)
#define FIO_CONFIGURE_SPAN_ARGS (ftdm_span_t *span, const char *str, ftdm_chan_type_t type, char *name, char *number)
#define FIO_CONFIGURE_ARGS (const char *category, const char *var, const char *val, int lineno)
#define FIO_OPEN_ARGS (ftdm_channel_t *ftdmchan)
#define FIO_CLOSE_ARGS (ftdm_channel_t *ftdmchan)
#define FIO_CHANNEL_DESTROY_ARGS (ftdm_channel_t *ftdmchan)
#define FIO_SPAN_DESTROY_ARGS (ftdm_span_t *span)
#define FIO_COMMAND_ARGS (ftdm_channel_t *ftdmchan, ftdm_command_t command, void *obj)
#define FIO_WAIT_ARGS (ftdm_channel_t *ftdmchan, ftdm_wait_flag_t *flags, int32_t to)
#define FIO_GET_ALARMS_ARGS (ftdm_channel_t *ftdmchan)
#define FIO_READ_ARGS (ftdm_channel_t *ftdmchan, void *data, ftdm_size_t *datalen)
#define FIO_WRITE_ARGS (ftdm_channel_t *ftdmchan, void *data, ftdm_size_t *datalen)
#define FIO_IO_LOAD_ARGS (ftdm_io_interface_t **fio)
#define FIO_IO_UNLOAD_ARGS (void)
#define FIO_SIG_LOAD_ARGS (void)
#define FIO_SIG_CONFIGURE_ARGS (ftdm_span_t *span, fio_signal_cb_t sig_cb, va_list ap)
#define FIO_CONFIGURE_SPAN_SIGNALING_ARGS (ftdm_span_t *span, fio_signal_cb_t sig_cb, ftdm_conf_parameter_t *ftdm_parameters)
#define FIO_SIG_UNLOAD_ARGS (void)
#define FIO_API_ARGS (ftdm_stream_handle_t *stream, const char *data)
#define FIO_SPAN_START_ARGS (ftdm_span_t *span)
#define FIO_SPAN_STOP_ARGS (ftdm_span_t *span)

typedef ftdm_status_t (*fio_channel_request_t) (ftdm_span_t *span, uint32_t chan_id, ftdm_hunt_direction_t direction, ftdm_caller_data_t *caller_data, ftdm_channel_t **ftdmchan) ;
typedef ftdm_status_t (*fio_channel_outgoing_call_t) (ftdm_channel_t *ftdmchan) ;
typedef ftdm_status_t (*fio_channel_indicate_t) (ftdm_channel_t *ftdmchan, ftdm_channel_indication_t indication);
typedef ftdm_status_t (*fio_channel_set_sig_status_t) (ftdm_channel_t *ftdmchan, ftdm_signaling_status_t status);
typedef ftdm_status_t (*fio_channel_get_sig_status_t) (ftdm_channel_t *ftdmchan, ftdm_signaling_status_t *status);
typedef ftdm_status_t (*fio_span_set_sig_status_t) (ftdm_span_t *span, ftdm_signaling_status_t status);
typedef ftdm_status_t (*fio_span_get_sig_status_t) (ftdm_span_t *span, ftdm_signaling_status_t *status);
typedef ftdm_status_t (*fio_span_poll_event_t) (ftdm_span_t *span, uint32_t ms, short *poll_events) ;
typedef ftdm_status_t (*fio_span_next_event_t) (ftdm_span_t *span, ftdm_event_t **event) ;
typedef ftdm_status_t (*fio_channel_next_event_t) (ftdm_channel_t *ftdmchan, ftdm_event_t **event) ;
typedef ftdm_status_t (*fio_signal_cb_t) (ftdm_sigmsg_t *sigmsg) ;

typedef ftdm_status_t (*fio_event_cb_t) (ftdm_channel_t *ftdmchan, ftdm_event_t *event) ;
typedef ftdm_status_t (*fio_configure_span_t) (ftdm_span_t *span, const char *str, ftdm_chan_type_t type, char *name, char *number) ;
typedef ftdm_status_t (*fio_configure_t) (const char *category, const char *var, const char *val, int lineno) ;
typedef ftdm_status_t (*fio_open_t) (ftdm_channel_t *ftdmchan) ;
typedef ftdm_status_t (*fio_close_t) (ftdm_channel_t *ftdmchan) ;
typedef ftdm_status_t (*fio_channel_destroy_t) (ftdm_channel_t *ftdmchan) ;
typedef ftdm_status_t (*fio_span_destroy_t) (ftdm_span_t *span) ;
typedef ftdm_status_t (*fio_get_alarms_t) (ftdm_channel_t *ftdmchan) ;
typedef ftdm_status_t (*fio_command_t) (ftdm_channel_t *ftdmchan, ftdm_command_t command, void *obj) ;
typedef ftdm_status_t (*fio_wait_t) (ftdm_channel_t *ftdmchan, ftdm_wait_flag_t *flags, int32_t to) ;
typedef ftdm_status_t (*fio_read_t) (ftdm_channel_t *ftdmchan, void *data, ftdm_size_t *datalen) ;
typedef ftdm_status_t (*fio_write_t) (ftdm_channel_t *ftdmchan, void *data, ftdm_size_t *datalen) ;
typedef ftdm_status_t (*fio_io_load_t) (ftdm_io_interface_t **fio) ;
typedef ftdm_status_t (*fio_sig_load_t) (void) ;
typedef ftdm_status_t (*fio_sig_configure_t) (ftdm_span_t *span, fio_signal_cb_t sig_cb, va_list ap) ;
typedef ftdm_status_t (*fio_configure_span_signaling_t) (ftdm_span_t *span, fio_signal_cb_t sig_cb, ftdm_conf_parameter_t *ftdm_parameters) ;
typedef ftdm_status_t (*fio_io_unload_t) (void) ;
typedef ftdm_status_t (*fio_sig_unload_t) (void) ;
typedef ftdm_status_t (*fio_api_t) (ftdm_stream_handle_t *stream, const char *data) ;
typedef ftdm_status_t (*fio_span_start_t) (ftdm_span_t *span) ;
typedef ftdm_status_t (*fio_span_stop_t) (ftdm_span_t *span) ;

#define FIO_CHANNEL_REQUEST_FUNCTION(name) ftdm_status_t name FIO_CHANNEL_REQUEST_ARGS
#define FIO_CHANNEL_OUTGOING_CALL_FUNCTION(name) ftdm_status_t name FIO_CHANNEL_OUTGOING_CALL_ARGS
#define FIO_CHANNEL_INDICATE_FUNCTION(name) ftdm_status_t name FIO_CHANNEL_INDICATE_ARGS
#define FIO_CHANNEL_SET_SIG_STATUS_FUNCTION(name) ftdm_status_t name FIO_CHANNEL_SET_SIG_STATUS_ARGS
#define FIO_CHANNEL_GET_SIG_STATUS_FUNCTION(name) ftdm_status_t name FIO_CHANNEL_GET_SIG_STATUS_ARGS
#define FIO_SPAN_SET_SIG_STATUS_FUNCTION(name) ftdm_status_t name FIO_SPAN_SET_SIG_STATUS_ARGS
#define FIO_SPAN_GET_SIG_STATUS_FUNCTION(name) ftdm_status_t name FIO_SPAN_GET_SIG_STATUS_ARGS
#define FIO_SPAN_POLL_EVENT_FUNCTION(name) ftdm_status_t name FIO_SPAN_POLL_EVENT_ARGS
#define FIO_SPAN_NEXT_EVENT_FUNCTION(name) ftdm_status_t name FIO_SPAN_NEXT_EVENT_ARGS
#define FIO_CHANNEL_NEXT_EVENT_FUNCTION(name) ftdm_status_t name FIO_CHANNEL_NEXT_EVENT_ARGS
#define FIO_SIGNAL_CB_FUNCTION(name) ftdm_status_t name FIO_SIGNAL_CB_ARGS
#define FIO_EVENT_CB_FUNCTION(name) ftdm_status_t name FIO_EVENT_CB_ARGS
#define FIO_CONFIGURE_SPAN_FUNCTION(name) ftdm_status_t name FIO_CONFIGURE_SPAN_ARGS
#define FIO_CONFIGURE_FUNCTION(name) ftdm_status_t name FIO_CONFIGURE_ARGS
#define FIO_OPEN_FUNCTION(name) ftdm_status_t name FIO_OPEN_ARGS
#define FIO_CLOSE_FUNCTION(name) ftdm_status_t name FIO_CLOSE_ARGS
#define FIO_CHANNEL_DESTROY_FUNCTION(name) ftdm_status_t name FIO_CHANNEL_DESTROY_ARGS
#define FIO_SPAN_DESTROY_FUNCTION(name) ftdm_status_t name FIO_SPAN_DESTROY_ARGS
#define FIO_GET_ALARMS_FUNCTION(name) ftdm_status_t name FIO_GET_ALARMS_ARGS
#define FIO_COMMAND_FUNCTION(name) ftdm_status_t name FIO_COMMAND_ARGS
#define FIO_WAIT_FUNCTION(name) ftdm_status_t name FIO_WAIT_ARGS
#define FIO_READ_FUNCTION(name) ftdm_status_t name FIO_READ_ARGS
#define FIO_WRITE_FUNCTION(name) ftdm_status_t name FIO_WRITE_ARGS
#define FIO_IO_LOAD_FUNCTION(name) ftdm_status_t name FIO_IO_LOAD_ARGS
#define FIO_SIG_LOAD_FUNCTION(name) ftdm_status_t name FIO_SIG_LOAD_ARGS
#define FIO_SIG_CONFIGURE_FUNCTION(name) ftdm_status_t name FIO_SIG_CONFIGURE_ARGS
#define FIO_CONFIGURE_SPAN_SIGNALING_FUNCTION(name) ftdm_status_t name FIO_CONFIGURE_SPAN_SIGNALING_ARGS
#define FIO_IO_UNLOAD_FUNCTION(name) ftdm_status_t name FIO_IO_UNLOAD_ARGS
#define FIO_SIG_UNLOAD_FUNCTION(name) ftdm_status_t name FIO_SIG_UNLOAD_ARGS
#define FIO_API_FUNCTION(name) ftdm_status_t name FIO_API_ARGS
#define FIO_SPAN_START_FUNCTION(name) ftdm_status_t name FIO_SPAN_START_ARGS
#define FIO_SPAN_STOP_FUNCTION(name) ftdm_status_t name FIO_SPAN_STOP_ARGS

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

ftdm_status_t ftdm_global_set_queue_handler(ftdm_queue_handler_t *handler);

int ftdm_channel_get_availability(ftdm_channel_t *ftdmchan);
#define ftdm_channel_call_answer(ftdmchan) _ftdm_channel_call_answer(__FILE__, __FTDM_FUNC__, __LINE__, (ftdmchan), NULL)
#define ftdm_channel_call_answer_ex(ftdmchan,usrmsg) _ftdm_channel_call_answer(__FILE__, __FTDM_FUNC__, __LINE__, (ftdmchan), (usrmsg))

ftdm_status_t _ftdm_channel_call_answer(const char *file, const char *func, int line, ftdm_channel_t *ftdmchan, ftdm_usrmsg_t *usrmsg);

#define ftdm_channel_call_place(ftdmchan) _ftdm_channel_call_place(__FILE__, __FTDM_FUNC__, __LINE__, (ftdmchan), NULL)
#define ftdm_channel_call_place_ex(ftdmchan,usrmsg) _ftdm_channel_call_place_ex(__FILE__, __FTDM_FUNC__, __LINE__, (ftdmchan), (usrmsg))

ftdm_status_t _ftdm_channel_call_place(const char *file, const char *func, int line, ftdm_channel_t *ftdmchan, ftdm_usrmsg_t *usrmsg);

#define ftdm_call_place(callerdata,hunting) _ftdm_call_place(__FILE__, __FTDM_FUNC__, __LINE__, (callerdata), (hunting), NULL)
#define ftdm_call_place_ex(callerdata,hunting,usrmsg) _ftdm_call_place(__FILE__, __FTDM_FUNC__, __LINE__, (callerdata), (hunting), (usrmsg))
ftdm_status_t _ftdm_call_place(const char *file, const char *func, int line, ftdm_caller_data_t *caller_data, ftdm_hunting_scheme_t *hunting, ftdm_usrmsg_t *usrmsg);
#define ftdm_channel_call_indicate(ftdmchan,indication) _ftdm_channel_call_indicate(__FILE__, __FTDM_FUNC__, __LINE__, (ftdmchan), (indication), NULL)
#define ftdm_channel_call_indicate_ex(ftdmchan,indication,usrmsg) _ftdm_channel_call_indicate(__FILE__, __FTDM_FUNC__, __LINE__, (ftdmchan), (indication), (usrmsg))

ftdm_status_t _ftdm_channel_call_indicate(const char *file, const char *func, int line, ftdm_channel_t *ftdmchan, ftdm_channel_indication_t indication, ftdm_usrmsg_t *usrmsg);

#define ftdm_channel_call_hangup(ftdmchan) _ftdm_channel_call_hangup(__FILE__, __FTDM_FUNC__, __LINE__, (ftdmchan), NULL)
#define ftdm_channel_call_hangup_ex(ftdmchan,usrmsg) _ftdm_channel_call_hangup(__FILE__, __FTDM_FUNC__, __LINE__, (ftdmchan), (usrmsg))

ftdm_status_t _ftdm_channel_call_hangup(const char *file, const char *func, int line, ftdm_channel_t *ftdmchan, ftdm_usrmsg_t *usrmsg);

#define ftdm_channel_call_hangup_with_cause(ftdmchan,cause) _ftdm_channel_call_hangup_with_cause(__FILE__, __FTDM_FUNC__, __LINE__, (ftdmchan), (cause), NULL)
#define ftdm_channel_call_hangup_with_cause_ex(ftdmchan,cause,usrmsg) _ftdm_channel_call_hangup_with_cause(__FILE__, __FTDM_FUNC__, __LINE__, (ftdmchan), (cause), (usrmsg))

ftdm_status_t _ftdm_channel_call_hangup_with_cause(const char *file, const char *func, int line, ftdm_channel_t *ftdmchan, ftdm_call_cause_t, ftdm_usrmsg_t *usrmsg);
#define ftdm_channel_call_transfer(ftdmchan,arg) _ftdm_channel_call_transfer(__FILE__, __FTDM_FUNC__, __LINE__, (ftdmchan), (arg), NULL)
#define ftdm_channel_call_transfer_ex(ftdmchan,arg,usrmsg) _ftdm_channel_call_transfer(__FILE__, __FTDM_FUNC__, __LINE__, (ftdmchan), (arg), (usrmsg))

ftdm_status_t _ftdm_channel_call_transfer(const char *file, const char *func, int line, ftdm_channel_t *ftdmchan, const char* arg, ftdm_usrmsg_t *usrmsg);

#define ftdm_channel_reset(ftdmchan) _ftdm_channel_reset(__FILE__, __FTDM_FUNC__, __LINE__, (ftdmchan), NULL)
#define ftdm_channel_reset_ex(ftdmchan,usrmsg) _ftdm_channel_reset(__FILE__, __FTDM_FUNC__, __LINE__, (ftdmchan), usrmsg)

ftdm_status_t _ftdm_channel_reset(const char *file, const char *func, int line, ftdm_channel_t *ftdmchan, ftdm_usrmsg_t *usrmsg);

#define ftdm_channel_call_hold(ftdmchan) _ftdm_channel_call_hold(__FILE__, __FTDM_FUNC__, __LINE__, (ftdmchan), NULL)
#define ftdm_channel_call_hold_ex(ftdmchan,usrmsg) _ftdm_channel_call_hold(__FILE__, __FTDM_FUNC__, __LINE__, (ftdmchan), (usrmsg))

ftdm_status_t _ftdm_channel_call_hold(const char *file, const char *func, int line, ftdm_channel_t *ftdmchan, ftdm_usrmsg_t *usrmsg);

#define ftdm_channel_call_unhold(ftdmchan) _ftdm_channel_call_unhold(__FILE__, __FTDM_FUNC__, __LINE__, (ftdmchan), NULL)
#define ftdm_channel_call_unhold_ex(ftdmchan,usrmsg) _ftdm_channel_call_unhold(__FILE__, __FTDM_FUNC__, __LINE__, (ftdmchan), (usrmsg))

ftdm_status_t _ftdm_channel_call_unhold(const char *file, const char *func, int line, ftdm_channel_t *ftdmchan, ftdm_usrmsg_t *usrmsg);

ftdm_bool_t ftdm_channel_call_check_answered(const ftdm_channel_t *ftdmchan);

ftdm_bool_t ftdm_channel_call_check_busy(const ftdm_channel_t *ftdmchan);

ftdm_bool_t ftdm_channel_call_check_hangup(const ftdm_channel_t *ftdmchan);

ftdm_bool_t ftdm_channel_call_check_done(const ftdm_channel_t *ftdmchan);

ftdm_bool_t ftdm_channel_call_check_hold(const ftdm_channel_t *ftdmchan);

ftdm_status_t ftdm_channel_set_sig_status(ftdm_channel_t *ftdmchan, ftdm_signaling_status_t status);

ftdm_status_t ftdm_channel_get_sig_status(ftdm_channel_t *ftdmchan, ftdm_signaling_status_t *status);

ftdm_status_t ftdm_span_set_sig_status(ftdm_span_t *span, ftdm_signaling_status_t status);

ftdm_status_t ftdm_span_get_sig_status(ftdm_span_t *span, ftdm_signaling_status_t *status);
void ftdm_channel_set_private(ftdm_channel_t *ftdmchan, void *pvt);
void * ftdm_channel_get_private(const ftdm_channel_t *ftdmchan);
ftdm_status_t ftdm_channel_clear_token(ftdm_channel_t *ftdmchan, const char *token);
void ftdm_channel_replace_token(ftdm_channel_t *ftdmchan, const char *old_token, const char *new_token);
ftdm_status_t ftdm_channel_add_token(ftdm_channel_t *ftdmchan, char *token, int end);
const char * ftdm_channel_get_token(const ftdm_channel_t *ftdmchan, uint32_t tokenid);
uint32_t ftdm_channel_get_token_count(const ftdm_channel_t *ftdmchan);
uint32_t ftdm_channel_get_io_interval(const ftdm_channel_t *ftdmchan);
uint32_t ftdm_channel_get_io_packet_len(const ftdm_channel_t *ftdmchan);
ftdm_codec_t ftdm_channel_get_codec(const ftdm_channel_t *ftdmchan);
const char * ftdm_channel_get_last_error(const ftdm_channel_t *ftdmchan);
ftdm_status_t ftdm_channel_get_alarms(ftdm_channel_t *ftdmchan, ftdm_alarm_flag_t *alarmbits);
ftdm_chan_type_t ftdm_channel_get_type(const ftdm_channel_t *ftdmchan);
ftdm_size_t ftdm_channel_dequeue_dtmf(ftdm_channel_t *ftdmchan, char *dtmf, ftdm_size_t len);

void ftdm_channel_flush_dtmf(ftdm_channel_t *ftdmchan);
ftdm_status_t ftdm_span_poll_event(ftdm_span_t *span, uint32_t ms, short *poll_events);
ftdm_status_t ftdm_span_find(uint32_t id, ftdm_span_t **span);
const char * ftdm_span_get_last_error(const ftdm_span_t *span);
ftdm_status_t ftdm_span_create(const char *iotype, const char *name, ftdm_span_t **span);
ftdm_status_t ftdm_span_add_channel(ftdm_span_t *span, ftdm_socket_t sockfd, ftdm_chan_type_t type, ftdm_channel_t **chan);

ftdm_status_t ftdm_channel_add_to_group(const char* name, ftdm_channel_t* ftdmchan);

ftdm_status_t ftdm_channel_remove_from_group(ftdm_group_t* group, ftdm_channel_t* ftdmchan);
ftdm_status_t ftdm_channel_read_event(ftdm_channel_t *ftdmchan, ftdm_event_t **event);

ftdm_status_t ftdm_group_find(uint32_t id, ftdm_group_t **group);

ftdm_status_t ftdm_group_find_by_name(const char *name, ftdm_group_t **group);

ftdm_status_t ftdm_group_create(ftdm_group_t **group, const char *name);

ftdm_status_t ftdm_span_channel_use_count(ftdm_span_t *span, uint32_t *count);

ftdm_status_t ftdm_group_channel_use_count(ftdm_group_t *group, uint32_t *count);

uint32_t ftdm_group_get_id(const ftdm_group_t *group);
ftdm_status_t ftdm_channel_open(uint32_t span_id, uint32_t chan_id, ftdm_channel_t **ftdmchan);
ftdm_status_t ftdm_channel_open_ph(uint32_t span_id, uint32_t chan_id, ftdm_channel_t **ftdmchan);
ftdm_status_t ftdm_channel_open_by_span(uint32_t span_id, ftdm_hunt_direction_t direction, ftdm_caller_data_t *caller_data, ftdm_channel_t **ftdmchan);
ftdm_status_t ftdm_channel_open_by_group(uint32_t group_id, ftdm_hunt_direction_t direction, ftdm_caller_data_t *caller_data, ftdm_channel_t **ftdmchan);
ftdm_status_t ftdm_channel_close(ftdm_channel_t **ftdmchan);
ftdm_status_t ftdm_channel_command(ftdm_channel_t *ftdmchan, ftdm_command_t command, void *arg);
ftdm_status_t ftdm_channel_wait(ftdm_channel_t *ftdmchan, ftdm_wait_flag_t *flags, int32_t timeout);
ftdm_status_t ftdm_channel_read(ftdm_channel_t *ftdmchan, void *data, ftdm_size_t *datalen);
ftdm_status_t ftdm_channel_write(ftdm_channel_t *ftdmchan, void *data, ftdm_size_t datasize, ftdm_size_t *datalen);

const char * ftdm_sigmsg_get_var(ftdm_sigmsg_t *sigmsg, const char *var_name);
ftdm_iterator_t * ftdm_sigmsg_get_var_iterator(const ftdm_sigmsg_t *sigmsg, ftdm_iterator_t *iter);
ftdm_status_t ftdm_sigmsg_get_raw_data(ftdm_sigmsg_t *sigmsg, void **data, ftdm_size_t *datalen);
ftdm_status_t ftdm_sigmsg_get_raw_data_detached(ftdm_sigmsg_t *sigmsg, void **data, ftdm_size_t *datalen);

ftdm_status_t ftdm_usrmsg_add_var(ftdm_usrmsg_t *usrmsg, const char *var_name, const char *value);
ftdm_status_t ftdm_usrmsg_set_raw_data(ftdm_usrmsg_t *usrmsg, void *data, ftdm_size_t datalen);

void * ftdm_iterator_current(ftdm_iterator_t *iter);

ftdm_status_t ftdm_get_current_var(ftdm_iterator_t *iter, const char **var_name, const char **var_val);

ftdm_iterator_t * ftdm_iterator_next(ftdm_iterator_t *iter);

ftdm_status_t ftdm_iterator_free(ftdm_iterator_t *iter);

ftdm_span_t * ftdm_channel_get_span(const ftdm_channel_t *ftdmchan);

uint32_t ftdm_channel_get_span_id(const ftdm_channel_t *ftdmchan);

uint32_t ftdm_channel_get_ph_span_id(const ftdm_channel_t *ftdmchan);

const char * ftdm_channel_get_span_name(const ftdm_channel_t *ftdmchan);

uint32_t ftdm_channel_get_id(const ftdm_channel_t *ftdmchan);

const char * ftdm_channel_get_name(const ftdm_channel_t *ftdmchan);

const char * ftdm_channel_get_number(const ftdm_channel_t *ftdmchan);

uint32_t ftdm_channel_get_ph_id(const ftdm_channel_t *ftdmchan);
ftdm_status_t ftdm_configure_span(ftdm_span_t *span, const char *type, fio_signal_cb_t sig_cb, ...);
#define FTDM_TAG_END NULL
ftdm_status_t ftdm_configure_span_signaling(ftdm_span_t *span, const char *type, fio_signal_cb_t sig_cb, ftdm_conf_parameter_t *parameters);
ftdm_status_t ftdm_span_register_signal_cb(ftdm_span_t *span, fio_signal_cb_t sig_cb);
ftdm_status_t ftdm_span_start(ftdm_span_t *span);
ftdm_status_t ftdm_span_stop(ftdm_span_t *span);
ftdm_status_t ftdm_global_add_io_interface(ftdm_io_interface_t *io_interface);
ftdm_io_interface_t * ftdm_global_get_io_interface(const char *iotype, ftdm_bool_t autoload);

ftdm_status_t ftdm_span_find_by_name(const char *name, ftdm_span_t **span);

uint32_t ftdm_span_get_id(const ftdm_span_t *span);

const char * ftdm_span_get_name(const ftdm_span_t *span);

ftdm_iterator_t * ftdm_span_get_chan_iterator(const ftdm_span_t *span, ftdm_iterator_t *iter);

ftdm_iterator_t * ftdm_get_span_iterator(ftdm_iterator_t *iter);
char * ftdm_api_execute(const char *cmd);
ftdm_status_t ftdm_conf_node_create(const char *name, ftdm_conf_node_t **node, ftdm_conf_node_t *parent);
ftdm_status_t ftdm_conf_node_add_param(ftdm_conf_node_t *node, const char *param, const char *val);
ftdm_status_t ftdm_conf_node_destroy(ftdm_conf_node_t *node);
ftdm_status_t ftdm_configure_span_channels(ftdm_span_t *span, const char *str, ftdm_channel_config_t *chan_config, unsigned *configured);
void ftdm_span_set_trunk_type(ftdm_span_t *span, ftdm_trunk_type_t type);
ftdm_trunk_type_t ftdm_span_get_trunk_type(const ftdm_span_t *span);

const char * ftdm_span_get_trunk_type_str(const ftdm_span_t *span);

void ftdm_span_set_trunk_mode(ftdm_span_t *span, ftdm_trunk_mode_t mode);

ftdm_trunk_mode_t ftdm_span_get_trunk_mode(const ftdm_span_t *span);

const char * ftdm_span_get_trunk_mode_str(const ftdm_span_t *span);
ftdm_channel_t * ftdm_span_get_channel(const ftdm_span_t *span, uint32_t chanid);
ftdm_channel_t * ftdm_span_get_channel_ph(const ftdm_span_t *span, uint32_t chanid);

uint32_t ftdm_span_get_chan_count(const ftdm_span_t *span);

ftdm_status_t ftdm_channel_set_caller_data(ftdm_channel_t *ftdmchan, ftdm_caller_data_t *caller_data);

ftdm_caller_data_t * ftdm_channel_get_caller_data(ftdm_channel_t *channel);

int ftdm_channel_get_state(const ftdm_channel_t *ftdmchan);

int ftdm_channel_get_last_state(const ftdm_channel_t *ftdmchan);

const char * ftdm_channel_get_state_str(const ftdm_channel_t *channel);

const char * ftdm_channel_get_last_state_str(const ftdm_channel_t *channel);

char * ftdm_channel_get_history_str(const ftdm_channel_t *channel);

ftdm_status_t ftdm_span_set_blocking_mode(const ftdm_span_t *span, ftdm_bool_t enabled);

ftdm_status_t ftdm_global_init(void);

ftdm_status_t ftdm_global_configuration(void);

ftdm_status_t ftdm_global_destroy(void);

ftdm_status_t ftdm_global_set_memory_handler(ftdm_memory_handler_t *handler);

void ftdm_global_set_crash_policy(ftdm_crash_policy_t policy);

void ftdm_global_set_logger(ftdm_logger_t logger);

void ftdm_global_set_default_logger(int level);

void ftdm_global_set_mod_directory(const char *path);

void ftdm_global_set_config_directory(const char *path);

ftdm_bool_t ftdm_running(void);
ftdm_status_t ftdm_backtrace_walk(void (* callback)(const int tid, const void *addr, const char *symbol, void *priv), void *priv);
ftdm_status_t ftdm_backtrace_span(ftdm_span_t *span);
ftdm_status_t ftdm_backtrace_chan(ftdm_channel_t *chan);

 extern ftdm_logger_t ftdm_log;

#define FIO_CODEC_ARGS (void *data, ftdm_size_t max, ftdm_size_t *datalen)
#define FIO_CODEC_FUNCTION(name) FT_DECLARE_NONSTD(ftdm_status_t) name FIO_CODEC_ARGS
typedef ftdm_status_t (*fio_codec_t) (void *data, ftdm_size_t max, ftdm_size_t *datalen) ;

ftdm_status_t fio_slin2ulaw (void *data, ftdm_size_t max, ftdm_size_t *datalen);
ftdm_status_t fio_ulaw2slin (void *data, ftdm_size_t max, ftdm_size_t *datalen);
ftdm_status_t fio_slin2alaw (void *data, ftdm_size_t max, ftdm_size_t *datalen);
ftdm_status_t fio_alaw2slin (void *data, ftdm_size_t max, ftdm_size_t *datalen);
ftdm_status_t fio_ulaw2alaw (void *data, ftdm_size_t max, ftdm_size_t *datalen);
ftdm_status_t fio_alaw2ulaw (void *data, ftdm_size_t max, ftdm_size_t *datalen);

#define FTDM_PRE __FILE__, __func__, __LINE__
#define FTDM_LOG_LEVEL_DEBUG 7
#define FTDM_LOG_LEVEL_INFO 6
#define FTDM_LOG_LEVEL_NOTICE 5
#define FTDM_LOG_LEVEL_WARNING 4
#define FTDM_LOG_LEVEL_ERROR 3
#define FTDM_LOG_LEVEL_CRIT 2
#define FTDM_LOG_LEVEL_ALERT 1
#define FTDM_LOG_LEVEL_EMERG 0

#define FTDM_LOG_DEBUG FTDM_PRE, FTDM_LOG_LEVEL_DEBUG
#define FTDM_LOG_INFO FTDM_PRE, FTDM_LOG_LEVEL_INFO
#define FTDM_LOG_NOTICE FTDM_PRE, FTDM_LOG_LEVEL_NOTICE
#define FTDM_LOG_WARNING FTDM_PRE, FTDM_LOG_LEVEL_WARNING
#define FTDM_LOG_ERROR FTDM_PRE, FTDM_LOG_LEVEL_ERROR
#define FTDM_LOG_CRIT FTDM_PRE, FTDM_LOG_LEVEL_CRIT
#define FTDM_LOG_ALERT FTDM_PRE, FTDM_LOG_LEVEL_ALERT
#define FTDM_LOG_EMERG FTDM_PRE, FTDM_LOG_LEVEL_EMERG

#define __PRIVATE_FTDM_CORE__ 
#define FTDM_THREAD_STACKSIZE 240 * 1024
#define FTDM_ENUM_NAMES(_NAME,_STRINGS) static const char * _NAME [] = { _STRINGS , NULL };

#define ftdm_true(expr) (expr && ( !strcasecmp(expr, "yes") || !strcasecmp(expr, "on") || !strcasecmp(expr, "true") || !strcasecmp(expr, "enabled") || !strcasecmp(expr, "active") || atoi(expr))) ? FTDM_TRUE : FTDM_FALSE

#define FTDM_TYPES_H 

# 1 "./src/include/private/fsk.h" 1
# 35 "./src/include/private/fsk.h"
#define __FSK_H__ 
# 1 "./src/include/private/uart.h" 1
# 35 "./src/include/private/uart.h"
#define __UART_H__ 

# 41 "./src/include/private/uart.h"
typedef void (*bytehandler_func_t) (void *, int);
typedef void (*bithandler_func_t) (void *, int);

typedef struct dsp_uart_attr_s
{
 bytehandler_func_t bytehandler;
 void *bytehandler_arg;
} dsp_uart_attr_t;

typedef struct
{
 dsp_uart_attr_t attr;
 int have_start;
 int data;
 int nbits;
} dsp_uart_handle_t;
# 69 "./src/include/private/uart.h"
void dsp_uart_attr_init(dsp_uart_attr_t *attributes);

bytehandler_func_t dsp_uart_attr_get_bytehandler(dsp_uart_attr_t *attributes, void **bytehandler_arg);
void dsp_uart_attr_set_bytehandler(dsp_uart_attr_t *attributes, bytehandler_func_t bytehandler, void *bytehandler_arg);

dsp_uart_handle_t * dsp_uart_create(dsp_uart_attr_t *attributes);
void dsp_uart_destroy(dsp_uart_handle_t **handle);

void dsp_uart_bit_handler(void *handle, int bit);
# 37 "./src/include/private/fsk.h" 2

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

typedef struct dsp_fsk_attr_s
{
 int sample_rate;
 bithandler_func_t bithandler;
 void *bithandler_arg;
 bytehandler_func_t bytehandler;
 void *bytehandler_arg;
} dsp_fsk_attr_t;

typedef struct
{
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
# 100 "./src/include/private/fsk.h"
void dsp_fsk_attr_init(dsp_fsk_attr_t *attributes);

bithandler_func_t dsp_fsk_attr_get_bithandler(dsp_fsk_attr_t *attributes, void **bithandler_arg);
void dsp_fsk_attr_set_bithandler(dsp_fsk_attr_t *attributes, bithandler_func_t bithandler, void *bithandler_arg);
bytehandler_func_t dsp_fsk_attr_get_bytehandler(dsp_fsk_attr_t *attributes, void **bytehandler_arg);
void dsp_fsk_attr_set_bytehandler(dsp_fsk_attr_t *attributes, bytehandler_func_t bytehandler, void *bytehandler_arg);
int dsp_fsk_attr_get_samplerate(dsp_fsk_attr_t *attributes);
int dsp_fsk_attr_set_samplerate(dsp_fsk_attr_t *attributes, int samplerate);

dsp_fsk_handle_t * dsp_fsk_create(dsp_fsk_attr_t *attributes);
void dsp_fsk_destroy(dsp_fsk_handle_t **handle);

void dsp_fsk_sample(dsp_fsk_handle_t *handle, double normalized_sample);

extern fsk_modem_definition_t fsk_modem_definitions[];

typedef ssize_t ftdm_ssize_t;
typedef int ftdm_filehandle_t;

#define FTDM_COMMAND_OBJ_SIZE *((ftdm_size_t *)obj)
#define FTDM_COMMAND_OBJ_INT *((int *)obj)
#define FTDM_COMMAND_OBJ_CHAR_P (char *)obj
#define FTDM_COMMAND_OBJ_FLOAT *(float *)obj
#define FTDM_FSK_MOD_FACTOR 0x10000
#define FTDM_DEFAULT_DTMF_ON 250
#define FTDM_DEFAULT_DTMF_OFF 50

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
#define MDMF_STRINGS "X", "DATETIME", "PHONE_NUM", "DDN", "NO_NUM", "X", "X", "PHONE_NAME", "NO_NAME", "ALT_ROUTE", "INVALID"
ftdm_mdmf_type_t ftdm_str2ftdm_mdmf_type (const char *name); const char * ftdm_mdmf_type2str (ftdm_mdmf_type_t type);

#define FTDM_TONEMAP_LEN 128
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
#define TONEMAP_STRINGS "NONE", "DIAL", "RING", "BUSY", "FAIL1", "FAIL2", "FAIL3", "ATTN", "CALLWAITING-CAS", "CALLWAITING-SAS", "CALLWAITING-ACK", "INVALID"
ftdm_tonemap_t ftdm_str2ftdm_tonemap (const char *name); const char * ftdm_tonemap2str (ftdm_tonemap_t type);

typedef enum {
 FTDM_ANALOG_START_KEWL,
 FTDM_ANALOG_START_LOOP,
 FTDM_ANALOG_START_GROUND,
 FTDM_ANALOG_START_WINK,
 FTDM_ANALOG_START_NA
} ftdm_analog_start_type_t;
#define START_TYPE_STRINGS "KEWL", "LOOP", "GROUND", "WINK", "NA"
ftdm_analog_start_type_t ftdm_str2ftdm_analog_start_type (const char *name); const char * ftdm_analog_start_type2str (ftdm_analog_start_type_t type);

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
#define OOB_STRINGS "NOOP", "ONHOOK", "OFFHOOK", "WINK", "FLASH", "RING_START", "RING_STOP", "ALARM_TRAP", "ALARM_CLEAR", "CAS_BITS_CHANGE", "POLARITY_REVERSE", "INVALID"
ftdm_oob_event_t ftdm_str2ftdm_oob_event (const char *name); const char * ftdm_oob_event2str (ftdm_oob_event_t type);

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
 FTDM_CHANNEL_FEATURE_HWEC = (1<<7),
 FTDM_CHANNEL_FEATURE_HWEC_DISABLED_ON_IDLE = (1<<8),
 FTDM_CHANNEL_FEATURE_IO_STATS = (1<<9),
 FTDM_CHANNEL_FEATURE_MF_GENERATE = (1<<10),
} ftdm_channel_feature_t;

typedef enum {
 FTDM_CHANNEL_IO_EVENT = (1 << 0),
 FTDM_CHANNEL_IO_READ = (1 << 1),
 FTDM_CHANNEL_IO_WRITE = (1 << 2),
} ftdm_channel_io_flags_t;

#define FTDM_CHANNEL_CONFIGURED (1ULL << 0)
#define FTDM_CHANNEL_READY (1ULL << 1)
#define FTDM_CHANNEL_OPEN (1ULL << 2)
#define FTDM_CHANNEL_DTMF_DETECT (1ULL << 3)
#define FTDM_CHANNEL_SUPRESS_DTMF (1ULL << 4)
#define FTDM_CHANNEL_TRANSCODE (1ULL << 5)
#define FTDM_CHANNEL_BUFFER (1ULL << 6)
#define FTDM_CHANNEL_INTHREAD (1ULL << 8)
#define FTDM_CHANNEL_WINK (1ULL << 9)
#define FTDM_CHANNEL_FLASH (1ULL << 10)
#define FTDM_CHANNEL_STATE_CHANGE (1ULL << 11)
#define FTDM_CHANNEL_HOLD (1ULL << 12)
#define FTDM_CHANNEL_INUSE (1ULL << 13)
#define FTDM_CHANNEL_OFFHOOK (1ULL << 14)
#define FTDM_CHANNEL_RINGING (1ULL << 15)
#define FTDM_CHANNEL_PROGRESS_DETECT (1ULL << 16)
#define FTDM_CHANNEL_CALLERID_DETECT (1ULL << 17)
#define FTDM_CHANNEL_OUTBOUND (1ULL << 18)
#define FTDM_CHANNEL_SUSPENDED (1ULL << 19)
#define FTDM_CHANNEL_3WAY (1ULL << 20)
#define FTDM_CHANNEL_PROGRESS (1ULL << 21)

#define FTDM_CHANNEL_MEDIA (1ULL << 22)

#define FTDM_CHANNEL_ANSWERED (1ULL << 23)
#define FTDM_CHANNEL_MUTE (1ULL << 24)
#define FTDM_CHANNEL_USE_RX_GAIN (1ULL << 25)
#define FTDM_CHANNEL_USE_TX_GAIN (1ULL << 26)
#define FTDM_CHANNEL_IN_ALARM (1ULL << 27)
#define FTDM_CHANNEL_SIG_UP (1ULL << 28)
#define FTDM_CHANNEL_USER_HANGUP (1ULL << 29)
#define FTDM_CHANNEL_RX_DISABLED (1ULL << 30)
#define FTDM_CHANNEL_TX_DISABLED (1ULL << 31)

#define FTDM_CHANNEL_CALL_STARTED (1ULL << 32)

#define FTDM_CHANNEL_NONBLOCK (1ULL << 33)

#define FTDM_CHANNEL_IND_ACK_PENDING (1ULL << 34)

#define FTDM_CHANNEL_BLOCKING (1ULL << 35)

#define FTDM_CHANNEL_DIGITAL_MEDIA (1ULL << 36)

#define FTDM_CHANNEL_NATIVE_SIGBRIDGE (1ULL << 37)

#define FTDM_CHANNEL_SIG_DTMF_DETECTION (1ULL << 38)

#define FTDM_CHANNEL_MAX_FLAG (1ULL << 39)

# 1 "./src/include/private/ftdm_state.h" 1
# 36 "./src/include/private/ftdm_state.h"
#define __FTDM_STATE_H__ 
# 51 "./src/include/private/ftdm_state.h"
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

#define CHANNEL_STATE_STRINGS "DOWN", "HOLD", "SUSPENDED", "DIALTONE", "COLLECT", "RING", "RINGING", "BUSY", "ATTN", "GENRING", "DIALING", "GET_CALLERID", "CALLWAITING", "RESTART", "PROCEED", "PROGRESS", "PROGRESS_MEDIA", "UP", "TRANSFER", "IDLE", "TERMINATING", "CANCEL", "HANGUP", "HANGUP_COMPLETE", "IN_LOOP", "RESET", "INVALID"

ftdm_channel_state_t ftdm_str2ftdm_channel_state (const char *name); const char * ftdm_channel_state2str (ftdm_channel_state_t type);

typedef struct {
 const char *file;
 const char *func;
 int line;
 ftdm_channel_state_t state;
 ftdm_channel_state_t last_state;
 ftdm_time_t time;
 ftdm_time_t end_time;
} ftdm_state_history_entry_t;

typedef ftdm_status_t (*ftdm_channel_state_processor_t)(ftdm_channel_t *fchan);

ftdm_status_t ftdm_channel_advance_states(ftdm_channel_t *fchan);

ftdm_status_t _ftdm_channel_complete_state(const char *file, const char *function, int line, ftdm_channel_t *fchan);
#define ftdm_channel_complete_state(obj) _ftdm_channel_complete_state(__FILE__, __FTDM_FUNC__, __LINE__, obj)
int ftdm_check_state_all(ftdm_span_t *span, ftdm_channel_state_t state);
# 148 "./src/include/private/ftdm_state.h"
typedef enum {
 FTDM_STATE_STATUS_NEW,
 FTDM_STATE_STATUS_PROCESSED,
 FTDM_STATE_STATUS_COMPLETED,
 FTDM_STATE_STATUS_INVALID
} ftdm_state_status_t;
#define CHANNEL_STATE_STATUS_STRINGS "NEW", "PROCESSED", "COMPLETED", "INVALID"
ftdm_state_status_t ftdm_str2ftdm_state_status (const char *name); const char * ftdm_state_status2str (ftdm_state_status_t type);

typedef enum {
 ZSM_NONE,
 ZSM_UNACCEPTABLE,
 ZSM_ACCEPTABLE
} ftdm_state_map_type_t;

typedef enum {
 ZSD_INBOUND,
 ZSD_OUTBOUND,
} ftdm_state_direction_t;

#define FTDM_MAP_NODE_SIZE 512
#define FTDM_MAP_MAX FTDM_CHANNEL_STATE_INVALID+2

struct ftdm_state_map_node {
 ftdm_state_direction_t direction;
 ftdm_state_map_type_t type;
 ftdm_channel_state_t check_states[FTDM_CHANNEL_STATE_INVALID+2];
 ftdm_channel_state_t states[FTDM_CHANNEL_STATE_INVALID+2];
};
typedef struct ftdm_state_map_node ftdm_state_map_node_t;

struct ftdm_state_map {
 ftdm_state_map_node_t nodes[512];
};
typedef struct ftdm_state_map ftdm_state_map_t;

ftdm_status_t ftdm_channel_cancel_state(const char *file, const char *func, int line,
  ftdm_channel_t *ftdmchan);

ftdm_status_t ftdm_channel_set_state(const char *file, const char *func, int line,
  ftdm_channel_t *ftdmchan, ftdm_channel_state_t state, int wait, ftdm_usrmsg_t *usrmsg);

ftdm_status_t _ftdm_set_state(const char *file, const char *func, int line,
   ftdm_channel_t *fchan, ftdm_channel_state_t state);
#define ftdm_set_state(obj,s) _ftdm_set_state(__FILE__, __FTDM_FUNC__, __LINE__, obj, s);

#define ftdm_set_state_locked(obj,s) do { ftdm_channel_lock(obj); ftdm_channel_set_state(__FILE__, __FTDM_FUNC__, __LINE__, obj, s, 0, NULL); ftdm_channel_unlock(obj); } while(0);

#define ftdm_set_state_r(obj,s,r) r = ftdm_channel_set_state(__FILE__, __FTDM_FUNC__, __LINE__, obj, s, 0);

#define ftdm_set_state_all(span,state) do { uint32_t _j; ftdm_mutex_lock((span)->mutex); for(_j = 1; _j <= (span)->chan_count; _j++) { if (!FTDM_IS_DCHAN(span->channels[_j])) { ftdm_set_state_locked((span->channels[_j]), state); } } ftdm_mutex_unlock((span)->mutex); } while (0);

typedef enum ftdm_channel_hw_link_status {
 FTDM_HW_LINK_DISCONNECTED = 0,
 FTDM_HW_LINK_CONNECTED
} ftdm_channel_hw_link_status_t;

typedef ftdm_status_t (*ftdm_stream_handle_raw_write_function_t) (ftdm_stream_handle_t *handle, uint8_t *data, ftdm_size_t datalen);
typedef ftdm_status_t (*ftdm_stream_handle_write_function_t) (ftdm_stream_handle_t *handle, const char *fmt, ...);

# 1 "./src/include/ftdm_dso.h" 1
# 23 "./src/include/ftdm_dso.h"
#define _FTDM_DSO_H 

typedef void (*ftdm_func_ptr_t) (void);
typedef void * ftdm_dso_lib_t;

ftdm_status_t ftdm_dso_destroy(ftdm_dso_lib_t *lib);
ftdm_dso_lib_t ftdm_dso_open(const char *path, char **err);
void * ftdm_dso_func_sym(ftdm_dso_lib_t lib, const char *sym, char **err);
char * ftdm_build_dso_path(const char *name, char *path, ftdm_size_t len);

#define FTDM_NODE_NAME_SIZE 50
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
typedef int (*ftdm_fsk_data_decoder_t)(ftdm_fsk_data_state_t *state);
typedef ftdm_status_t (*ftdm_fsk_write_sample_t)(int16_t *buf, ftdm_size_t buflen, void *user_data);
typedef struct hashtable ftdm_hash_t;
typedef struct hashtable_iterator ftdm_hash_iterator_t;
typedef struct key ftdm_hash_key_t;
typedef struct value ftdm_hash_val_t;
typedef struct ftdm_bitstream ftdm_bitstream_t;
typedef struct ftdm_fsk_modulator ftdm_fsk_modulator_t;
typedef ftdm_status_t (*ftdm_span_start_t)(ftdm_span_t *span);
typedef ftdm_status_t (*ftdm_span_stop_t)(ftdm_span_t *span);
typedef ftdm_status_t (*ftdm_span_destroy_t)(ftdm_span_t *span);
typedef ftdm_status_t (*ftdm_channel_sig_read_t)(ftdm_channel_t *ftdmchan, void *data, ftdm_size_t size);
typedef ftdm_status_t (*ftdm_channel_sig_write_t)(ftdm_channel_t *ftdmchan, void *data, ftdm_size_t size);
typedef ftdm_status_t (*ftdm_channel_sig_dtmf_t)(ftdm_channel_t *ftdmchan, const char *dtmf);

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
# 1 "./src/include/private/hashtable.h" 1

#define __HASHTABLE_CWC22_H__ 
# 15 "./src/include/private/hashtable.h"
struct hashtable;
struct hashtable_iterator;
# 84 "./src/include/private/hashtable.h"
struct hashtable *
create_hashtable(unsigned int minsize,
                 unsigned int (*hashfunction) (void*),
                 int (*key_eq_fn) (void*,void*));
# 109 "./src/include/private/hashtable.h"
typedef enum {
 HASHTABLE_FLAG_NONE = 0,
 HASHTABLE_FLAG_FREE_KEY = (1 << 0),
 HASHTABLE_FLAG_FREE_VALUE = (1 << 1)
} hashtable_flag_t;

int
hashtable_insert(struct hashtable *h, void *k, void *v, hashtable_flag_t flags);

#define DEFINE_HASHTABLE_INSERT(fnname,keytype,valuetype) int fnname (struct hashtable *h, keytype *k, valuetype *v) { return hashtable_insert(h,k,v); }
# 133 "./src/include/private/hashtable.h"
void *
hashtable_search(struct hashtable *h, void *k);

#define DEFINE_HASHTABLE_SEARCH(fnname,keytype,valuetype) valuetype * fnname (struct hashtable *h, keytype *k) { return (valuetype *) (hashtable_search(h,k)); }
# 151 "./src/include/private/hashtable.h"
void *
hashtable_remove(struct hashtable *h, void *k);

#define DEFINE_HASHTABLE_REMOVE(fnname,keytype,valuetype) valuetype * fnname (struct hashtable *h, keytype *k) { return (valuetype *) (hashtable_remove(h,k)); }
# 168 "./src/include/private/hashtable.h"
unsigned int
hashtable_count(struct hashtable *h);
# 180 "./src/include/private/hashtable.h"
void
hashtable_destroy(struct hashtable *h);

struct hashtable_iterator* hashtable_first(struct hashtable *h);
struct hashtable_iterator* hashtable_next(struct hashtable_iterator *i);
void hashtable_this(struct hashtable_iterator *i, const void **key, int *klen, void **val);
# 1 "./src/include/private/ftdm_config.h" 1
# 53 "./src/include/private/ftdm_config.h"
#define FTDM_CONFIG_H 

#define FTDM_URL_SEPARATOR "://"
# 66 "./src/include/private/ftdm_config.h"
#define FTDM_PATH_SEPARATOR "/"

#define ftdm_is_file_path(file) ((*file == '/') || strstr(file, SWITCH_URL_SEPARATOR))

typedef struct ftdm_config ftdm_config_t;

struct ftdm_config {

 FILE *file;

 char path[512];

 char category[256];

 char section[256];

 char buf[1024];

 int lineno;

 int catno;

 int sectno;

 int lockto;
};

int ftdm_config_open_file(ftdm_config_t * cfg, const char *file_path);

void ftdm_config_close_file(ftdm_config_t * cfg);

int ftdm_config_next_pair(ftdm_config_t * cfg, char **var, char **val);

int ftdm_config_get_cas_bits(char *strvalue, unsigned char *outbits);
# 1 "./src/include/private/g711.h" 1
# 43 "./src/include/private/g711.h"
#define _G711_H_ 
# 92 "./src/include/private/g711.h"
 static __inline__ int top_bit(unsigned int bits)
 {
  int res;

  __asm__ __volatile__(" movq $-1,%%rdx;\n"
        " bsrq %%rax,%%rdx;\n"
        : "=d" (res)
        : "a" (bits));
  return res;
 }

 static __inline__ int bottom_bit(unsigned int bits)
 {
  int res;

  __asm__ __volatile__(" movq $-1,%%rdx;\n"
        " bsfq %%rax,%%rdx;\n"
        : "=d" (res)
        : "a" (bits));
  return res;
 }
# 227 "./src/include/private/g711.h"
#define ULAW_BIAS 0x84

 static __inline__ uint8_t linear_to_ulaw(int linear)
 {
  uint8_t u_val;
  int mask;
  int seg;

  if (linear < 0)
   {
    linear = 0x84 - linear;
    mask = 0x7F;
   }
  else
   {
    linear = 0x84 + linear;
    mask = 0xFF;
   }

  seg = top_bit(linear | 0xFF) - 7;

  if (seg >= 8)
   u_val = (uint8_t) (0x7F ^ mask);
  else
   u_val = (uint8_t) (((seg << 4) | ((linear >> (seg + 3)) & 0xF)) ^ mask);

  return u_val;
 }

 static __inline__ int16_t ulaw_to_linear(uint8_t ulaw)
 {
  int t;

  ulaw = ~ulaw;

  t = (((ulaw & 0x0F) << 3) + 0x84) << (((int) ulaw & 0x70) >> 4);
  return (int16_t) ((ulaw & 0x80) ? (0x84 - t) : (t - 0x84));
 }
# 307 "./src/include/private/g711.h"
#define ALAW_AMI_MASK 0x55

 static __inline__ uint8_t linear_to_alaw(int linear)
 {
  int mask;
  int seg;

  if (linear >= 0)
   {

    mask = 0x55 | 0x80;
   }
  else
   {

    mask = 0x55;
    linear = -linear - 8;
   }

  seg = top_bit(linear | 0xFF) - 7;
  if (seg >= 8)
   {
    if (linear >= 0)
     {

      return (uint8_t) (0x7F ^ mask);
     }

    return (uint8_t) (0x00 ^ mask);
   }

  return (uint8_t) (((seg << 4) | ((linear >> ((seg) ? (seg + 3) : 4)) & 0x0F)) ^ mask);
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
#define LIBTELETONE_H 

# 1 "/usr/include/math.h" 1 3 4
# 24 "/usr/include/math.h" 3 4
#define _MATH_H 1

#define __GLIBC_INTERNAL_STARTING_HEADER_IMPLEMENTATION 
# 1 "/usr/include/x86_64-linux-gnu/bits/libc-header-start.h" 1 3 4
# 31 "/usr/include/x86_64-linux-gnu/bits/libc-header-start.h" 3 4
#undef __GLIBC_INTERNAL_STARTING_HEADER_IMPLEMENTATION

#undef __GLIBC_USE_LIB_EXT2

#define __GLIBC_USE_LIB_EXT2 0

#undef __GLIBC_USE_IEC_60559_BFP_EXT

#define __GLIBC_USE_IEC_60559_BFP_EXT 0

#undef __GLIBC_USE_IEC_60559_FUNCS_EXT

#define __GLIBC_USE_IEC_60559_FUNCS_EXT 0

#undef __GLIBC_USE_IEC_60559_TYPES_EXT

#define __GLIBC_USE_IEC_60559_TYPES_EXT 0
# 28 "/usr/include/math.h" 2 3 4

# 1 "/usr/include/x86_64-linux-gnu/bits/math-vector.h" 1 3 4
# 25 "/usr/include/x86_64-linux-gnu/bits/math-vector.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/libm-simd-decl-stubs.h" 1 3 4
# 34 "/usr/include/x86_64-linux-gnu/bits/libm-simd-decl-stubs.h" 3 4
#define _BITS_LIBM_SIMD_DECL_STUBS_H 1

#define __DECL_SIMD_cos 
#define __DECL_SIMD_cosf 
#define __DECL_SIMD_cosl 
#define __DECL_SIMD_cosf16 
#define __DECL_SIMD_cosf32 
#define __DECL_SIMD_cosf64 
#define __DECL_SIMD_cosf128 
#define __DECL_SIMD_cosf32x 
#define __DECL_SIMD_cosf64x 
#define __DECL_SIMD_cosf128x 

#define __DECL_SIMD_sin 
#define __DECL_SIMD_sinf 
#define __DECL_SIMD_sinl 
#define __DECL_SIMD_sinf16 
#define __DECL_SIMD_sinf32 
#define __DECL_SIMD_sinf64 
#define __DECL_SIMD_sinf128 
#define __DECL_SIMD_sinf32x 
#define __DECL_SIMD_sinf64x 
#define __DECL_SIMD_sinf128x 

#define __DECL_SIMD_sincos 
#define __DECL_SIMD_sincosf 
#define __DECL_SIMD_sincosl 
#define __DECL_SIMD_sincosf16 
#define __DECL_SIMD_sincosf32 
#define __DECL_SIMD_sincosf64 
#define __DECL_SIMD_sincosf128 
#define __DECL_SIMD_sincosf32x 
#define __DECL_SIMD_sincosf64x 
#define __DECL_SIMD_sincosf128x 

#define __DECL_SIMD_log 
#define __DECL_SIMD_logf 
#define __DECL_SIMD_logl 
#define __DECL_SIMD_logf16 
#define __DECL_SIMD_logf32 
#define __DECL_SIMD_logf64 
#define __DECL_SIMD_logf128 
#define __DECL_SIMD_logf32x 
#define __DECL_SIMD_logf64x 
#define __DECL_SIMD_logf128x 

#define __DECL_SIMD_exp 
#define __DECL_SIMD_expf 
#define __DECL_SIMD_expl 
#define __DECL_SIMD_expf16 
#define __DECL_SIMD_expf32 
#define __DECL_SIMD_expf64 
#define __DECL_SIMD_expf128 
#define __DECL_SIMD_expf32x 
#define __DECL_SIMD_expf64x 
#define __DECL_SIMD_expf128x 

#define __DECL_SIMD_pow 
#define __DECL_SIMD_powf 
#define __DECL_SIMD_powl 
#define __DECL_SIMD_powf16 
#define __DECL_SIMD_powf32 
#define __DECL_SIMD_powf64 
#define __DECL_SIMD_powf128 
#define __DECL_SIMD_powf32x 
#define __DECL_SIMD_powf64x 
#define __DECL_SIMD_powf128x 
# 26 "/usr/include/x86_64-linux-gnu/bits/math-vector.h" 2 3 4

#define __DECL_SIMD_x86_64 __attribute__ ((__simd__ ("notinbranch")))

#undef __DECL_SIMD_cos
#define __DECL_SIMD_cos __DECL_SIMD_x86_64
#undef __DECL_SIMD_cosf
#define __DECL_SIMD_cosf __DECL_SIMD_x86_64
#undef __DECL_SIMD_sin
#define __DECL_SIMD_sin __DECL_SIMD_x86_64
#undef __DECL_SIMD_sinf
#define __DECL_SIMD_sinf __DECL_SIMD_x86_64
#undef __DECL_SIMD_sincos
#define __DECL_SIMD_sincos __DECL_SIMD_x86_64
#undef __DECL_SIMD_sincosf
#define __DECL_SIMD_sincosf __DECL_SIMD_x86_64
#undef __DECL_SIMD_log
#define __DECL_SIMD_log __DECL_SIMD_x86_64
#undef __DECL_SIMD_logf
#define __DECL_SIMD_logf __DECL_SIMD_x86_64
#undef __DECL_SIMD_exp
#define __DECL_SIMD_exp __DECL_SIMD_x86_64
#undef __DECL_SIMD_expf
#define __DECL_SIMD_expf __DECL_SIMD_x86_64
#undef __DECL_SIMD_pow
#define __DECL_SIMD_pow __DECL_SIMD_x86_64
#undef __DECL_SIMD_powf
#define __DECL_SIMD_powf __DECL_SIMD_x86_64
# 41 "/usr/include/math.h" 2 3 4

#define HUGE_VAL (__builtin_huge_val ())
# 59 "/usr/include/math.h" 3 4
#define HUGE_VALF (__builtin_huge_valf ())
#define HUGE_VALL (__builtin_huge_vall ())
# 91 "/usr/include/math.h" 3 4
#define INFINITY (__builtin_inff ())

#define NAN (__builtin_nanf (""))
# 138 "/usr/include/math.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/flt-eval-method.h" 1 3 4
# 27 "/usr/include/x86_64-linux-gnu/bits/flt-eval-method.h" 3 4
#define __GLIBC_FLT_EVAL_METHOD __FLT_EVAL_METHOD__
# 139 "/usr/include/math.h" 2 3 4
# 149 "/usr/include/math.h" 3 4

# 149 "/usr/include/math.h" 3 4
typedef float float_t;
typedef double double_t;
# 190 "/usr/include/math.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/fp-logb.h" 1 3 4
# 23 "/usr/include/x86_64-linux-gnu/bits/fp-logb.h" 3 4
#define __FP_LOGB0_IS_MIN 1
#define __FP_LOGBNAN_IS_MIN 1
# 191 "/usr/include/math.h" 2 3 4

#define FP_ILOGB0 (-2147483647 - 1)

#define FP_ILOGBNAN (-2147483647 - 1)
# 233 "/usr/include/math.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/fp-fast.h" 1 3 4
# 234 "/usr/include/math.h" 2 3 4
# 262 "/usr/include/math.h" 3 4
#define __SIMD_DECL(function) __CONCAT (__DECL_SIMD_, function)

#define __MATHCALL_VEC(function,suffix,args) __SIMD_DECL (__MATH_PRECNAME (function, suffix)) __MATHCALL (function, suffix, args)

#define __MATHDECL_VEC(type,function,suffix,args) __SIMD_DECL (__MATH_PRECNAME (function, suffix)) __MATHDECL(type, function,suffix, args)

#define __MATHCALL(function,suffix,args) __MATHDECL (_Mdouble_,function,suffix, args)

#define __MATHDECL(type,function,suffix,args) __MATHDECL_1(type, function,suffix, args); __MATHDECL_1(type, __CONCAT(__,function),suffix, args)

#define __MATHCALLX(function,suffix,args,attrib) __MATHDECLX (_Mdouble_,function,suffix, args, attrib)

#define __MATHDECLX(type,function,suffix,args,attrib) __MATHDECL_1(type, function,suffix, args) __attribute__ (attrib); __MATHDECL_1(type, __CONCAT(__,function),suffix, args) __attribute__ (attrib)

#define __MATHDECL_1(type,function,suffix,args) extern type __MATH_PRECNAME(function,suffix) args __THROW

#define _Mdouble_ double
#define __MATH_PRECNAME(name,r) __CONCAT(name,r)
#define __MATH_DECLARING_DOUBLE 1
#define __MATH_DECLARING_FLOATN 0
# 1 "/usr/include/x86_64-linux-gnu/bits/mathcalls-helper-functions.h" 1 3 4
# 21 "/usr/include/x86_64-linux-gnu/bits/mathcalls-helper-functions.h" 3 4
extern int __fpclassify (double __value) __attribute__ ((__nothrow__ , __leaf__))
     __attribute__ ((__const__));

extern int __signbit (double __value) __attribute__ ((__nothrow__ , __leaf__))
     __attribute__ ((__const__));

extern int __isinf (double __value) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern int __finite (double __value) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern int __isnan (double __value) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern int __iseqsig (double __x, double __y) __attribute__ ((__nothrow__ , __leaf__));

extern int __issignaling (double __value) __attribute__ ((__nothrow__ , __leaf__))
     __attribute__ ((__const__));
# 290 "/usr/include/math.h" 2 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 1 3 4
# 53 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 3 4
extern double acos (double __x) __attribute__ ((__nothrow__ , __leaf__)); extern double __acos (double __x) __attribute__ ((__nothrow__ , __leaf__));

extern double asin (double __x) __attribute__ ((__nothrow__ , __leaf__)); extern double __asin (double __x) __attribute__ ((__nothrow__ , __leaf__));

extern double atan (double __x) __attribute__ ((__nothrow__ , __leaf__)); extern double __atan (double __x) __attribute__ ((__nothrow__ , __leaf__));

extern double atan2 (double __y, double __x) __attribute__ ((__nothrow__ , __leaf__)); extern double __atan2 (double __y, double __x) __attribute__ ((__nothrow__ , __leaf__));

__attribute__ ((__simd__ ("notinbranch"))) extern double cos (double __x) __attribute__ ((__nothrow__ , __leaf__)); extern double __cos (double __x) __attribute__ ((__nothrow__ , __leaf__));

__attribute__ ((__simd__ ("notinbranch"))) extern double sin (double __x) __attribute__ ((__nothrow__ , __leaf__)); extern double __sin (double __x) __attribute__ ((__nothrow__ , __leaf__));

extern double tan (double __x) __attribute__ ((__nothrow__ , __leaf__)); extern double __tan (double __x) __attribute__ ((__nothrow__ , __leaf__));

extern double cosh (double __x) __attribute__ ((__nothrow__ , __leaf__)); extern double __cosh (double __x) __attribute__ ((__nothrow__ , __leaf__));

extern double sinh (double __x) __attribute__ ((__nothrow__ , __leaf__)); extern double __sinh (double __x) __attribute__ ((__nothrow__ , __leaf__));

extern double tanh (double __x) __attribute__ ((__nothrow__ , __leaf__)); extern double __tanh (double __x) __attribute__ ((__nothrow__ , __leaf__));
# 85 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 3 4
extern double acosh (double __x) __attribute__ ((__nothrow__ , __leaf__)); extern double __acosh (double __x) __attribute__ ((__nothrow__ , __leaf__));

extern double asinh (double __x) __attribute__ ((__nothrow__ , __leaf__)); extern double __asinh (double __x) __attribute__ ((__nothrow__ , __leaf__));

extern double atanh (double __x) __attribute__ ((__nothrow__ , __leaf__)); extern double __atanh (double __x) __attribute__ ((__nothrow__ , __leaf__));

__attribute__ ((__simd__ ("notinbranch"))) extern double exp (double __x) __attribute__ ((__nothrow__ , __leaf__)); extern double __exp (double __x) __attribute__ ((__nothrow__ , __leaf__));

extern double frexp (double __x, int *__exponent) __attribute__ ((__nothrow__ , __leaf__)); extern double __frexp (double __x, int *__exponent) __attribute__ ((__nothrow__ , __leaf__));

extern double ldexp (double __x, int __exponent) __attribute__ ((__nothrow__ , __leaf__)); extern double __ldexp (double __x, int __exponent) __attribute__ ((__nothrow__ , __leaf__));

__attribute__ ((__simd__ ("notinbranch"))) extern double log (double __x) __attribute__ ((__nothrow__ , __leaf__)); extern double __log (double __x) __attribute__ ((__nothrow__ , __leaf__));

extern double log10 (double __x) __attribute__ ((__nothrow__ , __leaf__)); extern double __log10 (double __x) __attribute__ ((__nothrow__ , __leaf__));

extern double modf (double __x, double *__iptr) __attribute__ ((__nothrow__ , __leaf__)); extern double __modf (double __x, double *__iptr) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (2)));
# 119 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 3 4
extern double expm1 (double __x) __attribute__ ((__nothrow__ , __leaf__)); extern double __expm1 (double __x) __attribute__ ((__nothrow__ , __leaf__));

extern double log1p (double __x) __attribute__ ((__nothrow__ , __leaf__)); extern double __log1p (double __x) __attribute__ ((__nothrow__ , __leaf__));

extern double logb (double __x) __attribute__ ((__nothrow__ , __leaf__)); extern double __logb (double __x) __attribute__ ((__nothrow__ , __leaf__));

extern double exp2 (double __x) __attribute__ ((__nothrow__ , __leaf__)); extern double __exp2 (double __x) __attribute__ ((__nothrow__ , __leaf__));

extern double log2 (double __x) __attribute__ ((__nothrow__ , __leaf__)); extern double __log2 (double __x) __attribute__ ((__nothrow__ , __leaf__));

__attribute__ ((__simd__ ("notinbranch"))) extern double pow (double __x, double __y) __attribute__ ((__nothrow__ , __leaf__)); extern double __pow (double __x, double __y) __attribute__ ((__nothrow__ , __leaf__));

extern double sqrt (double __x) __attribute__ ((__nothrow__ , __leaf__)); extern double __sqrt (double __x) __attribute__ ((__nothrow__ , __leaf__));

extern double hypot (double __x, double __y) __attribute__ ((__nothrow__ , __leaf__)); extern double __hypot (double __x, double __y) __attribute__ ((__nothrow__ , __leaf__));

extern double cbrt (double __x) __attribute__ ((__nothrow__ , __leaf__)); extern double __cbrt (double __x) __attribute__ ((__nothrow__ , __leaf__));

extern double ceil (double __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__)); extern double __ceil (double __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern double fabs (double __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__)); extern double __fabs (double __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern double floor (double __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__)); extern double __floor (double __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern double fmod (double __x, double __y) __attribute__ ((__nothrow__ , __leaf__)); extern double __fmod (double __x, double __y) __attribute__ ((__nothrow__ , __leaf__));
# 196 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 3 4
extern double copysign (double __x, double __y) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__)); extern double __copysign (double __x, double __y) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern double nan (const char *__tagb) __attribute__ ((__nothrow__ , __leaf__)); extern double __nan (const char *__tagb) __attribute__ ((__nothrow__ , __leaf__));
# 217 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 3 4
extern double j0 (double) __attribute__ ((__nothrow__ , __leaf__)); extern double __j0 (double) __attribute__ ((__nothrow__ , __leaf__));
extern double j1 (double) __attribute__ ((__nothrow__ , __leaf__)); extern double __j1 (double) __attribute__ ((__nothrow__ , __leaf__));
extern double jn (int, double) __attribute__ ((__nothrow__ , __leaf__)); extern double __jn (int, double) __attribute__ ((__nothrow__ , __leaf__));
extern double y0 (double) __attribute__ ((__nothrow__ , __leaf__)); extern double __y0 (double) __attribute__ ((__nothrow__ , __leaf__));
extern double y1 (double) __attribute__ ((__nothrow__ , __leaf__)); extern double __y1 (double) __attribute__ ((__nothrow__ , __leaf__));
extern double yn (int, double) __attribute__ ((__nothrow__ , __leaf__)); extern double __yn (int, double) __attribute__ ((__nothrow__ , __leaf__));

extern double erf (double) __attribute__ ((__nothrow__ , __leaf__)); extern double __erf (double) __attribute__ ((__nothrow__ , __leaf__));
extern double erfc (double) __attribute__ ((__nothrow__ , __leaf__)); extern double __erfc (double) __attribute__ ((__nothrow__ , __leaf__));
extern double lgamma (double) __attribute__ ((__nothrow__ , __leaf__)); extern double __lgamma (double) __attribute__ ((__nothrow__ , __leaf__));

extern double tgamma (double) __attribute__ ((__nothrow__ , __leaf__)); extern double __tgamma (double) __attribute__ ((__nothrow__ , __leaf__));
# 256 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 3 4
extern double rint (double __x) __attribute__ ((__nothrow__ , __leaf__)); extern double __rint (double __x) __attribute__ ((__nothrow__ , __leaf__));

extern double nextafter (double __x, double __y) __attribute__ ((__nothrow__ , __leaf__)); extern double __nextafter (double __x, double __y) __attribute__ ((__nothrow__ , __leaf__));

extern double nexttoward (double __x, long double __y) __attribute__ ((__nothrow__ , __leaf__)); extern double __nexttoward (double __x, long double __y) __attribute__ ((__nothrow__ , __leaf__));
# 272 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 3 4
extern double remainder (double __x, double __y) __attribute__ ((__nothrow__ , __leaf__)); extern double __remainder (double __x, double __y) __attribute__ ((__nothrow__ , __leaf__));

extern double scalbn (double __x, int __n) __attribute__ ((__nothrow__ , __leaf__)); extern double __scalbn (double __x, int __n) __attribute__ ((__nothrow__ , __leaf__));

extern int ilogb (double __x) __attribute__ ((__nothrow__ , __leaf__)); extern int __ilogb (double __x) __attribute__ ((__nothrow__ , __leaf__));
# 290 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 3 4
extern double scalbln (double __x, long int __n) __attribute__ ((__nothrow__ , __leaf__)); extern double __scalbln (double __x, long int __n) __attribute__ ((__nothrow__ , __leaf__));

extern double nearbyint (double __x) __attribute__ ((__nothrow__ , __leaf__)); extern double __nearbyint (double __x) __attribute__ ((__nothrow__ , __leaf__));

extern double round (double __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__)); extern double __round (double __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern double trunc (double __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__)); extern double __trunc (double __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern double remquo (double __x, double __y, int *__quo) __attribute__ ((__nothrow__ , __leaf__)); extern double __remquo (double __x, double __y, int *__quo) __attribute__ ((__nothrow__ , __leaf__));

extern long int lrint (double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long int __lrint (double __x) __attribute__ ((__nothrow__ , __leaf__));
__extension__
extern long long int llrint (double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long long int __llrint (double __x) __attribute__ ((__nothrow__ , __leaf__));

extern long int lround (double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long int __lround (double __x) __attribute__ ((__nothrow__ , __leaf__));
__extension__
extern long long int llround (double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long long int __llround (double __x) __attribute__ ((__nothrow__ , __leaf__));

extern double fdim (double __x, double __y) __attribute__ ((__nothrow__ , __leaf__)); extern double __fdim (double __x, double __y) __attribute__ ((__nothrow__ , __leaf__));

extern double fmax (double __x, double __y) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__)); extern double __fmax (double __x, double __y) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern double fmin (double __x, double __y) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__)); extern double __fmin (double __x, double __y) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern double fma (double __x, double __y, double __z) __attribute__ ((__nothrow__ , __leaf__)); extern double __fma (double __x, double __y, double __z) __attribute__ ((__nothrow__ , __leaf__));
# 396 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 3 4
extern double scalb (double __x, double __n) __attribute__ ((__nothrow__ , __leaf__)); extern double __scalb (double __x, double __n) __attribute__ ((__nothrow__ , __leaf__));
# 291 "/usr/include/math.h" 2 3 4
#undef _Mdouble_
#undef __MATH_PRECNAME
#undef __MATH_DECLARING_DOUBLE
#undef __MATH_DECLARING_FLOATN

#define _Mdouble_ float
#define __MATH_PRECNAME(name,r) name ##f ##r
#define __MATH_DECLARING_DOUBLE 0
#define __MATH_DECLARING_FLOATN 0
# 1 "/usr/include/x86_64-linux-gnu/bits/mathcalls-helper-functions.h" 1 3 4
# 21 "/usr/include/x86_64-linux-gnu/bits/mathcalls-helper-functions.h" 3 4
extern int __fpclassifyf (float __value) __attribute__ ((__nothrow__ , __leaf__))
     __attribute__ ((__const__));

extern int __signbitf (float __value) __attribute__ ((__nothrow__ , __leaf__))
     __attribute__ ((__const__));

extern int __isinff (float __value) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern int __finitef (float __value) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern int __isnanf (float __value) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern int __iseqsigf (float __x, float __y) __attribute__ ((__nothrow__ , __leaf__));

extern int __issignalingf (float __value) __attribute__ ((__nothrow__ , __leaf__))
     __attribute__ ((__const__));
# 307 "/usr/include/math.h" 2 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 1 3 4
# 53 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 3 4
extern float acosf (float __x) __attribute__ ((__nothrow__ , __leaf__)); extern float __acosf (float __x) __attribute__ ((__nothrow__ , __leaf__));

extern float asinf (float __x) __attribute__ ((__nothrow__ , __leaf__)); extern float __asinf (float __x) __attribute__ ((__nothrow__ , __leaf__));

extern float atanf (float __x) __attribute__ ((__nothrow__ , __leaf__)); extern float __atanf (float __x) __attribute__ ((__nothrow__ , __leaf__));

extern float atan2f (float __y, float __x) __attribute__ ((__nothrow__ , __leaf__)); extern float __atan2f (float __y, float __x) __attribute__ ((__nothrow__ , __leaf__));

__attribute__ ((__simd__ ("notinbranch"))) extern float cosf (float __x) __attribute__ ((__nothrow__ , __leaf__)); extern float __cosf (float __x) __attribute__ ((__nothrow__ , __leaf__));

__attribute__ ((__simd__ ("notinbranch"))) extern float sinf (float __x) __attribute__ ((__nothrow__ , __leaf__)); extern float __sinf (float __x) __attribute__ ((__nothrow__ , __leaf__));

extern float tanf (float __x) __attribute__ ((__nothrow__ , __leaf__)); extern float __tanf (float __x) __attribute__ ((__nothrow__ , __leaf__));

extern float coshf (float __x) __attribute__ ((__nothrow__ , __leaf__)); extern float __coshf (float __x) __attribute__ ((__nothrow__ , __leaf__));

extern float sinhf (float __x) __attribute__ ((__nothrow__ , __leaf__)); extern float __sinhf (float __x) __attribute__ ((__nothrow__ , __leaf__));

extern float tanhf (float __x) __attribute__ ((__nothrow__ , __leaf__)); extern float __tanhf (float __x) __attribute__ ((__nothrow__ , __leaf__));
# 85 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 3 4
extern float acoshf (float __x) __attribute__ ((__nothrow__ , __leaf__)); extern float __acoshf (float __x) __attribute__ ((__nothrow__ , __leaf__));

extern float asinhf (float __x) __attribute__ ((__nothrow__ , __leaf__)); extern float __asinhf (float __x) __attribute__ ((__nothrow__ , __leaf__));

extern float atanhf (float __x) __attribute__ ((__nothrow__ , __leaf__)); extern float __atanhf (float __x) __attribute__ ((__nothrow__ , __leaf__));

__attribute__ ((__simd__ ("notinbranch"))) extern float expf (float __x) __attribute__ ((__nothrow__ , __leaf__)); extern float __expf (float __x) __attribute__ ((__nothrow__ , __leaf__));

extern float frexpf (float __x, int *__exponent) __attribute__ ((__nothrow__ , __leaf__)); extern float __frexpf (float __x, int *__exponent) __attribute__ ((__nothrow__ , __leaf__));

extern float ldexpf (float __x, int __exponent) __attribute__ ((__nothrow__ , __leaf__)); extern float __ldexpf (float __x, int __exponent) __attribute__ ((__nothrow__ , __leaf__));

__attribute__ ((__simd__ ("notinbranch"))) extern float logf (float __x) __attribute__ ((__nothrow__ , __leaf__)); extern float __logf (float __x) __attribute__ ((__nothrow__ , __leaf__));

extern float log10f (float __x) __attribute__ ((__nothrow__ , __leaf__)); extern float __log10f (float __x) __attribute__ ((__nothrow__ , __leaf__));

extern float modff (float __x, float *__iptr) __attribute__ ((__nothrow__ , __leaf__)); extern float __modff (float __x, float *__iptr) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (2)));
# 119 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 3 4
extern float expm1f (float __x) __attribute__ ((__nothrow__ , __leaf__)); extern float __expm1f (float __x) __attribute__ ((__nothrow__ , __leaf__));

extern float log1pf (float __x) __attribute__ ((__nothrow__ , __leaf__)); extern float __log1pf (float __x) __attribute__ ((__nothrow__ , __leaf__));

extern float logbf (float __x) __attribute__ ((__nothrow__ , __leaf__)); extern float __logbf (float __x) __attribute__ ((__nothrow__ , __leaf__));

extern float exp2f (float __x) __attribute__ ((__nothrow__ , __leaf__)); extern float __exp2f (float __x) __attribute__ ((__nothrow__ , __leaf__));

extern float log2f (float __x) __attribute__ ((__nothrow__ , __leaf__)); extern float __log2f (float __x) __attribute__ ((__nothrow__ , __leaf__));

__attribute__ ((__simd__ ("notinbranch"))) extern float powf (float __x, float __y) __attribute__ ((__nothrow__ , __leaf__)); extern float __powf (float __x, float __y) __attribute__ ((__nothrow__ , __leaf__));

extern float sqrtf (float __x) __attribute__ ((__nothrow__ , __leaf__)); extern float __sqrtf (float __x) __attribute__ ((__nothrow__ , __leaf__));

extern float hypotf (float __x, float __y) __attribute__ ((__nothrow__ , __leaf__)); extern float __hypotf (float __x, float __y) __attribute__ ((__nothrow__ , __leaf__));

extern float cbrtf (float __x) __attribute__ ((__nothrow__ , __leaf__)); extern float __cbrtf (float __x) __attribute__ ((__nothrow__ , __leaf__));

extern float ceilf (float __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__)); extern float __ceilf (float __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern float fabsf (float __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__)); extern float __fabsf (float __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern float floorf (float __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__)); extern float __floorf (float __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern float fmodf (float __x, float __y) __attribute__ ((__nothrow__ , __leaf__)); extern float __fmodf (float __x, float __y) __attribute__ ((__nothrow__ , __leaf__));
# 196 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 3 4
extern float copysignf (float __x, float __y) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__)); extern float __copysignf (float __x, float __y) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern float nanf (const char *__tagb) __attribute__ ((__nothrow__ , __leaf__)); extern float __nanf (const char *__tagb) __attribute__ ((__nothrow__ , __leaf__));
# 228 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 3 4
extern float erff (float) __attribute__ ((__nothrow__ , __leaf__)); extern float __erff (float) __attribute__ ((__nothrow__ , __leaf__));
extern float erfcf (float) __attribute__ ((__nothrow__ , __leaf__)); extern float __erfcf (float) __attribute__ ((__nothrow__ , __leaf__));
extern float lgammaf (float) __attribute__ ((__nothrow__ , __leaf__)); extern float __lgammaf (float) __attribute__ ((__nothrow__ , __leaf__));

extern float tgammaf (float) __attribute__ ((__nothrow__ , __leaf__)); extern float __tgammaf (float) __attribute__ ((__nothrow__ , __leaf__));
# 256 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 3 4
extern float rintf (float __x) __attribute__ ((__nothrow__ , __leaf__)); extern float __rintf (float __x) __attribute__ ((__nothrow__ , __leaf__));

extern float nextafterf (float __x, float __y) __attribute__ ((__nothrow__ , __leaf__)); extern float __nextafterf (float __x, float __y) __attribute__ ((__nothrow__ , __leaf__));

extern float nexttowardf (float __x, long double __y) __attribute__ ((__nothrow__ , __leaf__)); extern float __nexttowardf (float __x, long double __y) __attribute__ ((__nothrow__ , __leaf__));
# 272 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 3 4
extern float remainderf (float __x, float __y) __attribute__ ((__nothrow__ , __leaf__)); extern float __remainderf (float __x, float __y) __attribute__ ((__nothrow__ , __leaf__));

extern float scalbnf (float __x, int __n) __attribute__ ((__nothrow__ , __leaf__)); extern float __scalbnf (float __x, int __n) __attribute__ ((__nothrow__ , __leaf__));

extern int ilogbf (float __x) __attribute__ ((__nothrow__ , __leaf__)); extern int __ilogbf (float __x) __attribute__ ((__nothrow__ , __leaf__));
# 290 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 3 4
extern float scalblnf (float __x, long int __n) __attribute__ ((__nothrow__ , __leaf__)); extern float __scalblnf (float __x, long int __n) __attribute__ ((__nothrow__ , __leaf__));

extern float nearbyintf (float __x) __attribute__ ((__nothrow__ , __leaf__)); extern float __nearbyintf (float __x) __attribute__ ((__nothrow__ , __leaf__));

extern float roundf (float __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__)); extern float __roundf (float __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern float truncf (float __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__)); extern float __truncf (float __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern float remquof (float __x, float __y, int *__quo) __attribute__ ((__nothrow__ , __leaf__)); extern float __remquof (float __x, float __y, int *__quo) __attribute__ ((__nothrow__ , __leaf__));

extern long int lrintf (float __x) __attribute__ ((__nothrow__ , __leaf__)); extern long int __lrintf (float __x) __attribute__ ((__nothrow__ , __leaf__));
__extension__
extern long long int llrintf (float __x) __attribute__ ((__nothrow__ , __leaf__)); extern long long int __llrintf (float __x) __attribute__ ((__nothrow__ , __leaf__));

extern long int lroundf (float __x) __attribute__ ((__nothrow__ , __leaf__)); extern long int __lroundf (float __x) __attribute__ ((__nothrow__ , __leaf__));
__extension__
extern long long int llroundf (float __x) __attribute__ ((__nothrow__ , __leaf__)); extern long long int __llroundf (float __x) __attribute__ ((__nothrow__ , __leaf__));

extern float fdimf (float __x, float __y) __attribute__ ((__nothrow__ , __leaf__)); extern float __fdimf (float __x, float __y) __attribute__ ((__nothrow__ , __leaf__));

extern float fmaxf (float __x, float __y) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__)); extern float __fmaxf (float __x, float __y) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern float fminf (float __x, float __y) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__)); extern float __fminf (float __x, float __y) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern float fmaf (float __x, float __y, float __z) __attribute__ ((__nothrow__ , __leaf__)); extern float __fmaf (float __x, float __y, float __z) __attribute__ ((__nothrow__ , __leaf__));
# 308 "/usr/include/math.h" 2 3 4
#undef _Mdouble_
#undef __MATH_PRECNAME
#undef __MATH_DECLARING_DOUBLE
#undef __MATH_DECLARING_FLOATN
# 344 "/usr/include/math.h" 3 4
#define _Mdouble_ long double
#define __MATH_PRECNAME(name,r) name ##l ##r
#define __MATH_DECLARING_DOUBLE 0
#define __MATH_DECLARING_FLOATN 0
#define __MATH_DECLARE_LDOUBLE 1
# 1 "/usr/include/x86_64-linux-gnu/bits/mathcalls-helper-functions.h" 1 3 4
# 21 "/usr/include/x86_64-linux-gnu/bits/mathcalls-helper-functions.h" 3 4
extern int __fpclassifyl (long double __value) __attribute__ ((__nothrow__ , __leaf__))
     __attribute__ ((__const__));

extern int __signbitl (long double __value) __attribute__ ((__nothrow__ , __leaf__))
     __attribute__ ((__const__));

extern int __isinfl (long double __value) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern int __finitel (long double __value) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern int __isnanl (long double __value) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern int __iseqsigl (long double __x, long double __y) __attribute__ ((__nothrow__ , __leaf__));

extern int __issignalingl (long double __value) __attribute__ ((__nothrow__ , __leaf__))
     __attribute__ ((__const__));
# 350 "/usr/include/math.h" 2 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 1 3 4
# 53 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 3 4
extern long double acosl (long double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long double __acosl (long double __x) __attribute__ ((__nothrow__ , __leaf__));

extern long double asinl (long double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long double __asinl (long double __x) __attribute__ ((__nothrow__ , __leaf__));

extern long double atanl (long double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long double __atanl (long double __x) __attribute__ ((__nothrow__ , __leaf__));

extern long double atan2l (long double __y, long double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long double __atan2l (long double __y, long double __x) __attribute__ ((__nothrow__ , __leaf__));

 extern long double cosl (long double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long double __cosl (long double __x) __attribute__ ((__nothrow__ , __leaf__));

 extern long double sinl (long double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long double __sinl (long double __x) __attribute__ ((__nothrow__ , __leaf__));

extern long double tanl (long double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long double __tanl (long double __x) __attribute__ ((__nothrow__ , __leaf__));

extern long double coshl (long double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long double __coshl (long double __x) __attribute__ ((__nothrow__ , __leaf__));

extern long double sinhl (long double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long double __sinhl (long double __x) __attribute__ ((__nothrow__ , __leaf__));

extern long double tanhl (long double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long double __tanhl (long double __x) __attribute__ ((__nothrow__ , __leaf__));
# 85 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 3 4
extern long double acoshl (long double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long double __acoshl (long double __x) __attribute__ ((__nothrow__ , __leaf__));

extern long double asinhl (long double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long double __asinhl (long double __x) __attribute__ ((__nothrow__ , __leaf__));

extern long double atanhl (long double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long double __atanhl (long double __x) __attribute__ ((__nothrow__ , __leaf__));

 extern long double expl (long double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long double __expl (long double __x) __attribute__ ((__nothrow__ , __leaf__));

extern long double frexpl (long double __x, int *__exponent) __attribute__ ((__nothrow__ , __leaf__)); extern long double __frexpl (long double __x, int *__exponent) __attribute__ ((__nothrow__ , __leaf__));

extern long double ldexpl (long double __x, int __exponent) __attribute__ ((__nothrow__ , __leaf__)); extern long double __ldexpl (long double __x, int __exponent) __attribute__ ((__nothrow__ , __leaf__));

 extern long double logl (long double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long double __logl (long double __x) __attribute__ ((__nothrow__ , __leaf__));

extern long double log10l (long double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long double __log10l (long double __x) __attribute__ ((__nothrow__ , __leaf__));

extern long double modfl (long double __x, long double *__iptr) __attribute__ ((__nothrow__ , __leaf__)); extern long double __modfl (long double __x, long double *__iptr) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (2)));
# 119 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 3 4
extern long double expm1l (long double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long double __expm1l (long double __x) __attribute__ ((__nothrow__ , __leaf__));

extern long double log1pl (long double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long double __log1pl (long double __x) __attribute__ ((__nothrow__ , __leaf__));

extern long double logbl (long double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long double __logbl (long double __x) __attribute__ ((__nothrow__ , __leaf__));

extern long double exp2l (long double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long double __exp2l (long double __x) __attribute__ ((__nothrow__ , __leaf__));

extern long double log2l (long double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long double __log2l (long double __x) __attribute__ ((__nothrow__ , __leaf__));

 extern long double powl (long double __x, long double __y) __attribute__ ((__nothrow__ , __leaf__)); extern long double __powl (long double __x, long double __y) __attribute__ ((__nothrow__ , __leaf__));

extern long double sqrtl (long double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long double __sqrtl (long double __x) __attribute__ ((__nothrow__ , __leaf__));

extern long double hypotl (long double __x, long double __y) __attribute__ ((__nothrow__ , __leaf__)); extern long double __hypotl (long double __x, long double __y) __attribute__ ((__nothrow__ , __leaf__));

extern long double cbrtl (long double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long double __cbrtl (long double __x) __attribute__ ((__nothrow__ , __leaf__));

extern long double ceill (long double __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__)); extern long double __ceill (long double __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern long double fabsl (long double __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__)); extern long double __fabsl (long double __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern long double floorl (long double __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__)); extern long double __floorl (long double __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern long double fmodl (long double __x, long double __y) __attribute__ ((__nothrow__ , __leaf__)); extern long double __fmodl (long double __x, long double __y) __attribute__ ((__nothrow__ , __leaf__));
# 196 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 3 4
extern long double copysignl (long double __x, long double __y) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__)); extern long double __copysignl (long double __x, long double __y) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern long double nanl (const char *__tagb) __attribute__ ((__nothrow__ , __leaf__)); extern long double __nanl (const char *__tagb) __attribute__ ((__nothrow__ , __leaf__));
# 228 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 3 4
extern long double erfl (long double) __attribute__ ((__nothrow__ , __leaf__)); extern long double __erfl (long double) __attribute__ ((__nothrow__ , __leaf__));
extern long double erfcl (long double) __attribute__ ((__nothrow__ , __leaf__)); extern long double __erfcl (long double) __attribute__ ((__nothrow__ , __leaf__));
extern long double lgammal (long double) __attribute__ ((__nothrow__ , __leaf__)); extern long double __lgammal (long double) __attribute__ ((__nothrow__ , __leaf__));

extern long double tgammal (long double) __attribute__ ((__nothrow__ , __leaf__)); extern long double __tgammal (long double) __attribute__ ((__nothrow__ , __leaf__));
# 256 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 3 4
extern long double rintl (long double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long double __rintl (long double __x) __attribute__ ((__nothrow__ , __leaf__));

extern long double nextafterl (long double __x, long double __y) __attribute__ ((__nothrow__ , __leaf__)); extern long double __nextafterl (long double __x, long double __y) __attribute__ ((__nothrow__ , __leaf__));

extern long double nexttowardl (long double __x, long double __y) __attribute__ ((__nothrow__ , __leaf__)); extern long double __nexttowardl (long double __x, long double __y) __attribute__ ((__nothrow__ , __leaf__));
# 272 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 3 4
extern long double remainderl (long double __x, long double __y) __attribute__ ((__nothrow__ , __leaf__)); extern long double __remainderl (long double __x, long double __y) __attribute__ ((__nothrow__ , __leaf__));

extern long double scalbnl (long double __x, int __n) __attribute__ ((__nothrow__ , __leaf__)); extern long double __scalbnl (long double __x, int __n) __attribute__ ((__nothrow__ , __leaf__));

extern int ilogbl (long double __x) __attribute__ ((__nothrow__ , __leaf__)); extern int __ilogbl (long double __x) __attribute__ ((__nothrow__ , __leaf__));
# 290 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 3 4
extern long double scalblnl (long double __x, long int __n) __attribute__ ((__nothrow__ , __leaf__)); extern long double __scalblnl (long double __x, long int __n) __attribute__ ((__nothrow__ , __leaf__));

extern long double nearbyintl (long double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long double __nearbyintl (long double __x) __attribute__ ((__nothrow__ , __leaf__));

extern long double roundl (long double __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__)); extern long double __roundl (long double __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern long double truncl (long double __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__)); extern long double __truncl (long double __x) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern long double remquol (long double __x, long double __y, int *__quo) __attribute__ ((__nothrow__ , __leaf__)); extern long double __remquol (long double __x, long double __y, int *__quo) __attribute__ ((__nothrow__ , __leaf__));

extern long int lrintl (long double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long int __lrintl (long double __x) __attribute__ ((__nothrow__ , __leaf__));
__extension__
extern long long int llrintl (long double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long long int __llrintl (long double __x) __attribute__ ((__nothrow__ , __leaf__));

extern long int lroundl (long double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long int __lroundl (long double __x) __attribute__ ((__nothrow__ , __leaf__));
__extension__
extern long long int llroundl (long double __x) __attribute__ ((__nothrow__ , __leaf__)); extern long long int __llroundl (long double __x) __attribute__ ((__nothrow__ , __leaf__));

extern long double fdiml (long double __x, long double __y) __attribute__ ((__nothrow__ , __leaf__)); extern long double __fdiml (long double __x, long double __y) __attribute__ ((__nothrow__ , __leaf__));

extern long double fmaxl (long double __x, long double __y) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__)); extern long double __fmaxl (long double __x, long double __y) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern long double fminl (long double __x, long double __y) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__)); extern long double __fminl (long double __x, long double __y) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern long double fmal (long double __x, long double __y, long double __z) __attribute__ ((__nothrow__ , __leaf__)); extern long double __fmal (long double __x, long double __y, long double __z) __attribute__ ((__nothrow__ , __leaf__));
# 351 "/usr/include/math.h" 2 3 4
#undef _Mdouble_
#undef __MATH_PRECNAME
#undef __MATH_DECLARING_DOUBLE
#undef __MATH_DECLARING_FLOATN
# 381 "/usr/include/math.h" 3 4
#define _Mdouble_ _Float32
#define __MATH_PRECNAME(name,r) name ##f32 ##r
#define __MATH_DECLARING_DOUBLE 0
#define __MATH_DECLARING_FLOATN 1

#undef _Mdouble_
#undef __MATH_PRECNAME
#undef __MATH_DECLARING_DOUBLE
#undef __MATH_DECLARING_FLOATN

#define _Mdouble_ _Float64
#define __MATH_PRECNAME(name,r) name ##f64 ##r
#define __MATH_DECLARING_DOUBLE 0
#define __MATH_DECLARING_FLOATN 1

#undef _Mdouble_
#undef __MATH_PRECNAME
#undef __MATH_DECLARING_DOUBLE
#undef __MATH_DECLARING_FLOATN

#define _Mdouble_ _Float128
#define __MATH_PRECNAME(name,r) name ##f128 ##r
#define __MATH_DECLARING_DOUBLE 0
#define __MATH_DECLARING_FLOATN 1

# 1 "/usr/include/x86_64-linux-gnu/bits/mathcalls-helper-functions.h" 1 3 4
# 21 "/usr/include/x86_64-linux-gnu/bits/mathcalls-helper-functions.h" 3 4
extern int __fpclassifyf128 (_Float128 __value) __attribute__ ((__nothrow__ , __leaf__))
     __attribute__ ((__const__));

extern int __signbitf128 (_Float128 __value) __attribute__ ((__nothrow__ , __leaf__))
     __attribute__ ((__const__));

extern int __isinff128 (_Float128 __value) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern int __finitef128 (_Float128 __value) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern int __isnanf128 (_Float128 __value) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));

extern int __iseqsigf128 (_Float128 __x, _Float128 __y) __attribute__ ((__nothrow__ , __leaf__));

extern int __issignalingf128 (_Float128 __value) __attribute__ ((__nothrow__ , __leaf__))
     __attribute__ ((__const__));
# 421 "/usr/include/math.h" 2 3 4

#undef _Mdouble_
#undef __MATH_PRECNAME
#undef __MATH_DECLARING_DOUBLE
#undef __MATH_DECLARING_FLOATN

#define _Mdouble_ _Float32x
#define __MATH_PRECNAME(name,r) name ##f32x ##r
#define __MATH_DECLARING_DOUBLE 0
#define __MATH_DECLARING_FLOATN 1

#undef _Mdouble_
#undef __MATH_PRECNAME
#undef __MATH_DECLARING_DOUBLE
#undef __MATH_DECLARING_FLOATN

#define _Mdouble_ _Float64x
#define __MATH_PRECNAME(name,r) name ##f64x ##r
#define __MATH_DECLARING_DOUBLE 0
#define __MATH_DECLARING_FLOATN 1

#undef _Mdouble_
#undef __MATH_PRECNAME
#undef __MATH_DECLARING_DOUBLE
#undef __MATH_DECLARING_FLOATN
# 482 "/usr/include/math.h" 3 4
#undef __MATHDECL_1
#undef __MATHDECL
#undef __MATHCALL

#define __MATHCALL_NARROW_ARGS_1 (_Marg_ __x)
#define __MATHCALL_NARROW_ARGS_2 (_Marg_ __x, _Marg_ __y)
#define __MATHCALL_NARROW_ARGS_3 (_Marg_ __x, _Marg_ __y, _Marg_ __z)
#define __MATHCALL_NARROW_NORMAL(func,nargs) extern _Mret_ func __MATHCALL_NARROW_ARGS_ ## nargs __THROW

#define __MATHCALL_NARROW_REDIR(func,redir,nargs) extern _Mret_ __REDIRECT_NTH (func, __MATHCALL_NARROW_ARGS_ ## nargs, redir)

#define __MATHCALL_NARROW(func,redir,nargs) __MATHCALL_NARROW_NORMAL (func, nargs)
# 764 "/usr/include/math.h" 3 4
#undef __MATHCALL_NARROW_ARGS_1
#undef __MATHCALL_NARROW_ARGS_2
#undef __MATHCALL_NARROW_ARGS_3
#undef __MATHCALL_NARROW_NORMAL
#undef __MATHCALL_NARROW_REDIR
#undef __MATHCALL_NARROW

extern int signgam;
# 803 "/usr/include/math.h" 3 4
#define __MATH_TG_F32(FUNC,ARGS) _Float32: FUNC ## f ARGS,

#define __MATH_TG_F64X(FUNC,ARGS) _Float64x: FUNC ## l ARGS,

#define __MATH_TG(TG_ARG,FUNC,ARGS) _Generic ((TG_ARG), float: FUNC ## f ARGS, __MATH_TG_F32 (FUNC, ARGS) default: FUNC ARGS, long double: FUNC ## l ARGS, __MATH_TG_F64X (FUNC, ARGS) _Float128: FUNC ## f128 ARGS)
# 853 "/usr/include/math.h" 3 4
enum
  {
    FP_NAN =
#define FP_NAN 0
      0,
    FP_INFINITE =
#define FP_INFINITE 1
      1,
    FP_ZERO =
#define FP_ZERO 2
      2,
    FP_SUBNORMAL =
#define FP_SUBNORMAL 3
      3,
    FP_NORMAL =
#define FP_NORMAL 4
      4
  };
# 885 "/usr/include/math.h" 3 4
#define fpclassify(x) __builtin_fpclassify (FP_NAN, FP_INFINITE, FP_NORMAL, FP_SUBNORMAL, FP_ZERO, x)

#define signbit(x) __builtin_signbit (x)
# 911 "/usr/include/math.h" 3 4
#define isfinite(x) __builtin_isfinite (x)

#define isnormal(x) __builtin_isnormal (x)

#define isnan(x) __builtin_isnan (x)
# 943 "/usr/include/math.h" 3 4
#define isinf(x) __builtin_isinf_sign (x)

#define MATH_ERRNO 1
#define MATH_ERREXCEPT 2

#define math_errhandling 0
# 1054 "/usr/include/math.h" 3 4
#define MAXFLOAT 3.40282347e+38F

#define M_E 2.7182818284590452354
#define M_LOG2E 1.4426950408889634074
#define M_LOG10E 0.43429448190325182765
#define M_LN2 0.69314718055994530942
#define M_LN10 2.30258509299404568402
#define M_PI 3.14159265358979323846
#define M_PI_2 1.57079632679489661923
#define M_PI_4 0.78539816339744830962
#define M_1_PI 0.31830988618379067154
#define M_2_PI 0.63661977236758134308
#define M_2_SQRTPI 1.12837916709551257390
#define M_SQRT2 1.41421356237309504880
#define M_SQRT1_2 0.70710678118654752440
# 1209 "/usr/include/math.h" 3 4
#define isgreater(x,y) __builtin_isgreater(x, y)
#define isgreaterequal(x,y) __builtin_isgreaterequal(x, y)
#define isless(x,y) __builtin_isless(x, y)
#define islessequal(x,y) __builtin_islessequal(x, y)
#define islessgreater(x,y) __builtin_islessgreater(x, y)
#define isunordered(x,y) __builtin_isunordered(x, y)
# 1240 "/usr/include/math.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/mathinline.h" 1 3 4
# 26 "/usr/include/x86_64-linux-gnu/bits/mathinline.h" 3 4
#define __MATH_INLINE __extern_always_inline
# 1241 "/usr/include/math.h" 2 3 4

#define _Mdouble_ double
#define __MATH_DECLARING_DOUBLE 1
#define __MATH_DECLARING_FLOATN 0
#define __REDIRFROM_X(function,reentrant) function ## reentrant

#define __REDIRTO_X(function,reentrant) __ ## function ## reentrant ## _finite

# 1 "/usr/include/x86_64-linux-gnu/bits/math-finite.h" 1 3 4
# 23 "/usr/include/x86_64-linux-gnu/bits/math-finite.h" 3 4
#define __REDIRFROM(...) __REDIRFROM_X(__VA_ARGS__)

#define __REDIRTO(...) __REDIRTO_X(__VA_ARGS__)

#define __MATH_REDIRCALL_X(from,args,to) extern _Mdouble_ __REDIRECT_NTH (from, args, to)

#define __MATH_REDIRCALL(function,reentrant,args) __MATH_REDIRCALL_X (__REDIRFROM (function, reentrant), args, __REDIRTO (function, reentrant))

#define __MATH_REDIRCALL_2(from,reentrant,args,to) __MATH_REDIRCALL_X (__REDIRFROM (from, reentrant), args, __REDIRTO (to, reentrant))

#define __MATH_REDIRCALL_INTERNAL(function,reentrant,args) __MATH_REDIRCALL_X (__REDIRFROM (__CONCAT (__, function), __CONCAT (reentrant, _finite)), args, __REDIRTO (function, _r))

extern double acos (double) __asm__ ("" "__acos_finite") __attribute__ ((__nothrow__ , __leaf__));

extern double acosh (double) __asm__ ("" "__acosh_finite") __attribute__ ((__nothrow__ , __leaf__));

extern double asin (double) __asm__ ("" "__asin_finite") __attribute__ ((__nothrow__ , __leaf__));

extern double atan2 (double, double) __asm__ ("" "__atan2_finite") __attribute__ ((__nothrow__ , __leaf__));

extern double atanh (double) __asm__ ("" "__atanh_finite") __attribute__ ((__nothrow__ , __leaf__));

extern double cosh (double) __asm__ ("" "__cosh_finite") __attribute__ ((__nothrow__ , __leaf__));

extern double exp (double) __asm__ ("" "__exp_finite") __attribute__ ((__nothrow__ , __leaf__));
# 77 "/usr/include/x86_64-linux-gnu/bits/math-finite.h" 3 4
extern double exp2 (double) __asm__ ("" "__exp2_finite") __attribute__ ((__nothrow__ , __leaf__));

extern double fmod (double, double) __asm__ ("" "__fmod_finite") __attribute__ ((__nothrow__ , __leaf__));

extern double hypot (double, double) __asm__ ("" "__hypot_finite") __attribute__ ((__nothrow__ , __leaf__));

extern double j0 (double) __asm__ ("" "__j0_finite") __attribute__ ((__nothrow__ , __leaf__));

extern double y0 (double) __asm__ ("" "__y0_finite") __attribute__ ((__nothrow__ , __leaf__));

extern double j1 (double) __asm__ ("" "__j1_finite") __attribute__ ((__nothrow__ , __leaf__));

extern double y1 (double) __asm__ ("" "__y1_finite") __attribute__ ((__nothrow__ , __leaf__));

extern double jn (int, double) __asm__ ("" "__jn_finite") __attribute__ ((__nothrow__ , __leaf__));

extern double yn (int, double) __asm__ ("" "__yn_finite") __attribute__ ((__nothrow__ , __leaf__));
# 117 "/usr/include/x86_64-linux-gnu/bits/math-finite.h" 3 4
extern double __lgamma_r_finite (double, int *) __asm__ ("" "__lgamma_r_finite") __attribute__ ((__nothrow__ , __leaf__));

extern __inline __attribute__ ((__always_inline__)) __attribute__ ((__gnu_inline__)) double
__attribute__ ((__nothrow__ , __leaf__)) lgamma (double __d)
{

  return __lgamma_r_finite (__d, &signgam);

}
# 145 "/usr/include/x86_64-linux-gnu/bits/math-finite.h" 3 4
extern double log (double) __asm__ ("" "__log_finite") __attribute__ ((__nothrow__ , __leaf__));

extern double log10 (double) __asm__ ("" "__log10_finite") __attribute__ ((__nothrow__ , __leaf__));

extern double log2 (double) __asm__ ("" "__log2_finite") __attribute__ ((__nothrow__ , __leaf__));

extern double pow (double, double) __asm__ ("" "__pow_finite") __attribute__ ((__nothrow__ , __leaf__));

extern double remainder (double, double) __asm__ ("" "__remainder_finite") __attribute__ ((__nothrow__ , __leaf__));
# 169 "/usr/include/x86_64-linux-gnu/bits/math-finite.h" 3 4
extern double scalb (double, double) __asm__ ("" "__scalb_finite") __attribute__ ((__nothrow__ , __leaf__));

extern double sinh (double) __asm__ ("" "__sinh_finite") __attribute__ ((__nothrow__ , __leaf__));

extern double sqrt (double) __asm__ ("" "__sqrt_finite") __attribute__ ((__nothrow__ , __leaf__));

extern double
__gamma_r_finite (double, int *);

extern __inline __attribute__ ((__always_inline__)) __attribute__ ((__gnu_inline__)) double
__attribute__ ((__nothrow__ , __leaf__)) tgamma (double __d)
{
  int __local_signgam = 0;
  double __res = __gamma_r_finite (__d, &__local_signgam);
  return __local_signgam < 0 ? -__res : __res;
}

#undef __REDIRFROM
#undef __REDIRTO
#undef __MATH_REDIRCALL
#undef __MATH_REDIRCALL_2
#undef __MATH_REDIRCALL_INTERNAL
#undef __MATH_REDIRCALL_X
# 1256 "/usr/include/math.h" 2 3 4
#undef _Mdouble_
#undef __MATH_DECLARING_DOUBLE
#undef __MATH_DECLARING_FLOATN
#undef __REDIRFROM_X
#undef __REDIRTO_X

#define _Mdouble_ float
#define __MATH_DECLARING_DOUBLE 0
#define __MATH_DECLARING_FLOATN 0
#define __REDIRFROM_X(function,reentrant) function ## f ## reentrant

#define __REDIRTO_X(function,reentrant) __ ## function ## f ## reentrant ## _finite

# 1 "/usr/include/x86_64-linux-gnu/bits/math-finite.h" 1 3 4
# 23 "/usr/include/x86_64-linux-gnu/bits/math-finite.h" 3 4
#define __REDIRFROM(...) __REDIRFROM_X(__VA_ARGS__)

#define __REDIRTO(...) __REDIRTO_X(__VA_ARGS__)

#define __MATH_REDIRCALL_X(from,args,to) extern _Mdouble_ __REDIRECT_NTH (from, args, to)

#define __MATH_REDIRCALL(function,reentrant,args) __MATH_REDIRCALL_X (__REDIRFROM (function, reentrant), args, __REDIRTO (function, reentrant))

#define __MATH_REDIRCALL_2(from,reentrant,args,to) __MATH_REDIRCALL_X (__REDIRFROM (from, reentrant), args, __REDIRTO (to, reentrant))

#define __MATH_REDIRCALL_INTERNAL(function,reentrant,args) __MATH_REDIRCALL_X (__REDIRFROM (__CONCAT (__, function), __CONCAT (reentrant, _finite)), args, __REDIRTO (function, _r))

extern float acosf (float) __asm__ ("" "__acosf_finite") __attribute__ ((__nothrow__ , __leaf__));

extern float acoshf (float) __asm__ ("" "__acoshf_finite") __attribute__ ((__nothrow__ , __leaf__));

extern float asinf (float) __asm__ ("" "__asinf_finite") __attribute__ ((__nothrow__ , __leaf__));

extern float atan2f (float, float) __asm__ ("" "__atan2f_finite") __attribute__ ((__nothrow__ , __leaf__));

extern float atanhf (float) __asm__ ("" "__atanhf_finite") __attribute__ ((__nothrow__ , __leaf__));

extern float coshf (float) __asm__ ("" "__coshf_finite") __attribute__ ((__nothrow__ , __leaf__));

extern float expf (float) __asm__ ("" "__expf_finite") __attribute__ ((__nothrow__ , __leaf__));
# 77 "/usr/include/x86_64-linux-gnu/bits/math-finite.h" 3 4
extern float exp2f (float) __asm__ ("" "__exp2f_finite") __attribute__ ((__nothrow__ , __leaf__));

extern float fmodf (float, float) __asm__ ("" "__fmodf_finite") __attribute__ ((__nothrow__ , __leaf__));

extern float hypotf (float, float) __asm__ ("" "__hypotf_finite") __attribute__ ((__nothrow__ , __leaf__));
# 117 "/usr/include/x86_64-linux-gnu/bits/math-finite.h" 3 4
extern float __lgammaf_r_finite (float, int *) __asm__ ("" "__lgammaf_r_finite") __attribute__ ((__nothrow__ , __leaf__));

extern __inline __attribute__ ((__always_inline__)) __attribute__ ((__gnu_inline__)) float
__attribute__ ((__nothrow__ , __leaf__)) lgammaf (float __d)
{

  return __lgammaf_r_finite (__d, &signgam);

}
# 145 "/usr/include/x86_64-linux-gnu/bits/math-finite.h" 3 4
extern float logf (float) __asm__ ("" "__logf_finite") __attribute__ ((__nothrow__ , __leaf__));

extern float log10f (float) __asm__ ("" "__log10f_finite") __attribute__ ((__nothrow__ , __leaf__));

extern float log2f (float) __asm__ ("" "__log2f_finite") __attribute__ ((__nothrow__ , __leaf__));

extern float powf (float, float) __asm__ ("" "__powf_finite") __attribute__ ((__nothrow__ , __leaf__));

extern float remainderf (float, float) __asm__ ("" "__remainderf_finite") __attribute__ ((__nothrow__ , __leaf__));
# 173 "/usr/include/x86_64-linux-gnu/bits/math-finite.h" 3 4
extern float sinhf (float) __asm__ ("" "__sinhf_finite") __attribute__ ((__nothrow__ , __leaf__));

extern float sqrtf (float) __asm__ ("" "__sqrtf_finite") __attribute__ ((__nothrow__ , __leaf__));

extern float
__gammaf_r_finite (float, int *);

extern __inline __attribute__ ((__always_inline__)) __attribute__ ((__gnu_inline__)) float
__attribute__ ((__nothrow__ , __leaf__)) tgammaf (float __d)
{
  int __local_signgam = 0;
  float __res = __gammaf_r_finite (__d, &__local_signgam);
  return __local_signgam < 0 ? -__res : __res;
}

#undef __REDIRFROM
#undef __REDIRTO
#undef __MATH_REDIRCALL
#undef __MATH_REDIRCALL_2
#undef __MATH_REDIRCALL_INTERNAL
#undef __MATH_REDIRCALL_X
# 1275 "/usr/include/math.h" 2 3 4
#undef _Mdouble_
#undef __MATH_DECLARING_DOUBLE
#undef __MATH_DECLARING_FLOATN
#undef __REDIRFROM_X
#undef __REDIRTO_X

#define _Mdouble_ long double
#define __MATH_DECLARING_DOUBLE 0
#define __MATH_DECLARING_FLOATN 0
#define __REDIRFROM_X(function,reentrant) function ## l ## reentrant

#define __REDIRTO_X(function,reentrant) __ ## function ## l ## reentrant ## _finite

# 1 "/usr/include/x86_64-linux-gnu/bits/math-finite.h" 1 3 4
# 23 "/usr/include/x86_64-linux-gnu/bits/math-finite.h" 3 4
#define __REDIRFROM(...) __REDIRFROM_X(__VA_ARGS__)

#define __REDIRTO(...) __REDIRTO_X(__VA_ARGS__)

#define __MATH_REDIRCALL_X(from,args,to) extern _Mdouble_ __REDIRECT_NTH (from, args, to)

#define __MATH_REDIRCALL(function,reentrant,args) __MATH_REDIRCALL_X (__REDIRFROM (function, reentrant), args, __REDIRTO (function, reentrant))

#define __MATH_REDIRCALL_2(from,reentrant,args,to) __MATH_REDIRCALL_X (__REDIRFROM (from, reentrant), args, __REDIRTO (to, reentrant))

#define __MATH_REDIRCALL_INTERNAL(function,reentrant,args) __MATH_REDIRCALL_X (__REDIRFROM (__CONCAT (__, function), __CONCAT (reentrant, _finite)), args, __REDIRTO (function, _r))

extern long double acosl (long double) __asm__ ("" "__acosl_finite") __attribute__ ((__nothrow__ , __leaf__));

extern long double acoshl (long double) __asm__ ("" "__acoshl_finite") __attribute__ ((__nothrow__ , __leaf__));

extern long double asinl (long double) __asm__ ("" "__asinl_finite") __attribute__ ((__nothrow__ , __leaf__));

extern long double atan2l (long double, long double) __asm__ ("" "__atan2l_finite") __attribute__ ((__nothrow__ , __leaf__));

extern long double atanhl (long double) __asm__ ("" "__atanhl_finite") __attribute__ ((__nothrow__ , __leaf__));

extern long double coshl (long double) __asm__ ("" "__coshl_finite") __attribute__ ((__nothrow__ , __leaf__));

extern long double expl (long double) __asm__ ("" "__expl_finite") __attribute__ ((__nothrow__ , __leaf__));
# 77 "/usr/include/x86_64-linux-gnu/bits/math-finite.h" 3 4
extern long double exp2l (long double) __asm__ ("" "__exp2l_finite") __attribute__ ((__nothrow__ , __leaf__));

extern long double fmodl (long double, long double) __asm__ ("" "__fmodl_finite") __attribute__ ((__nothrow__ , __leaf__));

extern long double hypotl (long double, long double) __asm__ ("" "__hypotl_finite") __attribute__ ((__nothrow__ , __leaf__));
# 117 "/usr/include/x86_64-linux-gnu/bits/math-finite.h" 3 4
extern long double __lgammal_r_finite (long double, int *) __asm__ ("" "__lgammal_r_finite") __attribute__ ((__nothrow__ , __leaf__));

extern __inline __attribute__ ((__always_inline__)) __attribute__ ((__gnu_inline__)) long double
__attribute__ ((__nothrow__ , __leaf__)) lgammal (long double __d)
{

  return __lgammal_r_finite (__d, &signgam);

}
# 145 "/usr/include/x86_64-linux-gnu/bits/math-finite.h" 3 4
extern long double logl (long double) __asm__ ("" "__logl_finite") __attribute__ ((__nothrow__ , __leaf__));

extern long double log10l (long double) __asm__ ("" "__log10l_finite") __attribute__ ((__nothrow__ , __leaf__));

extern long double log2l (long double) __asm__ ("" "__log2l_finite") __attribute__ ((__nothrow__ , __leaf__));

extern long double powl (long double, long double) __asm__ ("" "__powl_finite") __attribute__ ((__nothrow__ , __leaf__));

extern long double remainderl (long double, long double) __asm__ ("" "__remainderl_finite") __attribute__ ((__nothrow__ , __leaf__));
# 173 "/usr/include/x86_64-linux-gnu/bits/math-finite.h" 3 4
extern long double sinhl (long double) __asm__ ("" "__sinhl_finite") __attribute__ ((__nothrow__ , __leaf__));

extern long double sqrtl (long double) __asm__ ("" "__sqrtl_finite") __attribute__ ((__nothrow__ , __leaf__));

extern long double
__gammal_r_finite (long double, int *);

extern __inline __attribute__ ((__always_inline__)) __attribute__ ((__gnu_inline__)) long double
__attribute__ ((__nothrow__ , __leaf__)) tgammal (long double __d)
{
  int __local_signgam = 0;
  long double __res = __gammal_r_finite (__d, &__local_signgam);
  return __local_signgam < 0 ? -__res : __res;
}

#undef __REDIRFROM
#undef __REDIRTO
#undef __MATH_REDIRCALL
#undef __MATH_REDIRCALL_2
#undef __MATH_REDIRCALL_INTERNAL
#undef __MATH_REDIRCALL_X
# 1296 "/usr/include/math.h" 2 3 4
#undef _Mdouble_
#undef __MATH_DECLARING_DOUBLE
#undef __MATH_DECLARING_FLOATN
#undef __REDIRFROM_X
#undef __REDIRTO_X
# 1553 "/usr/include/math.h" 3 4

#define TELETONE_MAX_DTMF_DIGITS 128
#define TELETONE_MAX_TONES 18
#define TELETONE_TONE_RANGE 127

typedef double teletone_process_t;
typedef struct {

 teletone_process_t freqs[18];
} teletone_tone_map_t;
#define teletone_assert(expr) assert(expr)
#define TELETONE_API(type) type
#define TELETONE_API_NONSTD(type) type
#define TELETONE_API_DATA 

#define LIBTELETONE_GENERATE_H 
# 1 "/usr/include/x86_64-linux-gnu/sys/stat.h" 1 3 4
# 23 "/usr/include/x86_64-linux-gnu/sys/stat.h" 3 4
#define _SYS_STAT_H 1
# 99 "/usr/include/x86_64-linux-gnu/sys/stat.h" 3 4

# 1 "/usr/include/x86_64-linux-gnu/bits/stat.h" 1 3 4
# 23 "/usr/include/x86_64-linux-gnu/bits/stat.h" 3 4
#define _BITS_STAT_H 1
# 37 "/usr/include/x86_64-linux-gnu/bits/stat.h" 3 4
#define _STAT_VER_KERNEL 0
#define _STAT_VER_LINUX 1

#define _MKNOD_VER_LINUX 0

#define _STAT_VER _STAT_VER_LINUX

# 46 "/usr/include/x86_64-linux-gnu/bits/stat.h" 3 4
struct stat
  {
    __dev_t st_dev;

    __ino_t st_ino;

    __nlink_t st_nlink;
    __mode_t st_mode;

    __uid_t st_uid;
    __gid_t st_gid;

    int __pad0;

    __dev_t st_rdev;

    __off_t st_size;

    __blksize_t st_blksize;

    __blkcnt_t st_blocks;
# 98 "/usr/include/x86_64-linux-gnu/bits/stat.h" 3 4
    __time_t st_atime;
    __syscall_ulong_t st_atimensec;
    __time_t st_mtime;
    __syscall_ulong_t st_mtimensec;
    __time_t st_ctime;
    __syscall_ulong_t st_ctimensec;

    __syscall_slong_t __glibc_reserved[3];
# 115 "/usr/include/x86_64-linux-gnu/bits/stat.h" 3 4
  };
# 172 "/usr/include/x86_64-linux-gnu/bits/stat.h" 3 4
#define _STATBUF_ST_BLKSIZE 
#define _STATBUF_ST_RDEV 

#define _STATBUF_ST_NSEC 

#define __S_IFMT 0170000

#define __S_IFDIR 0040000
#define __S_IFCHR 0020000
#define __S_IFBLK 0060000
#define __S_IFREG 0100000
#define __S_IFIFO 0010000
#define __S_IFLNK 0120000
#define __S_IFSOCK 0140000

#define __S_TYPEISMQ(buf) ((buf)->st_mode - (buf)->st_mode)
#define __S_TYPEISSEM(buf) ((buf)->st_mode - (buf)->st_mode)
#define __S_TYPEISSHM(buf) ((buf)->st_mode - (buf)->st_mode)

#define __S_ISUID 04000
#define __S_ISGID 02000
#define __S_ISVTX 01000
#define __S_IREAD 0400
#define __S_IWRITE 0200
#define __S_IEXEC 0100
# 102 "/usr/include/x86_64-linux-gnu/sys/stat.h" 2 3 4

#define S_IFMT __S_IFMT
#define S_IFDIR __S_IFDIR
#define S_IFCHR __S_IFCHR
#define S_IFBLK __S_IFBLK
#define S_IFREG __S_IFREG

#define S_IFIFO __S_IFIFO

#define S_IFLNK __S_IFLNK

#define S_IFSOCK __S_IFSOCK

#define __S_ISTYPE(mode,mask) (((mode) & __S_IFMT) == (mask))

#define S_ISDIR(mode) __S_ISTYPE((mode), __S_IFDIR)
#define S_ISCHR(mode) __S_ISTYPE((mode), __S_IFCHR)
#define S_ISBLK(mode) __S_ISTYPE((mode), __S_IFBLK)
#define S_ISREG(mode) __S_ISTYPE((mode), __S_IFREG)

#define S_ISFIFO(mode) __S_ISTYPE((mode), __S_IFIFO)

#define S_ISLNK(mode) __S_ISTYPE((mode), __S_IFLNK)
# 142 "/usr/include/x86_64-linux-gnu/sys/stat.h" 3 4
#define S_ISSOCK(mode) __S_ISTYPE((mode), __S_IFSOCK)
# 152 "/usr/include/x86_64-linux-gnu/sys/stat.h" 3 4
#define S_TYPEISMQ(buf) __S_TYPEISMQ(buf)
#define S_TYPEISSEM(buf) __S_TYPEISSEM(buf)
#define S_TYPEISSHM(buf) __S_TYPEISSHM(buf)

#define S_ISUID __S_ISUID
#define S_ISGID __S_ISGID

#define S_ISVTX __S_ISVTX

#define S_IRUSR __S_IREAD
#define S_IWUSR __S_IWRITE
#define S_IXUSR __S_IEXEC

#define S_IRWXU (__S_IREAD|__S_IWRITE|__S_IEXEC)

#define S_IRGRP (S_IRUSR >> 3)
#define S_IWGRP (S_IWUSR >> 3)
#define S_IXGRP (S_IXUSR >> 3)

#define S_IRWXG (S_IRWXU >> 3)

#define S_IROTH (S_IRGRP >> 3)
#define S_IWOTH (S_IWGRP >> 3)
#define S_IXOTH (S_IXGRP >> 3)

#define S_IRWXO (S_IRWXG >> 3)
# 205 "/usr/include/x86_64-linux-gnu/sys/stat.h" 3 4
extern int stat (const char *__restrict __file,
   struct stat *__restrict __buf) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));

extern int fstat (int __fd, struct stat *__buf) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (2)));
# 259 "/usr/include/x86_64-linux-gnu/sys/stat.h" 3 4
extern int lstat (const char *__restrict __file,
    struct stat *__restrict __buf) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1, 2)));
# 280 "/usr/include/x86_64-linux-gnu/sys/stat.h" 3 4
extern int chmod (const char *__file, __mode_t __mode)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));
# 293 "/usr/include/x86_64-linux-gnu/sys/stat.h" 3 4
extern int fchmod (int __fd, __mode_t __mode) __attribute__ ((__nothrow__ , __leaf__));
# 308 "/usr/include/x86_64-linux-gnu/sys/stat.h" 3 4
extern __mode_t umask (__mode_t __mask) __attribute__ ((__nothrow__ , __leaf__));
# 317 "/usr/include/x86_64-linux-gnu/sys/stat.h" 3 4
extern int mkdir (const char *__path, __mode_t __mode)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));
# 332 "/usr/include/x86_64-linux-gnu/sys/stat.h" 3 4
extern int mknod (const char *__path, __mode_t __mode, __dev_t __dev)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));
# 346 "/usr/include/x86_64-linux-gnu/sys/stat.h" 3 4
extern int mkfifo (const char *__path, __mode_t __mode)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (1)));
# 390 "/usr/include/x86_64-linux-gnu/sys/stat.h" 3 4
#define _MKNOD_VER 0

extern int __fxstat (int __ver, int __fildes, struct stat *__stat_buf)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (3)));
extern int __xstat (int __ver, const char *__filename,
      struct stat *__stat_buf) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (2, 3)));
extern int __lxstat (int __ver, const char *__filename,
       struct stat *__stat_buf) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (2, 3)));
extern int __fxstatat (int __ver, int __fildes, const char *__filename,
         struct stat *__stat_buf, int __flag)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (3, 4)));
# 438 "/usr/include/x86_64-linux-gnu/sys/stat.h" 3 4
extern int __xmknod (int __ver, const char *__path, __mode_t __mode,
       __dev_t *__dev) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (2, 4)));

extern int __xmknodat (int __ver, int __fd, const char *__path,
         __mode_t __mode, __dev_t *__dev)
     __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__nonnull__ (3, 5)));
# 452 "/usr/include/x86_64-linux-gnu/sys/stat.h" 3 4
extern __inline __attribute__ ((__gnu_inline__)) int
__attribute__ ((__nothrow__ , __leaf__)) stat (const char *__path, struct stat *__statbuf)
{
  return __xstat (1, __path, __statbuf);
}

extern __inline __attribute__ ((__gnu_inline__)) int
__attribute__ ((__nothrow__ , __leaf__)) lstat (const char *__path, struct stat *__statbuf)
{
  return __lxstat (1, __path, __statbuf);
}

extern __inline __attribute__ ((__gnu_inline__)) int
__attribute__ ((__nothrow__ , __leaf__)) fstat (int __fd, struct stat *__statbuf)
{
  return __fxstat (1, __fd, __statbuf);
}
# 534 "/usr/include/x86_64-linux-gnu/sys/stat.h" 3 4

# 1 "/usr/include/fcntl.h" 1 3 4
# 23 "/usr/include/fcntl.h" 3 4
#define _FCNTL_H 1

# 1 "/usr/include/x86_64-linux-gnu/bits/fcntl.h" 1 3 4
# 24 "/usr/include/x86_64-linux-gnu/bits/fcntl.h" 3 4
#define __O_LARGEFILE 0

#define F_GETLK64 5
#define F_SETLK64 6
#define F_SETLKW64 7

struct flock
  {
    short int l_type;
    short int l_whence;

    __off_t l_start;
    __off_t l_len;

    __pid_t l_pid;
  };
# 61 "/usr/include/x86_64-linux-gnu/bits/fcntl.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/fcntl-linux.h" 1 3 4
# 42 "/usr/include/x86_64-linux-gnu/bits/fcntl-linux.h" 3 4
#define O_ACCMODE 0003
#define O_RDONLY 00
#define O_WRONLY 01
#define O_RDWR 02

#define O_CREAT 0100

#define O_EXCL 0200

#define O_NOCTTY 0400

#define O_TRUNC 01000

#define O_APPEND 02000

#define O_NONBLOCK 04000

#define O_NDELAY O_NONBLOCK

#define O_SYNC 04010000

#define O_FSYNC O_SYNC

#define O_ASYNC 020000

#define __O_DIRECTORY 0200000

#define __O_NOFOLLOW 0400000

#define __O_CLOEXEC 02000000

#define __O_DIRECT 040000

#define __O_NOATIME 01000000

#define __O_PATH 010000000

#define __O_DSYNC 010000

#define __O_TMPFILE (020000000 | __O_DIRECTORY)

#define F_GETLK 5
#define F_SETLK 6
#define F_SETLKW 7
# 158 "/usr/include/x86_64-linux-gnu/bits/fcntl-linux.h" 3 4
#define O_DSYNC __O_DSYNC

#define O_RSYNC O_SYNC

#define F_DUPFD 0
#define F_GETFD 1
#define F_SETFD 2
#define F_GETFL 3
#define F_SETFL 4

#define __F_SETOWN 8
#define __F_GETOWN 9

#define F_SETOWN __F_SETOWN
#define F_GETOWN __F_GETOWN

#define __F_SETSIG 10
#define __F_GETSIG 11

#define __F_SETOWN_EX 15
#define __F_GETOWN_EX 16
# 219 "/usr/include/x86_64-linux-gnu/bits/fcntl-linux.h" 3 4
#define FD_CLOEXEC 1

#define F_RDLCK 0
#define F_WRLCK 1
#define F_UNLCK 2

#define F_EXLCK 4
#define F_SHLCK 8
# 310 "/usr/include/x86_64-linux-gnu/bits/fcntl-linux.h" 3 4
#define __POSIX_FADV_DONTNEED 4
#define __POSIX_FADV_NOREUSE 5

#define POSIX_FADV_NORMAL 0
#define POSIX_FADV_RANDOM 1
#define POSIX_FADV_SEQUENTIAL 2
#define POSIX_FADV_WILLNEED 3
#define POSIX_FADV_DONTNEED __POSIX_FADV_DONTNEED
#define POSIX_FADV_NOREUSE __POSIX_FADV_NOREUSE
# 384 "/usr/include/x86_64-linux-gnu/bits/fcntl-linux.h" 3 4

# 458 "/usr/include/x86_64-linux-gnu/bits/fcntl-linux.h" 3 4

# 61 "/usr/include/x86_64-linux-gnu/bits/fcntl.h" 2 3 4
# 36 "/usr/include/fcntl.h" 2 3 4

#define __OPEN_NEEDS_MODE(oflag) (((oflag) & O_CREAT) != 0 || ((oflag) & __O_TMPFILE) == __O_TMPFILE)
# 78 "/usr/include/fcntl.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/stat.h" 1 3 4
# 79 "/usr/include/fcntl.h" 2 3 4

#define S_IFMT __S_IFMT
#define S_IFDIR __S_IFDIR
#define S_IFCHR __S_IFCHR
#define S_IFBLK __S_IFBLK
#define S_IFREG __S_IFREG

#define S_IFIFO __S_IFIFO

#define S_IFLNK __S_IFLNK

#define S_IFSOCK __S_IFSOCK

#define S_ISUID __S_ISUID
#define S_ISGID __S_ISGID

#define S_ISVTX __S_ISVTX

#define S_IRUSR __S_IREAD
#define S_IWUSR __S_IWRITE
#define S_IXUSR __S_IEXEC

#define S_IRWXU (__S_IREAD|__S_IWRITE|__S_IEXEC)

#define S_IRGRP (S_IRUSR >> 3)
#define S_IWGRP (S_IWUSR >> 3)
#define S_IXGRP (S_IXUSR >> 3)

#define S_IRWXG (S_IRWXU >> 3)

#define S_IROTH (S_IRGRP >> 3)
#define S_IWOTH (S_IWGRP >> 3)
#define S_IXOTH (S_IXGRP >> 3)

#define S_IRWXO (S_IRWXG >> 3)
# 137 "/usr/include/fcntl.h" 3 4
#define SEEK_SET 0
#define SEEK_CUR 1
#define SEEK_END 2
# 148 "/usr/include/fcntl.h" 3 4
extern int fcntl (int __fd, int __cmd, ...);
# 168 "/usr/include/fcntl.h" 3 4
extern int open (const char *__file, int __oflag, ...) __attribute__ ((__nonnull__ (1)));
# 214 "/usr/include/fcntl.h" 3 4
extern int creat (const char *__file, mode_t __mode) __attribute__ ((__nonnull__ (1)));
# 260 "/usr/include/fcntl.h" 3 4
extern int posix_fadvise (int __fd, off_t __offset, off_t __len,
     int __advise) __attribute__ ((__nothrow__ , __leaf__));
# 282 "/usr/include/fcntl.h" 3 4
extern int posix_fallocate (int __fd, off_t __offset, off_t __len);
# 301 "/usr/include/fcntl.h" 3 4
# 1 "/usr/include/x86_64-linux-gnu/bits/fcntl2.h" 1 3 4
# 26 "/usr/include/x86_64-linux-gnu/bits/fcntl2.h" 3 4
extern int __open_2 (const char *__path, int __oflag) __attribute__ ((__nonnull__ (1)));
extern int __open_alias (const char *__path, int __oflag, ...) __asm__ ("" "open")
               __attribute__ ((__nonnull__ (1)));

extern void __open_too_many_args (void) __attribute__((__error__ ("open can be called either with 2 or 3 arguments, not more")))
                                                                  ;
extern void __open_missing_mode (void) __attribute__((__error__ ("open with O_CREAT or O_TMPFILE in second argument needs 3 arguments")))
                                                                            ;

extern __inline __attribute__ ((__always_inline__)) __attribute__ ((__gnu_inline__)) __attribute__ ((__artificial__)) int
open (const char *__path, int __oflag, ...)
{
  if (__builtin_va_arg_pack_len () > 1)
    __open_too_many_args ();

  if (__builtin_constant_p (__oflag))
    {
      if ((((__oflag) & 0100) != 0 || ((__oflag) & (020000000 | 0200000)) == (020000000 | 0200000)) && __builtin_va_arg_pack_len () < 1)
 {
   __open_missing_mode ();
   return __open_2 (__path, __oflag);
 }
      return __open_alias (__path, __oflag, __builtin_va_arg_pack ());
    }

  if (__builtin_va_arg_pack_len () < 1)
    return __open_2 (__path, __oflag);

  return __open_alias (__path, __oflag, __builtin_va_arg_pack ());
}
# 302 "/usr/include/fcntl.h" 2 3 4

extern float powf (float, float);

# 1 "/usr/include/errno.h" 1 3 4
# 23 "/usr/include/errno.h" 3 4
#define _ERRNO_H 1

# 1 "/usr/include/x86_64-linux-gnu/bits/errno.h" 1 3 4
# 20 "/usr/include/x86_64-linux-gnu/bits/errno.h" 3 4
#define _BITS_ERRNO_H 1

# 1 "/usr/include/linux/errno.h" 1 3 4
# 1 "/usr/include/x86_64-linux-gnu/asm/errno.h" 1 3 4
# 1 "/usr/include/asm-generic/errno.h" 1 3 4

#define _ASM_GENERIC_ERRNO_H 

# 1 "/usr/include/asm-generic/errno-base.h" 1 3 4

#define _ASM_GENERIC_ERRNO_BASE_H 

#define EPERM 1
#define ENOENT 2
#define ESRCH 3
#define EINTR 4
#define EIO 5
#define ENXIO 6
#define E2BIG 7
#define ENOEXEC 8
#define EBADF 9
#define ECHILD 10
#define EAGAIN 11
#define ENOMEM 12
#define EACCES 13
#define EFAULT 14
#define ENOTBLK 15
#define EBUSY 16
#define EEXIST 17
#define EXDEV 18
#define ENODEV 19
#define ENOTDIR 20
#define EISDIR 21
#define EINVAL 22
#define ENFILE 23
#define EMFILE 24
#define ENOTTY 25
#define ETXTBSY 26
#define EFBIG 27
#define ENOSPC 28
#define ESPIPE 29
#define EROFS 30
#define EMLINK 31
#define EPIPE 32
#define EDOM 33
#define ERANGE 34
# 6 "/usr/include/asm-generic/errno.h" 2 3 4

#define EDEADLK 35
#define ENAMETOOLONG 36
#define ENOLCK 37
# 18 "/usr/include/asm-generic/errno.h" 3 4
#define ENOSYS 38

#define ENOTEMPTY 39
#define ELOOP 40
#define EWOULDBLOCK EAGAIN
#define ENOMSG 42
#define EIDRM 43
#define ECHRNG 44
#define EL2NSYNC 45
#define EL3HLT 46
#define EL3RST 47
#define ELNRNG 48
#define EUNATCH 49
#define ENOCSI 50
#define EL2HLT 51
#define EBADE 52
#define EBADR 53
#define EXFULL 54
#define ENOANO 55
#define EBADRQC 56
#define EBADSLT 57

#define EDEADLOCK EDEADLK

#define EBFONT 59
#define ENOSTR 60
#define ENODATA 61
#define ETIME 62
#define ENOSR 63
#define ENONET 64
#define ENOPKG 65
#define EREMOTE 66
#define ENOLINK 67
#define EADV 68
#define ESRMNT 69
#define ECOMM 70
#define EPROTO 71
#define EMULTIHOP 72
#define EDOTDOT 73
#define EBADMSG 74
#define EOVERFLOW 75
#define ENOTUNIQ 76
#define EBADFD 77
#define EREMCHG 78
#define ELIBACC 79
#define ELIBBAD 80
#define ELIBSCN 81
#define ELIBMAX 82
#define ELIBEXEC 83
#define EILSEQ 84
#define ERESTART 85
#define ESTRPIPE 86
#define EUSERS 87
#define ENOTSOCK 88
#define EDESTADDRREQ 89
#define EMSGSIZE 90
#define EPROTOTYPE 91
#define ENOPROTOOPT 92
#define EPROTONOSUPPORT 93
#define ESOCKTNOSUPPORT 94
#define EOPNOTSUPP 95
#define EPFNOSUPPORT 96
#define EAFNOSUPPORT 97
#define EADDRINUSE 98
#define EADDRNOTAVAIL 99
#define ENETDOWN 100
#define ENETUNREACH 101
#define ENETRESET 102
#define ECONNABORTED 103
#define ECONNRESET 104
#define ENOBUFS 105
#define EISCONN 106
#define ENOTCONN 107
#define ESHUTDOWN 108
#define ETOOMANYREFS 109
#define ETIMEDOUT 110
#define ECONNREFUSED 111
#define EHOSTDOWN 112
#define EHOSTUNREACH 113
#define EALREADY 114
#define EINPROGRESS 115
#define ESTALE 116
#define EUCLEAN 117
#define ENOTNAM 118
#define ENAVAIL 119
#define EISNAM 120
#define EREMOTEIO 121
#define EDQUOT 122

#define ENOMEDIUM 123
#define EMEDIUMTYPE 124
#define ECANCELED 125
#define ENOKEY 126
#define EKEYEXPIRED 127
#define EKEYREVOKED 128
#define EKEYREJECTED 129

#define EOWNERDEAD 130
#define ENOTRECOVERABLE 131

#define ERFKILL 132

#define EHWPOISON 133
# 1 "/usr/include/x86_64-linux-gnu/asm/errno.h" 2 3 4
# 1 "/usr/include/linux/errno.h" 2 3 4
# 27 "/usr/include/x86_64-linux-gnu/bits/errno.h" 2 3 4

#define ENOTSUP EOPNOTSUPP
# 29 "/usr/include/errno.h" 2 3 4

# 37 "/usr/include/errno.h" 3 4
extern int *__errno_location (void) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__const__));
#define errno (*__errno_location ())
# 52 "/usr/include/errno.h" 3 4

# 1 "/usr/include/assert.h" 1 3 4
# 24 "/usr/include/assert.h" 3 4
#undef _ASSERT_H
#undef assert
#undef __ASSERT_VOID_CAST

#define _ASSERT_H 1

#define __ASSERT_VOID_CAST (void)
# 107 "/usr/include/assert.h" 3 4
#define assert(expr) ((void) sizeof ((expr) ? 1 : 0), __extension__ ({ if (expr) ; else __assert_fail (#expr, __FILE__, __LINE__, __ASSERT_FUNCTION); }))
# 129 "/usr/include/assert.h" 3 4
#define __ASSERT_FUNCTION __extension__ __PRETTY_FUNCTION__
# 142 "/usr/include/assert.h" 3 4
#undef static_assert
#define static_assert _Static_assert

#define TELETONE_VOL_DB_MAX 0
#define TELETONE_VOL_DB_MIN -63
#define MAX_PHASE_TONES 4

struct teletone_dds_state {
 uint32_t phase_rate[4];
 uint32_t scale_factor;
 uint32_t phase_accumulator;
 teletone_process_t tx_level;
};
typedef struct teletone_dds_state teletone_dds_state_t;

#define SINE_TABLE_MAX 128
#define SINE_TABLE_LEN (SINE_TABLE_MAX - 1)
#define MAX_PHASE_ACCUMULATOR 0x10000 * 0x10000

#define DBM0_MAX_POWER (3.14f + 3.02f)

 extern int16_t TELETONE_SINES[128];

static __inline__ int32_t teletone_dds_phase_rate(teletone_process_t tone, uint32_t rate)
{
 return (int32_t) ((tone * 0x10000 * 0x10000) / rate);
}

static __inline__ int16_t teletone_dds_state_modulate_sample(teletone_dds_state_t *dds, uint32_t pindex)
{
 int32_t bitmask = dds->phase_accumulator, sine_index = (bitmask >>= 23) & (128 - 1);
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

static __inline__ void teletone_dds_state_set_tx_level(teletone_dds_state_t *dds, float tx_level)
{
 dds->scale_factor = (int) (powf(10.0f, (tx_level - (3.14f + 3.02f)) / 20.0f) * (32767.0f * 1.414214f));
 dds->tx_level = tx_level;
}

static __inline__ void teletone_dds_state_reset_accum(teletone_dds_state_t *dds)
{
 dds->phase_accumulator = 0;
}

static __inline__ int teletone_dds_state_set_tone(teletone_dds_state_t *dds, teletone_process_t tone, uint32_t rate, uint32_t pindex)
{
 if (pindex < 4) {
  dds->phase_rate[pindex] = teletone_dds_phase_rate(tone, rate);
  return 0;
 }

 return -1;
}
typedef int16_t teletone_audio_t;
struct teletone_generation_session;
typedef int (*tone_handler)(struct teletone_generation_session *ts, teletone_tone_map_t *map);

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
int teletone_set_tone(teletone_generation_session_t *ts, int index, ...);

int teletone_set_map(teletone_tone_map_t *map, ...);
int teletone_init_session(teletone_generation_session_t *ts, int buflen, tone_handler handler, void *user_data);

int teletone_destroy_session(teletone_generation_session_t *ts);

int teletone_mux_tones(teletone_generation_session_t *ts, teletone_tone_map_t *map);

int teletone_run(teletone_generation_session_t *ts, const char *cmd);
#define LIBTELETONE_DETECT_H 
#define FALSE 0

#define TRUE (!FALSE)
#define DTMF_THRESHOLD 8.0e7
#define DTMF_NORMAL_TWIST 6.3
#define DTMF_REVERSE_TWIST 2.5
#define DTMF_RELATIVE_PEAK_ROW 6.3
#define DTMF_RELATIVE_PEAK_COL 6.3
#define DTMF_2ND_HARMONIC_ROW 2.5
#define DTMF_2ND_HARMONIC_COL 63.1
#define GRID_FACTOR 4
#define BLOCK_LEN 102
#define M_TWO_PI 2.0*M_PI

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

void teletone_multi_tone_init(teletone_multi_tone_t *mt, teletone_tone_map_t *map);
int teletone_multi_tone_detect (teletone_multi_tone_t *mt,
         int16_t sample_buffer[],
         int samples);

void teletone_dtmf_detect_init (teletone_dtmf_detect_state_t *dtmf_detect_state, int sample_rate);
teletone_hit_type_t teletone_dtmf_detect (teletone_dtmf_detect_state_t *dtmf_detect_state,
         int16_t sample_buffer[],
         int samples);

int teletone_dtmf_get (teletone_dtmf_detect_state_t *dtmf_detect_state, char *buf, unsigned int *dur);

void teletone_goertzel_update(teletone_goertzel_state_t *goertzel_state,
          int16_t sample_buffer[],
          int samples);
#define FTDM_BUFFER_H 
struct ftdm_buffer;
typedef struct ftdm_buffer ftdm_buffer_t;
ftdm_status_t ftdm_buffer_create(ftdm_buffer_t **buffer, ftdm_size_t blocksize, ftdm_size_t start_len, ftdm_size_t max_len);

ftdm_size_t ftdm_buffer_len(ftdm_buffer_t *buffer);

ftdm_size_t ftdm_buffer_freespace(ftdm_buffer_t *buffer);

ftdm_size_t ftdm_buffer_inuse(ftdm_buffer_t *buffer);

ftdm_size_t ftdm_buffer_read(ftdm_buffer_t *buffer, void *data, ftdm_size_t datalen);
ftdm_size_t ftdm_buffer_read_loop(ftdm_buffer_t *buffer, void *data, ftdm_size_t datalen);

void ftdm_buffer_set_loops(ftdm_buffer_t *buffer, int32_t loops);

ftdm_size_t ftdm_buffer_write(ftdm_buffer_t *buffer, const void *data, ftdm_size_t datalen);

ftdm_size_t ftdm_buffer_toss(ftdm_buffer_t *buffer, ftdm_size_t datalen);

void ftdm_buffer_zero(ftdm_buffer_t *buffer);

void ftdm_buffer_destroy(ftdm_buffer_t **buffer);

ftdm_size_t ftdm_buffer_seek(ftdm_buffer_t *buffer, ftdm_size_t datalen);

ftdm_size_t ftdm_buffer_zwrite(ftdm_buffer_t *buffer, const void *data, ftdm_size_t datalen);
#define __FTDM_SCHED_H__ 

#define FTDM_MICROSECONDS_PER_SECOND 1000000

typedef struct ftdm_sched ftdm_sched_t;
typedef void (*ftdm_sched_callback_t)(void *data);
typedef uint64_t ftdm_timer_id_t;

ftdm_status_t ftdm_sched_create(ftdm_sched_t **sched, const char *name);

ftdm_status_t ftdm_sched_run(ftdm_sched_t *sched);

ftdm_status_t ftdm_sched_free_run(ftdm_sched_t *sched);
ftdm_status_t ftdm_sched_timer(ftdm_sched_t *sched, const char *name,
  int ms, ftdm_sched_callback_t callback, void *data, ftdm_timer_id_t *timer);
ftdm_status_t ftdm_sched_cancel_timer(ftdm_sched_t *sched, ftdm_timer_id_t timer);

ftdm_status_t ftdm_sched_destroy(ftdm_sched_t **sched);

ftdm_status_t ftdm_sched_get_time_to_next_timer(const ftdm_sched_t *sched, int32_t *timeto);

ftdm_status_t ftdm_sched_global_init(void);

ftdm_status_t ftdm_sched_global_destroy(void);

ftdm_bool_t ftdm_free_sched_running(void);

ftdm_bool_t ftdm_free_sched_stop(void);

#define SPAN_PENDING_CHANS_QUEUE_SIZE 1000
#define SPAN_PENDING_SIGNALS_QUEUE_SIZE 1000

#define GOTO_STATUS(label,st) status = st; goto label ;

#define ftdm_copy_string(x,y,z) strncpy(x, y, z - 1)
#define ftdm_set_string(x,y) strncpy(x, y, sizeof(x)-1)
#define ftdm_strlen_zero(s) (!s || *s == '\0')
#define ftdm_strlen_zero_buf(s) (*s == '\0')

#define ftdm_channel_test_feature(obj,flag) ((obj)->features & flag)
#define ftdm_channel_set_feature(obj,flag) (obj)->features = (ftdm_channel_feature_t)((obj)->features | flag)
#define ftdm_channel_clear_feature(obj,flag) (obj)->features = (ftdm_channel_feature_t)((obj)->features & ( ~(flag) ))
#define ftdm_channel_set_member_locked(obj,_m,_v) ftdm_mutex_lock(obj->mutex); obj->_m = _v; ftdm_mutex_unlock(obj->mutex)

#define ftdm_test_flag(obj,flag) ((obj)->flags & flag)

#define ftdm_test_pflag(obj,flag) ((obj)->pflags & flag)

#define ftdm_test_sflag(obj,flag) ((obj)->sflags & flag)

#define ftdm_set_alarm_flag(obj,flag) (obj)->alarm_flags |= (flag)
#define ftdm_clear_alarm_flag(obj,flag) (obj)->alarm_flags &= ~(flag)
#define ftdm_test_alarm_flag(obj,flag) ((obj)->alarm_flags & flag)

#define ftdm_set_io_flag(obj,flag) (obj)->io_flags |= (flag)
#define ftdm_clear_io_flag(obj,flag) (obj)->io_flags &= ~(flag)
#define ftdm_test_io_flag(obj,flag) ((obj)->io_flags & flag)

#define ftdm_set_flag(obj,flag) (obj)->flags |= (flag)
#define ftdm_set_flag_locked(obj,flag) assert(obj->mutex != NULL); ftdm_mutex_lock(obj->mutex); (obj)->flags |= (flag); ftdm_mutex_unlock(obj->mutex);

#define ftdm_set_pflag(obj,flag) (obj)->pflags |= (flag)
#define ftdm_set_pflag_locked(obj,flag) assert(obj->mutex != NULL); ftdm_mutex_lock(obj->mutex); (obj)->pflags |= (flag); ftdm_mutex_unlock(obj->mutex);

#define ftdm_set_sflag(obj,flag) (obj)->sflags |= (flag)
#define ftdm_set_sflag_locked(obj,flag) assert(obj->mutex != NULL); ftdm_mutex_lock(obj->mutex); (obj)->sflags |= (flag); ftdm_mutex_unlock(obj->mutex);
#define ftdm_clear_flag(obj,flag) (obj)->flags &= ~(flag)

#define ftdm_clear_flag_locked(obj,flag) assert(obj->mutex != NULL); ftdm_mutex_lock(obj->mutex); (obj)->flags &= ~(flag); ftdm_mutex_unlock(obj->mutex);

#define ftdm_clear_pflag(obj,flag) (obj)->pflags &= ~(flag)

#define ftdm_clear_pflag_locked(obj,flag) assert(obj->mutex != NULL); ftdm_mutex_lock(obj->mutex); (obj)->pflags &= ~(flag); ftdm_mutex_unlock(obj->mutex);

#define ftdm_clear_sflag(obj,flag) (obj)->sflags &= ~(flag)

#define ftdm_clear_sflag_locked(obj,flag) assert(obj->mutex != NULL); ftdm_mutex_lock(obj->mutex); (obj)->sflags &= ~(flag); ftdm_mutex_unlock(obj->mutex);

#define ftdm_wait_for_flag_cleared(obj,flag,time) do { int __safety = time; while(__safety-- && ftdm_test_flag(obj, flag)) { ftdm_mutex_unlock(obj->mutex); ftdm_sleep(10); ftdm_mutex_lock(obj->mutex); } if(!__safety) { ftdm_log(FTDM_LOG_CRIT, "flag %"FTDM_UINT64_FMT" was never cleared\n", (uint64_t)flag); } } while(0);
#define ftdm_is_dtmf(key) ((key > 47 && key < 58) || (key > 64 && key < 69) || (key > 96 && key < 101) || key == 35 || key == 42 || key == 87 || key == 119)

#define ftdm_print_stack(level) do { void *__stacktrace[100] = { 0 }; char **__symbols = NULL; int __size = 0; int __i = 0; __size = backtrace(__stacktrace, ftdm_array_len(__stacktrace)); __symbols = backtrace_symbols(__stacktrace, __size); if (__symbols) { for (__i = 0; __i < __size; __i++) { ftdm_log(__level, "%s\n", __symbols[i]); } free(__symbols); } } while (0);
#define FTDM_SPAN_IS_BRI(x) ((x)->trunk_type == FTDM_TRUNK_BRI || (x)->trunk_type == FTDM_TRUNK_BRI_PTMP)

#define ftdm_copy_flags(dest,src,flags) (dest)->flags &= ~(flags); (dest)->flags |= ((src)->flags & (flags))

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

ftdm_status_t ftdm_console_stream_raw_write(ftdm_stream_handle_t *handle, uint8_t *data, ftdm_size_t datalen);
ftdm_status_t ftdm_console_stream_write(ftdm_stream_handle_t *handle, const char *fmt, ...);

#define FTDM_CMD_CHUNK_LEN 1024
#define FTDM_STANDARD_STREAM(s) memset(&s, 0, sizeof(s)); s.data = ftdm_malloc(FTDM_CMD_CHUNK_LEN); assert(s.data); memset(s.data, 0, FTDM_CMD_CHUNK_LEN); s.end = s.data; s.data_size = FTDM_CMD_CHUNK_LEN; s.write_function = ftdm_console_stream_write; s.raw_write_function = ftdm_console_stream_raw_write; s.alloc_len = FTDM_CMD_CHUNK_LEN; s.alloc_chunk = FTDM_CMD_CHUNK_LEN
#define ftdm_queue_create(queue,capacity) g_ftdm_queue_handler.create(queue, capacity)

#define ftdm_queue_enqueue(queue,obj) g_ftdm_queue_handler.enqueue(queue, obj)

#define ftdm_queue_dequeue(queue) g_ftdm_queue_handler.dequeue(queue)

#define ftdm_queue_wait(queue,ms) g_ftdm_queue_handler.wait(queue, ms)

#define ftdm_queue_get_interrupt(queue,ms) g_ftdm_queue_handler.get_interrupt(queue, ms)

#define ftdm_queue_destroy(queue) g_ftdm_queue_handler.destroy(queue)

 extern ftdm_queue_handler_t g_ftdm_queue_handler;

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

#define FTDM_IO_DUMP_DEFAULT_BUFF_SIZE 8 * 5000
typedef struct {
 char *buffer;
 ftdm_size_t size;
 int windex;
 int wrapped;
} ftdm_io_dump_t;

#define DTMF_DEBUG_TIMEOUT 250
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
 char tokens[10 +1][128];
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
 ftdm_analog_start_type_t start_type;
 ftdm_signal_type_t signal_type;
 uint32_t last_used_index;

 void *signal_data;
 fio_signal_cb_t signal_cb;
 ftdm_event_t event_header;
 char last_error[256];
 char tone_map[FTDM_TONEMAP_INVALID+1][128];
 teletone_tone_map_t tone_detect_map[FTDM_TONEMAP_INVALID+1];
 teletone_multi_tone_t tone_finder[FTDM_TONEMAP_INVALID+1];
 ftdm_channel_t *channels[32 * 128 +1];
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

ftdm_size_t ftdm_fsk_modulator_generate_bit(ftdm_fsk_modulator_t *fsk_trans, int8_t bit, int16_t *buf, ftdm_size_t buflen);
int32_t ftdm_fsk_modulator_generate_carrier_bits(ftdm_fsk_modulator_t *fsk_trans, uint32_t bits);
void ftdm_fsk_modulator_generate_chan_sieze(ftdm_fsk_modulator_t *fsk_trans);
void ftdm_fsk_modulator_send_data(ftdm_fsk_modulator_t *fsk_trans);
#define ftdm_fsk_modulator_send_all(_it) ftdm_fsk_modulator_generate_chan_sieze(_it); ftdm_fsk_modulator_generate_carrier_bits(_it, _it->carrier_bits_start); ftdm_fsk_modulator_send_data(_it); ftdm_fsk_modulator_generate_carrier_bits(_it, _it->carrier_bits_stop)

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
void ftdm_bitstream_init(ftdm_bitstream_t *bsp, uint8_t *data, uint32_t datalen, ftdm_endian_t endian, uint8_t ss);
ftdm_status_t ftdm_fsk_data_parse(ftdm_fsk_data_state_t *state, ftdm_size_t *type, char **data, ftdm_size_t *len);
ftdm_status_t ftdm_fsk_demod_feed(ftdm_fsk_data_state_t *state, int16_t *data, size_t samples);
ftdm_status_t ftdm_fsk_demod_destroy(ftdm_fsk_data_state_t *state);
int ftdm_fsk_demod_init(ftdm_fsk_data_state_t *state, int rate, uint8_t *buf, size_t bufsize);
ftdm_status_t ftdm_fsk_data_init(ftdm_fsk_data_state_t *state, uint8_t *data, uint32_t datalen);
ftdm_status_t ftdm_fsk_data_add_mdmf(ftdm_fsk_data_state_t *state, ftdm_mdmf_type_t type, const uint8_t *data, uint32_t datalen);
ftdm_status_t ftdm_fsk_data_add_checksum(ftdm_fsk_data_state_t *state);
ftdm_status_t ftdm_fsk_data_add_sdmf(ftdm_fsk_data_state_t *state, const char *date, char *number);
ftdm_status_t ftdm_channel_send_fsk_data(ftdm_channel_t *ftdmchan, ftdm_fsk_data_state_t *fsk_data, float db_level);

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
void ftdm_ack_indication(ftdm_channel_t *ftdmchan, ftdm_channel_indication_t indication, ftdm_status_t status);

ftdm_iterator_t * ftdm_get_iterator(ftdm_iterator_type_t type, ftdm_iterator_t *iter);

ftdm_status_t ftdm_channel_process_media(ftdm_channel_t *ftdmchan, void *data, ftdm_size_t *datalen);

ftdm_status_t ftdm_raw_read (ftdm_channel_t *ftdmchan, void *data, ftdm_size_t *datalen);
ftdm_status_t ftdm_raw_write (ftdm_channel_t *ftdmchan, void *data, ftdm_size_t *datalen);
ftdm_status_t ftdm_span_next_event(ftdm_span_t *span, ftdm_event_t **event);
ftdm_status_t ftdm_channel_queue_dtmf(ftdm_channel_t *ftdmchan, const char *dtmf);

ftdm_status_t ftdm_span_trigger_signals(const ftdm_span_t *span);

void ftdm_channel_clear_detected_tones(ftdm_channel_t *ftdmchan);

void ftdm_set_echocancel_call_begin(ftdm_channel_t *chan);

void ftdm_set_echocancel_call_end(ftdm_channel_t *chan);

ftdm_status_t ftdm_channel_save_usrmsg(ftdm_channel_t *ftdmchan, ftdm_usrmsg_t *usrmsg);

ftdm_status_t ftdm_usrmsg_free(ftdm_usrmsg_t **usrmsg);

const char * ftdm_usrmsg_get_var(ftdm_usrmsg_t *usrmsg, const char *var_name);
ftdm_status_t ftdm_usrmsg_get_raw_data(ftdm_usrmsg_t *usrmsg, void **data, ftdm_size_t *datalen);

ftdm_status_t ftdm_sigmsg_free(ftdm_sigmsg_t **sigmsg);

ftdm_status_t ftdm_sigmsg_add_var(ftdm_sigmsg_t *sigmsg, const char *var_name, const char *value);

ftdm_status_t ftdm_sigmsg_remove_var(ftdm_sigmsg_t *sigmsg, const char *var_name);
ftdm_status_t ftdm_sigmsg_set_raw_data(ftdm_sigmsg_t *sigmsg, void *data, ftdm_size_t datalen);

ftdm_status_t ftdm_get_channel_from_string(const char *string_id, ftdm_span_t **out_span, ftdm_channel_t **out_channel);

#define ftdm_assert(assertion,msg) if (!(assertion)) { ftdm_log(FTDM_LOG_CRIT, "%s", msg); if (g_ftdm_crash_policy & FTDM_CRASH_ON_ASSERT) { ftdm_abort(); } }
#define ftdm_assert_return(assertion,retval,msg) if (!(assertion)) { ftdm_log(FTDM_LOG_CRIT, "%s", msg); if (g_ftdm_crash_policy & FTDM_CRASH_ON_ASSERT) { ftdm_abort(); } else { return retval; } }
#define ftdm_socket_close(it) if (it > -1) { close(it); it = -1;}

#define ftdm_channel_lock(chan) ftdm_mutex_lock((chan)->mutex)
#define ftdm_channel_unlock(chan) ftdm_mutex_unlock((chan)->mutex)

#define ftdm_log_throttle(level,...) time_current_throttle_log = ftdm_current_time_in_ms(); if (time_current_throttle_log - time_last_throttle_log > FTDM_THROTTLE_LOG_INTERVAL) { ftdm_log(level, __VA_ARGS__); time_last_throttle_log = time_current_throttle_log; }

#define ftdm_log_chan_ex(fchan,file,func,line,level,format,...) ftdm_log(file, func, line, level, "[s%dc%d][%d:%d] " format, fchan->span_id, fchan->chan_id, fchan->physical_span_id, fchan->physical_chan_id, __VA_ARGS__)

#define ftdm_log_chan_ex_msg(fchan,file,func,line,level,msg) ftdm_log(file, func, line, level, "[s%dc%d][%d:%d] " msg, fchan->span_id, fchan->chan_id, fchan->physical_span_id, fchan->physical_chan_id)

#define ftdm_log_chan(fchan,level,format,...) ftdm_log(level, "[s%dc%d][%d:%d] " format, fchan->span_id, fchan->chan_id, fchan->physical_span_id, fchan->physical_chan_id, __VA_ARGS__)

#define ftdm_log_chan_msg(fchan,level,msg) ftdm_log(level, "[s%dc%d][%d:%d] " msg, fchan->span_id, fchan->chan_id, fchan->physical_span_id, fchan->physical_chan_id)

#define ftdm_log_chan_throttle(fchan,level,format,...) ftdm_log_throttle(level, "[s%dc%d][%d:%d] " format, fchan->span_id, fchan->chan_id, fchan->physical_span_id, fchan->physical_chan_id, __VA_ARGS__)
#define ftdm_log_chan_msg_throttle(fchan,level,format,...) ftdm_log_throttle(level, "[s%dc%d][%d:%d] " format, fchan->span_id, fchan->chan_id, fchan->physical_span_id, fchan->physical_chan_id, __VA_ARGS__)

#define ftdm_span_lock(span) ftdm_mutex_lock(span->mutex)
#define ftdm_span_unlock(span) ftdm_mutex_unlock(span->mutex)

#define ftdm_test_and_set_media(fchan) do { if (!ftdm_test_flag((fchan), FTDM_CHANNEL_MEDIA)) { ftdm_set_flag((fchan), FTDM_CHANNEL_MEDIA); ftdm_set_echocancel_call_begin((fchan)); if ((fchan)->dtmfdbg.requested) { ftdm_channel_command((fchan), FTDM_COMMAND_ENABLE_DEBUG_DTMF, NULL); } } } while (0);
 extern const char *FTDM_LEVEL_NAMES[9];

static __inline__ void ftdm_abort(void)
{

 abort();

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

typedef long ftdm_bitmap_t;
#define FTDM_BITMAP_NBITS (sizeof(ftdm_bitmap_t) * 8)
#define ftdm_map_set_bit(map,bit) (map[(bit/FTDM_BITMAP_NBITS)] |= ((ftdm_bitmap_t)1 << (bit % FTDM_BITMAP_NBITS)))
#define ftdm_map_clear_bit(map,bit) (map[(bit/FTDM_BITMAP_NBITS)] &= ~((ftdm_bitmap_t)1 << (bit % FTDM_BITMAP_NBITS)))
#define ftdm_map_test_bit(map,bit) (map[(bit/FTDM_BITMAP_NBITS)] & ((ftdm_bitmap_t)1 << (bit % FTDM_BITMAP_NBITS)))
#define FTDM_ZT_H 

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

#define ZT_MAX_BLOCKSIZE 8192
#define ZT_DEFAULT_MTU_MRU 2048

#define ZT_CODE 'J'
#define DAHDI_CODE 0xDA

#define ZT_GET_BLOCKSIZE _IOR (ZT_CODE, 1, int)
#define ZT_SET_BLOCKSIZE _IOW (ZT_CODE, 2, int)
#define ZT_FLUSH _IOW (ZT_CODE, 3, int)
#define ZT_SYNC _IOW (ZT_CODE, 4, int)
#define ZT_GET_PARAMS _IOR (ZT_CODE, 5, struct zt_params)
#define ZT_SET_PARAMS _IOW (ZT_CODE, 6, struct zt_params)
#define ZT_HOOK _IOW (ZT_CODE, 7, int)
#define ZT_GETEVENT _IOR (ZT_CODE, 8, int)
#define ZT_IOMUX _IOWR (ZT_CODE, 9, int)
#define ZT_SPANSTAT _IOWR (ZT_CODE, 10, struct zt_spaninfo)
#define ZT_MAINT _IOW (ZT_CODE, 11, struct zt_maintinfo)
#define ZT_GETCONF _IOWR (ZT_CODE, 12, struct zt_confinfo)
#define ZT_SETCONF _IOWR (ZT_CODE, 13, struct zt_confinfo)
#define ZT_CONFLINK _IOW (ZT_CODE, 14, struct zt_confinfo)
#define ZT_CONFDIAG _IOR (ZT_CODE, 15, int)

#define ZT_GETGAINS _IOWR (ZT_CODE, 16, struct zt_gains)
#define ZT_SETGAINS _IOWR (ZT_CODE, 17, struct zt_gains)
#define ZT_SPANCONFIG _IOW (ZT_CODE, 18, struct zt_lineconfig)
#define ZT_CHANCONFIG _IOW (ZT_CODE, 19, struct zt_chanconfig)
#define ZT_SET_BUFINFO _IOW (ZT_CODE, 27, struct zt_bufferinfo)
#define ZT_GET_BUFINFO _IOR (ZT_CODE, 28, struct zt_bufferinfo)
#define ZT_AUDIOMODE _IOW (ZT_CODE, 32, int)
#define ZT_ECHOCANCEL _IOW (ZT_CODE, 33, int)
#define ZT_HDLCRAWMODE _IOW (ZT_CODE, 36, int)
#define ZT_HDLCFCSMODE _IOW (ZT_CODE, 37, int)

#define ZT_SPECIFY _IOW (ZT_CODE, 38, int)

#define ZT_SETLAW _IOW (ZT_CODE, 39, int)

#define ZT_SETLINEAR _IOW (ZT_CODE, 40, int)

#define ZT_GETCONFMUTE _IOR (ZT_CODE, 49, int)
#define ZT_ECHOTRAIN _IOW (ZT_CODE, 50, int)

#define ZT_SETTXBITS _IOW (ZT_CODE, 43, int)
#define ZT_GETRXBITS _IOR (ZT_CODE, 45, int)

#define ZT_TONEDETECT _IOW(ZT_CODE, 91, int)

#define DAHDI_GET_BLOCKSIZE _IOR (DAHDI_CODE, 1, int)
#define DAHDI_SET_BLOCKSIZE _IOW (DAHDI_CODE, 1, int)
#define DAHDI_FLUSH _IOW (DAHDI_CODE, 3, int)
#define DAHDI_SYNC _IO (DAHDI_CODE, 4)
#define DAHDI_GET_PARAMS _IOR (DAHDI_CODE, 5, struct zt_params)
#define DAHDI_SET_PARAMS _IOW (DAHDI_CODE, 5, struct zt_params)
#define DAHDI_HOOK _IOW (DAHDI_CODE, 7, int)
#define DAHDI_GETEVENT _IOR (DAHDI_CODE, 8, int)
#define DAHDI_IOMUX _IOWR (DAHDI_CODE, 9, int)
#define DAHDI_SPANSTAT _IOWR (DAHDI_CODE, 10, struct zt_spaninfo)
#define DAHDI_MAINT _IOW (DAHDI_CODE, 11, struct zt_maintinfo)
#define DAHDI_GETCONF _IOR (DAHDI_CODE, 12, struct zt_confinfo)
#define DAHDI_SETCONF _IOW (DAHDI_CODE, 12, struct zt_confinfo)
#define DAHDI_CONFLINK _IOW (DAHDI_CODE, 14, struct zt_confinfo)
#define DAHDI_CONFDIAG _IOR (DAHDI_CODE, 15, int)

#define DAHDI_GETGAINS _IOR (DAHDI_CODE, 16, struct zt_gains)
#define DAHDI_SETGAINS _IOW (DAHDI_CODE, 16, struct zt_gains)
#define DAHDI_SPANCONFIG _IOW (DAHDI_CODE, 18, struct zt_lineconfig)
#define DAHDI_CHANCONFIG _IOW (DAHDI_CODE, 19, struct zt_chanconfig)
#define DAHDI_SET_BUFINFO _IOW (DAHDI_CODE, 27, struct zt_bufferinfo)
#define DAHDI_GET_BUFINFO _IOR (DAHDI_CODE, 27, struct zt_bufferinfo)
#define DAHDI_AUDIOMODE _IOW (DAHDI_CODE, 32, int)
#define DAHDI_ECHOCANCEL _IOW (DAHDI_CODE, 33, int)
#define DAHDI_HDLCRAWMODE _IOW (DAHDI_CODE, 36, int)
#define DAHDI_HDLCFCSMODE _IOW (DAHDI_CODE, 37, int)

#define DAHDI_ALARM_YELLOW (1 << 2)
#define DAHDI_ALARM_BLUE (1 << 4)

#define DAHDI_SPECIFY _IOW (DAHDI_CODE, 38, int)

#define DAHDI_SETLAW _IOW (DAHDI_CODE, 39, int)

#define DAHDI_SETLINEAR _IOW (DAHDI_CODE, 40, int)

#define DAHDI_GETCONFMUTE _IOR (DAHDI_CODE, 49, int)
#define DAHDI_ECHOTRAIN _IOW (DAHDI_CODE, 50, int)

#define DAHDI_SETTXBITS _IOW (DAHDI_CODE, 43, int)
#define DAHDI_GETRXBITS _IOR (DAHDI_CODE, 43, int)

#define DAHDI_SETPOLARITY _IOW (DAHDI_CODE, 92, int)

#define DAHDI_TONEDETECT _IOW(DAHDI_CODE, 91, int)

#define ELAST 500

static struct{
uint32_t codec_ms;
uint32_t wink_ms;
uint32_t flash_ms;
uint32_t eclevel;
uint32_t etlevel;
float rxgain;
float txgain;
}zt_globals;

typedef int ioctlcmd;

struct ioctl_codes{
ioctlcmd GET_BLOCKSIZE;
ioctlcmd SET_BLOCKSIZE;
ioctlcmd FLUSH;
ioctlcmd SYNC;
ioctlcmd GET_PARAMS;
ioctlcmd SET_PARAMS;
ioctlcmd HOOK;
ioctlcmd GETEVENT;
ioctlcmd IOMUX;
ioctlcmd SPANSTAT;
ioctlcmd MAINT;
ioctlcmd GETCONF;
ioctlcmd SETCONF;
ioctlcmd CONFLINK;
ioctlcmd CONFDIAG;
ioctlcmd GETGAINS;
ioctlcmd SETGAINS;
ioctlcmd SPANCONFIG;
ioctlcmd CHANCONFIG;
ioctlcmd SET_BUFINFO;
ioctlcmd GET_BUFINFO;
ioctlcmd AUDIOMODE;
ioctlcmd ECHOCANCEL;
ioctlcmd HDLCRAWMODE;
ioctlcmd HDLCFCSMODE;
ioctlcmd SPECIFY;
ioctlcmd SETLAW;
ioctlcmd SETLINEAR;
ioctlcmd GETCONFMUTE;
ioctlcmd ECHOTRAIN;
ioctlcmd SETTXBITS;
ioctlcmd GETRXBITS;
ioctlcmd SETPOLARITY;
ioctlcmd TONEDETECT;
};

static struct ioctl_codes zt_ioctl_codes= {
.GET_BLOCKSIZE= 
               (((2U) << (((0 +8)+8)+14)) | (((
               'J'
               )) << (0 +8)) | (((
               1
               )) << 0) | ((((sizeof(
               int
               )))) << ((0 +8)+8)))
                               ,
.SET_BLOCKSIZE= 
               (((1U) << (((0 +8)+8)+14)) | (((
               'J'
               )) << (0 +8)) | (((
               2
               )) << 0) | ((((sizeof(
               int
               )))) << ((0 +8)+8)))
                               ,
.FLUSH= 
       (((1U) << (((0 +8)+8)+14)) | (((
       'J'
       )) << (0 +8)) | (((
       3
       )) << 0) | ((((sizeof(
       int
       )))) << ((0 +8)+8)))
               ,
.SYNC= 
      (((1U) << (((0 +8)+8)+14)) | (((
      'J'
      )) << (0 +8)) | (((
      4
      )) << 0) | ((((sizeof(
      int
      )))) << ((0 +8)+8)))
             ,
.GET_PARAMS= 
            (((2U) << (((0 +8)+8)+14)) | (((
            'J'
            )) << (0 +8)) | (((
            5
            )) << 0) | ((((sizeof(
            struct zt_params
            )))) << ((0 +8)+8)))
                         ,
.SET_PARAMS= 
            (((1U) << (((0 +8)+8)+14)) | (((
            'J'
            )) << (0 +8)) | (((
            6
            )) << 0) | ((((sizeof(
            struct zt_params
            )))) << ((0 +8)+8)))
                         ,
.HOOK= 
      (((1U) << (((0 +8)+8)+14)) | (((
      'J'
      )) << (0 +8)) | (((
      7
      )) << 0) | ((((sizeof(
      int
      )))) << ((0 +8)+8)))
             ,
.GETEVENT= 
          (((2U) << (((0 +8)+8)+14)) | (((
          'J'
          )) << (0 +8)) | (((
          8
          )) << 0) | ((((sizeof(
          int
          )))) << ((0 +8)+8)))
                     ,
.IOMUX= 
       (((2U|1U) << (((0 +8)+8)+14)) | (((
       'J'
       )) << (0 +8)) | (((
       9
       )) << 0) | ((((sizeof(
       int
       )))) << ((0 +8)+8)))
               ,
.SPANSTAT= 
          (((2U|1U) << (((0 +8)+8)+14)) | (((
          'J'
          )) << (0 +8)) | (((
          10
          )) << 0) | ((((sizeof(
          struct zt_spaninfo
          )))) << ((0 +8)+8)))
                     ,
.MAINT= 
       (((1U) << (((0 +8)+8)+14)) | (((
       'J'
       )) << (0 +8)) | (((
       11
       )) << 0) | ((((sizeof(
       struct zt_maintinfo
       )))) << ((0 +8)+8)))
               ,
.GETCONF= 
         (((2U|1U) << (((0 +8)+8)+14)) | (((
         'J'
         )) << (0 +8)) | (((
         12
         )) << 0) | ((((sizeof(
         struct zt_confinfo
         )))) << ((0 +8)+8)))
                   ,
.SETCONF= 
         (((2U|1U) << (((0 +8)+8)+14)) | (((
         'J'
         )) << (0 +8)) | (((
         13
         )) << 0) | ((((sizeof(
         struct zt_confinfo
         )))) << ((0 +8)+8)))
                   ,
.CONFLINK= 
          (((1U) << (((0 +8)+8)+14)) | (((
          'J'
          )) << (0 +8)) | (((
          14
          )) << 0) | ((((sizeof(
          struct zt_confinfo
          )))) << ((0 +8)+8)))
                     ,
.CONFDIAG= 
          (((2U) << (((0 +8)+8)+14)) | (((
          'J'
          )) << (0 +8)) | (((
          15
          )) << 0) | ((((sizeof(
          int
          )))) << ((0 +8)+8)))
                     ,
.GETGAINS= 
          (((2U|1U) << (((0 +8)+8)+14)) | (((
          'J'
          )) << (0 +8)) | (((
          16
          )) << 0) | ((((sizeof(
          struct zt_gains
          )))) << ((0 +8)+8)))
                     ,
.SETGAINS= 
          (((2U|1U) << (((0 +8)+8)+14)) | (((
          'J'
          )) << (0 +8)) | (((
          17
          )) << 0) | ((((sizeof(
          struct zt_gains
          )))) << ((0 +8)+8)))
                     ,
.SPANCONFIG= 
            (((1U) << (((0 +8)+8)+14)) | (((
            'J'
            )) << (0 +8)) | (((
            18
            )) << 0) | ((((sizeof(
            struct zt_lineconfig
            )))) << ((0 +8)+8)))
                         ,
.CHANCONFIG= 
            (((1U) << (((0 +8)+8)+14)) | (((
            'J'
            )) << (0 +8)) | (((
            19
            )) << 0) | ((((sizeof(
            struct zt_chanconfig
            )))) << ((0 +8)+8)))
                         ,
.SET_BUFINFO= 
             (((1U) << (((0 +8)+8)+14)) | (((
             'J'
             )) << (0 +8)) | (((
             27
             )) << 0) | ((((sizeof(
             struct zt_bufferinfo
             )))) << ((0 +8)+8)))
                           ,
.GET_BUFINFO= 
             (((2U) << (((0 +8)+8)+14)) | (((
             'J'
             )) << (0 +8)) | (((
             28
             )) << 0) | ((((sizeof(
             struct zt_bufferinfo
             )))) << ((0 +8)+8)))
                           ,
.AUDIOMODE= 
           (((1U) << (((0 +8)+8)+14)) | (((
           'J'
           )) << (0 +8)) | (((
           32
           )) << 0) | ((((sizeof(
           int
           )))) << ((0 +8)+8)))
                       ,
.ECHOCANCEL= 
            (((1U) << (((0 +8)+8)+14)) | (((
            'J'
            )) << (0 +8)) | (((
            33
            )) << 0) | ((((sizeof(
            int
            )))) << ((0 +8)+8)))
                         ,
.HDLCRAWMODE= 
             (((1U) << (((0 +8)+8)+14)) | (((
             'J'
             )) << (0 +8)) | (((
             36
             )) << 0) | ((((sizeof(
             int
             )))) << ((0 +8)+8)))
                           ,
.HDLCFCSMODE= 
             (((1U) << (((0 +8)+8)+14)) | (((
             'J'
             )) << (0 +8)) | (((
             37
             )) << 0) | ((((sizeof(
             int
             )))) << ((0 +8)+8)))
                           ,
.SPECIFY= 
         (((1U) << (((0 +8)+8)+14)) | (((
         'J'
         )) << (0 +8)) | (((
         38
         )) << 0) | ((((sizeof(
         int
         )))) << ((0 +8)+8)))
                   ,
.SETLAW= 
        (((1U) << (((0 +8)+8)+14)) | (((
        'J'
        )) << (0 +8)) | (((
        39
        )) << 0) | ((((sizeof(
        int
        )))) << ((0 +8)+8)))
                 ,
.SETLINEAR= 
           (((1U) << (((0 +8)+8)+14)) | (((
           'J'
           )) << (0 +8)) | (((
           40
           )) << 0) | ((((sizeof(
           int
           )))) << ((0 +8)+8)))
                       ,
.GETCONFMUTE= 
             (((2U) << (((0 +8)+8)+14)) | (((
             'J'
             )) << (0 +8)) | (((
             49
             )) << 0) | ((((sizeof(
             int
             )))) << ((0 +8)+8)))
                           ,
.ECHOTRAIN= 
           (((1U) << (((0 +8)+8)+14)) | (((
           'J'
           )) << (0 +8)) | (((
           50
           )) << 0) | ((((sizeof(
           int
           )))) << ((0 +8)+8)))
                       ,
.SETTXBITS= 
           (((1U) << (((0 +8)+8)+14)) | (((
           'J'
           )) << (0 +8)) | (((
           43
           )) << 0) | ((((sizeof(
           int
           )))) << ((0 +8)+8)))
                       ,
.GETRXBITS= 
           (((2U) << (((0 +8)+8)+14)) | (((
           'J'
           )) << (0 +8)) | (((
           45
           )) << 0) | ((((sizeof(
           int
           )))) << ((0 +8)+8)))
                       ,
.TONEDETECT= 
            (((1U) << (((0 +8)+8)+14)) | (((
            'J'
            )) << (0 +8)) | (((
            91
            )) << 0) | ((((sizeof(
            int
            )))) << ((0 +8)+8)))
                         ,
};

static struct ioctl_codes dahdi_ioctl_codes= {
.GET_BLOCKSIZE= 
               (((2U) << (((0 +8)+8)+14)) | (((
               0xDA
               )) << (0 +8)) | (((
               1
               )) << 0) | ((((sizeof(
               int
               )))) << ((0 +8)+8)))
                                  ,
.SET_BLOCKSIZE= 
               (((1U) << (((0 +8)+8)+14)) | (((
               0xDA
               )) << (0 +8)) | (((
               1
               )) << 0) | ((((sizeof(
               int
               )))) << ((0 +8)+8)))
                                  ,
.FLUSH= 
       (((1U) << (((0 +8)+8)+14)) | (((
       0xDA
       )) << (0 +8)) | (((
       3
       )) << 0) | ((((sizeof(
       int
       )))) << ((0 +8)+8)))
                  ,
.SYNC= 
      (((0U) << (((0 +8)+8)+14)) | (((
      0xDA
      )) << (0 +8)) | (((
      4
      )) << 0) | ((0) << ((0 +8)+8)))
                ,
.GET_PARAMS= 
            (((2U) << (((0 +8)+8)+14)) | (((
            0xDA
            )) << (0 +8)) | (((
            5
            )) << 0) | ((((sizeof(
            struct zt_params
            )))) << ((0 +8)+8)))
                            ,
.SET_PARAMS= 
            (((1U) << (((0 +8)+8)+14)) | (((
            0xDA
            )) << (0 +8)) | (((
            5
            )) << 0) | ((((sizeof(
            struct zt_params
            )))) << ((0 +8)+8)))
                            ,
.HOOK= 
      (((1U) << (((0 +8)+8)+14)) | (((
      0xDA
      )) << (0 +8)) | (((
      7
      )) << 0) | ((((sizeof(
      int
      )))) << ((0 +8)+8)))
                ,
.GETEVENT= 
          (((2U) << (((0 +8)+8)+14)) | (((
          0xDA
          )) << (0 +8)) | (((
          8
          )) << 0) | ((((sizeof(
          int
          )))) << ((0 +8)+8)))
                        ,
.IOMUX= 
       (((2U|1U) << (((0 +8)+8)+14)) | (((
       0xDA
       )) << (0 +8)) | (((
       9
       )) << 0) | ((((sizeof(
       int
       )))) << ((0 +8)+8)))
                  ,
.SPANSTAT= 
          (((2U|1U) << (((0 +8)+8)+14)) | (((
          0xDA
          )) << (0 +8)) | (((
          10
          )) << 0) | ((((sizeof(
          struct zt_spaninfo
          )))) << ((0 +8)+8)))
                        ,
.MAINT= 
       (((1U) << (((0 +8)+8)+14)) | (((
       0xDA
       )) << (0 +8)) | (((
       11
       )) << 0) | ((((sizeof(
       struct zt_maintinfo
       )))) << ((0 +8)+8)))
                  ,
.GETCONF= 
         (((2U) << (((0 +8)+8)+14)) | (((
         0xDA
         )) << (0 +8)) | (((
         12
         )) << 0) | ((((sizeof(
         struct zt_confinfo
         )))) << ((0 +8)+8)))
                      ,
.SETCONF= 
         (((1U) << (((0 +8)+8)+14)) | (((
         0xDA
         )) << (0 +8)) | (((
         12
         )) << 0) | ((((sizeof(
         struct zt_confinfo
         )))) << ((0 +8)+8)))
                      ,
.CONFLINK= 
          (((1U) << (((0 +8)+8)+14)) | (((
          0xDA
          )) << (0 +8)) | (((
          14
          )) << 0) | ((((sizeof(
          struct zt_confinfo
          )))) << ((0 +8)+8)))
                        ,
.CONFDIAG= 
          (((2U) << (((0 +8)+8)+14)) | (((
          0xDA
          )) << (0 +8)) | (((
          15
          )) << 0) | ((((sizeof(
          int
          )))) << ((0 +8)+8)))
                        ,
.GETGAINS= 
          (((2U) << (((0 +8)+8)+14)) | (((
          0xDA
          )) << (0 +8)) | (((
          16
          )) << 0) | ((((sizeof(
          struct zt_gains
          )))) << ((0 +8)+8)))
                        ,
.SETGAINS= 
          (((1U) << (((0 +8)+8)+14)) | (((
          0xDA
          )) << (0 +8)) | (((
          16
          )) << 0) | ((((sizeof(
          struct zt_gains
          )))) << ((0 +8)+8)))
                        ,
.SPANCONFIG= 
            (((1U) << (((0 +8)+8)+14)) | (((
            0xDA
            )) << (0 +8)) | (((
            18
            )) << 0) | ((((sizeof(
            struct zt_lineconfig
            )))) << ((0 +8)+8)))
                            ,
.CHANCONFIG= 
            (((1U) << (((0 +8)+8)+14)) | (((
            0xDA
            )) << (0 +8)) | (((
            19
            )) << 0) | ((((sizeof(
            struct zt_chanconfig
            )))) << ((0 +8)+8)))
                            ,
.SET_BUFINFO= 
             (((1U) << (((0 +8)+8)+14)) | (((
             0xDA
             )) << (0 +8)) | (((
             27
             )) << 0) | ((((sizeof(
             struct zt_bufferinfo
             )))) << ((0 +8)+8)))
                              ,
.GET_BUFINFO= 
             (((2U) << (((0 +8)+8)+14)) | (((
             0xDA
             )) << (0 +8)) | (((
             27
             )) << 0) | ((((sizeof(
             struct zt_bufferinfo
             )))) << ((0 +8)+8)))
                              ,
.AUDIOMODE= 
           (((1U) << (((0 +8)+8)+14)) | (((
           0xDA
           )) << (0 +8)) | (((
           32
           )) << 0) | ((((sizeof(
           int
           )))) << ((0 +8)+8)))
                          ,
.ECHOCANCEL= 
            (((1U) << (((0 +8)+8)+14)) | (((
            0xDA
            )) << (0 +8)) | (((
            33
            )) << 0) | ((((sizeof(
            int
            )))) << ((0 +8)+8)))
                            ,
.HDLCRAWMODE= 
             (((1U) << (((0 +8)+8)+14)) | (((
             0xDA
             )) << (0 +8)) | (((
             36
             )) << 0) | ((((sizeof(
             int
             )))) << ((0 +8)+8)))
                              ,
.HDLCFCSMODE= 
             (((1U) << (((0 +8)+8)+14)) | (((
             0xDA
             )) << (0 +8)) | (((
             37
             )) << 0) | ((((sizeof(
             int
             )))) << ((0 +8)+8)))
                              ,
.SPECIFY= 
         (((1U) << (((0 +8)+8)+14)) | (((
         0xDA
         )) << (0 +8)) | (((
         38
         )) << 0) | ((((sizeof(
         int
         )))) << ((0 +8)+8)))
                      ,
.SETLAW= 
        (((1U) << (((0 +8)+8)+14)) | (((
        0xDA
        )) << (0 +8)) | (((
        39
        )) << 0) | ((((sizeof(
        int
        )))) << ((0 +8)+8)))
                    ,
.SETLINEAR= 
           (((1U) << (((0 +8)+8)+14)) | (((
           0xDA
           )) << (0 +8)) | (((
           40
           )) << 0) | ((((sizeof(
           int
           )))) << ((0 +8)+8)))
                          ,
.GETCONFMUTE= 
             (((2U) << (((0 +8)+8)+14)) | (((
             0xDA
             )) << (0 +8)) | (((
             49
             )) << 0) | ((((sizeof(
             int
             )))) << ((0 +8)+8)))
                              ,
.ECHOTRAIN= 
           (((1U) << (((0 +8)+8)+14)) | (((
           0xDA
           )) << (0 +8)) | (((
           50
           )) << 0) | ((((sizeof(
           int
           )))) << ((0 +8)+8)))
                          ,
.SETTXBITS= 
           (((1U) << (((0 +8)+8)+14)) | (((
           0xDA
           )) << (0 +8)) | (((
           43
           )) << 0) | ((((sizeof(
           int
           )))) << ((0 +8)+8)))
                          ,
.GETRXBITS= 
           (((2U) << (((0 +8)+8)+14)) | (((
           0xDA
           )) << (0 +8)) | (((
           43
           )) << 0) | ((((sizeof(
           int
           )))) << ((0 +8)+8)))
                          ,
.SETPOLARITY= 
             (((1U) << (((0 +8)+8)+14)) | (((
             0xDA
             )) << (0 +8)) | (((
             92
             )) << 0) | ((((sizeof(
             int
             )))) << ((0 +8)+8)))
                              ,
.TONEDETECT= 
            (((1U) << (((0 +8)+8)+14)) | (((
            0xDA
            )) << (0 +8)) | (((
            91
            )) << 0) | ((((sizeof(
            int
            )))) << ((0 +8)+8)))
                            ,
};

#define ZT_INVALID_SOCKET -1
static struct ioctl_codes codes;
static const char*ctlpath= 
                          ((void *)0)
                              ;
static const char*chanpath= 
                           ((void *)0)
                               ;

static const char dahdi_ctlpath[]= "/dev/dahdi/ctl";
static const char dahdi_chanpath[]= "/dev/dahdi/channel";

static const char zt_ctlpath[]= "/dev/zap/ctl";
static const char zt_chanpath[]= "/dev/zap/channel";

static ftdm_socket_t CONTROL_FD= -1;

ftdm_status_t zt_next_event (ftdm_span_t *span, ftdm_event_t **event);
ftdm_status_t zt_poll_event (ftdm_span_t *span, uint32_t ms, short *poll_events);
ftdm_status_t zt_channel_next_event (ftdm_channel_t *ftdmchan, ftdm_event_t **event);
static void zt_build_gains(struct zt_gains*g,float rxgain,float txgain,int codec)
{
int j;
int k;
float linear_rxgain= pow(10.0,rxgain/20.0);
float linear_txgain= pow(10.0,txgain/20.0);

switch(codec){
case FTDM_CODEC_ALAW:
for(j= 0;j<(sizeof(g->receive_gain)/sizeof(g->receive_gain[0]));j++){
if(rxgain){
k= (int)(((float)alaw_to_linear(j))*linear_rxgain);
if(k> 32767)k= 32767;
if(k<-32767)k= -32767;
g->receive_gain[j]= linear_to_alaw(k);
}else{
g->receive_gain[j]= j;
}
if(txgain){
k= (int)(((float)alaw_to_linear(j))*linear_txgain);
if(k> 32767)k= 32767;
if(k<-32767)k= -32767;
g->transmit_gain[j]= linear_to_alaw(k);
}else{
g->transmit_gain[j]= j;
}
}
break;
case FTDM_CODEC_ULAW:
for(j= 0;j<(sizeof(g->receive_gain)/sizeof(g->receive_gain[0]));j++){
if(rxgain){
k= (int)(((float)ulaw_to_linear(j))*linear_rxgain);
if(k> 32767)k= 32767;
if(k<-32767)k= -32767;
g->receive_gain[j]= linear_to_ulaw(k);
}else{
g->receive_gain[j]= j;
}
if(txgain){
k= (int)(((float)ulaw_to_linear(j))*linear_txgain);
if(k> 32767)k= 32767;
if(k<-32767)k= -32767;
g->transmit_gain[j]= linear_to_ulaw(k);
}else{
g->transmit_gain[j]= j;
}
}
break;
}
}
static unsigned zt_open_range(ftdm_span_t*span,unsigned start,unsigned end,ftdm_chan_type_t type,char*name,char*number,unsigned char cas_bits)
{
unsigned configured= 0,x;
zt_params_t ztp;
zt_tone_mode_t mode= 0;

memset(&ztp,0,sizeof(ztp));

if(type==FTDM_CHAN_TYPE_CAS){
ftdm_log("./ftmod_zt.w", __func__, 283, 7,"Configuring CAS channels with abcd == 0x%X\n",cas_bits);
}
for(x= start;x<end;x++){
ftdm_channel_t*ftdmchan;
ftdm_socket_t sockfd= -1;
int len;

sockfd= open(chanpath,
                     02
                           );
if(sockfd!=-1&&ftdm_span_add_channel(span,sockfd,type,&ftdmchan)==FTDM_SUCCESS){

if(ioctl(sockfd,codes.SPECIFY,&x)){
ftdm_log("./ftmod_zt.w", __func__, 294, 3,"failure configuring device %s chan %d fd %d (%s)\n",chanpath,x,sockfd,strerror(
                                                                                                       (*__errno_location ())
                                                                                                            ));
close(sockfd);
continue;
}

if(ftdmchan->type==FTDM_CHAN_TYPE_DQ921){
struct zt_bufferinfo binfo;
memset(&binfo,0,sizeof(binfo));
binfo.txbufpolicy= 0;
binfo.rxbufpolicy= 0;
binfo.numbufs= 32;
binfo.bufsize= 1024;
if(ioctl(sockfd,codes.SET_BUFINFO,&binfo)){
ftdm_log("./ftmod_zt.w", __func__, 307, 3,"failure configuring device %s as FreeTDM device %d:%d fd:%d\n",chanpath,ftdmchan->span_id,ftdmchan->chan_id,sockfd);
close(sockfd);
continue;
}
}

if(type==FTDM_CHAN_TYPE_FXS||type==FTDM_CHAN_TYPE_FXO){
struct zt_chanconfig cc;
memset(&cc,0,sizeof(cc));
cc.chan= cc.master= x;

switch(type){
case FTDM_CHAN_TYPE_FXS:
{
switch(span->start_type){
case FTDM_ANALOG_START_KEWL:
cc.sigtype= ZT_SIG_FXOKS;
break;
case FTDM_ANALOG_START_LOOP:
cc.sigtype= ZT_SIG_FXOLS;
break;
case FTDM_ANALOG_START_GROUND:
cc.sigtype= ZT_SIG_FXOGS;
break;
default:
break;
}
}
break;
case FTDM_CHAN_TYPE_FXO:
{
switch(span->start_type){
case FTDM_ANALOG_START_KEWL:
cc.sigtype= ZT_SIG_FXSKS;
break;
case FTDM_ANALOG_START_LOOP:
cc.sigtype= ZT_SIG_FXSLS;
break;
case FTDM_ANALOG_START_GROUND:
cc.sigtype= ZT_SIG_FXSGS;
break;
default:
break;
}
}
break;
default:
break;
}
}

if(type==FTDM_CHAN_TYPE_CAS){
struct zt_chanconfig cc;
memset(&cc,0,sizeof(cc));
cc.chan= cc.master= x;
cc.sigtype= ZT_SIG_CAS;
cc.idlebits= cas_bits;
if(ioctl(CONTROL_FD,codes.CHANCONFIG,&cc)){
ftdm_log("./ftmod_zt.w", __func__, 365, 3,"failure configuring device %s as FreeTDM device %d:%d fd:%d err:%s\n",chanpath,ftdmchan->span_id,ftdmchan->chan_id,sockfd,strerror(
                                                                                                                                                           (*__errno_location ())
                                                                                                                                                                ));
close(sockfd);
continue;
}
}

if(ftdmchan->type!=FTDM_CHAN_TYPE_DQ921&&ftdmchan->type!=FTDM_CHAN_TYPE_DQ931){
len= zt_globals.codec_ms*8;
if(ioctl(ftdmchan->sockfd,codes.SET_BLOCKSIZE,&len)){
ftdm_log("./ftmod_zt.w", __func__, 374, 3,"failure configuring device %s as FreeTDM device %d:%d fd:%d err:%s\n",
chanpath,ftdmchan->span_id,ftdmchan->chan_id,sockfd,strerror(
                                                            (*__errno_location ())
                                                                 ));
close(sockfd);
continue;
}

ftdmchan->packet_len= len;
ftdmchan->effective_interval= ftdmchan->native_interval= ftdmchan->packet_len/8;

if(ftdmchan->effective_codec==FTDM_CODEC_SLIN){
ftdmchan->packet_len*= 2;
}
}

if(ioctl(sockfd,codes.GET_PARAMS,&ztp)<0){
ftdm_log("./ftmod_zt.w", __func__, 389, 3,"failure configuring device %s as FreeTDM device %d:%d fd:%d\n",chanpath,ftdmchan->span_id,ftdmchan->chan_id,sockfd);
close(sockfd);
continue;
}

if(ftdmchan->type==FTDM_CHAN_TYPE_DQ921){
if(
(ztp.sig_type!=ZT_SIG_HDLCRAW)&&
(ztp.sig_type!=ZT_SIG_HDLCFCS)&&
(ztp.sig_type!=ZT_SIG_HARDHDLC)
){
ftdm_log("./ftmod_zt.w", __func__, 400, 3,"Failure configuring device %s as FreeTDM device %d:%d fd:%d, hardware signaling is not HDLC, fix your Zap/DAHDI configuration!\n",chanpath,ftdmchan->span_id,ftdmchan->chan_id,sockfd);
close(sockfd);
continue;
}
}

ftdm_log("./ftmod_zt.w", __func__, 406, 6,"configuring device %s channel %d as FreeTDM device %d:%d fd:%d\n",chanpath,x,ftdmchan->span_id,ftdmchan->chan_id,sockfd);

ftdmchan->rate= 8000;
ftdmchan->physical_span_id= ztp.span_no;
ftdmchan->physical_chan_id= ztp.chan_no;

if(type==FTDM_CHAN_TYPE_FXS||type==FTDM_CHAN_TYPE_FXO||type==FTDM_CHAN_TYPE_EM||type==FTDM_CHAN_TYPE_B){
if(ztp.g711_type==ZT_G711_ALAW){
ftdmchan->native_codec= ftdmchan->effective_codec= FTDM_CODEC_ALAW;
}else if(ztp.g711_type==ZT_G711_MULAW){
ftdmchan->native_codec= ftdmchan->effective_codec= FTDM_CODEC_ULAW;
}else{
int type;

if(ftdmchan->span->trunk_type==FTDM_TRUNK_E1){
type= FTDM_CODEC_ALAW;
}else{
type= FTDM_CODEC_ULAW;
}

ftdmchan->native_codec= ftdmchan->effective_codec= type;

}
}

ztp.wink_time= zt_globals.wink_ms;
ztp.flash_time= zt_globals.flash_ms;

if(ioctl(sockfd,codes.SET_PARAMS,&ztp)<0){
ftdm_log("./ftmod_zt.w", __func__, 435, 3,"failure configuring device %s as FreeTDM device %d:%d fd:%d\n",chanpath,ftdmchan->span_id,ftdmchan->chan_id,sockfd);
close(sockfd);
continue;
}

mode= ZT_TONEDETECT_ON|ZT_TONEDETECT_MUTE;
if(ioctl(sockfd,codes.TONEDETECT,&mode)){
ftdm_log("./ftmod_zt.w", __func__, 442, 7,"HW DTMF not available on FreeTDM device %d:%d fd:%d\n",ftdmchan->span_id,ftdmchan->chan_id,sockfd);
}else{
ftdm_log("./ftmod_zt.w", __func__, 444, 7,"HW DTMF available on FreeTDM device %d:%d fd:%d\n",ftdmchan->span_id,ftdmchan->chan_id,sockfd);
(ftdmchan)->features = (ftdm_channel_feature_t)((ftdmchan)->features | FTDM_CHANNEL_FEATURE_DTMF_DETECT);
mode= 0;
ioctl(sockfd,codes.TONEDETECT,&mode);
}

if(!(!name || *name == '\0')){
strncpy(ftdmchan->chan_name, name, sizeof(ftdmchan->chan_name) - 1);
}
if(!(!number || *number == '\0')){
strncpy(ftdmchan->chan_number, number, sizeof(ftdmchan->chan_number) - 1);
}

configured++;
}else{
ftdm_log("./ftmod_zt.w", __func__, 459, 3,"failure configuring device %s\n",chanpath);
}
}

return configured;
}
static ftdm_status_t zt_configure_span (ftdm_span_t *span, const char *str, ftdm_chan_type_t type, char *name, char *number)
{

int items,i;
char*mydata,*item_list[10];
char*ch,*mx;
unsigned char cas_bits= 0;
int channo;
int top= 0;
unsigned configured= 0;

((void) sizeof ((
str!=
((void *)0)) ? 1 : 0), __extension__ ({ if (
str!=
((void *)0)) ; else __assert_fail (
"str!=NULL"
, "./ftmod_zt.w", 488, __extension__ __PRETTY_FUNCTION__); }))
                ;

mydata= ftdm_strdup(str);

((void) sizeof ((
mydata!=
((void *)0)) ? 1 : 0), __extension__ ({ if (
mydata!=
((void *)0)) ; else __assert_fail (
"mydata!=NULL"
, "./ftmod_zt.w", 492, __extension__ __PRETTY_FUNCTION__); }))
                   ;

items= ftdm_separate_string(mydata,',',item_list,(sizeof(item_list)/sizeof(item_list[0])));

for(i= 0;i<items;i++){
ch= item_list[i];

if(!(ch)){
ftdm_log("./ftmod_zt.w", __func__, 501, 3,"Invalid input\n");
continue;
}

channo= atoi(ch);

if(channo<0){
ftdm_log("./ftmod_zt.w", __func__, 508, 3,"Invalid channel number %d\n",channo);
continue;
}

if((mx= strchr(ch,'-'))){
mx++;
top= atoi(mx)+1;
}else{
top= channo+1;
}

if(top<0){
ftdm_log("./ftmod_zt.w", __func__, 521, 3,"Invalid range number %d\n",top);
continue;
}
if(FTDM_CHAN_TYPE_CAS==type&&ftdm_config_get_cas_bits(ch,&cas_bits)){
ftdm_log("./ftmod_zt.w", __func__, 525, 3,"Failed to get CAS bits in CAS channel\n");
continue;
}
configured+= zt_open_range(span,channo,top,type,name,number,cas_bits);

}

if (mydata) { g_ftdm_mem_handler.free(g_ftdm_mem_handler.pool, mydata); mydata = 
((void *)0)
; };

return configured;

}
static ftdm_status_t zt_configure (const char *category, const char *var, const char *val, int lineno)
{

int num;
float fnum;

if(!strcasecmp(category,"defaults")){
if(!strcasecmp(var,"codec_ms")){
num= atoi(val);
if(num<10||num> 60){
ftdm_log("./ftmod_zt.w", __func__, 556, 4,"invalid codec ms at line %d\n",lineno);
}else{
zt_globals.codec_ms= num;
}
}else if(!strcasecmp(var,"wink_ms")){
num= atoi(val);
if(num<50||num> 3000){
ftdm_log("./ftmod_zt.w", __func__, 563, 4,"invalid wink ms at line %d\n",lineno);
}else{
zt_globals.wink_ms= num;
}
}else if(!strcasecmp(var,"flash_ms")){
num= atoi(val);
if(num<50||num> 3000){
ftdm_log("./ftmod_zt.w", __func__, 570, 4,"invalid flash ms at line %d\n",lineno);
}else{
zt_globals.flash_ms= num;
}
}else if(!strcasecmp(var,"echo_cancel_level")){
num= atoi(val);
if(num<0||num> 1024){
ftdm_log("./ftmod_zt.w", __func__, 577, 4,"invalid echo can val at line %d\n",lineno);
}else{
zt_globals.eclevel= num;
}
}else if(!strcasecmp(var,"echo_train_level")){
if(zt_globals.eclevel<1){
ftdm_log("./ftmod_zt.w", __func__, 583, 4,"can't set echo train level without setting echo cancel level first at line %d\n",lineno);
}else{
num= atoi(val);
if(num<0||num> 256){
ftdm_log("./ftmod_zt.w", __func__, 587, 4,"invalid echo train val at line %d\n",lineno);
}else{
zt_globals.etlevel= num;
}
}
}else if(!strcasecmp(var,"rxgain")){
fnum= (float)atof(val);
if(fnum<-100.0||fnum> 100.0){
ftdm_log("./ftmod_zt.w", __func__, 595, 4,"invalid rxgain val at line %d\n",lineno);
}else{
zt_globals.rxgain= fnum;
ftdm_log("./ftmod_zt.w", __func__, 598, 6,"Setting rxgain val to %f\n",fnum);
}
}else if(!strcasecmp(var,"txgain")){
fnum= (float)atof(val);
if(fnum<-100.0||fnum> 100.0){
ftdm_log("./ftmod_zt.w", __func__, 603, 4,"invalid txgain val at line %d\n",lineno);
}else{
zt_globals.txgain= fnum;
ftdm_log("./ftmod_zt.w", __func__, 606, 6,"Setting txgain val to %f\n",fnum);
}
}else{
ftdm_log("./ftmod_zt.w", __func__, 609, 4,"Ignoring unknown setting '%s'\n",var);
}
}

return FTDM_SUCCESS;
}

static ftdm_status_t zt_open (ftdm_channel_t *ftdmchan)
{
(ftdmchan)->features = (ftdm_channel_feature_t)((ftdmchan)->features | FTDM_CHANNEL_FEATURE_INTERVAL);

if(ftdmchan->type==FTDM_CHAN_TYPE_DQ921||ftdmchan->type==FTDM_CHAN_TYPE_DQ931){
ftdmchan->native_codec= ftdmchan->effective_codec= FTDM_CODEC_NONE;
}else{
int blocksize= zt_globals.codec_ms*(ftdmchan->rate/1000);
int err;
if((err= ioctl(ftdmchan->sockfd,codes.SET_BLOCKSIZE,&blocksize))){
snprintf(ftdmchan->last_error,sizeof(ftdmchan->last_error),"%s",strerror(
                                                                        (*__errno_location ())
                                                                             ));
return FTDM_FAIL;
}else{
ftdmchan->effective_interval= ftdmchan->native_interval;
ftdmchan->packet_len= blocksize;
ftdmchan->native_codec= ftdmchan->effective_codec;
}

if(ftdmchan->type==FTDM_CHAN_TYPE_B){
int one= 1;
if(ioctl(ftdmchan->sockfd,codes.AUDIOMODE,&one)){
snprintf(ftdmchan->last_error,sizeof(ftdmchan->last_error),"%s",strerror(
                                                                        (*__errno_location ())
                                                                             ));
ftdm_log("./ftmod_zt.w", __func__, 643, 3,"%s\n",ftdmchan->last_error);
return FTDM_FAIL;
}
}
if(zt_globals.rxgain||zt_globals.txgain){
struct zt_gains gains;
memset(&gains,0,sizeof(gains));

gains.chan_no= ftdmchan->physical_chan_id;
zt_build_gains(&gains,zt_globals.rxgain,zt_globals.txgain,ftdmchan->native_codec);

if(zt_globals.rxgain)
ftdm_log("./ftmod_zt.w", __func__, 655, 6,"Setting rxgain to %f on channel %d\n",zt_globals.rxgain,gains.chan_no);

if(zt_globals.txgain)
ftdm_log("./ftmod_zt.w", __func__, 658, 6,"Setting txgain to %f on channel %d\n",zt_globals.txgain,gains.chan_no);

if(ioctl(ftdmchan->sockfd,codes.SETGAINS,&gains)<0){
ftdm_log("./ftmod_zt.w", __func__, 661, 3,"failure configuring device %s as FreeTDM device %d:%d fd:%d\n",chanpath,ftdmchan->span_id,ftdmchan->chan_id,ftdmchan->sockfd);
}
}

if(1){
int len= zt_globals.eclevel;
if(len){
ftdm_log("./ftmod_zt.w", __func__, 668, 6,"Setting echo cancel to %d taps for %d:%d\n",len,ftdmchan->span_id,ftdmchan->chan_id);
}else{
ftdm_log("./ftmod_zt.w", __func__, 670, 6,"Disable echo cancel for %d:%d\n",ftdmchan->span_id,ftdmchan->chan_id);
}
if(ioctl(ftdmchan->sockfd,codes.ECHOCANCEL,&len)){
ftdm_log("./ftmod_zt.w", __func__, 673, 4,"Echo cancel not available for %d:%d\n",ftdmchan->span_id,ftdmchan->chan_id);
}else if(zt_globals.etlevel> 0){
len= zt_globals.etlevel;
if(ioctl(ftdmchan->sockfd,codes.ECHOTRAIN,&len)){
ftdm_log("./ftmod_zt.w", __func__, 677, 4,"Echo training not available for %d:%d\n",ftdmchan->span_id,ftdmchan->chan_id);
}
}
}
}
return FTDM_SUCCESS;
}

static ftdm_status_t zt_close (ftdm_channel_t *ftdmchan)
{
if(ftdmchan->type==FTDM_CHAN_TYPE_B){
int value= 0;
if(ioctl(ftdmchan->sockfd,codes.AUDIOMODE,&value)){
snprintf(ftdmchan->last_error,sizeof(ftdmchan->last_error),"%s",strerror(
                                                                        (*__errno_location ())
                                                                             ));
ftdm_log("./ftmod_zt.w", __func__, 696, 3,"%s\n",ftdmchan->last_error);
return FTDM_FAIL;
}
}
return FTDM_SUCCESS;
}
static ftdm_status_t zt_command (ftdm_channel_t *ftdmchan, ftdm_command_t command, void *obj)
{
zt_params_t ztp;
int err= 0;

memset(&ztp,0,sizeof(ztp));

switch(command){
case FTDM_COMMAND_ENABLE_ECHOCANCEL:
{
int level= *((int *)obj);
err= ioctl(ftdmchan->sockfd,codes.ECHOCANCEL,&level);
*((int *)obj)= level;
}
case FTDM_COMMAND_DISABLE_ECHOCANCEL:
{
int level= 0;
err= ioctl(ftdmchan->sockfd,codes.ECHOCANCEL,&level);
*((int *)obj)= level;
}
break;
case FTDM_COMMAND_ENABLE_ECHOTRAIN:
{
int level= *((int *)obj);
err= ioctl(ftdmchan->sockfd,codes.ECHOTRAIN,&level);
*((int *)obj)= level;
}
case FTDM_COMMAND_DISABLE_ECHOTRAIN:
{
int level= 0;
err= ioctl(ftdmchan->sockfd,codes.ECHOTRAIN,&level);
*((int *)obj)= level;
}
break;
case FTDM_COMMAND_OFFHOOK:
{
int command= ZT_OFFHOOK;
if(ioctl(ftdmchan->sockfd,codes.HOOK,&command)){
ftdm_log("./ftmod_zt.w", __func__, 748, 3, "[s%dc%d][%d:%d] " "OFFHOOK Failed", ftdmchan->span_id, ftdmchan->chan_id, ftdmchan->physical_span_id, ftdmchan->physical_chan_id);
return FTDM_FAIL;
}
ftdm_log("./ftmod_zt.w", __func__, 751, 7, "[s%dc%d][%d:%d] " "Channel is now offhook\n", ftdmchan->span_id, ftdmchan->chan_id, ftdmchan->physical_span_id, ftdmchan->physical_chan_id);

((void) sizeof ((
ftdmchan->mutex != 
((void *)0)) ? 1 : 0), __extension__ ({ if (
ftdmchan->mutex != 
((void *)0)) ; else __assert_fail (
"ftdmchan->mutex != NULL"
, "./ftmod_zt.w", 752, __extension__ __PRETTY_FUNCTION__); }))
; _ftdm_mutex_lock("./ftmod_zt.w", 752, (const char *)__func__, ftdmchan->mutex); (ftdmchan)->flags |= ((1ULL << 14)); _ftdm_mutex_unlock("./ftmod_zt.w", 752, (const char *)__func__, ftdmchan->mutex);;
}
break;
case FTDM_COMMAND_ONHOOK:
{
int command= ZT_ONHOOK;
if(ioctl(ftdmchan->sockfd,codes.HOOK,&command)){
ftdm_log("./ftmod_zt.w", __func__, 759, 3, "[s%dc%d][%d:%d] " "ONHOOK Failed", ftdmchan->span_id, ftdmchan->chan_id, ftdmchan->physical_span_id, ftdmchan->physical_chan_id);
return FTDM_FAIL;
}
ftdm_log("./ftmod_zt.w", __func__, 762, 7, "[s%dc%d][%d:%d] " "Channel is now onhook\n", ftdmchan->span_id, ftdmchan->chan_id, ftdmchan->physical_span_id, ftdmchan->physical_chan_id);

((void) sizeof ((
ftdmchan->mutex != 
((void *)0)) ? 1 : 0), __extension__ ({ if (
ftdmchan->mutex != 
((void *)0)) ; else __assert_fail (
"ftdmchan->mutex != NULL"
, "./ftmod_zt.w", 763, __extension__ __PRETTY_FUNCTION__); }))
; _ftdm_mutex_lock("./ftmod_zt.w", 763, (const char *)__func__, ftdmchan->mutex); (ftdmchan)->flags &= ~((1ULL << 14)); _ftdm_mutex_unlock("./ftmod_zt.w", 763, (const char *)__func__, ftdmchan->mutex);;
}
break;
case FTDM_COMMAND_FLASH:
{
int command= ZT_FLASH;
if(ioctl(ftdmchan->sockfd,codes.HOOK,&command)){
ftdm_log("./ftmod_zt.w", __func__, 770, 3, "[s%dc%d][%d:%d] " "FLASH Failed", ftdmchan->span_id, ftdmchan->chan_id, ftdmchan->physical_span_id, ftdmchan->physical_chan_id);
return FTDM_FAIL;
}
}
break;
case FTDM_COMMAND_WINK:
{
int command= ZT_WINK;
if(ioctl(ftdmchan->sockfd,codes.HOOK,&command)){
ftdm_log("./ftmod_zt.w", __func__, 779, 3, "[s%dc%d][%d:%d] " "WINK Failed", ftdmchan->span_id, ftdmchan->chan_id, ftdmchan->physical_span_id, ftdmchan->physical_chan_id);
return FTDM_FAIL;
}
}
break;
case FTDM_COMMAND_GENERATE_RING_ON:
{
int command= ZT_RING;
if(ioctl(ftdmchan->sockfd,codes.HOOK,&command)){
ftdm_log("./ftmod_zt.w", __func__, 788, 3, "[s%dc%d][%d:%d] " "RING Failed", ftdmchan->span_id, ftdmchan->chan_id, ftdmchan->physical_span_id, ftdmchan->physical_chan_id);
return FTDM_FAIL;
}

((void) sizeof ((
ftdmchan->mutex != 
((void *)0)) ? 1 : 0), __extension__ ({ if (
ftdmchan->mutex != 
((void *)0)) ; else __assert_fail (
"ftdmchan->mutex != NULL"
, "./ftmod_zt.w", 791, __extension__ __PRETTY_FUNCTION__); }))
; _ftdm_mutex_lock("./ftmod_zt.w", 791, (const char *)__func__, ftdmchan->mutex); (ftdmchan)->flags |= ((1ULL << 15)); _ftdm_mutex_unlock("./ftmod_zt.w", 791, (const char *)__func__, ftdmchan->mutex);;
}
break;
case FTDM_COMMAND_GENERATE_RING_OFF:
{
int command= ZT_RINGOFF;
if(ioctl(ftdmchan->sockfd,codes.HOOK,&command)){
ftdm_log("./ftmod_zt.w", __func__, 798, 3, "[s%dc%d][%d:%d] " "Ring-off Failed", ftdmchan->span_id, ftdmchan->chan_id, ftdmchan->physical_span_id, ftdmchan->physical_chan_id);
return FTDM_FAIL;
}

((void) sizeof ((
ftdmchan->mutex != 
((void *)0)) ? 1 : 0), __extension__ ({ if (
ftdmchan->mutex != 
((void *)0)) ; else __assert_fail (
"ftdmchan->mutex != NULL"
, "./ftmod_zt.w", 801, __extension__ __PRETTY_FUNCTION__); }))
; _ftdm_mutex_lock("./ftmod_zt.w", 801, (const char *)__func__, ftdmchan->mutex); (ftdmchan)->flags &= ~((1ULL << 15)); _ftdm_mutex_unlock("./ftmod_zt.w", 801, (const char *)__func__, ftdmchan->mutex);;
}
break;
case FTDM_COMMAND_GET_INTERVAL:
{

if(!(err= ioctl(ftdmchan->sockfd,codes.GET_BLOCKSIZE,&ftdmchan->packet_len))){
ftdmchan->native_interval= ftdmchan->packet_len/8;
if(ftdmchan->effective_codec==FTDM_CODEC_SLIN){
ftdmchan->packet_len*= 2;
}
*((int *)obj)= ftdmchan->native_interval;
}
}
break;
case FTDM_COMMAND_SET_INTERVAL:
{
int interval= *((int *)obj);
int len= interval*8;

if(!(err= ioctl(ftdmchan->sockfd,codes.SET_BLOCKSIZE,&len))){
ftdmchan->packet_len= len;
ftdmchan->effective_interval= ftdmchan->native_interval= ftdmchan->packet_len/8;

if(ftdmchan->effective_codec==FTDM_CODEC_SLIN){
ftdmchan->packet_len*= 2;
}
}
}
break;
case FTDM_COMMAND_SET_CAS_BITS:
{
int bits= *((int *)obj);
err= ioctl(ftdmchan->sockfd,codes.SETTXBITS,&bits);
}
break;
case FTDM_COMMAND_GET_CAS_BITS:
{
err= ioctl(ftdmchan->sockfd,codes.GETRXBITS,&ftdmchan->rx_cas_bits);
if(!err){
*((int *)obj)= ftdmchan->rx_cas_bits;
}
}
break;
case FTDM_COMMAND_FLUSH_TX_BUFFERS:
{
int flushmode= ZT_FLUSH_WRITE;
err= ioctl(ftdmchan->sockfd,codes.FLUSH,&flushmode);
}
break;
case FTDM_COMMAND_SET_POLARITY:
{
ftdm_polarity_t polarity= *((int *)obj);
err= ioctl(ftdmchan->sockfd,codes.SETPOLARITY,polarity);
if(!err){
ftdmchan->polarity= polarity;
}
}
break;
case FTDM_COMMAND_FLUSH_RX_BUFFERS:
{
int flushmode= ZT_FLUSH_READ;
err= ioctl(ftdmchan->sockfd,codes.FLUSH,&flushmode);
}
break;
case FTDM_COMMAND_FLUSH_BUFFERS:
{
int flushmode= ZT_FLUSH_BOTH;
err= ioctl(ftdmchan->sockfd,codes.FLUSH,&flushmode);
}
break;
case FTDM_COMMAND_SET_RX_QUEUE_SIZE:
case FTDM_COMMAND_SET_TX_QUEUE_SIZE:

err= 0;
break;
case FTDM_COMMAND_ENABLE_DTMF_DETECT:
{
zt_tone_mode_t mode= ZT_TONEDETECT_ON|ZT_TONEDETECT_MUTE;
err= ioctl(ftdmchan->sockfd,codes.TONEDETECT,&mode);
}
break;
case FTDM_COMMAND_DISABLE_DTMF_DETECT:
{
zt_tone_mode_t mode= 0;
err= ioctl(ftdmchan->sockfd,codes.TONEDETECT,&mode);
}
break;
default:
err= FTDM_NOTIMPL;
break;
};

if(err&&err!=FTDM_NOTIMPL){
snprintf(ftdmchan->last_error,sizeof(ftdmchan->last_error),"%s",strerror(
                                                                        (*__errno_location ())
                                                                             ));
return FTDM_FAIL;
}

return err==0?FTDM_SUCCESS:err;
}

static ftdm_status_t zt_get_alarms (ftdm_channel_t *ftdmchan)
{
struct zt_spaninfo info;
zt_params_t params;

memset(&info,0,sizeof(info));
info.span_no= ftdmchan->physical_span_id;

memset(&params,0,sizeof(params));

if(ioctl(CONTROL_FD,codes.SPANSTAT,&info)){
snprintf(ftdmchan->last_error,sizeof(ftdmchan->last_error),"ioctl failed (%s)",strerror(
                                                                                       (*__errno_location ())
                                                                                            ));
snprintf(ftdmchan->span->last_error,sizeof(ftdmchan->span->last_error),"ioctl failed (%s)",strerror(
                                                                                                   (*__errno_location ())
                                                                                                        ));
return FTDM_FAIL;
}

ftdmchan->alarm_flags= info.alarms;

if(info.alarms==FTDM_ALARM_NONE){
if(ioctl(ftdmchan->sockfd,codes.GET_PARAMS,&params)){
snprintf(ftdmchan->last_error,sizeof(ftdmchan->last_error),"ioctl failed (%s)",strerror(
                                                                                       (*__errno_location ())
                                                                                            ));
snprintf(ftdmchan->span->last_error,sizeof(ftdmchan->span->last_error),"ioctl failed (%s)",strerror(
                                                                                                   (*__errno_location ())
                                                                                                        ));
return FTDM_FAIL;
}

if(params.chan_alarms> 0){
if(params.chan_alarms==(1 << 2)){
ftdmchan->alarm_flags= FTDM_ALARM_YELLOW;
}
else if(params.chan_alarms==(1 << 4)){
ftdmchan->alarm_flags= FTDM_ALARM_BLUE;
}
else{
ftdmchan->alarm_flags= FTDM_ALARM_RED;
}
}
}

return FTDM_SUCCESS;
}

#define ftdm_zt_set_event_pending(fchan) do { ftdm_set_io_flag(fchan, FTDM_CHANNEL_IO_EVENT); fchan->last_event_time = ftdm_current_time_in_ms(); } while (0);

#define ftdm_zt_store_chan_event(fchan,revent) do { if (fchan->io_data) { ftdm_log_chan(fchan, FTDM_LOG_WARNING, "Dropping event %d, not retrieved on time\n", revent); } fchan->io_data = (void *)zt_event_id; ftdm_zt_set_event_pending(fchan); } while (0);
static ftdm_status_t zt_wait (ftdm_channel_t *ftdmchan, ftdm_wait_flag_t *flags, int32_t to)
{
int32_t inflags= 0;
int result;
struct pollfd pfds[1];

if(*flags&FTDM_READ){
inflags|= 
         0x001
               ;
}

if(*flags&FTDM_WRITE){
inflags|= 
         0x004
                ;
}

if(*flags&FTDM_EVENTS){
inflags|= 
         0x002
                ;
}

pollagain:
memset(&pfds[0],0,sizeof(pfds[0]));
pfds[0].fd= ftdmchan->sockfd;
pfds[0].events= inflags;
result= poll(pfds,1,to);
*flags= FTDM_NO_FLAGS;

if(result<0&&
            (*__errno_location ())
                 ==
                   4
                        ){
ftdm_log("./ftmod_zt.w", __func__, 999, 7, "[s%dc%d][%d:%d] " "DAHDI wait got interrupted, trying again\n", ftdmchan->span_id, ftdmchan->chan_id, ftdmchan->physical_span_id, ftdmchan->physical_chan_id);
goto pollagain;
}

if(pfds[0].revents&
                  0x008
                         ){
ftdm_log("./ftmod_zt.w", __func__, 1004, 3, "[s%dc%d][%d:%d] " "DAHDI device got POLLERR\n", ftdmchan->span_id, ftdmchan->chan_id, ftdmchan->physical_span_id, ftdmchan->physical_chan_id);
result= -1;
}

if(result> 0){
inflags= pfds[0].revents;
}

if(result<0){
snprintf(ftdmchan->last_error,sizeof(ftdmchan->last_error),"Poll failed");
ftdm_log("./ftmod_zt.w", __func__, 1014, 3, "[s%dc%d][%d:%d] " "Failed to poll DAHDI device: %s\n", ftdmchan->span_id, ftdmchan->chan_id, ftdmchan->physical_span_id, ftdmchan->physical_chan_id, strerror(
(*__errno_location ())
));
return FTDM_FAIL;
}

if(result==0){
return FTDM_TIMEOUT;
}

if(inflags&
          0x001
                ){
*flags|= FTDM_READ;
}

if(inflags&
          0x004
                 ){
*flags|= FTDM_WRITE;
}

if((inflags&
           0x002
                  )||(ftdmchan->io_data&&(*flags&FTDM_EVENTS))){
*flags|= FTDM_EVENTS;
}

return FTDM_SUCCESS;

}

ftdm_status_t zt_poll_event (ftdm_span_t *span, uint32_t ms, short *poll_events)
{
struct pollfd pfds[32 * 128];
uint32_t i,j= 0,k= 0;
int r;

(void)(poll_events);

for(i= 1;i<=span->chan_count;i++){
memset(&pfds[j],0,sizeof(pfds[j]));
pfds[j].fd= span->channels[i]->sockfd;
pfds[j].events= 
               0x002
                      ;
j++;
}

r= poll(pfds,j,ms);

if(r==0){
return FTDM_TIMEOUT;
}else if(r<0){
snprintf(span->last_error,sizeof(span->last_error),"%s",strerror(
                                                                (*__errno_location ())
                                                                     ));
return FTDM_FAIL;
}

for(i= 1;i<=span->chan_count;i++){

_ftdm_mutex_lock("./ftmod_zt.w", 1070, (const char *)__func__, (span->channels[i])->mutex);

if(pfds[i-1].revents&
                    0x008
                           ){
ftdm_log("./ftmod_zt.w", __func__, 1073, 3, "[s%dc%d][%d:%d] " "POLLERR, flags=%d\n", span->channels[i]->span_id, span->channels[i]->chan_id, span->channels[i]->physical_span_id, span->channels[i]->physical_chan_id, pfds[i-1].events);

_ftdm_mutex_unlock("./ftmod_zt.w", 1075, (const char *)__func__, (span->channels[i])->mutex);

continue;
}
if((pfds[i-1].revents&
                     0x002
                            )||(span->channels[i]->io_data)){
do { (span->channels[i])->io_flags |= (FTDM_CHANNEL_IO_EVENT); span->channels[i]->last_event_time = ftdm_current_time_in_ms(); } while (0);;
k++;
}
if(pfds[i-1].revents&
                    0x001
                          ){
(span->channels[i])->io_flags |= (FTDM_CHANNEL_IO_READ);
}
if(pfds[i-1].revents&
                    0x004
                           ){
(span->channels[i])->io_flags |= (FTDM_CHANNEL_IO_WRITE);
}

_ftdm_mutex_unlock("./ftmod_zt.w", 1090, (const char *)__func__, (span->channels[i])->mutex);

}

if(!k){
snprintf(span->last_error,sizeof(span->last_error),"no matching descriptor");
}

return k?FTDM_SUCCESS:FTDM_FAIL;
}

static __inline__ int handle_dtmf_event(ftdm_channel_t*fchan,zt_event_t zt_event_id)
{
if((zt_event_id&ZT_EVENT_DTMFUP)){
int digit= (zt_event_id&(~ZT_EVENT_DTMFUP));
char tmp_dtmf[2]= {digit,0};
ftdm_log("./ftmod_zt.w", __func__, 1106, 7, "[s%dc%d][%d:%d] " "DTMF UP [%d]\n", fchan->span_id, fchan->chan_id, fchan->physical_span_id, fchan->physical_chan_id, digit);
ftdm_channel_queue_dtmf(fchan,tmp_dtmf);
return 0;
}else if((zt_event_id&ZT_EVENT_DTMFDOWN)){
int digit= (zt_event_id&(~ZT_EVENT_DTMFDOWN));
ftdm_log("./ftmod_zt.w", __func__, 1111, 7, "[s%dc%d][%d:%d] " "DTMF DOWN [%d]\n", fchan->span_id, fchan->chan_id, fchan->physical_span_id, fchan->physical_chan_id, digit);
return 0;
}else{
return-1;
}
}
static __inline__ ftdm_status_t zt_channel_process_event(ftdm_channel_t*fchan,ftdm_oob_event_t*event_id,zt_event_t zt_event_id)
{
ftdm_log("./ftmod_zt.w", __func__, 1127, 7, "[s%dc%d][%d:%d] " "Processing zap hardware event %d\n", fchan->span_id, fchan->chan_id, fchan->physical_span_id, fchan->physical_chan_id, zt_event_id);
switch(zt_event_id){
case ZT_EVENT_RINGEROFF:
{
ftdm_log("./ftmod_zt.w", __func__, 1131, 7, "[s%dc%d][%d:%d] " "ZT RINGER OFF\n", fchan->span_id, fchan->chan_id, fchan->physical_span_id, fchan->physical_chan_id);
*event_id= FTDM_OOB_NOOP;
}
break;
case ZT_EVENT_RINGERON:
{
ftdm_log("./ftmod_zt.w", __func__, 1137, 7, "[s%dc%d][%d:%d] " "ZT RINGER ON\n", fchan->span_id, fchan->chan_id, fchan->physical_span_id, fchan->physical_chan_id);
*event_id= FTDM_OOB_NOOP;
}
break;
case ZT_EVENT_RINGBEGIN:
{
*event_id= FTDM_OOB_RING_START;
}
break;
case ZT_EVENT_ONHOOK:
{
*event_id= FTDM_OOB_ONHOOK;
}
break;
case ZT_EVENT_WINKFLASH:
{
if(fchan->state==FTDM_CHANNEL_STATE_DOWN||fchan->state==FTDM_CHANNEL_STATE_DIALING){
*event_id= FTDM_OOB_WINK;
}else{
*event_id= FTDM_OOB_FLASH;
}
}
break;
case ZT_EVENT_RINGOFFHOOK:
{
*event_id= FTDM_OOB_NOOP;
if(fchan->type==FTDM_CHAN_TYPE_FXS||(fchan->type==FTDM_CHAN_TYPE_EM&&fchan->state!=FTDM_CHANNEL_STATE_UP)){
if(fchan->type!=FTDM_CHAN_TYPE_EM){

((void) sizeof ((
fchan->mutex != 
((void *)0)) ? 1 : 0), __extension__ ({ if (
fchan->mutex != 
((void *)0)) ; else __assert_fail (
"fchan->mutex != NULL"
, "./ftmod_zt.w", 1166, __extension__ __PRETTY_FUNCTION__); }))
; _ftdm_mutex_lock("./ftmod_zt.w", 1166, (const char *)__func__, fchan->mutex); (fchan)->flags |= ((1ULL << 14)); _ftdm_mutex_unlock("./ftmod_zt.w", 1166, (const char *)__func__, fchan->mutex);;
}

if(fchan->type==FTDM_CHAN_TYPE_EM&&((fchan)->flags & (1ULL << 18))){
fchan->ring_count++;

if(fchan->ring_count==2){
*event_id= FTDM_OOB_OFFHOOK;
}
}else{
*event_id= FTDM_OOB_OFFHOOK;
}
}else if(fchan->type==FTDM_CHAN_TYPE_FXO){
*event_id= FTDM_OOB_RING_START;
}
}
break;
case ZT_EVENT_ALARM:
{
*event_id= FTDM_OOB_ALARM_TRAP;
}
break;
case ZT_EVENT_NOALARM:
{
*event_id= FTDM_OOB_ALARM_CLEAR;
}
break;
case ZT_EVENT_BITSCHANGED:
{
*event_id= FTDM_OOB_CAS_BITS_CHANGE;
int bits= 0;
int err= ioctl(fchan->sockfd,codes.GETRXBITS,&bits);
if(err){
return FTDM_FAIL;
}
fchan->rx_cas_bits= bits;
}
break;
case ZT_EVENT_BADFCS:
{
ftdm_log("./ftmod_zt.w", __func__, 1212, 3, "[s%dc%d][%d:%d] " "Bad frame checksum (ZT_EVENT_BADFCS)\n", fchan->span_id, fchan->chan_id, fchan->physical_span_id, fchan->physical_chan_id);
*event_id= FTDM_OOB_NOOP;
}
break;
case ZT_EVENT_OVERRUN:
{
ftdm_log("./ftmod_zt.w", __func__, 1218, 3, "[s%dc%d][%d:%d] " "HDLC frame overrun (ZT_EVENT_OVERRUN)\n", fchan->span_id, fchan->chan_id, fchan->physical_span_id, fchan->physical_chan_id);
*event_id= FTDM_OOB_NOOP;
}
break;
case ZT_EVENT_ABORT:
{
ftdm_log("./ftmod_zt.w", __func__, 1224, 3, "[s%dc%d][%d:%d] " "HDLC abort frame received (ZT_EVENT_ABORT)\n", fchan->span_id, fchan->chan_id, fchan->physical_span_id, fchan->physical_chan_id);
*event_id= FTDM_OOB_NOOP;
}
break;
case ZT_EVENT_POLARITY:
{
ftdm_log("./ftmod_zt.w", __func__, 1230, 3, "[s%dc%d][%d:%d] " "Got polarity reverse (ZT_EVENT_POLARITY)\n", fchan->span_id, fchan->chan_id, fchan->physical_span_id, fchan->physical_chan_id);
*event_id= FTDM_OOB_POLARITY_REVERSE;
}
break;
case ZT_EVENT_NONE:
{
ftdm_log("./ftmod_zt.w", __func__, 1236, 7, "[s%dc%d][%d:%d] " "No event\n", fchan->span_id, fchan->chan_id, fchan->physical_span_id, fchan->physical_chan_id);
*event_id= FTDM_OOB_NOOP;
}
break;
default:
{
if(handle_dtmf_event(fchan,zt_event_id)){
ftdm_log("./ftmod_zt.w", __func__, 1243, 4, "[s%dc%d][%d:%d] " "Unhandled event %d\n", fchan->span_id, fchan->chan_id, fchan->physical_span_id, fchan->physical_chan_id, zt_event_id);
*event_id= FTDM_OOB_INVALID;
}else{
*event_id= FTDM_OOB_NOOP;
}
}
break;
}
return FTDM_SUCCESS;
}

ftdm_status_t zt_channel_next_event (ftdm_channel_t *ftdmchan, ftdm_event_t **event)
{
uint32_t event_id= FTDM_OOB_INVALID;
zt_event_t zt_event_id= 0;
ftdm_span_t*span= ftdmchan->span;

if(((ftdmchan)->io_flags & FTDM_CHANNEL_IO_EVENT)){
(ftdmchan)->io_flags &= ~(FTDM_CHANNEL_IO_EVENT);
}

if(ftdmchan->io_data){
zt_event_id= (zt_event_t)ftdmchan->io_data;
ftdmchan->io_data= 
                  ((void *)0)
                      ;
}else if(ioctl(ftdmchan->sockfd,codes.GETEVENT,&zt_event_id)==-1){
ftdm_log("./ftmod_zt.w", __func__, 1275, 3, "[s%dc%d][%d:%d] " "Failed retrieving event from channel: %s\n", ftdmchan->span_id, ftdmchan->chan_id, ftdmchan->physical_span_id, ftdmchan->physical_chan_id, strerror(
(*__errno_location ())
))
                ;
return FTDM_FAIL;
}

if((zt_channel_process_event(ftdmchan,&event_id,zt_event_id))!=FTDM_SUCCESS){
ftdm_log("./ftmod_zt.w", __func__, 1281, 3, "[s%dc%d][%d:%d] " "Failed to process DAHDI event %d from channel\n", ftdmchan->span_id, ftdmchan->chan_id, ftdmchan->physical_span_id, ftdmchan->physical_chan_id, zt_event_id);
return FTDM_FAIL;
}

ftdmchan->last_event_time= 0;
span->event_header.e_type= FTDM_EVENT_OOB;
span->event_header.enum_id= event_id;
span->event_header.channel= ftdmchan;
*event= &span->event_header;
return FTDM_SUCCESS;
}

ftdm_status_t zt_next_event (ftdm_span_t *span, ftdm_event_t **event)
{
uint32_t i,event_id= FTDM_OOB_INVALID;
zt_event_t zt_event_id= 0;

for(i= 1;i<=span->chan_count;i++){
ftdm_channel_t*fchan= span->channels[i];

_ftdm_mutex_lock("./ftmod_zt.w", 1307, (const char *)__func__, (fchan)->mutex);

if(!((fchan)->io_flags & FTDM_CHANNEL_IO_EVENT)){

_ftdm_mutex_unlock("./ftmod_zt.w", 1311, (const char *)__func__, (fchan)->mutex);

continue;
}

(fchan)->io_flags &= ~(FTDM_CHANNEL_IO_EVENT);

if(fchan->io_data){
zt_event_id= (zt_event_t)fchan->io_data;
fchan->io_data= 
               ((void *)0)
                   ;
}else if(ioctl(fchan->sockfd,codes.GETEVENT,&zt_event_id)==-1){
ftdm_log("./ftmod_zt.w", __func__, 1322, 3, "[s%dc%d][%d:%d] " "Failed to retrieve DAHDI event from channel: %s\n", fchan->span_id, fchan->chan_id, fchan->physical_span_id, fchan->physical_chan_id, strerror(
(*__errno_location ())
));

_ftdm_mutex_unlock("./ftmod_zt.w", 1324, (const char *)__func__, (fchan)->mutex);

continue;
}

if((zt_channel_process_event(fchan,&event_id,zt_event_id))!=FTDM_SUCCESS){
ftdm_log("./ftmod_zt.w", __func__, 1330, 3, "[s%dc%d][%d:%d] " "Failed to process DAHDI event %d from channel\n", fchan->span_id, fchan->chan_id, fchan->physical_span_id, fchan->physical_chan_id, zt_event_id);

_ftdm_mutex_unlock("./ftmod_zt.w", 1332, (const char *)__func__, (fchan)->mutex);

return FTDM_FAIL;
}

fchan->last_event_time= 0;
span->event_header.e_type= FTDM_EVENT_OOB;
span->event_header.enum_id= event_id;
span->event_header.channel= fchan;
*event= &span->event_header;

_ftdm_mutex_unlock("./ftmod_zt.w", 1343, (const char *)__func__, (fchan)->mutex);

return FTDM_SUCCESS;
}

return FTDM_FAIL;
}
static ftdm_status_t zt_read (ftdm_channel_t *ftdmchan, void *data, ftdm_size_t *datalen)
{
ftdm_ssize_t r= 0;
int read_errno= 0;
int errs= 0;

while(errs++<30){
r= read(ftdmchan->sockfd,data,*datalen);
if(r> 0){

break;
}

if(r==0){
usleep(10 * 1000);
if(errs)errs--;
continue;
}

read_errno= 
           (*__errno_location ())
                ;
if(read_errno==
              11
                    ||read_errno==
                                  4
                                       ){

continue;
}

if(read_errno==500){
zt_event_t zt_event_id= 0;
if(ioctl(ftdmchan->sockfd,codes.GETEVENT,&zt_event_id)==-1){
ftdm_log("./ftmod_zt.w", __func__, 1390, 3, "[s%dc%d][%d:%d] " "Failed retrieving event after ELAST on read: %s\n", ftdmchan->span_id, ftdmchan->chan_id, ftdmchan->physical_span_id, ftdmchan->physical_chan_id, strerror(
(*__errno_location ())
));
r= -1;
break;
}

if(handle_dtmf_event(ftdmchan,zt_event_id)){

ftdm_log("./ftmod_zt.w", __func__, 1397, 7, "[s%dc%d][%d:%d] " "Deferring event %d to be able to read data\n", ftdmchan->span_id, ftdmchan->chan_id, ftdmchan->physical_span_id, ftdmchan->physical_chan_id, zt_event_id);
do { if (ftdmchan->io_data) { ftdm_log("./ftmod_zt.w", __func__, 1398, 4, "[s%dc%d][%d:%d] " "Dropping event %d, not retrieved on time\n", ftdmchan->span_id, ftdmchan->chan_id, ftdmchan->physical_span_id, ftdmchan->physical_chan_id, zt_event_id); } ftdmchan->io_data = (void *)zt_event_id; do { (ftdmchan)->io_flags |= (FTDM_CHANNEL_IO_EVENT); ftdmchan->last_event_time = ftdm_current_time_in_ms(); } while (0);; } while (0);;
}else{
ftdm_log("./ftmod_zt.w", __func__, 1400, 7, "[s%dc%d][%d:%d] " "Skipping one IO read cycle due to DTMF event processing\n", ftdmchan->span_id, ftdmchan->chan_id, ftdmchan->physical_span_id, ftdmchan->physical_chan_id);
}
break;
}

ftdm_log("./ftmod_zt.w", __func__, 1406, 3,"IO read failed: %s\n",strerror(read_errno));
}

if(r> 0){
*datalen= r;
if(ftdmchan->type==FTDM_CHAN_TYPE_DQ921){
*datalen-= 2;
}
return FTDM_SUCCESS;
}
else if(read_errno==500){
return FTDM_SUCCESS;
}
return r==0?FTDM_TIMEOUT:FTDM_FAIL;
}
static ftdm_status_t zt_write (ftdm_channel_t *ftdmchan, void *data, ftdm_size_t *datalen)
{
ftdm_ssize_t w= 0;
ftdm_size_t bytes= *datalen;

if(ftdmchan->type==FTDM_CHAN_TYPE_DQ921){
memset(data+bytes,0,2);
bytes+= 2;
}

tryagain:
w= write(ftdmchan->sockfd,data,bytes);

if(w>=0){
*datalen= w;
return FTDM_SUCCESS;
}

if(
  (*__errno_location ())
       ==500){
zt_event_t zt_event_id= 0;
if(ioctl(ftdmchan->sockfd,codes.GETEVENT,&zt_event_id)==-1){
ftdm_log("./ftmod_zt.w", __func__, 1450, 3, "[s%dc%d][%d:%d] " "Failed retrieving event after ELAST on write: %s\n", ftdmchan->span_id, ftdmchan->chan_id, ftdmchan->physical_span_id, ftdmchan->physical_chan_id, strerror(
(*__errno_location ())
));
return FTDM_FAIL;
}

if(handle_dtmf_event(ftdmchan,zt_event_id)){

ftdm_log("./ftmod_zt.w", __func__, 1456, 7, "[s%dc%d][%d:%d] " "Deferring event %d to be able to write data\n", ftdmchan->span_id, ftdmchan->chan_id, ftdmchan->physical_span_id, ftdmchan->physical_chan_id, zt_event_id);
do { if (ftdmchan->io_data) { ftdm_log("./ftmod_zt.w", __func__, 1457, 4, "[s%dc%d][%d:%d] " "Dropping event %d, not retrieved on time\n", ftdmchan->span_id, ftdmchan->chan_id, ftdmchan->physical_span_id, ftdmchan->physical_chan_id, zt_event_id); } ftdmchan->io_data = (void *)zt_event_id; do { (ftdmchan)->io_flags |= (FTDM_CHANNEL_IO_EVENT); ftdmchan->last_event_time = ftdm_current_time_in_ms(); } while (0);; } while (0);;
}

goto tryagain;
}

return FTDM_FAIL;
}

static ftdm_status_t zt_channel_destroy (ftdm_channel_t *ftdmchan)
{
close(ftdmchan->sockfd);
ftdmchan->sockfd= -1;
return FTDM_SUCCESS;
}

static ftdm_io_interface_t zt_interface;

static ftdm_status_t zt_init (ftdm_io_interface_t **fio)
{

((void) sizeof ((
fio!=
((void *)0)) ? 1 : 0), __extension__ ({ if (
fio!=
((void *)0)) ; else __assert_fail (
"fio!=NULL"
, "./ftmod_zt.w", 1490, __extension__ __PRETTY_FUNCTION__); }))
                ;
struct stat statbuf;
memset(&zt_interface,0,sizeof(zt_interface));
memset(&zt_globals,0,sizeof(zt_globals));

if(!stat(zt_ctlpath,&statbuf)){
ftdm_log("./ftmod_zt.w", __func__, 1496, 5,"Using Zaptel control device\n");
ctlpath= zt_ctlpath;
chanpath= zt_chanpath;
memcpy(&codes,&zt_ioctl_codes,sizeof(codes));
}else if(!stat(dahdi_ctlpath,&statbuf)){
ftdm_log("./ftmod_zt.w", __func__, 1501, 5,"Using DAHDI control device\n");
ctlpath= dahdi_ctlpath;
chanpath= dahdi_chanpath;
memcpy(&codes,&dahdi_ioctl_codes,sizeof(codes));
}else{
ftdm_log("./ftmod_zt.w", __func__, 1506, 3,"No DAHDI or Zap control device found in /dev/\n");
return FTDM_FAIL;
}
if((CONTROL_FD= open(ctlpath,
                            02
                                  ))<0){
ftdm_log("./ftmod_zt.w", __func__, 1510, 3,"Cannot open control device %s: %s\n",ctlpath,strerror(
                                                                              (*__errno_location ())
                                                                                   ));
return FTDM_FAIL;
}

zt_globals.codec_ms= 20;
zt_globals.wink_ms= 150;
zt_globals.flash_ms= 750;
zt_globals.eclevel= 0;
zt_globals.etlevel= 0;

zt_interface.name= "zt";
zt_interface.configure= zt_configure;
zt_interface.configure_span= zt_configure_span;
zt_interface.open= zt_open;
zt_interface.close= zt_close;
zt_interface.command= zt_command;
zt_interface.wait= zt_wait;
zt_interface.read= zt_read;
zt_interface.write= zt_write;
zt_interface.poll_event= zt_poll_event;
zt_interface.next_event= zt_next_event;
zt_interface.channel_next_event= zt_channel_next_event;
zt_interface.channel_destroy= zt_channel_destroy;
zt_interface.get_alarms= zt_get_alarms;
*fio= &zt_interface;

return FTDM_SUCCESS;
}

static ftdm_status_t zt_destroy (void)
{
close(CONTROL_FD);
memset(&zt_interface,0,sizeof(zt_interface));
return FTDM_SUCCESS;
}

ftdm_module_t ftdm_module= {
"zt",
zt_init,
zt_destroy,
};

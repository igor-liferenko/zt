@* Intro.

Read is done each 128 milliseconds.

@c
#include <errno.h>
#include <stdio.h> 
#include <math.h> 
#include <fcntl.h> 
#include <sys/ioctl.h> 
#include <dahdi/user.h> 
#include <unistd.h> 
#include <time.h>
#include <sys/time.h>

@<Typedef@>@;

int main(void)
{
  FILE *fp;
  if ((fp = fopen("rec.pcm","w")) == NULL) return 1;

  int fd;
  if ((fd = open("/dev/dahdi/channel", O_RDONLY)) == -1) return 2;

  int chan = 4;
  if (ioctl(fd, DAHDI_SPECIFY, &chan) == -1) return 3;

  int linear = 1;
  if (ioctl(fd, DAHDI_SETLINEAR, &linear) == -1) return 4;

  int n;
  char buf[8192];
  struct timeval tval;
  struct tm *tms;
  while (1) {
    if ((n = read(fd, buf, sizeof buf)) == -1) break;
    if (gettimeofday (&tval, NULL) == -1) return 5;
    if ((tms = localtime (&tval.tv_sec)) == NULL) return 6;
    printf ("%d bytes, %d:%02d:%02d.%03ld.%03ld\n", n,
             tms->tm_hour, tms->tm_min, tms->tm_sec, tval.tv_usec / 1000,
             tval.tv_usec % 1000);
    if (fwrite(buf, n, 1, fp) != 1) return 7;
  }

  zt_event_t zt_event_id = 0;
  if (errno == ELAST) {
    if (ioctl(fd, DAHDI_GETEVENT, &zt_event_id) == -1) return 8;
    printf("event: %d\n", zt_event_id);
  }
  else return 9;
}

@ @<Typedef@>=
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

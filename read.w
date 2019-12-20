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

int main(void)
{
  FILE *fp;
  if ((fp = fopen("rec.raw","w")) == NULL) return 1;

  int channel;
  if ((channel = open("/dev/dahdi/channel", O_RDONLY)) == -1) return 2;

  int chan = 4;
  if (ioctl(channel, DAHDI_SPECIFY, &chan) == -1) return 3;

  int linear = 1;
  if (ioctl(channel, DAHDI_SETLINEAR, &linear) == -1) return 4;

  int n;
  char buf[8192];
  struct timeval tval;
  struct tm *tms;
  while (1) {
    if ((n = read(channel, buf, sizeof buf)) == -1) return 0;
    if (gettimeofday(&tval, NULL) == -1) return 5;
    if ((tms = localtime(&tval.tv_sec)) == NULL) return 6;
    printf("%d bytes, %d:%02d:%02d.%03ld.%03ld\n", n,
             tms->tm_hour, tms->tm_min, tms->tm_sec, tval.tv_usec / 1000,
             tval.tv_usec % 1000);
    if (fwrite(buf, n, 1, fp) != 1) return 7;
  }
}

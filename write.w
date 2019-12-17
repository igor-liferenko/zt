@* Intro.

Write is done each 128 milliseconds (default block size is 1024 bytes, 2048 in linear mode).

@d BLOCK_SIZE 2048

@c
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
  int media;
  if ((media = open("rec.raw", O_RDONLY)) == -1) return 1;

  int channel;
  if ((channel = open("/dev/dahdi/channel", O_WRONLY)) == -1) return 2;

  int chan = 4;
  if (ioctl(channel, DAHDI_SPECIFY, &chan) == -1) return 3;

  int linear = 1;
  if (ioctl(channel, DAHDI_SETLINEAR, &linear) == -1) return 4;

  char buf[BLOCK_SIZE];
  struct timeval tval;
  struct tm *tms;
  while (1) {
    if (read(media, buf, BLOCK_SIZE) != BLOCK_SIZE) return 0;
    if (write(channel, buf, BLOCK_SIZE) != BLOCK_SIZE) return 5;
    if (gettimeofday (&tval, NULL) == -1) return 6;
    if ((tms = localtime (&tval.tv_sec)) == NULL) return 7;
    printf ("%d:%02d:%02d.%03ld.%03ld\n",
             tms->tm_hour, tms->tm_min, tms->tm_sec, tval.tv_usec / 1000,
             tval.tv_usec % 1000);
  }
}

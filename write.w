@* Intro.

Write is done each 128 milliseconds.

mp32pcm <silbo.mp3 | sox -r 44100 -e signed -b 16 -c 2 -t raw - -c 1 -r 8000 write.raw

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
  int fp;
  if ((fp = open("write.raw",O_RDWR)) == -1) return 1;

  int fd;
  if ((fd = open("/dev/dahdi/channel",O_RDWR)) == -1) return 2;

  int chan = 4;
  if (ioctl(fd, DAHDI_SPECIFY, &chan) == -1) return 3;

  int linear = 1;
  if (ioctl(fd, DAHDI_SETLINEAR, &linear) == -1) return 4;

  char buf[8192];
  struct timeval tval;
  struct tm *tms;
  while (1) {
    if (read(fp, buf, 2048) != 2048) return 19;
    if (write(fd, buf, 2048) != 2048) break;
    if (gettimeofday (&tval, NULL) == -1) return 6;
    if ((tms = localtime (&tval.tv_sec)) == NULL) return 7;
    printf ("%d:%02d:%02d.%03ld.%03ld\n",
             tms -> tm_hour, tms -> tm_min, tms -> tm_sec, tval.tv_usec / 1000,
             tval.tv_usec % 1000);
  }

  return 0;
}

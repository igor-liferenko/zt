@* Intro.

Read is done each 128 milliseconds.

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
  FILE *fp;
  if ((fp = fopen("rec.pcm","w")) == NULL) return 1;

  int fd;
  if ((fd = open("/dev/dahdi/channel",O_RDWR)) == -1) return 2;

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
    if (gettimeofday (&tval, NULL) == -1) return 6;
    if ((tms = localtime (&tval.tv_sec)) == NULL) return 7;
    printf ("%d bytes, %d:%02d:%02d.%03ld.%03ld\n", n,
             tms -> tm_hour, tms -> tm_min, tms -> tm_sec, tval.tv_usec / 1000,
             tval.tv_usec % 1000);
    if (fwrite(buf, n, 1, fp) != 1) return 5;
  }

  return 0;
}

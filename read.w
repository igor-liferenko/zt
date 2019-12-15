@* Intro.

sox -r 8000 -e signed -b 16 -c 1 read.raw read.wav

@c
#include <stdio.h> 
#include <math.h> 
#include <fcntl.h> 
#include <sys/ioctl.h> 
#include <dahdi/user.h> 
#include <unistd.h> 
int main(void)
{
  FILE *fp;
  if ((fp = fopen("read.raw","w")) == NULL) return 1;

  int fd;
  if ((fd = open("/dev/dahdi/channel",O_RDWR)) == -1) return 2;

  int chan = 4;
  if (ioctl(fd, DAHDI_SPECIFY, &chan) == -1) return 3;

  int linear = 1;
  if (ioctl(fd, DAHDI_SETLINEAR, &linear) == -1) return 4;

  int n;
  char buf[8192];
  while (1) {
    if ((n = read(fd, buf, sizeof buf)) == -1) break;
    if (fwrite(buf, n, 1, fp) != 1) return 5;
  }

  return 0;
}

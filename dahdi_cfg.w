@* Intro.

@c
#include <stdio.h> /* |fprintf| */
#include <fcntl.h> /* |open| */
#include <string.h> /* |memset| */
#include <sys/ioctl.h> /* |ioctl| */
#include <dahdi/user.h>
#include <dahdi/tonezone.h>

int main(void)
{
  @<Wait for all spans assigned@>@;

  int fd = open("/dev/dahdi/ctl", O_RDWR);
  if (fd == -1) {
    fprintf(stderr, "Unable to open ctl device: %m\n");
    return 1;
  }

  if (tone_zone_register(fd, "us") != 0) {
    fprintf(stderr, "tone_zone_register() failed\n");
    return 1;
  }

  int deftonezone = 0;
  if (ioctl(fd, DAHDI_DEFAULTZONE, &deftonezone) == -1) {
    fprintf(stderr, "DAHDI_DEFAULTZONE failed: %m\n");
    return 1;
  }

  for (int x = 2; x <= 4; x++) {
    struct dahdi_chanconfig cc;
    memset(&cc, 0, sizeof cc);
    cc.chan = x;
    cc.sigtype = DAHDI_SIG_FXOKS; /* reversed */
    if (ioctl(fd, DAHDI_CHANCONFIG, &cc) == -1) {
      fprintf(stderr, "DAHDI_CHANCONFIG failed: %m\n");
      return 1;
    }

    struct dahdi_attach_echocan ae;
    memset(&ae, 0, sizeof ae);
    ae.chan = x;
    strcpy(ae.echocan, "oslec");
    if (ioctl(fd, DAHDI_ATTACH_ECHOCAN, &ae) == -1) {
      fprintf(stderr, "DAHDI_ATTACH_ECHOCAN failed: %m\n");
      return 1;
    }
  }

  return 0;
}

@ If configuration will not be applied, 
take implementation of \\{wait\_for\_all\_spans\_assigned} from \.{dahdi_cfg.c}

@<Wait for all spans assigned@>=

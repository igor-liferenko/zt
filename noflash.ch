rxflashtime: time after pressing red button during which flash event can be sensed (also used for pulse dialing detection)

This parameter sets timer when red button is pressed, and if it expires before green button is pressed, this will be an on-hook event. Default is 1250.

See __dahdi_hooksig_pvt() and rbs_itimer_expire().

(preflashtime and flashtime are totally irrelevant to flash detection - they are used to create flash)

Default values:
preflashtime = 50
flashtime = 750
rxflashtime = 1250

@x
#include <dahdi/user.h>
@y
#include <dahdi/user.h>
#include <string.h>
@z

@x
  if (ioctl(channel, DAHDI_SETLINEAR, &linear) == -1) return 4;
@y
  if (ioctl(channel, DAHDI_SETLINEAR, &linear) == -1) return 4;

  struct dahdi_params ztp;
  memset(&ztp, 0, sizeof ztp); /* is it necessary? */
  if (ioctl(channel, DAHDI_GET_PARAMS, &ztp) == -1) return 100;
  ztp.rxflashtime = 1;
  if (ioctl(channel, DAHDI_SET_PARAMS, &ztp) == -1) return 101;
@z

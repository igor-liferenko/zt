TODO: see where rxflashtime is used and add printing to dmesg there to find out
if that code is ever executed and if nothing prevents, make preflashtime 1 ms
(including in ftmod_zt.w)

We need to set it to non-zero in order that timer which is set by this
parameter will expire (so that rbs_itimer_expire() will be called)

See __dahdi_hooksig_pvt().

NOTE: if you need pulse dialing work, set it to PULSE_MAX_...+1 in hope that
you will not be able to generate (either manually or by 'flash' button on phone) voltage drop intervals shorter than this

TODO: in zaptel source read what mean preflash_time flash_time receive_flash_time

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
  ztp.rxflashtime = 3;
  if (ioctl(channel, DAHDI_SET_PARAMS, &ztp) == -1) return 101;
@z

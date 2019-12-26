It seems DAHDI_DIAL is not an alternative to freetdm's dtmf generation feature, because
writing to cgannel fails after it.

@x
#include <dahdi/user.h>
@y
#include <dahdi/user.h>
#include <string.h>
@z

@x
  char buf[BLOCK_SIZE];
@y
  struct dahdi_dialoperation zo = {
    .op = DAHDI_DIAL_OP_REPLACE,
  };
  strcpy(zo.dialstr, "1234"); /* The zo initialization has already terminated the dialstr. */
  if (ioctl(channel, DAHDI_DIAL, &zo) == -1) return 100;
  sleep(10);

  char buf[BLOCK_SIZE];
@z

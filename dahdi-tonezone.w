\let\lheader\rheader
\nosecs
@* Intro.

The "tone zone" defines the standard tone indications (dialing, ringing, busy, etc).
(Without this phone will not ring on incoming calls.)

The defaultzone is used if no zone is specified for a channel (after \.{DAHDI\_SPECIFY} (?)).

\noindent
To compile this program, install \.{libtonezone-dev} package.
Compile with
\smallskip
\centerline{\tt gcc -o /bin/dahdi-tonezone dahdi-tonezone.c -ltonezone}
\bigskip

@c
#include <fcntl.h> /* |open| */
#include <sys/ioctl.h> /* |ioctl| */
#include <dahdi/user.h>
#include <dahdi/tonezone.h> /* |tone_zone_register| */

int main(void)
{
  int fd = open("/dev/dahdi/ctl", O_WRONLY);
  if (fd == -1) return 1;

  if (tone_zone_register(fd, "us") != 0)
    return 1;

  return 0;
}

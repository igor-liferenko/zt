\let\lheader\rheader
\nosecs
@* Intro.

\noindent
To compile this program, install \.{libtonezone-dev} package.
Compile with
\smallskip
\centerline{\tt gcc -o /bin/dahdi-tonezone dahdi-tonezone.c -ltonezone}
\medskip
\noindent
To apply the configuration, add ???

Without this phone will not ring on incoming calls.

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
  int deftonezone = 0;
  if (ioctl(fd, DAHDI_DEFAULTZONE, &deftonezone) == -1)
    return 1;

  return 0;
}

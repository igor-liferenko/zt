\let\lheader\rheader
\nosecs
@* Intro.

NOTE: if it fails, instead of `return 2' repeat until success (it means span was not yet assigned)

\noindent
The result of running this program must be that in \.{/proc/dahdi/1} for each configured channel
appear `\.{FXOKS}' and `\.{EC: OSLEC}'.
\bigskip

@c
#include <fcntl.h> /* |open| */
#include <string.h> /* |memset|, |strcpy| */
#include <sys/ioctl.h> /* |ioctl| */
#include <dahdi/user.h>

int main(void)
{
  int fd = open("/dev/dahdi/ctl", O_WRONLY);
  if (fd == -1) return 1;

  for (int channel = 2; channel <= 4; channel++) {
    @<Configure channel@>@;
    @<Attach echo canceller@>@;
  }

  return 0;
}

@ Set signalling type for channel.
(Each channel may be configured to handle different signalling types,
e.g., FXOLS, FXOGS and FXOKS.)

@<Configure channel@>=
struct dahdi_chanconfig cc;
memset(&cc, 0, sizeof cc);
cc.chan = channel;
cc.sigtype = DAHDI_SIG_FXOKS; /* reversed */
if (ioctl(fd, DAHDI_CHANCONFIG, &cc) == -1)  
  return 2;

@ Attach the desired echo canceler module to a channel,
so that when the channel needs an echo canceler
that module will be used to supply one.

@<Attach echo canceller@>=
struct dahdi_attach_echocan ae;
memset(&ae, 0, sizeof ae);
ae.chan = channel;
strcpy(ae.echocan, "oslec");
if (ioctl(fd, DAHDI_ATTACH_ECHOCAN, &ae) == -1)
  return 2;

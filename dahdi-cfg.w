\let\lheader\rheader
\nosecs
@* Intro.

\noindent
We use only one card, so assign span automatically. Use the following command.
When it is used, the file \.{/proc/dahdi/1} is created.
\smallskip
\line{\hss\tt\catcode`_11 echo options dahdi auto_assign_spans=1 >/etc/modprobe.d/dahdi.conf\hss}
\medskip
\noindent
To compile this program, install \.{libtonezone-dev} package.
Compile with
\smallskip
\centerline{\tt gcc -o /bin/dahdi-cfg dahdi-cfg.c -ltonezone}
\medskip
\noindent
To apply the configuration, add the following line to \.{/lib/udev/rules.d/60-dahdi.rules}:
\smallskip
\line{\hss\tt\catcode`_11
  SUBSYSTEM=="dahdi_spans", ACTION=="add", RUN+="/bin/dahdi-cfg"\hss}
\medskip
\noindent
The result of running this program must be that in \.{/proc/dahdi/1} for each configured channel
appear `\.{FXOKS}' and `\.{EC: OSLEC}'.
\bigskip

@c
#include <fcntl.h> /* |open| */
#include <string.h> /* |memset|, |strcpy| */
#include <sys/ioctl.h> /* |ioctl| */
#include <dahdi/user.h>
#include <dahdi/tonezone.h> /* |tone_zone_register| */

int main(void)
{
  @<Wait for all spans assigned@>@;

  int fd = open("/dev/dahdi/ctl", O_WRONLY);
  if (fd == -1) return 1;

  @<Configure tone zone@>@;

  for (int channel = 2; channel <= 4; channel++) {
    @<Configure channel@>@;
    @<Attach echo canceller@>@;
  }

  return 0;
}

@ If configuration will not be applied, 
take implementation of function \\{wait\_for\_all\_spans\_assigned} from \.{dahdi\_cfg.c}

@<Wait for all spans assigned@>=

@ Set signalling type.

@<Configure channel@>=
struct dahdi_chanconfig cc;
memset(&cc, 0, sizeof cc);
cc.chan = channel;
cc.sigtype = DAHDI_SIG_FXOKS; /* reversed */
if (ioctl(fd, DAHDI_CHANCONFIG, &cc) == -1)  
  return 1;

@ Attach the desired echo canceler module to a channel,
so that when the channel needs an echo canceler
that module will be used to supply one.

@<Attach echo canceller@>=
struct dahdi_attach_echocan ae;
memset(&ae, 0, sizeof ae);
ae.chan = channel;
strcpy(ae.echocan, "oslec");
if (ioctl(fd, DAHDI_ATTACH_ECHOCAN, &ae) == -1)
  return 1;

@ Without this phone will not ring on incoming calls.

@<Configure tone zone@>=
  if (tone_zone_register(fd, "us") != 0)
    return 1;
  int deftonezone = 0;
  if (ioctl(fd, DAHDI_DEFAULTZONE, &deftonezone) == -1)
    return 1;
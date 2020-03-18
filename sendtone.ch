If writing is done to the channel, tone stops automatically.
If reading is done from channel, tone must be stopped manually with DAHDI_TONE_STOP
right after dtmf was sensed.

@x
  if (ioctl(channel, DAHDI_SETLINEAR, &linear) == -1) return 4;
@y
  if (ioctl(channel, DAHDI_SETLINEAR, &linear) == -1) return 4;

  int x = DAHDI_TONE_DIALTONE;
  if (ioctl(channel, DAHDI_SENDTONE, &x) == -1) return 102;
  sleep(10);
@z

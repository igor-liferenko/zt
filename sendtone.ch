@x
  if (ioctl(channel, DAHDI_SETLINEAR, &linear) == -1) return 4;
@y
  if (ioctl(channel, DAHDI_SETLINEAR, &linear) == -1) return 4;

  int x = 0;
  if (ioctl(channel, DAHDI_SENDTONE, &x) == -1) return 102;
@z

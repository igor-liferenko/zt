@x
  if (ioctl(channel, DAHDI_SETLINEAR, &linear) == -1) return 4;
@y
  if (ioctl(channel, DAHDI_SETLINEAR, &linear) == -1) return 4;

  struct dahdi_params ztp;
  if (ioctl(channel, DAHDI_GET_PARAMS, &ztp) == -1) return 100;
/* TODO: print values of these parameters to see existing values */
  ztp.preflashtime = 0;
  ztp.flashtime = 0;
  ztp.starttime = 0;
  ztp.rxflashtime = 0;
  ztp.debouncetime = 0;
  ztp.pulsebreaktime = 0;
  ztp.pulsemaketime = 0;
  ztp.pulseaftertime = 0;
  if (ioctl(channel, DAHDI_SET_PARAMS, &ztp) == -1) return 101;
@z

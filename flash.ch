@x
  if (ioctl(fd, DAHDI_SETLINEAR, &linear) == -1) return 4;
@y
  if (ioctl(fd, DAHDI_SETLINEAR, &linear) == -1) return 4;

  struct dahdi_params ztp;
  if (ioctl(fd, DAHDI_GET_PARAMS, &ztp) == -1) return 100;
  ztp.prewinktime = 0;
  ztp.preflashtime = 0;
  ztp.winktime = 0;
  ztp.flashtime = 0;
  ztp.starttime = 0;
  ztp.rxwinktime = 0;
  ztp.rxflashtime = 0;
  ztp.debouncetime = 0;
  ztp.pulsebreaktime = 0;
  ztp.pulsemaketime = 0;
  ztp.pulseaftertime = 0;
  if (ioctl(fd, DAHDI_SET_PARAMS, &ztp) == -1) return 101;
@z

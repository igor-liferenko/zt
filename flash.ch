@x
  if (ioctl(channel, DAHDI_SETLINEAR, &linear) == -1) return 4;
@y
  if (ioctl(channel, DAHDI_SETLINEAR, &linear) == -1) return 4;

  struct dahdi_params ztp;
  if (ioctl(channel, DAHDI_GET_PARAMS, &ztp) == -1) return 100;
  printf("Default values:\n");
  printf("preflashtime = %d\n", ztp.preflashtime);
  printf("flashtime = %d\n", ztp.flashtime);
  printf("starttime = %d\n", ztp.starttime);
  printf("rxflashtime = %d\n", ztp.rxflashtime);
  printf("debouncetime = %d\n", ztp.debouncetime);
  printf("pulsebreaktime = %d\n", ztp.pulsebreaktime);
  printf("pulsemaketime = %d\n", ztp.pulsemaketime);
  printf("pulseaftertime = %d\n", ztp.pulseaftertime);
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

@x
  if (ioctl(channel, DAHDI_SETLINEAR, &linear) == -1) return 4;
@y
  if (ioctl(channel, DAHDI_SETLINEAR, &linear) == -1) return 4;

  struct dahdi_params ztp;
  if (ioctl(channel, DAHDI_GET_PARAMS, &ztp) == -1) return 100;
  printf("Default values:\n");
  printf("preflashtime = %d\n", ztp.preflashtime); /* set to 300000 */
  printf("flashtime = %d\n", ztp.flashtime);
  printf("rxflashtime = %d\n", ztp.rxflashtime);
  ztp.preflashtime = 300000;
  ztp.flashtime = 0;
  ztp.rxflashtime = 0;
  if (ioctl(channel, DAHDI_SET_PARAMS, &ztp) == -1) return 101;
@z

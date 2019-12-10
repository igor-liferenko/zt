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

TODO: rename z to tone_zone

@d MAX_SIZE 16384
@d LEVEL -10

@c
#include <errno.h>
#include <fcntl.h> /* |open| */
#include <math.h>
#include <stdio.h>
#include <string.h>
#include <sys/ioctl.h> /* |ioctl| */
#include <dahdi/user.h>

struct tone_zone_sound {
        int toneid;
        char data[256];                         /* Actual zone description */
        /* Description is a series of tones of the format:
           [!]freq1[+freq2][/time] separated by commas.  There
           are no spaces.  The sequence is repeated back to the
           first tone description not preceeded by !.  time is
           specified in milliseconds */
};

struct {
        int zone;                               /* Zone number */
        char country[10];                       /* Country code */
        char description[40];                   /* Description */
        int ringcadence[DAHDI_MAX_CADENCE];     /* Ring cadence */
        struct tone_zone_sound tones[DAHDI_TONE_MAX];
        int dtmf_high_level;                    /* Power level of high frequency component
                                                   of DTMF, expressed in dBm0. */
        int dtmf_low_level;                     /* Power level of low frequency component
                                                   of DTMF, expressed in dBm0. */
        int mfr1_level;                         /* Power level of MFR1, expressed in dBm0. */
        int mfr2_level;                         /* Power level of MFR2, expressed in dBm0. */
} z
@t\hskip2.5pt@> = { @t\1@> @/
    0, @/
    "us", @/
    "United States / North America", @/
    { 2000, 4000 }, @/
    {
      { DAHDI_TONE_DIALTONE, "350+440" }, @/
      { DAHDI_TONE_BUSY, "480+620/500,0/500" },
      { DAHDI_TONE_RINGTONE, "440+480/2000,0/4000" }, @/
      { DAHDI_TONE_CONGESTION, "480+620/250,0/250" }, @/
      { DAHDI_TONE_CALLWAIT, "440/300,0/10000" }, @/
      { DAHDI_TONE_DIALRECALL,
          "!350+440/100,!0/100,!350+440/100,!0/100,!350+440/100,!0/100,350+440" }, @/
      { DAHDI_TONE_RECORDTONE, "1400/500,0/15000" }, @/
      { DAHDI_TONE_INFO, "!950/330,!1400/330,!1800/330,0" }, @/
      { DAHDI_TONE_STUTTER, "!350+440/100,!0/100,!350+440/100,!0/100,!350+440/100,"
          "!0/100,!350+440/100,!0/100,!350+440/100,!0/100,!350+440/100,!0/100,350+440" }, @/
    }, @/
    -10, @/
    -10, @/
    -10, @/
@t\2@> -8 @/
};

int build_tone(void *data, size_t size, struct tone_zone_sound *t, int *count)
{
	char *dup, *s;
	struct dahdi_tone_def *td=NULL;
	int firstnobang = -1;
	int freq1, freq2, time;
	int modulate = 0;
	float db = 1.0;
	float gain;
	int used = 0;
	dup = strdup(t->data);
	s = strtok(dup, ",");
	while(s && strlen(s)) {
		/* Handle optional ! which signifies don't start here*/
		if (s[0] == '!') {
			s++;
		} else if (firstnobang < 0) {
			firstnobang = *count;
		}

		if (sscanf(s, "%d+%d/%d", &freq1, &freq2, &time) == 3) {
			/* f1+f2/time format */
		} else if (sscanf(s, "%d*%d/%d", &freq1, &freq2, &time) == 3) {
			/* f1*f2/time format */
			modulate = 1;
		} else if (sscanf(s, "%d+%d", &freq1, &freq2) == 2) {
			time = 0;
		} else if (sscanf(s, "%d*%d", &freq1, &freq2) == 2) {
			modulate = 1;
			time = 0;
		} else if (sscanf(s, "%d/%d", &freq1, &time) == 2) {
			freq2 = 0;
		} else if (sscanf(s, "%d@@/%d", &freq1, &time) == 2) {
			/* The "@@" character has been added to enable an
 			 * approximately -20db tone generation of any frequency This has been done
 			 * primarily to generate the Australian congestion tone.
			 * Example: "425/375,0/375,425@@/375,0/375" 
			 */
			db = 0.3;
			freq2 = 0;
		} else if (sscanf(s, "%d", &freq1) == 1) {
			firstnobang = *count;
			freq2 = 0;
			time = 0;
		} else {
			fprintf(stderr, "tone component '%s' of '%s' is a syntax error\n", s,t->data);
			return -1;
		}

		if (size < sizeof(*td)) {
			fprintf(stderr, "Not enough space for tones\n");
			return -1;
		}
		td = data;

		/* Bring it down -8 dbm */
		gain = db*(pow(10.0, (LEVEL - 3.14) / 20.0) * 65536.0 / 2.0);

		td->fac1 = 2.0 * cos(2.0 * M_PI * (freq1 / 8000.0)) * 32768.0;
		td->init_v2_1 = sin(-4.0 * M_PI * (freq1 / 8000.0)) * gain;
		td->init_v3_1 = sin(-2.0 * M_PI * (freq1 / 8000.0)) * gain;
		
		td->fac2 = 2.0 * cos(2.0 * M_PI * (freq2 / 8000.0)) * 32768.0;
		td->init_v2_2 = sin(-4.0 * M_PI * (freq2 / 8000.0)) * gain;
		td->init_v3_2 = sin(-2.0 * M_PI * (freq2 / 8000.0)) * gain;

		td->modulate = modulate;

		data += sizeof(*td);
		used += sizeof(*td);
		size -= sizeof(*td);
		td->tone = t->toneid;
		if (time) {
			/* We should move to the next tone */
			td->next = *count + 1;
			td->samples = time * 8;
		} else {
			/* Stay with us */
			td->next = *count;
			td->samples = 8000;
		}
		*count += 1;
		s = strtok(NULL, ",");
	}
	if (td && time) {
		/* If we don't end on a solid tone, return */
		td->next = firstnobang;
	}
	if (firstnobang < 0)
    fprintf(stderr,
      "tone '%s' does not end with a solid tone or silence "
      "(all tone components have an exclamation mark)\n", t->data);

	return used;
}

/* Tone frequency tables */
struct mf_tone {
	int	tone;
	float   f1;     /* first freq */
	float   f2;     /* second freq */
};
 
static struct mf_tone dtmf_tones[] = {
	{ DAHDI_TONE_DTMF_0, 941.0, 1336.0 },
	{ DAHDI_TONE_DTMF_1, 697.0, 1209.0 },
	{ DAHDI_TONE_DTMF_2, 697.0, 1336.0 },
	{ DAHDI_TONE_DTMF_3, 697.0, 1477.0 },
	{ DAHDI_TONE_DTMF_4, 770.0, 1209.0 },
	{ DAHDI_TONE_DTMF_5, 770.0, 1336.0 },
	{ DAHDI_TONE_DTMF_6, 770.0, 1477.0 },
	{ DAHDI_TONE_DTMF_7, 852.0, 1209.0 },
	{ DAHDI_TONE_DTMF_8, 852.0, 1336.0 },
	{ DAHDI_TONE_DTMF_9, 852.0, 1477.0 },
	{ DAHDI_TONE_DTMF_s, 941.0, 1209.0 },
	{ DAHDI_TONE_DTMF_p, 941.0, 1477.0 },
	{ DAHDI_TONE_DTMF_A, 697.0, 1633.0 },
	{ DAHDI_TONE_DTMF_B, 770.0, 1633.0 },
	{ DAHDI_TONE_DTMF_C, 852.0, 1633.0 },
	{ DAHDI_TONE_DTMF_D, 941.0, 1633.0 },
	{ 0, 0, 0 }
};
 
static struct mf_tone mfr1_tones[] = {
	{ DAHDI_TONE_MFR1_0, 1300.0, 1500.0 },
	{ DAHDI_TONE_MFR1_1, 700.0, 900.0 },
	{ DAHDI_TONE_MFR1_2, 700.0, 1100.0 },
	{ DAHDI_TONE_MFR1_3, 900.0, 1100.0 },
	{ DAHDI_TONE_MFR1_4, 700.0, 1300.0 },
	{ DAHDI_TONE_MFR1_5, 900.0, 1300.0 },
	{ DAHDI_TONE_MFR1_6, 1100.0, 1300.0 },
	{ DAHDI_TONE_MFR1_7, 700.0, 1500.0 },
	{ DAHDI_TONE_MFR1_8, 900.0, 1500.0 },
	{ DAHDI_TONE_MFR1_9, 1100.0, 1500.0 },
	{ DAHDI_TONE_MFR1_KP, 1100.0, 1700.0 },	/* KP */
	{ DAHDI_TONE_MFR1_ST, 1500.0, 1700.0 },	/* ST */
	{ DAHDI_TONE_MFR1_STP, 900.0, 1700.0 },	/* KP' or ST' */
	{ DAHDI_TONE_MFR1_ST2P, 1300.0, 1700.0 },	/* KP'' or ST'' */ 
	{ DAHDI_TONE_MFR1_ST3P, 700.0, 1700.0 },	/* KP''' or ST''' */
	{ 0, 0, 0 }
};

static struct mf_tone mfr2_fwd_tones[] = {
	{ DAHDI_TONE_MFR2_FWD_1, 1380.0, 1500.0 },
	{ DAHDI_TONE_MFR2_FWD_2, 1380.0, 1620.0 },
	{ DAHDI_TONE_MFR2_FWD_3, 1500.0, 1620.0 },
	{ DAHDI_TONE_MFR2_FWD_4, 1380.0, 1740.0 },
	{ DAHDI_TONE_MFR2_FWD_5, 1500.0, 1740.0 },
	{ DAHDI_TONE_MFR2_FWD_6, 1620.0, 1740.0 },
	{ DAHDI_TONE_MFR2_FWD_7, 1380.0, 1860.0 },
	{ DAHDI_TONE_MFR2_FWD_8, 1500.0, 1860.0 },
	{ DAHDI_TONE_MFR2_FWD_9, 1620.0, 1860.0 },
	{ DAHDI_TONE_MFR2_FWD_10, 1740.0, 1860.0 },
	{ DAHDI_TONE_MFR2_FWD_11, 1380.0, 1980.0 },
	{ DAHDI_TONE_MFR2_FWD_12, 1500.0, 1980.0 },
	{ DAHDI_TONE_MFR2_FWD_13, 1620.0, 1980.0 },
	{ DAHDI_TONE_MFR2_FWD_14, 1740.0, 1980.0 },
	{ DAHDI_TONE_MFR2_FWD_15, 1860.0, 1980.0 },
	{ 0, 0, 0 }
};

static struct mf_tone mfr2_rev_tones[] = {
	{ DAHDI_TONE_MFR2_REV_1, 1020.0, 1140.0 },
	{ DAHDI_TONE_MFR2_REV_2, 900.0, 1140.0 },
	{ DAHDI_TONE_MFR2_REV_3, 900.0, 1020.0 },
	{ DAHDI_TONE_MFR2_REV_4, 780.0, 1140.0 },
	{ DAHDI_TONE_MFR2_REV_5, 780.0, 1020.0 },
	{ DAHDI_TONE_MFR2_REV_6, 780.0, 900.0 },
	{ DAHDI_TONE_MFR2_REV_7, 660.0, 1140.0 },
	{ DAHDI_TONE_MFR2_REV_8, 660.0, 1020.0 },
	{ DAHDI_TONE_MFR2_REV_9, 660.0, 900.0 },
	{ DAHDI_TONE_MFR2_REV_10, 660.0, 780.0 },
	{ DAHDI_TONE_MFR2_REV_11, 540.0, 1140.0 },
	{ DAHDI_TONE_MFR2_REV_12, 540.0, 1020.0 },
	{ DAHDI_TONE_MFR2_REV_13, 540.0, 900.0 },
	{ DAHDI_TONE_MFR2_REV_14, 540.0, 780.0 },
	{ DAHDI_TONE_MFR2_REV_15, 540.0, 660.0 },
	{ 0, 0, 0 }
};


int build_mf_tones(void *data, size_t size, int *count, struct mf_tone *tone, int low_tone_level,
  int high_tone_level)
{
	struct dahdi_tone_def *td;
	float gain;
	int used = 0;

	while (tone->tone) {
		if (size < sizeof(*td)) {
			fprintf(stderr, "Not enough space for samples\n");
			return -1;
		}
		td = data;
		data += sizeof(*td);
		used += sizeof(*td);
		size -= sizeof(*td);
		td->tone = tone->tone;
		*count += 1;

		/* Bring it down 6 dBm */
		gain = pow(10.0, (low_tone_level - 3.14) / 20.0) * 65536.0 / 2.0;
		td->fac1 = 2.0 * cos(2.0 * M_PI * (tone->f1 / 8000.0)) * 32768.0;
		td->init_v2_1 = sin(-4.0 * M_PI * (tone->f1 / 8000.0)) * gain;
		td->init_v3_1 = sin(-2.0 * M_PI * (tone->f1 / 8000.0)) * gain;
		
		gain = pow(10.0, (high_tone_level - 3.14) / 20.0) * 65536.0 / 2.0;
		td->fac2 = 2.0 * cos(2.0 * M_PI * (tone->f2 / 8000.0)) * 32768.0;
		td->init_v2_2 = sin(-4.0 * M_PI * (tone->f2 / 8000.0)) * gain;
		td->init_v3_2 = sin(-2.0 * M_PI * (tone->f2 / 8000.0)) * gain;

		tone++;
	}

	return used;
}
int main(void)
{
  int fd = open("/dev/dahdi/ctl", O_WRONLY);
  if (fd == -1) return 1;

  char buf[MAX_SIZE];
  int res;
  int count = 0;
  int x;
  size_t space = MAX_SIZE;
  void *ptr = buf;
  struct dahdi_tone_def_header *h;

  memset(buf, 0, sizeof(buf));

  h = ptr;
  ptr += sizeof(*h);
  space -= sizeof(*h);
  h->zone = z.zone;

  strncpy(h->name, z.description, sizeof(h->name));

  for (x = 0; x < DAHDI_MAX_CADENCE; x++) 
    h->ringcadence[x] = z.ringcadence[x];

  for (x = 0; x < DAHDI_TONE_MAX; x++) {
    if (!strlen(z.tones[x].data)) continue;

    if ((res = build_tone(ptr, space, &z.tones[x], &count)) < 0) {
      fprintf(stderr, "Tone %d not built.\n", x);
      return 1;
    }
    ptr += res;
    space -= res;
  }

  if ((res = build_mf_tones(ptr, space, &count, dtmf_tones, z.dtmf_low_level, z.dtmf_high_level))
       < 0) {
    fprintf(stderr, "Could not build DTMF tones.\n");
    return 1;
  }
  ptr += res;
  space -= res;

  if ((res = build_mf_tones(ptr, space, &count, mfr1_tones, z.mfr1_level, z.mfr1_level)) < 0) {
    fprintf(stderr, "Could not build MFR1 tones.\n");
    return 1;
  }
  ptr += res;
  space -= res;

  if ((res = build_mf_tones(ptr, space, &count, mfr2_fwd_tones, z.mfr2_level, z.mfr2_level))
       < 0) {
    fprintf(stderr, "Could not build MFR2 FWD tones.\n");
    return 1;
  }
  ptr += res;
  space -= res;

  if ((res = build_mf_tones(ptr, space, &count, mfr2_rev_tones, z.mfr2_level, z.mfr2_level))
       < 0) {
    fprintf(stderr, "Could not build MFR2 REV tones.\n");
    return 1;
  }
  ptr += res;
  space -= res;

  h->count = count;

  if ((res = ioctl(fd, DAHDI_LOADZONE, h))) {
    fprintf(stderr, "ioctl(DAHDI_LOADZONE) failed: %s\n", strerror(errno));
    return res;
  }

  return 0;
}

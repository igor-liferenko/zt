#include "private/ftdm_core.h"
#include "fsk.h"
#include "uart.h"

FT_DECLARE(ftdm_status_t) ftdm_fsk_data_init(ftdm_fsk_data_state_t *state, uint8_t *data, uint32_t datalen)
{
	memset(state, 0, sizeof(*state));
	state->buf = data;
	state->bufsize = datalen;
	state->bpos = 2;

	return FTDM_SUCCESS;
}

FT_DECLARE(ftdm_status_t) ftdm_fsk_data_add_sdmf(ftdm_fsk_data_state_t *state, const char *date, char *number)
{
	size_t dlen = strlen(date);
	size_t nlen = strlen(number);

	state->buf[0] = FTDM_CID_TYPE_SDMF;
	memcpy(&state->buf[state->bpos], date, dlen);
	state->bpos += dlen;
	memcpy(&state->buf[state->bpos], number, nlen);
	state->bpos += nlen;

	return FTDM_SUCCESS;
}

FT_DECLARE(ftdm_status_t) ftdm_fsk_data_add_mdmf(ftdm_fsk_data_state_t *state, ftdm_mdmf_type_t type, const uint8_t *data, uint32_t datalen)
{
	state->buf[0] = FTDM_CID_TYPE_MDMF;
	state->buf[state->bpos++] = type;
	state->buf[state->bpos++] = (uint8_t)datalen;
	memcpy(&state->buf[state->bpos], data, datalen);
	state->bpos += datalen;
	return FTDM_SUCCESS;
}


FT_DECLARE(ftdm_status_t) ftdm_fsk_data_add_checksum(ftdm_fsk_data_state_t *state)
{
	uint32_t i;
	uint8_t check = 0;

	state->buf[1] = (uint8_t)(state->bpos - 2);

	for (i = 0; i < state->bpos; i++) {
		check = check + state->buf[i];
	}

	state->checksum = state->buf[state->bpos] = (uint8_t)(256 - check);
	state->bpos++;

	state->dlen = state->bpos;
	state->blen = state->buf[1];

	return FTDM_SUCCESS;
}

FT_DECLARE(ftdm_size_t) ftdm_fsk_modulator_generate_bit(ftdm_fsk_modulator_t *fsk_trans, int8_t bit, int16_t *buf, ftdm_size_t buflen)
{
	ftdm_size_t i;
		
	for(i = 0 ; i < buflen; i++) {
		fsk_trans->bit_accum += fsk_trans->bit_factor;
		if (fsk_trans->bit_accum >= FTDM_FSK_MOD_FACTOR) {
			fsk_trans->bit_accum -= (FTDM_FSK_MOD_FACTOR + fsk_trans->bit_factor);
			break;
		}

		buf[i] = teletone_dds_state_modulate_sample(&fsk_trans->dds, bit);
	}

	return i;
}


FT_DECLARE(int32_t) ftdm_fsk_modulator_generate_carrier_bits(ftdm_fsk_modulator_t *fsk_trans, uint32_t bits)
{
	uint32_t i = 0;
	ftdm_size_t r = 0;
	int8_t bit = 1;

	for (i = 0; i < bits; i++) {
		if ((r = ftdm_fsk_modulator_generate_bit(fsk_trans, bit, fsk_trans->sample_buffer, sizeof(fsk_trans->sample_buffer) / 2))) {
			if (fsk_trans->write_sample_callback(fsk_trans->sample_buffer, r, fsk_trans->user_data) != FTDM_SUCCESS) {
				break;
			}
		} else {
			break;
		}
	}

	return i;
}


FT_DECLARE(void) ftdm_fsk_modulator_generate_chan_sieze(ftdm_fsk_modulator_t *fsk_trans)
{
	uint32_t i = 0;
	ftdm_size_t r = 0;
	int8_t bit = 0;
	
	for (i = 0; i < fsk_trans->chan_sieze_bits; i++) {
		if ((r = ftdm_fsk_modulator_generate_bit(fsk_trans, bit, fsk_trans->sample_buffer, sizeof(fsk_trans->sample_buffer) / 2))) {
			if (fsk_trans->write_sample_callback(fsk_trans->sample_buffer, r, fsk_trans->user_data) != FTDM_SUCCESS) {
				break;
			}
		} else {
			break;
		}
		bit = !bit;
	}
	

}


FT_DECLARE(void) ftdm_fsk_modulator_send_data(ftdm_fsk_modulator_t *fsk_trans)
{
	ftdm_size_t r = 0;
	int8_t bit = 0;

	while((bit = ftdm_bitstream_get_bit(&fsk_trans->bs)) > -1) {
		if ((r = ftdm_fsk_modulator_generate_bit(fsk_trans, bit, fsk_trans->sample_buffer, sizeof(fsk_trans->sample_buffer) / 2))) {
			if (fsk_trans->write_sample_callback(fsk_trans->sample_buffer, r, fsk_trans->user_data) != FTDM_SUCCESS) {
				break;
			}
		} else {
			break;
		}
	}
}


FT_DECLARE(ftdm_status_t) ftdm_fsk_modulator_init(ftdm_fsk_modulator_t *fsk_trans,
									fsk_modem_types_t modem_type,
									uint32_t sample_rate,
									ftdm_fsk_data_state_t *fsk_data,
									float db_level,
									uint32_t carrier_bits_start,
									uint32_t carrier_bits_stop,
									uint32_t chan_sieze_bits,
									ftdm_fsk_write_sample_t write_sample_callback,
									void *user_data)
{
	memset(fsk_trans, 0, sizeof(*fsk_trans));
	fsk_trans->modem_type = modem_type;
	teletone_dds_state_set_tone(&fsk_trans->dds, fsk_modem_definitions[fsk_trans->modem_type].freq_space, sample_rate, 0);
	teletone_dds_state_set_tone(&fsk_trans->dds, fsk_modem_definitions[fsk_trans->modem_type].freq_mark, sample_rate, 1);
	fsk_trans->bit_factor = (uint32_t)((fsk_modem_definitions[fsk_trans->modem_type].baud_rate * FTDM_FSK_MOD_FACTOR) / (float)sample_rate);
	fsk_trans->samples_per_bit = (uint32_t) (sample_rate / fsk_modem_definitions[fsk_trans->modem_type].baud_rate);
	fsk_trans->est_bytes = (int32_t)(((fsk_data->dlen * 10) + carrier_bits_start + carrier_bits_stop + chan_sieze_bits) * ((fsk_trans->samples_per_bit + 1) * 2));
	fsk_trans->bit_accum = 0;
	fsk_trans->fsk_data = fsk_data;
	teletone_dds_state_set_tx_level(&fsk_trans->dds, db_level);
	ftdm_bitstream_init(&fsk_trans->bs, fsk_trans->fsk_data->buf, (uint32_t)fsk_trans->fsk_data->dlen, FTDM_ENDIAN_BIG, 1);
	fsk_trans->carrier_bits_start = carrier_bits_start;
	fsk_trans->carrier_bits_stop = carrier_bits_stop;
	fsk_trans->chan_sieze_bits = chan_sieze_bits;
	fsk_trans->write_sample_callback = write_sample_callback;
	fsk_trans->user_data = user_data;
	return FTDM_SUCCESS;
}


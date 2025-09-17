/*--------------------------------------------------------------------------
-- FILE        :	main.c
-- DESCRIPTION :	LimePSB RPCM GPSDO CPU Firmware
-- DATE        :
-- AUTHOR(s)   :	Lime Microsystems
-- REVISIONS   :
--------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include <irq.h>
#include <libbase/uart.h>
#include <libbase/console.h>

#include <generated/soc.h>
#include <generated/mem.h>
#include <generated/csr.h>

#include "vctcxo_tamer.h"

/*-----------------------------------------------------------------------*/
/* Constants                                                             */
/*-----------------------------------------------------------------------*/

#define DEBUG_PRINT

/*-----------------------------------------------------------------------*/
/* Global Variables                                                      */
/*-----------------------------------------------------------------------*/

struct vctcxo_tamer_pkt_buf vctcxo_tamer_pkt;
uint16_t dac_val = 30714;

/*-----------------------------------------------------------------------*/
/* Helpers                                                               */
/*-----------------------------------------------------------------------*/

/**
 * @brief Controls the TCXO DAC via SPI by sending configuration data.
 *
 * This function enables SPI communication, sends configuration data to the TCXO DAC,
 * and disables SPI communication afterward. The configuration consists of two parts:
 *  - The two least significant bits of `pd` are sent in the first SPI transfer.
 *  - The 16-bit `data` is sent in two subsequent SPI transfers (upper byte first, then lower byte).
 *
 * @param pd A 8-bit value where only the two least significant bits (LSBs) are used.
 * @param data A 16-bit value to be transmitted to the DAC in two parts (MSB and LSB).
 */

#define SPI_START   (1 << 0)
#define SPI_DONE    (1 << 0)
#define SPI_LENGTH  (1 << 8)

static void Control_TCXO_DAC(uint8_t pd, uint16_t data) {
	uint32_t word;

	/* Prepare Word */
	word = (pd << 16) | data;

	/* Write word on MOSI */
	spi_mosi_write(word);

	/* Initiate SPI Xfer */
	spi_control_write(24*SPI_LENGTH | SPI_START);

	/* Wait SPI Xfer to be done */
	while(spi_status_read() != SPI_DONE);
}

/*-----------------------------------------------------------------------*/
/* Main                                                                  */
/*-----------------------------------------------------------------------*/
int main(void)
{
#ifdef CONFIG_CPU_HAS_INTERRUPT
	irq_setmask(0);
	irq_setie(1);
#endif

#ifdef DEBUG_PRINT
	uart_init();
	puts("\nLimePSB-RPCM GPSDO Firmware\n");
#endif
	// Trim DAC constants
  	const uint16_t trimdac_min = 0x0000; // Decimal value = 0
  	const uint16_t trimdac_max = 0xFFFF; // Decimal value = 65535

    // Trim DAC calibration line
    line_t trimdac_cal_line;

    // VCTCXO Tune State machine
    state_t tune_state = COARSE_TUNE_MIN;

    // Set the known/default values of the trim DAC cal line
    trimdac_cal_line.point[0].x = 0;
    trimdac_cal_line.point[0].y = trimdac_min;
    trimdac_cal_line.point[1].x = 0;
    trimdac_cal_line.point[1].y = trimdac_max;
    trimdac_cal_line.slope = 0;
    trimdac_cal_line.y_intercept = 0;
    vctcxo_tamer_pkt.ready = false;

    uint8_t vctcxo_tamer_en=0,	vctcxo_tamer_en_old = 0;

    /* Set Default VCTCXO DAC value */
    vctcxo_trim_dac_write(0x08, 0x77FA);
    Control_TCXO_DAC(0x0, 0x77FA);  //Set DAC in normal operation mode, set new val

//#ifdef DEBUG_PRINT
//  printf("VT_DAC_TUNNED_VAL_ADDR0=0x%02x\n", vctcxo_tamer_read(VT_DAC_TUNNED_VAL_ADDR0));
//  printf("VT_DAC_TUNNED_VAL_ADDR1=0x%02x\n", vctcxo_tamer_read(VT_DAC_TUNNED_VAL_ADDR1));
//#endif

 while (1)
  {
    //Get vctcxo tamer enable bit status
    vctcxo_tamer_en_old = vctcxo_tamer_en;
    vctcxo_tamer_en = mailbox_gpsdo_en_read();

    // Enable or disable VCTCXO tamer module depending on enable signal
    if (vctcxo_tamer_en_old != vctcxo_tamer_en){
    	if (vctcxo_tamer_en == 0x01){  //Enable
    		vctcxo_tamer_init();
        tune_state = COARSE_TUNE_MIN;
    		vctcxo_tamer_pkt.ready = true;
    	}
    	else {  //Disable
    		vctcxo_tamer_dis();
    		tune_state = COARSE_TUNE_MIN;
    		vctcxo_tamer_pkt.ready = false;
    	}
    }

    /* VCTCXO Calibration FSM. */
    if (vctcxo_tamer_pkt.ready)
    {
      vctcxo_tamer_pkt.ready = false;

      switch (tune_state)
      {

      case COARSE_TUNE_MIN:

        /* Tune to the minimum DAC value */
        vctcxo_trim_dac_write(0x08, trimdac_min);
        dac_val = (uint16_t)trimdac_min;
        Control_TCXO_DAC(0x0, dac_val);  //Set DAC in normal operation mode, set new val

        /* State to enter upon the next interrupt */
        tune_state = COARSE_TUNE_MAX;
        #ifdef DEBUG_PRINT
          puts("\nCOARSE_TUNE_MIN\n");
          // printf("COARSE_TUNE_MIN: \r\n\t");
          // printf("DAC value: ");
          // printf("%u;\t", (unsigned int)dac_val);
        #endif

        break;

      case COARSE_TUNE_MAX:
        /* We have the error from the minimum DAC setting, store it
         * as the 'x' coordinate for the first point */
        trimdac_cal_line.point[0].x = vctcxo_tamer_pkt.pps_1s_error;

        // printf("1s_error: ");
        // printf("%i;\r\n", (int)vctcxo_tamer_pkt.pps_1s_error);

        /* Tune to the maximum DAC value */
        vctcxo_trim_dac_write(0x08, trimdac_max);
        dac_val = (uint16_t)trimdac_max;
        Control_TCXO_DAC(0x0, dac_val);  //Set DAC in normal operation mode, set new val

        /* State to enter upon the next interrupt */
        tune_state = COARSE_TUNE_DONE;
        #ifdef DEBUG_PRINT
          puts("\nCOARSE_TUNE_MAX\n");
        #endif

        break;

      case COARSE_TUNE_DONE:
        /* Write status to to state register*/
        vctcxo_tamer_write(VT_STATE_ADDR, 0x01);

        /* We have the error from the maximum DAC setting, store it
         * as the 'x' coordinate for the second point */
        trimdac_cal_line.point[1].x = vctcxo_tamer_pkt.pps_1s_error;

        // printf("1s_error: ");
        // printf("%i;\r\n", (int)vctcxo_tamer_pkt.pps_1s_error);

        /* We now have two points, so we can calculate the equation
         * for a line plotted with DAC counts on the Y axis and
         * error on the X axis. We want a PPM of zero, which ideally
         * corresponds to the y-intercept of the line. */

        trimdac_cal_line.slope = ((float)(trimdac_cal_line.point[1].y - trimdac_cal_line.point[0].y) / (float)(trimdac_cal_line.point[1].x - trimdac_cal_line.point[0].x));

        trimdac_cal_line.y_intercept = (trimdac_cal_line.point[0].y -
                                        (uint16_t)(lroundf(trimdac_cal_line.slope * (float)trimdac_cal_line.point[0].x)));

        /* Set the trim DAC count to the y-intercept */
        vctcxo_trim_dac_write(0x08, trimdac_cal_line.y_intercept);
        dac_val = (uint16_t)trimdac_cal_line.y_intercept;
        Control_TCXO_DAC(0x0, dac_val);  //Set DAC in normal operation mode, set new val

        /* State to enter upon the next interrupt */
        tune_state = FINE_TUNE;
        #ifdef DEBUG_PRINT
          puts("\nCOARSE_TUNE_DONE\n");
        #endif

        break;

      case FINE_TUNE:
        #ifdef DEBUG_PRINT
          puts("\nFINE_TUNE\n");
        #endif

        /* We should be extremely close to a perfectly tuned
         * VCTCXO, but some minor adjustments need to be made */

        /* Check the magnitude of the errors starting with the
         * one second count. If an error is greater than the maximum
         * tolerated error, adjust the trim DAC by the error (Hz)
         * multiplied by the slope (in counts/Hz) and scale the
         * result by the precision interval (e.g. 1s, 10s, 100s). */

        if (vctcxo_tamer_pkt.pps_1s_error_flag)
        {
          vctcxo_trim_dac_value = (vctcxo_trim_dac_value -
                                   (uint16_t)(lroundf((float)vctcxo_tamer_pkt.pps_1s_error * trimdac_cal_line.slope) / 1));
          // Write tuned val to VCTCXO_tamer MM registers
          vctcxo_trim_dac_write(0x08, vctcxo_trim_dac_value);
          // Change DAC value
          dac_val = (uint16_t)vctcxo_trim_dac_value;
          Control_TCXO_DAC(0x0, dac_val);  //Set DAC in normal operation mode, set new val
          // printf("001;");
          // printf("%u;", (unsigned int)dac_val);
          // printf("%i;\r\n", (int) vctcxo_tamer_pkt.pps_1s_error);
        }
        else if (vctcxo_tamer_pkt.pps_10s_error_flag)
        {
          vctcxo_trim_dac_value = (vctcxo_trim_dac_value -
                                   (uint16_t)(lroundf((float)vctcxo_tamer_pkt.pps_10s_error * trimdac_cal_line.slope) / 10));
          // Write tuned val to VCTCXO_tamer MM registers
          vctcxo_trim_dac_write(0x08, vctcxo_trim_dac_value);
          // Change DAC value
          dac_val = (uint16_t)vctcxo_trim_dac_value;
          Control_TCXO_DAC(0x0, dac_val);  //Set DAC in normal operation mode, set new val
          // printf("010;");
          // printf("%u;", (unsigned int)dac_val);
          // printf("%i;\r\n", (int) vctcxo_tamer_pkt.pps_10s_error);
        }
        else if (vctcxo_tamer_pkt.pps_100s_error_flag)
        {
          vctcxo_trim_dac_value = (vctcxo_trim_dac_value -
                                   (uint16_t)(lroundf((float)vctcxo_tamer_pkt.pps_100s_error * trimdac_cal_line.slope) / 100));
          // Write tuned val to VCTCXO_tamer MM registers
          vctcxo_trim_dac_write(0x08, vctcxo_trim_dac_value);
          // Change DAC value
          dac_val = (uint16_t)vctcxo_trim_dac_value;
          Control_TCXO_DAC(0x0, dac_val);  //Set DAC in normal operation mode, set new val
          // printf("100;");
          // printf("%u;", (unsigned int)dac_val);
          // printf("%i;\r\n", (int) vctcxo_tamer_pkt.pps_100s_error);
        }

        break;

      default:
        break;

      } /* switch */

      /* Take PPS counters out of reset */
      vctcxo_tamer_reset_counters(false);

      /* Enable interrupts */
      vctcxo_tamer_enable_isr(true);

    } /* VCTCXO Tamer interrupt */
  }

  return 0;
}

#if 0
// handler functions for the external interrupt channels:
// - must not have parameters nor a return value
// - should not use the interrupt attribute, as they can be normal functions called by the actual interrupt handler

void ext_irq_ch0_handler(void)
{
  vctcxo_tamer_isr(&vctcxo_tamer_pkt);
}

#endif

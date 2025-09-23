/*--------------------------------------------------------------------------
-- FILE        : main.c
-- DESCRIPTION : LimePSB RPCM GPSDO CPU Firmware.
-- DATE        :
-- AUTHOR(s)   : Lime Microsystems.
-- REVISIONS   :
--------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include <libbase/uart.h>
#include <libbase/console.h>

#include <generated/soc.h>
#include <generated/mem.h>
#include <generated/csr.h>

#include "vctcxo_tamer.h"

/*-----------------------------------------------------------------------*/
/* Constants                                                             */
/*-----------------------------------------------------------------------*/

#define VCTCXO_DEBUG

#define VCTCXO_DEFAULT_DAC_VALUE 0x77FA

/*-----------------------------------------------------------------------*/
/* Global Variables                                                      */
/*-----------------------------------------------------------------------*/

struct vctcxo_tamer_pkt_buf vctcxo_tamer_pkt;

/*-----------------------------------------------------------------------*/
/* Helpers                                                               */
/*-----------------------------------------------------------------------*/

#define SPI_START   (1 << 0)
#define SPI_DONE    (1 << 0)
#define SPI_LENGTH  (1 << 8)

/* Sets the VCTCXO DAC value via SPI.
 *
 * @param pd   Power-down control bits (PD1 PD0).
 * @param data 16-bit DAC value.
 */
static void vctcxo_dac_set(uint8_t pd, uint16_t data) {
    uint32_t word;

    /* Prepare Word. */
    word = (pd << 16) | data;

    /* Write word on MOSI. */
    spi_mosi_write(word);

    /* Initiate SPI Xfer. */
    spi_control_write(24 * SPI_LENGTH | SPI_START);

    /* Wait SPI Xfer to be done. */
    while (spi_status_read() != SPI_DONE);
}

/* Adjusts the trim DAC value based on error, slope, and scale.
 *
 * @param error The PPS error value.
 * @param slope The calibration slope.
 * @param scale The scaling factor (1, 10, or 100).
 */
static void adjust_trim_dac(int32_t error, float slope, int scale) {
    /* Compute new trim DAC value */
    vctcxo_trim_dac_value = (
        vctcxo_trim_dac_value -
        (uint16_t)(lroundf((float)error * slope) / scale));

    /* Write value to VCTCXO Tamer. */
    vctcxo_trim_dac_write(vctcxo_trim_dac_value);

    /* Write value to DAC. */
    vctcxo_dac_set(0x0, vctcxo_trim_dac_value);
}

/*-----------------------------------------------------------------------*/
/* Main                                                                  */
/*-----------------------------------------------------------------------*/
int main(void)
{
#ifdef VCTCXO_DEBUG
    uart_init();
    puts("\nLimePSB-RPCM GPSDO Firmware.\n");
#endif

    /* Trim DAC constants. */
    const uint16_t trimdac_min = 0x0000; /* Decimal value = 0. */
    const uint16_t trimdac_max = 0xFFFF; /* Decimal value = 65535. */

    /* Trim DAC calibration line. */
    line_t trimdac_cal_line;

    /* VCTCXO Tamer Tune State machine. */
    state_t tune_state = COARSE_TUNE_MIN;

    /* Set the known/default values of the trim DAC cal line. */
    trimdac_cal_line.point[0].x  = 0;
    trimdac_cal_line.point[0].y  = trimdac_min;
    trimdac_cal_line.point[1].x  = 0;
    trimdac_cal_line.point[1].y  = trimdac_max;
    trimdac_cal_line.slope       = 0;
    trimdac_cal_line.y_intercept = 0;
    vctcxo_tamer_pkt.ready       = false;

    uint8_t vctcxo_tamer_en     = 0;
    uint8_t vctcxo_tamer_en_old = 0;

    /* Set Default VCTCXO/DAC value. */
    vctcxo_trim_dac_write(VCTCXO_DEFAULT_DAC_VALUE);
    vctcxo_dac_set(0x0,   VCTCXO_DEFAULT_DAC_VALUE);

    /* ---------- */
    /*  Main Loop */
    /* ---------- */
    while (1)
    {
        /* Get VCTCXO Tamer enable bit status. */
        vctcxo_tamer_en_old = vctcxo_tamer_en;
        vctcxo_tamer_en     = gpsdo_control_enable_read();

        /* Get VCTCXO Tamer irq status. */
        if (gpsdo_control_irq_read()) {
            vctcxo_tamer_isr(&vctcxo_tamer_pkt);
            gpsdo_control_irq_read();
        }

        /* Enable or disable VCTCXO Tamer module depending on enable signal. */
        if (vctcxo_tamer_en_old != vctcxo_tamer_en) {
            /* Enable. */
            if (vctcxo_tamer_en == 0x01) {
                vctcxo_tamer_init();
                tune_state = COARSE_TUNE_MIN;
                vctcxo_tamer_pkt.ready = true;
            }
            /* Disable. */
            else {
                vctcxo_tamer_dis();
                tune_state = COARSE_TUNE_MIN;
                vctcxo_tamer_pkt.ready = false;
            }
        }

        /* VCTCXO Tamer Calibration FSM. */
        if (vctcxo_tamer_pkt.ready)
        {
            vctcxo_tamer_pkt.ready = false;

            switch (tune_state)
            {

            /* --------------------- */
            /* COARSE TUNE MIN State */
            /* --------------------- */
            case COARSE_TUNE_MIN:
#ifdef VCTCXO_DEBUG
                puts("\nCOARSE_TUNE_MIN\n");
#endif
                /* Set trim DAC to minimum value. */
                vctcxo_trim_dac_write(trimdac_min);
                vctcxo_dac_set(0x0,   trimdac_min);

                /* Set next interrupt state. */
                tune_state = COARSE_TUNE_MAX;

                break;

            /* ----------------------- */
            /* COARSE TUNE MAX State   */
            /* ----------------------- */
            case COARSE_TUNE_MAX:
#ifdef VCTCXO_DEBUG
                puts("\nCOARSE_TUNE_MAX\n");
#endif
                /* We have the error from the minimum DAC setting, store it as
                   the 'x' coordinate for the first point. */
                trimdac_cal_line.point[0].x = vctcxo_tamer_pkt.pps_1s_error;

                /* Set DAC to maximum value. */
                vctcxo_trim_dac_write(trimdac_max);
                vctcxo_dac_set(0x0,   trimdac_max);

                /* Set next interrupt state. */
                tune_state = COARSE_TUNE_DONE;

                break;

            /* ---------------------- */
            /* COARSE TUNE DONE State */
            /* ---------------------- */

            case COARSE_TUNE_DONE:
#ifdef VCTCXO_DEBUG
                puts("\nCOARSE_TUNE_DONE\n");
#endif
                /* Write status to state register. */
                vctcxo_tamer_write(VT_STATE_ADDR, 0x01);

                /* We have the error from the maximum DAC setting, store it as
                   the 'x' coordinate for the second point. */
                trimdac_cal_line.point[1].x = vctcxo_tamer_pkt.pps_1s_error;

                /* We now have two points, so we can calculate the equation for
                   a line plotted with DAC counts on the Y axis and error on
                   the X axis. We want a PPM of zero, which ideally corresponds
                   to the y-intercept of the line. */
                if ((trimdac_cal_line.point[1].x - trimdac_cal_line.point[0].x) != 0) {
                    trimdac_cal_line.slope = (
                        (float)(trimdac_cal_line.point[1].y - trimdac_cal_line.point[0].y) /
                        (float)(trimdac_cal_line.point[1].x - trimdac_cal_line.point[0].x));

                    trimdac_cal_line.y_intercept = (
                        trimdac_cal_line.point[0].y -
                        (uint16_t)(lroundf(trimdac_cal_line.slope * (float)trimdac_cal_line.point[0].x)));
                } else {
                    /* Handle division by zero (rare, but set to default). */
                    trimdac_cal_line.y_intercept = VCTCXO_DEFAULT_DAC_VALUE;
                }

                /* Set the trim DAC count to the y-intercept. */
                vctcxo_trim_dac_write(trimdac_cal_line.y_intercept);
                vctcxo_dac_set(0x0,   trimdac_cal_line.y_intercept);

                /* Set next interrupt state. */
                tune_state = FINE_TUNE;

                break;

            /* --------------- */
            /* FINE TUNE State */
            /* --------------- */
            case FINE_TUNE:
#ifdef VCTCXO_DEBUG
                puts("\nFINE_TUNE\n");
#endif

                /* We should be extremely close to a perfectly tuned VCTCXO, but
                   some minor adjustments need to be made. */

                /* Check the magnitude of the errors starting with the one
                   second count. If an error is greater than the maximum
                   tolerated error, adjust the trim DAC by the error
                   (Hz) multiplied by the slope (in counts/Hz) and scale the
                   result by the precision interval (e.g. 1s, 10s, 100s). */

                if (vctcxo_tamer_pkt.pps_1s_error_flag)
                {
                    adjust_trim_dac(vctcxo_tamer_pkt.pps_1s_error, trimdac_cal_line.slope, 1);
                }
                else if (vctcxo_tamer_pkt.pps_10s_error_flag)
                {
                    adjust_trim_dac(vctcxo_tamer_pkt.pps_10s_error, trimdac_cal_line.slope, 10);
                }
                else if (vctcxo_tamer_pkt.pps_100s_error_flag)
                {
                    adjust_trim_dac(vctcxo_tamer_pkt.pps_100s_error, trimdac_cal_line.slope, 100);
                }

                break;

            default:
                break;

            }

            /* Take PPS counters out of reset. */
            vctcxo_tamer_reset_counters(false);

            /* Enable interrupts. */
            vctcxo_tamer_enable_isr(true);

        }
    }

    return 0;
}

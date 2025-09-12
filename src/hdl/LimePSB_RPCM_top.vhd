-- ----------------------------------------------------------------------------
-- FILE:          LimePSB_RPCM_top.vhd
-- DESCRIPTION:   Top design file for LimePSB_RPCM FPGA
-- DATE:          09:46 2024-10-01
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- NOTES:
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.gpsdocfg_pkg.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity LimePSB_RPCM_top is
   port (
      -- Sys Clk/Rst.
      SYS_CLK          : in std_logic;
      SYS_RST_N        : in std_logic;

      -- RF Clks.
      LMK10_CLK_OUT0   : in     std_logic;
      LMKRF_CLK_OUT4   : in     std_logic;

      -- RPI
      RPI_SYNC_IN      : inout  std_logic;
      RPI_SYNC_OUT     : in     std_logic;
      RPI_SPI1_SCLK    : in     std_logic;
      RPI_SPI1_MOSI    : in     std_logic;
      RPI_SPI1_MISO    : out    std_logic;
      RPI_SPI1_SS1     : in     std_logic;
      RPI_SPI1_SS2     : in     std_logic;

      --FPGA
      FPGA_GPIO        : inout  std_logic_vector(1 downto 0);
      FPGA_CFG_SPI_SCK : inout  std_logic;
      FPGA_CFG_SPI_SI  : inout  std_logic;
      FPGA_CFG_SPI_SO  : inout  std_logic;
      FPGA_CFG_SPI_CSN : in     std_logic;
      FPGA_I2C_SCL     : inout  std_logic;
      FPGA_I2C_SDA     : inout  std_logic;
      FPGA_SYNC_OUT    : out    std_logic;
      FPGA_SPI0_SCLK   : out    std_logic;
      FPGA_SPI0_MOSI   : out    std_logic;
      FPGA_SPI0_DAC_SS : out    std_logic;

      -- GNSS
      GNSS_TPULSE      : in std_logic
   );
end LimePSB_RPCM_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of LimePSB_RPCM_top is

   constant c_GPSDOCFG_START_ADDR : integer := 0;

   signal to_gpsdocfg      : t_TO_GPSDOCFG;
   signal from_gpsdocfg    : t_FROM_GPSDOCFG;
   signal rpi_spi1_miso_o  : std_logic;
   signal gpsdocfg_oen     : std_logic;

   signal tpulse_internal : std_logic;

   signal neo430_gpio   : std_logic_vector(15 downto 0);

   component pps_detector is
    port (
        clk        : in  std_logic;
        reset      : in  std_logic;
        pps        : in  std_logic;
        pps_active : out std_logic
    );
   end component;

   component vctcxo_tamer is
    port(
        tune_ref           :   in  std_logic;
        vctcxo_clock       :   in  std_logic;
        mm_clock           :   in  std_logic;
        mm_reset           :   in  std_logic;
        mm_rd_req          :   in  std_logic;
        mm_wr_req          :   in  std_logic;
        mm_addr            :   in  std_logic_vector(7 downto 0);
        mm_wr_data         :   in  std_logic_vector(7 downto 0);
        mm_rd_data         :   out std_logic_vector(7 downto 0);
        mm_wait_req        :   out std_logic := '0';
        mm_irq             :   out std_logic := '0';
        PPS_1S_TARGET       :   in std_logic_vector(31 downto 0);
        PPS_1S_ERROR_TOL    :   in std_logic_vector(31 downto 0);
        PPS_10S_TARGET      :   in std_logic_vector(31 downto 0);
        PPS_10S_ERROR_TOL   :   in std_logic_vector(31 downto 0);
        PPS_100S_TARGET     :   in std_logic_vector(31 downto 0);
        PPS_100S_ERROR_TOL  :   in std_logic_vector(31 downto 0);
        pps_1s_error       :   out std_logic_vector(31 downto 0);
        pps_10s_error      :   out std_logic_vector(31 downto 0);
        pps_100s_error     :   out std_logic_vector(31 downto 0);
        accuracy           :   out std_logic_vector(3 downto 0);
        state              :   out std_logic_vector(3 downto 0);
        dac_tuned_val      :   out std_logic_vector(15 downto 0)
    );
   end component;

   component neo430_top_avm is
      port (
        clk_i           : in  std_logic;
        rst_i           : in  std_logic;
        gpio_o          : out std_logic_vector(15 downto 0);
        gpio_i          : in  std_logic_vector(15 downto 0);
        pwm_o           : out std_logic_vector(03 downto 0);
        freq_gen_o      : out std_logic_vector(02 downto 0);

        uart_txd_o      : out std_logic;
        uart_rxd_i      : in  std_logic;
        spi_sclk_o      : out std_logic;
        spi_mosi_o      : out std_logic;
        spi_miso_i      : in  std_logic;
        spi_cs_o        : out std_logic;
        twi_sda_io      : inout std_logic;
        twi_scl_io      : inout std_logic;
        ext_irq_i       : in  std_logic_vector(07 downto 0);
        ext_ack_o       : out std_logic_vector(07 downto 0);
        avm_address     : out std_logic_vector(31 downto 0);
        avm_readdata    : in  std_logic_vector(31 downto 0);
        avm_writedata   : out std_logic_vector(31 downto 0);
        avm_byteenable  : out std_logic_vector(03 downto 0);
        avm_write       : out std_logic;
        avm_read        : out std_logic;
        avm_waitrequest : in  std_logic
      );
   end component;

   --Testing temp
   signal neo430_avm_address     :  std_logic_vector(31 downto 0);
   signal neo430_avm_readdata    :  std_logic_vector(31 downto 0);
   signal neo430_avm_writedata   :  std_logic_vector(31 downto 0);
   signal neo430_avm_byteenable  :  std_logic_vector(03 downto 0);
   signal neo430_avm_write       :  std_logic;
   signal neo430_avm_read        :  std_logic;
   signal neo430_avm_waitrequest :  std_logic;

   signal neo430_ext_irq         : std_logic_vector(7 downto 0);
   signal neo430_ext_irq_ack     : std_logic_vector(7 downto 0);
   signal neo430_ext_irq_reg     : std_logic_vector(7 downto 0);
   signal neo430_ext_irq_rising_edge : std_logic_vector(7 downto 0);

   signal neo430_spi_sclk        : std_logic;
   signal neo430_spi_mosi        : std_logic;  
   signal neo430_spi_cs          : std_logic;

   signal vctcxo_tamer_mm_irq    : std_logic;
   signal vctcxo_tamer_mm_irq_reg: std_logic;

   signal vctcxo_tamer_pps_1s_error    : std_logic_vector(31 downto 0);
   signal vctcxo_tamer_pps_10s_error   : std_logic_vector(31 downto 0);
   signal vctcxo_tamer_pps_100s_error  : std_logic_vector(31 downto 0);

   signal vctcxo_tamer_dac_tuned_val   : std_logic_vector(15 downto 0);
   signal vctcxo_tamer_accuracy        : std_logic_vector( 3 downto 0);
   signal vctcxo_tamer_state           : std_logic_vector( 3 downto 0);

   signal gnns_tpulse_reg        : std_logic_vector(3 downto 0);

   signal neo430_gpio_i          : std_logic_vector(15 downto 0);

   signal vctcxo_clk             : std_logic;

   signal tpulse_active          : std_logic;


begin


   pps_detector_inst : pps_detector
--      Generic map(
--          CLK_FREQ_HZ => 6_000_000, -- Nominal system clock frequency
--          TOLERANCE   => 5_000_000   -- Allow ±50% tolerance (adjust as needed)
--      )
      Port map(
          clk        => SYS_CLK,            -- System clock
          reset      => NOT SYS_RST_N,    -- Reset signal
          pps        => tpulse_internal,  -- 1PPS input signal
          pps_active => tpulse_active     -- Indicates if PPS is active
      );

-- ----------------------------------------------------------------------------
-- gpsdocfg SPI instance.
-- ----------------------------------------------------------------------------
   to_gpsdocfg.PPS_1S_ERROR   <= vctcxo_tamer_pps_1s_error;  
   to_gpsdocfg.PPS_10S_ERROR  <= vctcxo_tamer_pps_10s_error; 
   to_gpsdocfg.PPS_100S_ERROR <= vctcxo_tamer_pps_100s_error;
   to_gpsdocfg.DAC_TUNED_VAL  <= vctcxo_tamer_dac_tuned_val;
   to_gpsdocfg.STATE          <= vctcxo_tamer_state;
   to_gpsdocfg.ACCURACY       <= vctcxo_tamer_accuracy;
   to_gpsdocfg.TPULSE_ACTIVE  <= tpulse_active;
                 
-- ----------------------------------------------------------------------------
-- NEO430 CPU
-- ----------------------------------------------------------------------------
   neo430_inst : neo430_top_avm
--   generic map(
--     -- general configuration --
--     CLOCK_SPEED  => 6000000,    -- main clock in Hz
--     IMEM_SIZE    => 5*1024,     -- internal IMEM size in bytes, max 48kB (default=4kB)
--     DMEM_SIZE    => 2*1024,     -- internal DMEM size in bytes, max 12kB (default=2kB)
--     -- additional configuration --
--     USER_CODE    => x"0000",    -- custom user code
--     -- module configuration --
--     MULDIV_USE   => false,   -- implement multiplier/divider unit? (default=true)
--     WB32_USE     => true,    -- implement WB32 unit? (default=true)
--     WDT_USE      => false,   -- implement WDT? (default=true)
--     GPIO_USE     => true,    -- implement GPIO unit? (default=true)
--     TIMER_USE    => false,   -- implement timer? (default=true)
--     UART_USE     => false,   -- implement UART? (default=true)
--     CRC_USE      => false,   -- implement CRC unit? (default=true)
--     CFU_USE      => false,   -- implement custom functions unit? (default=false)
--     PWM_USE      => false,   -- implement PWM controller?
--     TWI_USE      => false,   -- implement two wire serial interface? (default=true)
--     SPI_USE      => true,    -- implement SPI? (default=true)
--     TRNG_USE     => false,   -- implement TRNG? (default=false)
--     EXIRQ_USE    => true,    -- implement EXIRQ? (default=true)
--     FREQ_GEN_USE => false,   -- implement FREQ_GEN? (default=true)
--     -- boot configuration --
--     BOOTLD_USE   => false,   -- implement and use bootloader? (default=true)
--     IMEM_AS_ROM  => true    -- implement IMEM as read-only memory? (default=false)
--   )
   port map(
     -- global control --
     clk_i           => SYS_CLK,      -- global clock, rising edge
     rst_i           => SYS_RST_N,  -- global reset, async, low-active
     -- GPIO --
     gpio_o          => neo430_gpio,   -- parallel output
     gpio_i          => neo430_gpio_i, -- parallel input
     -- pwm channels --
     pwm_o           => open, -- pwm channels
     -- arbitrary frequency generator --
     freq_gen_o      => open, -- programmable frequency output
     -- UART --
     uart_txd_o      => FPGA_GPIO(0),  -- UART send data
     uart_rxd_i      => FPGA_GPIO(1),  -- UART receive data
     -- SPI --
     spi_sclk_o      => neo430_spi_sclk, -- serial clock line
     spi_mosi_o      => neo430_spi_mosi, -- serial data line out
     spi_miso_i      => '0',             -- serial data line in
     spi_cs_o        => neo430_spi_cs,   -- SPI CS
     --spi_cs_o(0)     => neo430_spi_cs,   -- SPI CS
     --spi_cs_o(1)     => open, -- SPI CS
     --spi_cs_o(2)     => open, -- SPI CS
     --spi_cs_o(3)     => open, -- SPI CS
     --spi_cs_o(4)     => open, -- SPI CS
     --spi_cs_o(5)     => open, -- SPI CS
     twi_sda_io      => open, -- twi serial data line
     twi_scl_io      => open, -- twi serial clock line
     -- external interrupts --
     ext_irq_i       => neo430_ext_irq,      -- external interrupt request lines
     ext_ack_o       => neo430_ext_irq_ack,  -- external interrupt request acknowledges
     -- Avalon master interface --
     avm_address     => neo430_avm_address    ,
     avm_readdata    => neo430_avm_readdata   ,
     avm_writedata   => neo430_avm_writedata  ,
     avm_byteenable  => neo430_avm_byteenable ,
     avm_write       => neo430_avm_write      ,
     avm_read        => neo430_avm_read       ,
     avm_waitrequest => neo430_avm_waitrequest
   );


   process (SYS_CLK, SYS_RST_N)
   begin
      if SYS_RST_N = '0' then
         vctcxo_tamer_mm_irq_reg <= '0';
         neo430_ext_irq(0)       <= '0';
      elsif (rising_edge(SYS_CLK)) then
         vctcxo_tamer_mm_irq_reg <= vctcxo_tamer_mm_irq;
   
         if neo430_ext_irq_ack(0) = '1'  then 
            neo430_ext_irq(0) <= '0';
         elsif vctcxo_tamer_mm_irq_reg = '0' AND vctcxo_tamer_mm_irq = '1' then 
            neo430_ext_irq(0) <= '1';
         else
            neo430_ext_irq(0) <= neo430_ext_irq(0);
         end if;
   
      end if;
   end process;

   neo430_ext_irq(7 downto 1) <= (others=>'0'); 

   neo430_gpio_i(0)           <= from_gpsdocfg.IICFG_EN;
   neo430_gpio_i(15 downto 1) <= (others=>'0');

-- ----------------------------------------------------------------------------
-- VCTCXO tamer 
-- ----------------------------------------------------------------------------
   tpulse_internal   <= RPI_SYNC_OUT   when from_gpsdocfg.IICFG_TPULSE_SEL = "01" else 
                        RPI_SYNC_IN    when from_gpsdocfg.IICFG_TPULSE_SEL = "10" else GNSS_TPULSE;
   vctcxo_clk        <= LMK10_CLK_OUT0 when from_gpsdocfg.IICFG_CLK_SEL = '1'     else LMKRF_CLK_OUT4;

   vctcxo_tamer_inst : vctcxo_tamer
      port map(
         -- Physical Interface
         tune_ref           => tpulse_internal,
         vctcxo_clock       => vctcxo_clk,
         --tune_ref           => GNSS_TPULSE,
         --vctcxo_clock       => LMKRF_CLK_OUT4,
         
         -- Avalon-MM Interface
         mm_clock           => SYS_CLK,
         mm_reset           => not SYS_RST_N,
         mm_rd_req          => neo430_avm_read,
         mm_wr_req          => neo430_avm_write,
         mm_addr            => neo430_avm_address(7 downto 0),
         mm_wr_data         => neo430_avm_writedata(7 downto 0),
         mm_rd_data         => neo430_avm_readdata(7 downto 0),
         --mm_rd_datav        => open,
         mm_wait_req        => neo430_avm_waitrequest,
         
         -- Avalon Interrupts
         mm_irq             => vctcxo_tamer_mm_irq, 
         
         PPS_1S_TARGET       => from_gpsdocfg.IICFG_1S_TARGET(31 downto 0),           --x"01D4_C000", -- 3072e4,
         PPS_1S_ERROR_TOL    => x"0000" & from_gpsdocfg.IICFG_1S_TOL(15 downto 0),    --std_logic_vector(to_unsigned(3, 32)),
         PPS_10S_TARGET      => from_gpsdocfg.IICFG_10S_TARGET(31 downto 0),          --x"124F_8000",
         PPS_10S_ERROR_TOL   => x"0000" & from_gpsdocfg.IICFG_10S_TOL(15 downto 0),   --std_logic_vector(to_unsigned(34, 32)),
         PPS_100S_TARGET     => from_gpsdocfg.IICFG_100S_TARGET(31 downto 0),         --x"B71B_0000",
         PPS_100S_ERROR_TOL  => x"0000" & from_gpsdocfg.IICFG_100S_TOL(15 downto 0),  --std_logic_vector(to_unsigned(356, 32)),
         
         -- Status registers
         --pps_1s_error_v     => open, 
         pps_1s_error       => vctcxo_tamer_pps_1s_error, 
         --pps_10s_error_v    => open, 
         pps_10s_error      => vctcxo_tamer_pps_10s_error, 
         --pps_100s_error_v   => open, 
         pps_100s_error     => vctcxo_tamer_pps_100s_error, 
         accuracy           => vctcxo_tamer_accuracy, 
         state              => vctcxo_tamer_state, 
         dac_tuned_val      => vctcxo_tamer_dac_tuned_val 
         --pps_1s_count_v     => open, 
         --pps_10s_count_v    => open, 
         --pps_100s_count_v   => open
      );



-- ----------------------------------------------------------------------------
-- Output ports
-- ----------------------------------------------------------------------------

   --DAC can be controlled from host only when GPSO is turned off
   FPGA_SPI0_SCLK   <= RPI_SPI1_SCLK   when from_gpsdocfg.IICFG_EN = '0' else neo430_spi_sclk;
   FPGA_SPI0_MOSI   <= RPI_SPI1_MOSI   when from_gpsdocfg.IICFG_EN = '0' else neo430_spi_mosi;
   FPGA_SPI0_DAC_SS <= RPI_SPI1_SS2    when from_gpsdocfg.IICFG_EN = '0' else neo430_spi_cs;

   FPGA_SYNC_OUT     <= LMK10_CLK_OUT0;
   
   RPI_SYNC_IN <=    'Z'            when from_gpsdocfg.IICFG_TPULSE_SEL = "10" OR from_gpsdocfg.IICFG_RPI_SYNC_IN_DIR = '0' else 
                     GNSS_TPULSE;          -- 10 - RPI_SYNC_IN is input , else - RPI_SYNC_IN is output with GNSS_TPULSE
   
   RPI_SPI1_MISO <= rpi_spi1_miso_o when gpsdocfg_oen = '1' else 'Z';
   
   
  
end arch;   
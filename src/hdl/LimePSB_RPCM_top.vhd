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
library synplify;
use synplify.attributes.all;

library sb_ice40_components_syn;
use sb_ice40_components_syn.components.all;

use work.gpsdocfg_pkg.all;
-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity LimePSB_RPCM_top is
   port (
      LMK10_CLK_OUT0    : in     std_logic;
      LMKRF_CLK_OUT4    : in     std_logic;
      -- RPI   
      RPI_SYNC_IN       : inout  std_logic;
      RPI_SYNC_OUT      : in     std_logic;
      RPI_SPI1_SCLK     : in     std_logic;
      RPI_SPI1_MOSI     : in     std_logic;
      RPI_SPI1_MISO     : out    std_logic;
      RPI_SPI1_SS1      : in     std_logic;
      RPI_SPI1_SS2      : in     std_logic;
      RPI_UART0_TX      : in     std_logic;
      RPI_UART0_RX      : out    std_logic;
      --FPGA 
      FPGA_GPIO         : inout  std_logic_vector(1 downto 0); 
      FPGA_CFG_SPI_SCK  : inout  std_logic;
      FPGA_CFG_SPI_SI   : inout  std_logic;
      FPGA_CFG_SPI_SO   : inout  std_logic;
      FPGA_CFG_SPI_CSN  : in     std_logic;
      FPGA_RF_SW_TDD    : out    std_logic;
      FPGA_I2C_SCL      : inout  std_logic;
      FPGA_I2C_SDA      : inout  std_logic;
      FPGA_SYNC_OUT     : out    std_logic;
      FPGA_SPI0_SCLK    : out    std_logic;
      FPGA_SPI0_MOSI    : out    std_logic;
      FPGA_SPI0_DAC_SS  : out    std_logic;
      FPGA_LED_R        : out    std_logic;
      -- GNSS
      GNSS_EXTINT       : out    std_logic;
      GNSS_RESET        : out    std_logic;
      GNSS_DDC_SCL      : inout  std_logic;
      GNSS_DDC_SDA      : inout  std_logic;
      GNSS_TPULSE       : in     std_logic; 
      GNSS_UART_TX      : in     std_logic;
      GNSS_UART_RX      : out    std_logic;
      -- MISC
      PCIE_UIM          : in     std_logic;
      EN_CM5_USB3       : in     std_logic;
      BOM_VER           : in     std_logic_vector(2 downto 0);
      HW_VER            : in     std_logic_vector(1 downto 0)
   );
end LimePSB_RPCM_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of LimePSB_RPCM_top is
--declare signals,  components here
   constant c_GPSDOCFG_START_ADDR : integer := 0;  

   signal clkhfen       : std_logic := '1';
   signal clkhfpu       : std_logic := '1';
   signal clkhf         : std_logic;

   signal clklfen       : std_logic := '1';
   signal clklfpu       : std_logic := '1';
   signal clklf         : std_logic;

   signal por_vect      : std_logic_vector(1 downto 0) :=(others=>'0');
   signal por_rst_n     : std_logic := '0';

   --signal beat_cnt      : unsigned(8 downto 0);
   --signal beat          : std_logic;
  

   signal to_gpsdocfg    : t_TO_GPSDOCFG;
   signal from_gpsdocfg  : t_FROM_GPSDOCFG;

   signal fpga_gpio_reg : std_logic_vector (FPGA_GPIO'LENGTH-1 downto 0);
   signal bom_ver_sig   : std_logic_vector(2 downto 0);
   signal bom_ver_reg   : std_logic_vector(2 downto 0);
   signal hw_ver_sig    : std_logic_vector(1 downto 0);
   signal en_cm5_usb3_reg : std_logic;

   signal tpulse_internal : std_logic;

   signal neo430_gpio   : std_logic_vector(15 downto 0);
   
   component rgb_io is
      port (
         RGB : inout  std_logic_vector(2 downto 0);
         rgb0     : out    std_logic;
         rgb1     : out    std_logic;
         rgb2     : out    std_logic
      );
   end component;

   --Testing temp
   signal ad5662_wr : std_logic;
   signal ad5662_d  : std_logic_vector(15 downto 0);

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

-- ----------------------------------------------------------------------------
-- Internal LOW Oscilator instance.
   -- Examples of ice5LP macro instance can be found in installdir lscc\iCEcube2.2020.12\LSE\userware\NT\SYNTHESIS_HEADERS
-- ----------------------------------------------------------------------------
--clklfen  <= '1';
--clklfpu  <= '1';
--
--LFOSC_inst : SB_LFOSC
--port map (
--   CLKLFEN  => clklfen,
--   CLKLFPU  => clklfpu, 
--   CLKLF    => clklf
--);


-- ----------------------------------------------------------------------------
-- Internal Oscilator instance.
   -- NOTE: CLKHF_DIV parameter is defined as string 
   -- "0b00" - Sets 48MHz HFOSC output.
   -- "0b01" - Sets 24MHz HFOSC output.
   -- "0b10" - Sets 12MHz HFOSC output.
   -- "0b11" - Sets 6MHz HFOSC output
   -- Examples of ice5LP macro instance can be found in installdir lscc\iCEcube2.2020.12\LSE\userware\NT\SYNTHESIS_HEADERS
-- ----------------------------------------------------------------------------
   clkhfen  <= '1';
   clkhfpu  <= '1';

   HFOSC_inst : SB_HFOSC
   generic map (
      CLKHF_DIV    => "0b11"
   )
   port map (
      CLKHFEN  => clkhfen,
      CLKHFPU  => clkhfpu, 
      CLKHF    => clkhf
   );

-- ----------------------------------------------------------------------------
-- POR (power on reset)
-- ----------------------------------------------------------------------------
process (clkhf)
begin
   if (rising_edge(clkhf)) then
      por_vect <= por_vect(0) & '1';
   end if;
end process;

por_rst_n <= por_vect(0) AND por_vect(1);


-- ----------------------------------------------------------------------------
-- Alive beat
-- ----------------------------------------------------------------------------
   --alive_beat_cnt: process (clklf, por_rst_n)
   --begin
   --   if por_rst_n = '0' then 
   --      beat_cnt <= (others=>'0');
   --   elsif (rising_edge(clklf)) then
   --      beat_cnt <= beat_cnt + 1;
   --   end if;
   --end process alive_beat_cnt;
   --
   --beat <= beat_cnt(beat_cnt'left);

-- ----------------------------------------------------------------------------
-- RGB instance.
-- ----------------------------------------------------------------------------
   rgb_io_inst : entity work.rgb_io
   port map(
      clk      => LMK10_CLK_OUT0,
      RGB(0)   => HW_VER(0),
      RGB(1)   => HW_VER(1),
      RGB(2)   => FPGA_LED_R,
      rgb0     => hw_ver_sig(0),
      rgb1     => hw_ver_sig(1),
      rgb2_in  => NOT (GNSS_TPULSE AND from_gpsdocfg.IICFG_EN),
      rgb2_out => open
   );


   pps_detector_inst : entity work.pps_detector
      Generic map(
          CLK_FREQ_HZ => 6_000_000, -- Nominal system clock frequency
          TOLERANCE   => 5_000_000   -- Allow ±50% tolerance (adjust as needed)
      )
      Port map(
          clk        => clkhf,            -- System clock
          reset      => NOT por_rst_n,    -- Reset signal
          pps        => tpulse_internal,  -- 1PPS input signal
          pps_active => tpulse_active     -- Indicates if PPS is active
      );

-- ----------------------------------------------------------------------------
-- gpsdocfg SPI instance.
-- ----------------------------------------------------------------------------
   gpsdocfg_inst : entity work.gpsdocfg
   port map(
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress       => std_logic_vector(to_unsigned(c_GPSDOCFG_START_ADDR/32,10)),
      mimo_en        => '1',   
      -- Serial port IOs
      sdin           => RPI_SPI1_MOSI,
      sclk           => RPI_SPI1_SCLK,
      sen            => RPI_SPI1_SS1,
      sdout          => RPI_SPI1_MISO,  
      -- Signals coming from the pins or top level serial interface
      lreset         => not por_rst_n,   -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset         => not por_rst_n,   -- Memory reset signal, resets configuration memory only (use only one reset)      
      oen            => open,
      stateo         => open,      
      to_gpsdocfg    => to_gpsdocfg,
      from_gpsdocfg  => from_gpsdocfg
   );

   --to_gpsdocfg.BOM_VER <= '0'  & BOM_VER;
   --to_gpsdocfg.HW_VER  <= "00" & hw_ver_sig;


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
   neo430_inst : entity work.neo430_top_avm
   generic map(
     -- general configuration --
     CLOCK_SPEED  => 6000000,    -- main clock in Hz
     IMEM_SIZE    => 5*1024,     -- internal IMEM size in bytes, max 48kB (default=4kB)
     DMEM_SIZE    => 2*1024,     -- internal DMEM size in bytes, max 12kB (default=2kB)
     -- additional configuration --
     USER_CODE    => x"0000",    -- custom user code
     -- module configuration --
     MULDIV_USE   => false,   -- implement multiplier/divider unit? (default=true)
     WB32_USE     => true,    -- implement WB32 unit? (default=true)
     WDT_USE      => false,   -- implement WDT? (default=true)
     GPIO_USE     => true,    -- implement GPIO unit? (default=true)
     TIMER_USE    => false,   -- implement timer? (default=true)
     UART_USE     => false,   -- implement UART? (default=true)
     CRC_USE      => false,   -- implement CRC unit? (default=true)
     CFU_USE      => false,   -- implement custom functions unit? (default=false)
     PWM_USE      => false,   -- implement PWM controller?
     TWI_USE      => false,   -- implement two wire serial interface? (default=true)
     SPI_USE      => true,    -- implement SPI? (default=true)
     TRNG_USE     => false,   -- implement TRNG? (default=false)
     EXIRQ_USE    => true,    -- implement EXIRQ? (default=true)
     FREQ_GEN_USE => false,   -- implement FREQ_GEN? (default=true)
     -- boot configuration --
     BOOTLD_USE   => false,   -- implement and use bootloader? (default=true)
     IMEM_AS_ROM  => true    -- implement IMEM as read-only memory? (default=false)
   )
   port map(
     -- global control --
     clk_i           => clkhf,      -- global clock, rising edge
     rst_i           => por_rst_n,  -- global reset, async, low-active
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
     spi_cs_o(0)     => neo430_spi_cs,   -- SPI CS
     spi_cs_o(1)     => open, -- SPI CS
     spi_cs_o(2)     => open, -- SPI CS
     spi_cs_o(3)     => open, -- SPI CS
     spi_cs_o(4)     => open, -- SPI CS
     spi_cs_o(5)     => open, -- SPI CS
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


   process (clkhf, por_rst_n)
   begin
      if por_rst_n = '0' then 
         vctcxo_tamer_mm_irq_reg <= '0';
         neo430_ext_irq(0)       <= '0';
      elsif (rising_edge(clkhf)) then
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

   vctcxo_tamer_inst : entity work.vctcxo_tamer
      port map(
         -- Physical Interface
         tune_ref           => tpulse_internal,
         vctcxo_clock       => vctcxo_clk,
         --tune_ref           => GNSS_TPULSE,
         --vctcxo_clock       => LMKRF_CLK_OUT4,
         
         -- Avalon-MM Interface
         mm_clock           => clkhf,
         mm_reset           => not por_rst_n,
         mm_rd_req          => neo430_avm_read,
         mm_wr_req          => neo430_avm_write,
         mm_addr            => neo430_avm_address(7 downto 0),
         mm_wr_data         => neo430_avm_writedata(7 downto 0),
         mm_rd_data         => neo430_avm_readdata(7 downto 0),
         mm_rd_datav        => open,
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
   RPI_UART0_RX      <= GNSS_UART_TX;
   GNSS_UART_RX      <= RPI_UART0_TX;
   
   -- In HW_VER="01" TDD signal has to be inverted
   process(all)
   begin 
      if hw_ver_sig(0)='1' then 
         FPGA_RF_SW_TDD    <= NOT PCIE_UIM; 
      else 
         FPGA_RF_SW_TDD    <= PCIE_UIM;
      end if;
   end process;

   --DAC can be controlled from host only when GPSO is turned off
   FPGA_SPI0_SCLK   <= RPI_SPI1_SCLK   when from_gpsdocfg.IICFG_EN = '0' else neo430_spi_sclk;
   FPGA_SPI0_MOSI   <= RPI_SPI1_MOSI   when from_gpsdocfg.IICFG_EN = '0' else neo430_spi_mosi;
   FPGA_SPI0_DAC_SS <= RPI_SPI1_SS2    when from_gpsdocfg.IICFG_EN = '0' else neo430_spi_cs;

   FPGA_SYNC_OUT     <= LMK10_CLK_OUT0;

   GNSS_RESET <= '1';
   
   
  
end arch;   
-- ----------------------------------------------------------------------------
-- FILE:          rgb_io.vhd
-- DESCRIPTION:   RGB LED buffer control module for ICE5LP4K
-- DATE:          13:29 2024-10-01
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- NOTES:
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--library sb_ice40_components_syn;
--use sb_ice40_components_syn.components.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity rgb_io is
   port (
      clk       : in    std_logic;
      RGB       : inout std_logic_vector(2 downto 0);
      rgb0      : out   std_logic;
      rgb1      : out   std_logic;
      rgb2_in   : in    std_logic;
      rgb2_out  : out   std_logic
   );
end rgb_io;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of rgb_io is

component SB_IO_OD
   generic (
      PIN_TYPE    : bit_vector(5 downto 0);
      NEG_TRIGGER : bit
   );
   port (
      DOUT1           : in std_logic;
      DOUT0           : in std_logic;
      CLOCKENABLE     : in std_logic;
      LATCHINPUTVALUE : in std_logic;
      INPUTCLK        : in std_logic;
      DIN1            : out std_logic;
      DIN0            : out std_logic;
      OUTPUTENABLE    : in std_logic := 'H';
      OUTPUTCLK       : in std_logic;
      PACKAGEPIN      : inout std_logic
   );
end component;

begin

   RGB0_inst : SB_IO_OD
   generic map (
      PIN_TYPE    => "000001",
      NEG_TRIGGER => '0'
   )
   port map (
      PACKAGEPIN      => RGB(0),
      LATCHINPUTVALUE => '0',
      CLOCKENABLE     => '0',
      INPUTCLK        => '0',
      OUTPUTCLK       => '0',
      OUTPUTENABLE    => open,
      DOUT0           => '0',
      DOUT1           => '0',
      DIN0            => rgb0,
      DIN1            => open
   );

   RGB1_inst : SB_IO_OD
   generic map (
      PIN_TYPE    => "000001",
      NEG_TRIGGER => '0'
   )
   port map (
      PACKAGEPIN      => RGB(1),
      LATCHINPUTVALUE => '0',
      CLOCKENABLE     => '0',
      INPUTCLK        => '0',
      OUTPUTCLK       => '0',
      OUTPUTENABLE    => open,
      DOUT0           => '0',
      DOUT1           => '0',
      DIN0            => rgb1,
      DIN1            => open
   );

   RGB2_inst : SB_IO_OD
   generic map (
      PIN_TYPE    => "011001",
      NEG_TRIGGER => '0'
   )
   port map (
      PACKAGEPIN      => RGB(2),
      LATCHINPUTVALUE => '0',
      CLOCKENABLE     => '0',
      INPUTCLK        => '0',
      OUTPUTCLK       => '0',
      OUTPUTENABLE    => open,
      DOUT0           => rgb2_in,
      DOUT1           => '0',
      DIN0            => rgb2_out,
      DIN1            => open
   );


end arch;

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
library sb_ice40_components_syn;
use sb_ice40_components_syn.components.all;

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


begin

   RGB0_inst : SB_IO_OD 
   generic map (
      PIN_TYPE    => "000001",
      NEG_TRIGGER => '0'
   )
   port map (
      PACKAGEPIN        => RGB(0),
      LATCHINPUTVALUE   => open, 
      CLOCKENABLE       => open, 
      INPUTCLK          => open, 
      OUTPUTCLK         => open,
      OUTPUTENABLE      => open, 
      DOUT0             => open, 
      DOUT1             => open, 
      DIN0              => rgb0,
      DIN1              => open
   );
   
   RGB1_inst : SB_IO_OD 
   generic map (
      PIN_TYPE    => "000001",
      NEG_TRIGGER => '0'
   )
   port map (
      PACKAGEPIN        => RGB(1),
      LATCHINPUTVALUE   => open, 
      CLOCKENABLE       => open, 
      INPUTCLK          => open, 
      OUTPUTCLK         => open,
      OUTPUTENABLE      => open, 
      DOUT0             => open, 
      DOUT1             => open, 
      DIN0              => rgb1,
      DIN1              => open
   );
   
   RGB2_inst : SB_IO_OD 
   generic map (
      PIN_TYPE    => "011001",
      NEG_TRIGGER => '0'
   )
   port map (
      PACKAGEPIN        => RGB(2),
      LATCHINPUTVALUE   => open, 
      CLOCKENABLE       => open, 
      INPUTCLK          => open, 
      OUTPUTCLK         => open,
      OUTPUTENABLE      => '1', 
      DOUT0             => rgb2_in, 
      DOUT1             => open, 
      DIN0              => rgb2_out,
      DIN1              => open
   );
   
  
end arch;   



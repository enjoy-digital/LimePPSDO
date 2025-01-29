-- ----------------------------------------------------------------------------
-- FILE:          gpsdocfg_pkg.vhd
-- DESCRIPTION:   Package for fpgacfg module
-- DATE:          11:13 AM Friday, May 11, 2018
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES:
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Package declaration
-- ----------------------------------------------------------------------------
package gpsdocfg_pkg is
   
   -- Outputs from the fpgacfg.
   type t_FROM_GPSDOCFG is record
      IICFG_EN          : std_logic;
      IICFG_CLK_SEL     : std_logic;
      IICFG_TPULSE_SEL  : std_logic_vector(1 downto 0);
      --IIRST_CNT         : std_logic;
      --IIIRQ_EN          : std_logic;
      --IIIRQ_RST         : std_logic;
      IICFG_1S_TARGET   : std_logic_vector(31 downto 0);
      IICFG_1S_TOL      : std_logic_vector(15 downto 0);
      IICFG_10S_TARGET  : std_logic_vector(31 downto 0);
      IICFG_10S_TOL     : std_logic_vector(15 downto 0);
      IICFG_100S_TARGET : std_logic_vector(31 downto 0);
      IICFG_100S_TOL    : std_logic_vector(15 downto 0);

   end record t_FROM_GPSDOCFG;
  
   -- Inputs to the fpgacfg.
   type t_TO_GPSDOCFG is record
      --HW_VER   : std_logic_vector(3 downto 0);
      --BOM_VER  : std_logic_vector(3 downto 0);
      --PWR_SRC  : std_logic;
      --tx_pct_cnt : std_logic_vector(15 downto 0);
      PPS_1S_ERROR   : std_logic_vector(31 downto 0); 
      PPS_10S_ERROR  : std_logic_vector(31 downto 0); 
      PPS_100S_ERROR : std_logic_vector(31 downto 0); 
      DAC_TUNED_VAL  : std_logic_vector(15 downto 0);
      ACCURACY       : std_logic_vector( 3 downto 0);
      STATE          : std_logic_vector( 3 downto 0);
      TPULSE_ACTIVE  : std_logic;
   end record t_TO_GPSDOCFG;
   

      
end package gpsdocfg_pkg;
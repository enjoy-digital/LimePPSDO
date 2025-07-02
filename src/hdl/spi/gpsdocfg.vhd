-- ----------------------------------------------------------------------------	
-- FILE:	fpgacfg.vhd
-- DESCRIPTION:	Serial configuration interface to control TX modules
-- DATE:	June 07, 2007
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:	
-- ----------------------------------------------------------------------------	

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_package.all;
use work.revisions.all;
use work.gpsdocfg_pkg.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity gpsdocfg is
   port (
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress    : in  std_logic_vector(9 downto 0);
      mimo_en     : in  std_logic;   -- MIMO enable, from TOP SPI (always 1)
   
      -- Serial port IOs
      sdin        : in  std_logic;  -- Data in
      sclk        : in  std_logic;  -- Data clock
      sen         : in  std_logic;  -- Enable signal (active low)
      sdout       : out std_logic;  -- Data out
   
      -- Signals coming from the pins or top level serial interface
      lreset      : in  std_logic;  -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset      : in  std_logic;  -- Memory reset signal, resets configuration memory only (use only one reset)
      
      oen         : out std_logic;  --nc
      --stateo      : out std_logic_vector(5 downto 0);
      
      to_gpsdocfg  : in  t_TO_GPSDOCFG;
      from_gpsdocfg: out t_FROM_GPSDOCFG
      
      
   );
end gpsdocfg;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of gpsdocfg is

   signal inst_reg: std_logic_vector(15 downto 0);    -- Instruction register
   signal inst_reg_en: std_logic;

   signal din_reg: std_logic_vector(15 downto 0);     -- Data in register
   signal din_reg_en: std_logic;
   
   signal dout_reg: std_logic_vector(15 downto 0);    -- Data out register
   signal dout_reg_sen, dout_reg_len: std_logic;
   
   signal mem: marray10x16 := (  0 => x"0000", 
                                 1 => x"C000",
                                 2 => x"01D4",
                                 3 => x"0003",
                                 4 => x"8000",
                                 5 => x"124F",
                                 6 => x"0022",
                                 7 => x"0000",
                                 8 => x"B71B",
                                 9 => x"0164",
                                 others=>(others=>'0')
                                 );                           -- Config memory
   signal mem_we: std_logic;
   
   signal oe: std_logic;                              -- Tri state buffers control
   signal spi_config_data_rev	: std_logic_vector(143 downto 0);
   
   --signal BOARD_ID_reg        : std_logic_vector(15 downto 0);
   --signal MAJOR_REV_reg       : std_logic_vector(15 downto 0);
   --signal COMPILE_REV_reg     : std_logic_vector(15 downto 0);
   --
   --attribute noprune          : boolean;
   --attribute noprune of BOARD_ID_reg      : signal is true;
   --attribute noprune of MAJOR_REV_reg     : signal is true;
   --attribute noprune of COMPILE_REV_reg   : signal is true;
   
   
				
   
   -- Components
   use work.mcfg_components.mcfg32wm_fsm;
   for all: mcfg32wm_fsm use entity work.mcfg32wm_fsm(mcfg32wm_fsm_arch);

begin

   ---------------------------------------------------------------------------------------------
   -- To avoid optimizations
   -- ---------------------------------------------------------------------------------------------
   --process(sclk, lreset)
   --begin
   --   if lreset = '0' then
   --      BOARD_ID_reg      <= BOARD_ID;
   --      MAJOR_REV_reg     <= std_logic_vector(to_signed(MAJOR_REV, 16));
   --      COMPILE_REV_reg   <= std_logic_vector(to_signed(COMPILE_REV, 16));
   --   elsif sclk'event and sclk = '1' then
   --      BOARD_ID_reg      <= BOARD_ID;
   --      MAJOR_REV_reg     <= std_logic_vector(to_signed(MAJOR_REV, 16));
   --      COMPILE_REV_reg   <= std_logic_vector(to_signed(COMPILE_REV, 16));
   --   end if;
   --end process;


   -- ---------------------------------------------------------------------------------------------
   -- Finite state machines
   -- ---------------------------------------------------------------------------------------------
   --fsm: mcfg32wm_fsm port map( 
   --   address => maddress, mimo_en => mimo_en, inst_reg => inst_reg, sclk => sclk, sen => sen, reset => lreset,
   --   inst_reg_en => inst_reg_en, din_reg_en => din_reg_en, dout_reg_sen => dout_reg_sen,
   --   dout_reg_len => dout_reg_len, mem_we => mem_we, oe => oe, stateo => stateo);
      
   fsm: mcfg32wm_fsm port map( 
      address => maddress, mimo_en => mimo_en, inst_reg => inst_reg, sclk => sclk, sen => sen, reset => lreset,
      inst_reg_en => inst_reg_en, din_reg_en => din_reg_en, dout_reg_sen => dout_reg_sen,
      dout_reg_len => dout_reg_len, mem_we => mem_we, oe => oe);
      
   -- ---------------------------------------------------------------------------------------------
   -- Instruction register
   -- ---------------------------------------------------------------------------------------------
   inst_reg_proc: process(sclk, lreset)
      variable i: integer;
   begin
      if lreset = '1' then
         inst_reg <= (others => '0');
      elsif sclk'event and sclk = '1' then
         if inst_reg_en = '1' then
            for i in 15 downto 1 loop
               inst_reg(i) <= inst_reg(i-1);
            end loop;
            inst_reg(0) <= sdin;
         end if;
      end if;
   end process inst_reg_proc;

   -- ---------------------------------------------------------------------------------------------
   -- Data input register
   -- ---------------------------------------------------------------------------------------------
   din_reg_proc: process(sclk, lreset)
      variable i: integer;
   begin
      if lreset = '1' then
         din_reg <= (others => '0');
      elsif sclk'event and sclk = '1' then
         if din_reg_en = '1' then
            for i in 15 downto 1 loop
               din_reg(i) <= din_reg(i-1);
            end loop;
            din_reg(0) <= sdin;
         end if;
      end if;
   end process din_reg_proc;

   -- ---------------------------------------------------------------------------------------------
   -- Data output register
   -- ---------------------------------------------------------------------------------------------
   dout_reg_proc: process(sclk, lreset)
      variable i: integer;
   begin
      if lreset = '1' then
         dout_reg <= (others => '0');
      elsif sclk'event and sclk = '0' then
         -- Shift operation
         if dout_reg_sen = '1' then
            for i in 15 downto 1 loop
               dout_reg(i) <= dout_reg(i-1);
            end loop;
            dout_reg(0) <= dout_reg(15);
         -- Load operation
         elsif dout_reg_len = '1' then
            case inst_reg(4 downto 0) is  -- mux read-only outputs
               --when "00001" => dout_reg <= (15 downto 8 => '0') to_gpsdocfg.BOM_VER & to_gpsdocfg.HW_VER;
               when "01010" => dout_reg <= to_gpsdocfg.PPS_1S_ERROR(15 downto  0);   --adr = 25
               when "01011" => dout_reg <= to_gpsdocfg.PPS_1S_ERROR(31 downto 16);   --adr = 26
               when "01100" => dout_reg <= to_gpsdocfg.PPS_10S_ERROR(15 downto 0);   --adr = 27
               when "01101" => dout_reg <= to_gpsdocfg.PPS_10S_ERROR(31 downto 16);  --adr = 28
               when "01110" => dout_reg <= to_gpsdocfg.PPS_100S_ERROR(15 downto 0);  --adr = 29
               when "01111" => dout_reg <= to_gpsdocfg.PPS_100S_ERROR(31 downto 16); --adr = 30
               when "10000" => dout_reg <= to_gpsdocfg.DAC_TUNED_VAL;
               when "10001" => dout_reg <= (15 downto 9 => '0') & to_gpsdocfg.TPULSE_ACTIVE & to_gpsdocfg.ACCURACY & to_gpsdocfg.STATE;
               when others  => dout_reg <= mem(to_integer(unsigned(inst_reg(4 downto 0))));
            end case;
         end if;
      end if;
   end process dout_reg_proc;
   
   -- Tri state buffer to connect multiple serial interfaces in parallel
   --sdout <= dout_reg(7) when oe = '1' else 'Z';

-- sdout <= dout_reg(7);
-- oen <= oe;

   sdout <= dout_reg(15) and oe;
   oen <= oe;
   -- ---------------------------------------------------------------------------------------------
   -- Configuration memory
   -- --------------------------------------------------------------------------------------------- 
   ram: process(sclk, mreset) --(remap)
   begin
      -- Defaults
      if mreset = '1' then
         --Read only registers
         mem(0)   <= "0000000000000000";  -- 00 free, Board ID
         --Interface Config
         mem(1)   <= x"C000"; --  0 free, IICFG_1S_TARGET[15: 0]
         mem(2)   <= x"01D4"; --  0 free, IICFG_1S_TARGET[31:16]
         mem(3)   <= x"0003"; --  0 free, IICFG_1S_TOL[15: 0]

         mem(4)   <= x"8000"; --  0 free, IICFG_10S_TARGET[15: 0]
         mem(5)   <= x"124F"; --  0 free, IICFG_10S_TARGET[31:16]
         mem(6)   <= x"0022"; --  0 free, IICFG_10S_TOL[15: 0]

         mem(7)   <= x"0000"; --  0 free, IICFG_100S_TARGET[15: 0]
         mem(8)   <= x"B71B"; --  0 free, IICFG_100S_TARGET[31:16]
         mem(9)   <= x"0164"; --  0 free, IICFG_100S_TOL[15: 0]

         --mem(10)  <= "0000000000000000";  --  0 free, PPS_1S_ERROR[15: 0]
         --mem(11)  <= "0000000000000000";  --  0 free, PPS_1S_ERROR[31: 16]
         --mem(12)  <= "0000000000000000";  --  0 free, PPS_10S_ERROR[15: 0]
         --mem(13)  <= "0000000000000000";  --  0 free, PPS_10S_ERROR[31: 16]
         --mem(14)  <= "0000000000000000";  --  0 free, PPS_100S_ERROR[15: 0]
         --mem(15)  <= "0000000000000000";  --  0 free, PPS_100S_ERROR[31: 16]
         --mem(31)  <= "0000000000000000";  -- 16 free, (Reserved)
         
      elsif sclk'event and sclk = '1' then
            if mem_we = '1' then
               mem(to_integer(unsigned(inst_reg(4 downto 0)))) <= din_reg(14 downto 0) & sdin;
            end if;
            
            if dout_reg_len = '0' then
--               for_loop : for i in 0 to 3 loop
--                  mem(3)(i+4) <= not mem(3)(i);
--               end loop;
            end if;
            
      end if;
   end process ram;
   
   -- ---------------------------------------------------------------------------------------------
   -- Decoding logic
   -- ---------------------------------------------------------------------------------------------
   
   --FPGA direct clocking
   from_gpsdocfg.IICFG_EN              <=  mem( 0) (0);
   from_gpsdocfg.IICFG_CLK_SEL         <=  mem( 0) (1);
   from_gpsdocfg.IICFG_TPULSE_SEL      <=  mem( 0) (3 downto 2);
   from_gpsdocfg.IICFG_RPI_SYNC_IN_DIR <=  mem( 0) (4);
   from_gpsdocfg.IICFG_1S_TARGET    <=  mem( 2) & mem( 1); 
   from_gpsdocfg.IICFG_1S_TOL       <=  mem( 3); 
   from_gpsdocfg.IICFG_10S_TARGET   <=  mem( 5) & mem( 4); 
   from_gpsdocfg.IICFG_10S_TOL      <=  mem( 6); 
   from_gpsdocfg.IICFG_100S_TARGET  <=  mem( 8) & mem( 7); 
   from_gpsdocfg.IICFG_100S_TOL     <=  mem( 9); 


end arch;

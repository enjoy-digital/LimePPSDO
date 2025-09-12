-- ----------------------------------------------------------------------------	
-- FILE        :	gpsdocfg.vhd
-- DESCRIPTION :	Serial configuration interface to control GPSDO
-- DATE        :	June 07, 2007
-- AUTHOR(s)   :	Lime Microsystems
-- REVISIONS   :
-- ----------------------------------------------------------------------------	

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_package.all;
use work.revisions.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity gpsdocfg is
   port (
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress                  : in  std_logic_vector(9 downto 0);
      mimo_en                   : in  std_logic;   -- MIMO enable, from TOP SPI (always 1)

      -- Serial port IOs
      sdin                      : in  std_logic;  -- Data in
      sclk                      : in  std_logic;  -- Data clock
      sen                       : in  std_logic;  -- Enable signal (active low)
      sdout                     : out std_logic;  -- Data out

      -- Signals coming from the pins or top level serial interface
      lreset                    : in  std_logic;  -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset                    : in  std_logic;  -- Memory reset signal, resets configuration memory only (use only one reset)

      oen                       : out std_logic;  --nc

      -- Inputs (formerly in t_TO_GPSDOCFG)
      PPS_1S_ERROR_in           : in  std_logic_vector(31 downto 0);
      PPS_10S_ERROR_in          : in  std_logic_vector(31 downto 0);
      PPS_100S_ERROR_in         : in  std_logic_vector(31 downto 0);
      DAC_TUNED_VAL_in          : in  std_logic_vector(15 downto 0);
      ACCURACY_in               : in  std_logic_vector(3 downto 0);
      STATE_in                  : in  std_logic_vector(3 downto 0);
      TPULSE_ACTIVE_in          : in  std_logic;

      -- Outputs (formerly in t_FROM_GPSDOCFG)
      IICFG_EN_out              : out std_logic;
      IICFG_CLK_SEL_out         : out std_logic;
      IICFG_TPULSE_SEL_out      : out std_logic_vector(1 downto 0);
      IICFG_RPI_SYNC_IN_DIR_out : out std_logic;
      IICFG_1S_TARGET_out       : out std_logic_vector(31 downto 0);
      IICFG_1S_TOL_out          : out std_logic_vector(15 downto 0);
      IICFG_10S_TARGET_out      : out std_logic_vector(31 downto 0);
      IICFG_10S_TOL_out         : out std_logic_vector(15 downto 0);
      IICFG_100S_TARGET_out     : out std_logic_vector(31 downto 0);
      IICFG_100S_TOL_out        : out std_logic_vector(15 downto 0)
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
   signal spi_config_data_rev : std_logic_vector(143 downto 0);


   component mcfg32wm_fsm
      port(
         address      : in std_logic_vector(9 downto 0);  -- Hardware address
         mimo_en      : in std_logic;
         inst_reg     : in std_logic_vector(15 downto 0); -- Instruction register (read only here)
         sclk         : in std_logic;                     -- Serial clock
         sen          : in std_logic;                     -- Serial enable
         reset        : in std_logic;                     -- Reset
         inst_reg_en  : out std_logic;                    -- Instruction register enable
         din_reg_en   : out std_logic;                    -- Data in register enable
         dout_reg_sen : out std_logic;                    -- Data out register shift enable
         dout_reg_len : out std_logic;                    -- Data out register load enable
         mem_we       : out std_logic;                    -- Memory write enable
         oe           : out std_logic                     -- Output enable
      );
   end component;

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
               when "01010" => dout_reg <= PPS_1S_ERROR_in(15 downto  0);   --adr = 25
               when "01011" => dout_reg <= PPS_1S_ERROR_in(31 downto 16);   --adr = 26
               when "01100" => dout_reg <= PPS_10S_ERROR_in(15 downto 0);   --adr = 27
               when "01101" => dout_reg <= PPS_10S_ERROR_in(31 downto 16);  --adr = 28
               when "01110" => dout_reg <= PPS_100S_ERROR_in(15 downto 0);  --adr = 29
               when "01111" => dout_reg <= PPS_100S_ERROR_in(31 downto 16); --adr = 30
               when "10000" => dout_reg <= DAC_TUNED_VAL_in;
               when "10001" => dout_reg <= (15 downto 9 => '0') & TPULSE_ACTIVE_in & ACCURACY_in & STATE_in;
               when others  => dout_reg <= mem(to_integer(unsigned(inst_reg(4 downto 0))));
            end case;
         end if;
      end if;
   end process dout_reg_proc;

   -- Tri state buffer to connect multiple serial interfaces in parallel
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
         mem(1)   <= x"C000"; --  0 free, IICFG_1S_TARGET[15: 0]
         mem(2)   <= x"01D4"; --  0 free, IICFG_1S_TARGET[31:16]
         mem(3)   <= x"0003"; --  0 free, IICFG_1S_TOL[15: 0]
         mem(4)   <= x"8000"; --  0 free, IICFG_10S_TARGET[15: 0]
         mem(5)   <= x"124F"; --  0 free, IICFG_10S_TARGET[31:16]
         mem(6)   <= x"0022"; --  0 free, IICFG_10S_TOL[15: 0]
         mem(7)   <= x"0000"; --  0 free, IICFG_100S_TARGET[15: 0]
         mem(8)   <= x"B71B"; --  0 free, IICFG_100S_TARGET[31:16]
         mem(9)   <= x"0164"; --  0 free, IICFG_100S_TOL[15: 0]

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
   IICFG_EN_out              <= mem(0)(0);
   IICFG_CLK_SEL_out         <= mem(0)(1);
   IICFG_TPULSE_SEL_out      <= mem(0)(3 downto 2);
   IICFG_RPI_SYNC_IN_DIR_out <= mem(0)(4);
   IICFG_1S_TARGET_out       <= mem(2) & mem(1);
   IICFG_1S_TOL_out          <= mem(3);
   IICFG_10S_TARGET_out      <= mem(5) & mem(4);
   IICFG_10S_TOL_out         <= mem(6);
   IICFG_100S_TARGET_out     <= mem(8) & mem(7);
   IICFG_100S_TOL_out        <= mem(9);

end arch;

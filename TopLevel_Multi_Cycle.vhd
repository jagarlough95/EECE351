----------------------------------------------------------------------------------
-- Company: 		 Binghamton University
-- Engineer(s):    Carl Betcher
-- 
-- Create Date:    11/18/2017 
-- Design Name: 	 ARM Processor Top Level
-- Module Name:    TopLevel - Behavioral 
-- Project Name:   ARM Multi-Cycle Processor
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revisions: 
--    
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use ieee.numeric_std.all;

entity TopLevel is
	Generic ( DELAY : integer := 640000 -- DELAY = 20 mS / clk_period
				  );								-- for Simulation, DELAY = 3
    Port ( Clk : in STD_LOGIC;
			  DIR_RIGHT : in STD_LOGIC; 	
	        DIR_LEFT : in STD_LOGIC;  
	        DIR_DOWN : in STD_LOGIC;  
	        DIR_UP : in STD_LOGIC;    
			  SWITCH : in  STD_LOGIC_VECTOR (7 downto 0);
           LED : out  STD_LOGIC_VECTOR (7 downto 0);
			  Seg7_SEG : out STD_LOGIC_VECTOR (6 downto 0); 
			  Seg7_DP  : out STD_LOGIC; 
			  Seg7_AN  : out STD_LOGIC_VECTOR (4 downto 0)
			  );
end TopLevel;

architecture Behavioral of TopLevel is

	COMPONENT debounce
	Generic ( DELAY : integer := 640000 -- DELAY = 20 mS / clk_period
				  );
	PORT(
		clk : IN std_logic;
		sig_in : IN std_logic;          
		sig_out : OUT std_logic
		);
	END COMPONENT;

	COMPONENT HEXon7segDisp
	PORT(
		hex_data_in0 : in  STD_LOGIC_VECTOR (3 downto 0);
      hex_data_in1 : in  STD_LOGIC_VECTOR (3 downto 0);
      hex_data_in2 : in  STD_LOGIC_VECTOR (3 downto 0);
      hex_data_in3 : in  STD_LOGIC_VECTOR (3 downto 0);
		dp_in : IN std_logic_vector(2 downto 0);
		clk : IN std_logic;          
		seg_out : OUT std_logic_vector(6 downto 0);
      an_out : out  STD_LOGIC_VECTOR (3 downto 0);
		dp_out : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT ARM
	GENERIC ( addr_size : positive := 9 );
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		en_ARM : IN std_logic;
		SWITCH : IN std_logic_vector(7 downto 0);          
		PCOut : OUT std_logic_vector(7 downto 0);
		InstrOut : OUT std_logic_vector(27 downto 20);
		ReadDataOut : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

-- Needed for Papilio One with LogicStart MegaWing:
--	-- define function to reverse the ordering of bits of a std_logic_vector signal
--	function reverse (x : std_logic_vector) return std_logic_vector is
--		variable y : std_logic_vector (x'range);
--	begin
--		for i in x'range loop
--			y(i) := x(x'left - (i - x'right));
--		end loop;
--		return y;
--	end;

	-- Constant defining memory address range
	constant addr_width : positive := 9;
	
	-- Signal for reversed SWITCH ordering (Papilio One)
--	signal SWITCHrev : std_logic_vector(7 downto 0);
	
	-- Signal for Hex Display Controller input
	signal HexDisp : std_logic_vector(15 downto 0) := x"0000";
	
	-- Signals for displaying Funct on LEDs, and PC and Memory RD on 7-seg display
	signal PC : std_logic_vector(7 downto 0);
	signal IR_Funct : std_logic_vector(27 downto 20);
	signal MEM_RD : std_logic_vector(7 downto 0);

	-- Signals needed to implement reset, run, stop, stop at breakpoint, and single-step functions
	signal stop_reset, stop_reset_sync, reset, run, run_sync, run_ARM, en_ARM, stop, stop_at_bp, 
				                stop_at_bp_sync, bp_stop, bp_mode, step, step_sync : std_logic := '0';
	
begin

	-- Momentary switches used to control the ARM processor
	-- For the Papilio One FPGA Board, invert the button inputs
	stop_reset <= DIR_LEFT; -- not DIR_LEFT;
	run <= DIR_UP;				-- not DIR_UP;
	stop_at_bp <= DIR_DOWN; -- not DIR_DOWN;
	step <= DIR_RIGHT;		-- not DIR_RIGHT;
	
	-- For the Papilio One FPGA board, reverse the order of the switches so that 
	-- SWITCH(0) is on the right end instead of the left end
--	SWITCHrev <= reverse(SWITCH);
	
	-- Debounce the "run" signal and synchronize it to the clock
	-- and generate the "run_sync" signal for exactly one clock cycle
	debounce_run: debounce 
	GENERIC MAP(DELAY => DELAY)
	PORT MAP(
		clk => Clk ,
		sig_in => run,
		sig_out => run_sync 
	);

	-- Debounce the "stop_reset" signal and synchronize it to the clock
	-- and generate the "stop_reset_sync" signal for exactly one clock cycle
	debounce_reset: debounce 
	GENERIC MAP(DELAY => DELAY)
	PORT MAP(
		clk => Clk ,
		sig_in => stop_reset,
		sig_out => stop_reset_sync 
	);

	-- Debounce the "step" signal and synchronize it to the clock
	-- and generate the "step_sync" signal for exactly one clock cycle
	debounce_step: debounce 
	GENERIC MAP(DELAY => DELAY)
	PORT MAP(
		clk => Clk ,
		sig_in => step,
		sig_out => step_sync 
	);

	-- Debounce the "stop_at_bp" signal and synchronize it to the clock
	-- and generate the "stop_at_bp_sync" signal for exactly one clock cycle
	debounce_bp: debounce 
	GENERIC MAP(DELAY => DELAY)
	PORT MAP(
		clk => Clk ,
		sig_in => stop_at_bp,
		sig_out => stop_at_bp_sync 
	);

	-- One push button is used to generate both a "stop" signal and a "reset" signal
	--
	-- Generate "stop" signal
	-- Generate the "stop" signal when the ARM processor is running (run_ARM = '1')
	-- and the Stop/Reset button is pressed (stop_reset_sync = '1')
	-- Sync this signal with the clock
	process(Clk)
	begin
		if rising_edge(Clk) then
			if run_ARM = '1' and stop_reset_sync = '1' then
				stop <= '1';
			else
				stop <= '0';
			end if;	
		end if;
	end process;
	--
	-- Generate "reset" signal
	-- Generate the "reset" signal when the ARM processor is not running
	-- (run_ARM = '0') and the Stop/Reset button is pressed (stop_reset_sync = '1')
	-- Sync this signal with the clock
	process(Clk)
	begin
		if rising_edge(Clk) then
			if run_ARM = '0' and stop_reset_sync = '1' then
				reset <= '1';
			else
				reset <= '0';
			end if;	
		end if;
	end process;

	-- The "run_ARM" signal is '1' when we want the ARM processor to be running
	-- When "run_sync" or "stop_at_bp_sync" becomes a '1', "run_ARM" is set to '1' 
	-- and is held at a '1' until a "reset" signal or a "stop" signal or
	-- a "bp_stop" is received
	process(Clk)
	begin
		if rising_edge(Clk) then
			if reset = '1' or stop = '1' or bp_stop = '1' then
				run_ARM <= '0';
			elsif run_sync = '1' or stop_at_bp_sync = '1' then
				run_ARM <= '1';
			else
				run_ARM <= run_ARM;
			end if;	
		end if;
	end process;
	
	-- Breakpoint mode
	-- "bp_mode" is set to '1' when Stop at Breakpoint button is pressed
	-- (stop_at_bp_sync = '1')
	-- and is held at a '1' until a "reset" signal or a "stop" signal or
	-- a "bp_stop" is received
	process(Clk)
	begin
		if rising_edge(Clk) then
			if reset = '1' or stop = '1' or bp_stop = '1' then
				bp_mode <= '0';
			elsif stop_at_bp_sync = '1' then
				bp_mode <= '1';
			else
				bp_mode <= bp_mode;
			end if;	
		end if;
	end process;

	-- Stop at Breakpoint
	-- "bp_stop" is set to '1' when the value set by the switches matches the PC
	-- It is cleared with reset, or immediately after it is set (run_ARM AND bp_stop)	
	process(Clk)
	begin
		if rising_edge(Clk) then
			if reset = '1' or (run_ARM = '1' AND bp_stop = '1') then
				bp_stop <= '0';
			elsif bp_mode = '1' AND PC = SWITCH then
				bp_stop <= '1';
			else
				bp_stop <= bp_stop;
			end if;	
		end if;
	end process;	
	
	-- The en_ARM signal enables the ARM Processor to change its architecture state
	-- When en_ARM = '1', the decoder FSM is allowed to leave its decode state and
	--    complete the current instruction
	-- This signal is synchronized to the system clock
	-- When run_ARM is '1', en_ARM is '1'
	-- If run_ARM is '0' and step_sync is '1' for one clock cycle, 
	--    en_ARM will be '1' for one clock cycle, allowing the controller to 
	--    complete the execution of the current instruction.
	process(Clk)
	begin
		if rising_edge(Clk) then
			if run_ARM = '1' or step_sync = '1' then
				en_ARM <= '1';
			else
				en_ARM <= '0';
			end if;	
		end if;
	end process;
		
	-- Instantiate Hex to 7-segment controller module
	HEXon7segDisp1: HEXon7segDisp PORT MAP(
		hex_data_in0 => HexDisp(15 downto 12), -- Reverse this order
		hex_data_in1 => HexDisp(11 downto 8),  -- for the Papilio One
		hex_data_in2 => HexDisp(7 downto 4),   --
		hex_data_in3 => HexDisp(3 downto 0),   --
		dp_in => "000",  -- no decimal point
		seg_out => Seg7_SEG,
		an_out => Seg7_AN(3 downto 0),
		dp_out => Seg7_DP,
		clk => Clk
	);
	
	Seg7_AN(4) <= '1'; -- Anode 4 is always "off"
		
	-- Instantiate the ARM processor
	i_ARM: ARM 
	GENERIC MAP ( addr_width )
	PORT MAP(
		clk => Clk,
		reset => reset,
		en_ARM => en_ARM,
		SWITCH => SWITCH,
		PCOut => PC,
		InstrOut => IR_Funct,
		ReadDataOut => MEM_RD
	);

	-- When program is stopped (en_ARM = '0'), the program counter (PC) is  
	-- displayed on the left two characters of the 7-segment display
	-- and the data memory address, A(7 downto 0) is SWITCH and the
	-- data in addressed memory location appearing on ReadData(7 downto 0), 
	-- is displayed on the right two characters of the 7-segment display 
	HexDisp <= PC & MEM_RD when en_ARM = '0' else x"0000";
	
	-- Instr (27 downto 20) displayed on LEDs
--	LED(7 downto 0) <= Reverse(IR_Funct);	-- use with Papilio One
	LED(7 downto 0) <= IR_Funct;	
	
end Behavioral;

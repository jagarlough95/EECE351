----------------------------------------------------------------------------------
-- Company: 		 Binghamton University
-- Engineer: 		 Carl Betcher
-- 
-- Create Date:    14:25:00 09/24/2017 
-- Design Name: 
-- Module Name:    ControlLogicFSM - Behavioral 
-- Project Name: 	 Lab4 - ALU Module and Test Bench
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ControlLogicFSM is
    Port ( Clk : in  STD_LOGIC;
           Left : in  STD_LOGIC;
           Right : in  STD_LOGIC;
           Up : in  STD_LOGIC;
           Down : in  STD_LOGIC;
           load_A_Reg : out  STD_LOGIC;
           load_B_Reg : out  STD_LOGIC;
           Load_Ctrl_Reg : out  STD_LOGIC;
           MUX_Select : out  STD_LOGIC_VECTOR(1 downto 0));
end ControlLogicFSM;

architecture Behavioral of ControlLogicFSM is
	
	type state_type is (Start, RegA, RegB, RegC, Ld_A, Ld_B, Ld_C, Result, Flags);
	signal state : state_type := Start;
	signal next_state : state_type;

begin

	state_reg: process(Clk)
	begin
		if rising_edge(Clk) then
			state <= next_state;
		end if;
	end process;
	
	combo_logic: process (state, Left, Right, Up, Down)
	begin
		-- default next_state and outputs
		next_state <= state;
		load_A_Reg <= '0';
		load_B_Reg <= '0';
		load_Ctrl_Reg <= '0';
		MUX_Select <= "00";
		
		case state is
			when Start =>
				if Left = '1' then
					next_state <= RegA;
				end if;
				
			when RegA =>
				if Down = '1' then
					next_state <= Start;
				elsif Left = '1' then
					next_state <= Ld_A;
				elsif Up = '1' then	
					next_state <= RegB;
				end if;
			
			when RegB =>
				if Down = '1' then
					next_state <= Start;
				elsif Up = '1' then
					next_state <= Ld_B;
				elsif Right = '1' then	
					next_state <= RegC;
				end if;
			
			when RegC =>
				MUX_Select <= "01";
				if Down = '1' then
					next_state <= Start;
				elsif Right = '1' then
					next_state <= Ld_C;
				elsif Left = '1' then	
					next_state <= Result;
				end if;
			
			when Ld_A =>
				load_A_Reg <= '1';
				next_state <= RegA;
				
			when Ld_B =>
				load_B_Reg <= '1';
				next_state <= RegB;
				
			when Ld_C =>
				MUX_Select <= "01";
				load_Ctrl_Reg <= '1';
				next_state <= RegC;
				
			when Result =>
				MUX_Select <= "10";
				if Down = '1' then
					next_state <= Start;
				elsif Right = '1' then
					next_state <= Flags;
				end if;	
				
			when Flags =>
				MUX_Select <= "11";
				if Down = '1' then
					next_state <= Start;
				elsif Left = '1' then
					next_state <= Result;
				end if;
				
		end case;
	end process;

end Behavioral;


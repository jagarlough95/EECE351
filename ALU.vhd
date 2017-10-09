----------------------------------------------------------------------------------
-- Company: Binghamton University
-- Engineers: Randy Miller and Jeremy Garlough
-- 
-- Create Date:    16:01:21 10/02/2017 
-- Design Name: 
-- Module Name:    ALU - Behavioral 
-- Project Name: 
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
use IEEE.NUMERIC_STD.ALL;

entity ALU is
		Generic (data_size : positive := 32);
    Port ( A : in  STD_LOGIC_VECTOR (data_size-1 downto 0);
           B : in  STD_LOGIC_VECTOR (data_size-1 downto 0);
           ALUControl : in  STD_LOGIC_VECTOR (1 downto 0);
           Result : out  STD_LOGIC_VECTOR (data_size-1 downto 0);
           ALUFlags : out  STD_LOGIC_VECTOR (3 downto 0));
end ALU;

architecture Behavioral of ALU is

signal A_sig, B_sig : signed (data_size-1 downto 0);
signal R_sig : signed (data_size-1 downto 0);
signal N, Z, C, V : std_logic;
signal sum : signed (data_size downto 0);

begin
A_sig <= signed(A);
B_sig <= signed(B);

	process(A, B, ALUControl)
	begin
		case ALUControl is
			when "00" => Sum <= resize(A_sig,data_size+1) + resize(B_sig,data_size+1);
								R_sig <= Sum(data_size-1 downto 0);
			when "01" => Sum <= resize(A_sig,data_size+1) - resize(B_sig,data_size+1);
							R_sig <= Sum(data_size-1 downto 0);
			when "10" => R_sig <= (A_sig and B_sig);
			when "11" => R_sig <= (A_sig or B_sig);
			when others => NULL;
		end case;
		
	end process;
	
	--process (Result, ALUFlags)
	--begin
		--case Result is
		--when (Result < '0') => ALUFlags(3) <= '1';
		--end case;
	--end process;
end Behavioral;




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
signal sub : signed (data_size downto 0);

begin
A_sig <= signed(A);
B_sig <= signed(B);

	process(A, B, ALUControl)
	begin
		case ALUControl is
			when "00" => sum <= resize(A_sig,data_size+1) + resize(B_sig,data_size+1);
								R_sig <= sum(data_size-1 downto 0);
			when "01" => sub <= resize(A_sig,data_size+1) - resize(B_sig,data_size+1);
							R_sig <= sub(data_size-1 downto 0);
			when "10" => R_sig <= (A_sig and B_sig);
			when "11" => R_sig <= (A_sig or B_sig);
			when others => NULL;
		end case;
		
	end process;
	
		-- negative flag
		-- logic is right but the syntax is wrong
		if(R_sig(data_size-1))= '1' then N = '1';
		else N = '0';
		
		-- zero flag
		
		-- carry flag
		
		-- overflow flag
		
end Behavioral;




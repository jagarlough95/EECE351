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

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
		Generic (data_size : positive := 32);
    Port ( A : in  STD_LOGIC_VECTOR (data_size-1 downto 0);
           B : in  STD_LOGIC_VECTOR (data_size-1 downto 0);
           ALUControl : in  STD_LOGIC_VECTOR (1 downto 0);
           Result : out  STD_LOGIC_VECTOR (data_size-1 downto 0);
           ALUFlags : out  STD_LOGIC_VECTOR (3 downto 0));
end ALU;

architecture Behavioral of ALU is

signal (N, Z, C, V) : out  STD_LOGIC;

begin
	process(A, B, ALUControl)
	begin
		case ALUControl is
			when "00" => Result <= A+B;
			when "01" => Result <= A-B;
			when "10" => Result <= A and B;
			when "11" => Result <= A or B;
		end case;
		
		if Result = "10" && "11" then ALUFlags(3) <= '1';
		end if;
		
	end process;
end Behavioral;


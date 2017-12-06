----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:23:17 11/29/2017 
-- Design Name: 
-- Module Name:    Memory - Behavioral 
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
library std;
use std.texto.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Memory is

	Generic (data_width : positive := 32;
				addr_wdith : positive := 9);
				
	Port (clk : in STD_LOGIC;
			WE3 : in STD_LOGIC;
			EN1 : in STD_LOGIC;
			EN2 : in STD_LOGIC;
			A1 : in STD_LOGIC_VECTOR (addr_width-1 downto 0);
			A2 : in STD_LOGIC_VECTOR (addr_width-1 downto 0);
			WD : in STD_LOGIC_VECTOR (data_width-1 downto 0);
			RD1 : in STD_LOGIC_VECTOR (data_width-1 downto 0);
			RD2 : in STD_LOGIC_VECTOR (data_width-1 downto 0));
			
end Memory;

architecture Behavioral of Memory is

	-- Delcare type for the memory
	type MEM_type is array (0 to 2**addr_width-1)
				of bit_vector (data_width-1 downto 0);
				
	-- Declare function for reading a file and returning
	--	a data array of the initial memory contents with the program
	impure function init_MEM (file_name : in string)
				return MEM_type is
			FILE MEM_file : text is in file_name;
			variable MEM_word : line;
			variable MEM : MEM_type;
			
begin
	-- Loop for the reading each line in the file 
	for I in MEM_type'range loop
		readline (MEM_file, MEM_word);
		read (MEM_word, MEM(I));
	end loop;
	return MEM;
end function;

-- declare a signal for the memory array used from the file
signal MEM : MEM_type := init_MEM("program.txt");

begin
	
	-- Memory Port 1
	process (clk)
	begin
		if rising_edge(clk) then
			if EN1 = '1' then
				RD1 <= to_stdlogicvector(MEM(to_integer(unsigned(A1)))); -- Sychronous Read
			end if;
		end if;
	end process;
	
	-- Memory Port 2
	process (clk)
	begin
		if rising_edge(clk) then
			if WE2 = '1' then 
				MEM(to_integer(unsigned(A2))) <= to_bitvector(WD); -- Synchronous Write
			elsif EN2 = '1' then
				RD2 <= to_stdlogicvector(MEM(to_integer(unsigned(A2)))); -- Synchronous Read
			end if;
		end if;
	end process;
	
end Behavioral;


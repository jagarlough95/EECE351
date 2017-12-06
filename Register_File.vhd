-- Register File for ARM Processor
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
 
entity Register_File is
generic (word_size : natural := 32;
        address_size : natural := 4 );
port (clk        : in std_logic;
	WE3       : in std_logic;
	A1     : in std_logic_vector(address_size-1 downto 0);
	A2     : in std_logic_vector(address_size-1 downto 0);
	A3     : in std_logic_vector(address_size-1 downto 0);
	WD3		: in std_logic_vector(word_size-1 downto 0);
	R15		: in std_logic_vector(word_size-1 downto 0);
	RD1 	: out std_logic_vector(word_size-1 downto 0);
	RD2     : out std_logic_vector(word_size-1 downto 0)
	);
end Register_File;

architecture Behaviorial of Register_File is
	type Register_File_type is array (0 to 2**address_size-1) of
								std_logic_vector (word_size-1 downto 0);
	signal Register_File : Register_File_type := (others => '0');
begin 
 
-- write to Register_File
 process (clk)
	begin
		if rising_edge(clk) then
		if (WE3 = '1') then
		Register_File(to_integer(unsigned(WD3))) <= A3;
		end if;
	end if;
end process; 
 
-- read from Register_File
 RD1 <= Register_File(to_integer(unsigned(A1)));
 RD2 <= Register_File(to_integer(unsigned(A2))); 
 
 -- when a read address of 15 is placed on A1 and/or A2
process (address_size)
begin
	if address_size = "15" then R15 <= (RD1 and RD2);
	end if;
end process;
 
end Behaviorial; 
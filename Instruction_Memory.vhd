----------------------------------------------------------------------------------
-- Company: 		 Binghamton University
-- Engineer: 		 Carl Betcher
-- 
-- Create Date:    10:14:31 11/08/2016 
-- Design Name: 
-- Module Name:    Instruction_Memory - Behavioral 
-- Project Name:   ARM Single-Cycle Processor
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
use std.textio.all;

entity Instruction_Memory is
   Generic ( data_width : positive := 32; addr_width : positive := 9);
--   Port( clk : std_logic;                       -- need if synchronous output
--			A  : in  STD_LOGIC_VECTOR (addr_width-1 downto 0);
   Port( A  : in  STD_LOGIC_VECTOR (addr_width-1 downto 0);
         RD : out  STD_LOGIC_VECTOR (data_width-1 downto 0));
end Instruction_Memory;

architecture Behavioral of Instruction_Memory is

   -- Declare type for instruction ROM
	type instr_ROM_type is array(0 to 2**addr_width-1) 
	     	   of bit_vector(data_width-1 downto 0); 
   
   -- Declare function for reading a file and returning 
	-- a data array of the instruction memory contents
	impure function init_ROM (file_name : in string) 
				return instr_ROM_type is  
                                                 
      FILE rom_file        : text is in file_name;                       
      variable instruction : line;                                 
      variable instr_ROM   : instr_ROM_type;   
                                   
   begin 
      -- Loop for reading each line in the file
		for I in instr_ROM_type'range loop                                  
          readline (rom_file, instruction);                             
          read (instruction, instr_ROM(I));                                  
      end loop;  	
      return instr_ROM;                                            
   end function;                                                

   -- Declare a constant for the instruction array read from the file
	constant Instr_MEM : instr_ROM_type := init_ROM("program.txt");

begin

	process (A)    -- Asynchronous Output                                            
	begin                                                        
		RD <= to_stdlogicvector(Instr_MEM(to_integer(unsigned(A))));      
	end process; 

--	process (clk)   -- Synchronous Output                                             
--	begin 
--		if rising_edge(clk) then
--			RD <= to_stdlogicvector(Instr_MEM(to_integer(unsigned(A))));    
--		end if;		
--	end process; 

end Behavioral;

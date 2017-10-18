--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:22:07 10/15/2017
-- Design Name:   
-- Module Name:   C:/Users/rmill/OneDrive/BU/EECE 351/EECE351-Lab4/Test_ALU.vhd
-- Project Name:  Lab4
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ALU
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY Test_ALU IS
END Test_ALU;
 
ARCHITECTURE behavior OF Test_ALU IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ALU
    PORT(
         A : IN  std_logic_vector(7 downto 0);
         B : IN  std_logic_vector(7 downto 0);
         ALUControl : IN  std_logic_vector(1 downto 0);
         Result : OUT  std_logic_vector(7 downto 0);
         ALUFlags : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal A : std_logic_vector(7 downto 0) := (others => '0');
   signal B : std_logic_vector(7 downto 0) := (others => '0');
   signal ALUControl : std_logic_vector(1 downto 0) := (others => '0');

 	--Outputs
   signal Result : std_logic_vector(7 downto 0);
   signal ALUFlags : std_logic_vector(3 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   --constant <clock>_period : time := 10 ns;
	
	-- test inputs and outputs of the ALU
	type test_vector is record
			A : std_logic_vector(7 downto 0);
         B : std_logic_vector(7 downto 0);
         ALUControl : std_logic_vector(1 downto 0);
         Result : std_logic_vector(7 downto 0);
         ALUFlags : std_logic_vector(3 downto 0);
	end record test_vector;
	
	type test_data_array is array (natural range <>) of test_vector;
	
 constant test_data : test_data_array := 
		(("00000001", "00000001", "00", "00000010", "0000"),
		("10000000", "10000000", "00", "00000000", "1101"),
		("01101010", "01101010", "00", "11010100", "1010"),
		("10101010", "10101010", "00", "01010100", "1100"),
		("01010101", "01010101", "00", "10101010", "1010"),
		("00000001", "00000010", "01", "11111111", "0010"),
		("11111111", "10101010", "10", "10101010", "0010"),
		("10101010", "11111111", "10", "10101010", "0010"),
		("00000000", "10101010", "11", "11111111", "0010"),
		("10101010", "00000000", "11", "11111111", "0010"));
		
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ALU PORT MAP (
          A => A,
          B => B,
          ALUControl => ALUControl,
          Result => Result,
          ALUFlags => ALUFlags
        );

   -- Clock process definitions
--   <clock>_process :process
--   begin
--		<clock> <= '0';
--		wait for <clock>_period/2;
--		<clock> <= '1';
--		wait for <clock>_period/2;
--   end process;
 

   -- Stimulus process
  stim_proc: process
   begin		
      -- hold reset state for 100 ns.
     wait for 100 ns;	

--      wait for <clock>_period*10;

      -- insert stimulus here
			report "ALU simulation has begun";
			-- apply the test vector to the ALU
			for i in test_data'range loop
				A <= test_data(i).A;
				B <= test_data(i).B;
				ALUControl <= test_data(i).ALUControl;
				wait for 100 ns;
				assert Result = test_data(i).result report "Error in Result";
				assert ALUFlags = test_data(i).ALUFlags report "Error in Flags";
			end loop;
			report "ALU simulation has finished"; 			
		wait;
   end process;

END;

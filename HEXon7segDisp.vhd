----------------------------------------------------------------------------------
-- Company: 		 Binghamton University
-- Engineer: 		 Randy Miller, Jeremy Garlough
-- 
-- Module Name:    HEXon7segDisp - Behavioral 
-- Project Name:   Lab3 - 7-Segment Display Controller
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity HEXon7segDisp is
    Port ( hex_data_in0 : in  STD_LOGIC_VECTOR (3 downto 0);
           hex_data_in1 : in  STD_LOGIC_VECTOR (3 downto 0);
           hex_data_in2 : in  STD_LOGIC_VECTOR (3 downto 0);
           hex_data_in3 : in  STD_LOGIC_VECTOR (3 downto 0);
           dp_in : in  STD_LOGIC_VECTOR (2 downto 0);
           seg_out : out  STD_LOGIC_VECTOR (6 downto 0);
           an_out : out  STD_LOGIC_VECTOR (3 downto 0);
           dp_out : out  STD_LOGIC;
           clk : in  STD_LOGIC);
end HEXon7segDisp;

architecture Behavioral of HEXon7segDisp is

	signal Counter : unsigned (10 downto 0) := (others => '0') ;
		alias MuxSel1 : unsigned (1 downto 0) is Counter(10 downto 9);
		alias MuxSel2 : unsigned (3 downto 0) is Counter(10 downto 7);

	signal HexSel : std_logic_vector (3 downto 0):= (others => '0') ;

begin

	-- Create an upcounter "cntr"
	process (clk)
	begin
		if rising_edge(clk) then
			counter <= counter + "1";
		end if;
	end process;
	
	-- Create a mux which selects one of the hex data inputs according 
	-- to the value of MuxSel1
	-- Code using process with case statement:
	process (MuxSel1, HexSel, hex_data_in0, hex_data_in1, hex_data_in2, hex_data_in3)
	begin 
		case MuxSel1 is
			-- map hex_data to hex_select 	
			when "00" => HexSel <= hex_data_in0;
			when "01" => HexSel <= hex_data_in1;
			when "10" => HexSel <= hex_data_in2;
			when "11" => HexSel <= hex_data_in3;
			when others => report "Error: MuxSel signal not correct";
		end case;
	end process; 
	
	
	-- Create a mux that will enable one of the anodes. 
	-- Enable the anode of the digit to be displayed as selected by MuxSel2.
	-- A zero enables the respective anode.
	
	
	
	process (MuxSel2)
	begin
		case MuxSel2 is
			when "0001" | "0010" => an_out <= "1110" ; -- an_out gets 0
			when "0101" | "0110" => an_out <= "1101" ; -- an_out gets 1
			when "1000" | "1010" => an_out <= "1011" ; -- an_out gets 2
			when "1101" | "1110" => an_out <= "0111" ; -- an_out gets 3
			when others => an_out <= "1111";
		end case;
	end process;
	
	-- Create combinational logic to convert a four-bit hex character 
	-- value to a 7-segment vector, seg_out.  
	-- Map HEX character of selected data (in the HexSel register) 
	-- to value of seg_out using the following segment encoding:
	--      A
	--     ---  
	--  F |   | B
	--     ---  <- G
	--  E |   | C
	--     ---
	--      D
	-- seg_out has the order "GFEDCBA"	
	-- a zero lights the segment
	-- e.g. "1111001" lights segments B and C which is a "1"
	-- seg_out : out  STD_LOGIC_VECTOR (6 downto 0);
	process (HexSel)
	begin
		case HexSel is				-- GFEDCBA
			when "0000" => seg_out <= "1000000"; -- "Hex: 0"
			when "0001" => seg_out <= "1111001"; -- "Hex: 1"
			when "0010" => seg_out <= "0110101"; -- "Hex: 2"
			when "0011" => seg_out <= "0110000"; -- "Hex: 3"
			when "0100" => seg_out <= "0011001"; -- "Hex: 4"
			when "0101" => seg_out <= "0110010"; -- "Hex: 5"
			when "0110" => seg_out <= "0000010"; -- "Hex: 6"
			when "0111" => seg_out <= "1111000"; -- "Hex: 7"
			when "1000" => seg_out <= "0000000"; -- "Hex: 8"
			when "1001" => seg_out <= "0010000"; -- "Hex: 9"
			when "1010" => seg_out <= "0001000"; -- "Hex: A"
			when "1011" => seg_out <= "0000011"; -- "Hex: b"
			when "1100" => seg_out <= "1000110"; -- "Hex: C"
			when "1101" => seg_out <= "0100001"; -- "Hex: d"
			when "1110" => seg_out <= "0000110"; -- "Hex: E"
			when "1111" => seg_out <= "0001110"; -- "Hex: F"
			when others => seg_out <= "1000000";
		end case;
	end process;
	

	-- Create combinational logic to enable the selected decimal point. 
	-- Enable the dp_out (enabled is '0') if selected by dp_in
	-- and only when its respective anode is enabled according to the
	-- value of MuxSel2
	-- dp_in    display
	-- "000"    8 8 8 8
	-- "001"    8.8 8 8	
	-- "010"    8 8.8 8	
	-- "011"    8 8 8.8	
	-- "100"    8 8 8 8.	
	
	process(MuxSel2, dp_in)
	begin
		case MuxSel2 is
			when "0001" | "0010" => 
				if dp_in = "001" then 
					dp_out <= '0';
				else
					dp_out <= '1';
				end if;

			when "0101" | "0110" => 
				if dp_in = "010" then
					dp_out <= '0';
				else
					dp_out <= '1';
				end if;
			
			when "1000" | "1010" =>
				if dp_in = "011" then
					dp_out <= '0';
				else
					dp_out <= '1';
				end if;
				
			when "1101" | "1110" => 
				if dp_in = "100" then
					dp_out <= '0';
				else
					dp_out <= '1';
				end if;
				
			when others => dp_out <= '1';
			
		end case;
	end process;

end Behavioral ;
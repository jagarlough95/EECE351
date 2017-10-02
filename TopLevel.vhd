----------------------------------------------------------------------------------
-- Company: 		 Binghamton University 
--						 Electrical and Computer Engineering Department
-- Engineer: 		 Carl Betcher
-- 
-- Create Date:    22:00:51 09/23/2017 
-- Design Name: 
-- Module Name:    TopLevel - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TopLevel is
	 Generic ( DELAY : positive := 640000); -- DELAY = 20 mS / clk_period
    Port ( Clk : in  STD_LOGIC := '0';
			  Switch     : in  STD_LOGIC_vector(7 downto 0) := x"00";
			  DIR_LEFT   : in  STD_LOGIC := '1';	
			  DIR_RIGHT  : in  STD_LOGIC := '1';	
			  DIR_UP     : in  STD_LOGIC := '1';	
			  DIR_DOWN   : in  STD_LOGIC := '1';	
			  Seg7_SEG   : out STD_LOGIC_vector(6 downto 0); 
			  Seg7_DP    : out STD_LOGIC; 
			  Seg7_AN    : out STD_LOGIC_vector(4 downto 0); 
			  LED        : out STD_LOGIC_vector(7 downto 0) 
			  );
end TopLevel;

architecture Behavioral of TopLevel is

	COMPONENT ALU
	GENERIC ( data_size : positive := 32 );
	PORT( A : in  STD_LOGIC_vector(data_size-1 downto 0);
         B : in  STD_LOGIC_vector(data_size-1 downto 0);
			ALUControl : in STD_LOGIC_vector(1 downto 0);
         Result : out  STD_LOGIC_vector(data_size-1 downto 0);
         ALUFlags : out  STD_LOGIC_vector(3 downto 0)
			);
	END COMPONENT;

	COMPONENT ControlLogicFSM
	PORT(
		Clk : IN std_logic;
		Left : IN std_logic;
		Right : IN std_logic;
		Up : IN std_logic;
		Down : IN std_logic;          
		load_A_Reg : OUT std_logic;
		load_B_Reg : OUT std_logic;
		Load_Ctrl_Reg : OUT std_logic;
		MUX_Select : OUT std_logic_vector(1 downto 0)
		);
	END COMPONENT;

	COMPONENT HEXon7segDisp
	PORT(
		hex_data_in0 : IN std_logic_vector(3 downto 0);
		hex_data_in1 : IN std_logic_vector(3 downto 0);
		hex_data_in2 : IN std_logic_vector(3 downto 0);
		hex_data_in3 : IN std_logic_vector(3 downto 0);
		dp_in : IN std_logic_vector(2 downto 0);
		clk : IN std_logic;          
		seg_out : OUT std_logic_vector(6 downto 0);
		an_out : OUT std_logic_vector(3 downto 0);
		dp_out : OUT std_logic
		);
	END COMPONENT;

	COMPONENT debounce is 
		GENERIC ( DELAY : positive := 640000 -- DELAY = 20 mS / clk_period
					 );
		PORT ( clk : in  STD_LOGIC;
				 sig_in : in  STD_LOGIC;
				 sig_out : out  STD_LOGIC
				 );
	END COMPONENT;

	constant ALU_width : positive := 8;
	signal A_Reg, B_Reg : std_logic_vector(ALU_width-1 downto 0) := (others => '0');
	signal ALUControl_Reg : std_logic_vector(1 downto 0) := (others => '0');
	signal ALU_Result : std_logic_vector(ALU_width-1 downto 0);
	signal ALU_Flags : std_logic_vector(3 downto 0);
	signal Left, Right, Up, Down : std_logic;
	
	signal load_A_Reg, load_B_Reg, load_Ctrl_Reg : std_logic;
	signal MUX_Select : std_logic_vector(1 downto 0) := (others => '0');
	
	signal an_out3_0 : std_logic_vector(3 downto 0);
	
begin

	-- Debounce DIR input signals and produce synchronized pulses
	Sync_DIR_LEFT: debounce 
						generic map ( DELAY => DELAY ) 
						port map (	sig_in => 	DIR_LEFT,
													clk    => 	Clk,
													sig_out => 	Left);

	Sync_DIR_RIGHT: debounce 
						generic map ( DELAY => DELAY ) 
						port map (	sig_in => 	DIR_RIGHT,
													clk    => 	Clk,
													sig_out => 	Right);

	Sync_DIR_UP: debounce 
						generic map ( DELAY => DELAY ) 
						port map (	sig_in => 	DIR_UP,
													clk    => 	Clk,
													sig_out => 	Up);

	Sync_DIR_DOWN: debounce 
						generic map ( DELAY => DELAY ) 
						port map (	sig_in => 	DIR_DOWN,
													clk    => 	Clk,
													sig_out => 	Down);

	-- Instantiate control logic FSM
	-- Decodes button actions into control signals
	Ctrl_LogicFSM: ControlLogicFSM PORT MAP(
		-- input ports
		Clk => Clk,
		Left => Left,
		Right => Right,
		Up => Up,
		Down => Down,
		-- output ports
		load_A_Reg => load_A_Reg,
		load_B_Reg => load_B_Reg,
		Load_Ctrl_Reg => Load_Ctrl_Reg,
		MUX_Select => MUX_Select
	);

	-- A Register
	process (Clk)
	begin
		if rising_edge(Clk) then
			if load_A_Reg = '1' then
				A_Reg <= Switch;
			end if;
		end if;		
	end process;
	
	-- B Register
	process (Clk)
	begin
		if rising_edge(Clk) then
			if load_B_Reg = '1' then
				B_Reg <= Switch;
			end if;
		end if;		
	end process;
	
	-- ALUControl Register
	process (Clk)
	begin
		if rising_edge(Clk) then
			if load_Ctrl_Reg = '1' then
				ALUControl_Reg <= Switch(1 downto 0);
			end if;
		end if;		
	end process;
	
	-- Instantiate ALU
	Inst_ALU: ALU 
	GENERIC MAP(data_size => ALU_width)
	PORT MAP(
		A => A_Reg,
		B => B_Reg,
		ALUControl => ALUControl_Reg,
		Result => ALU_Result,
		ALUFlags => ALU_Flags
	);

	-- Select what to display on the LEDs using MUX_Select
	-- 00 = Display Switches on LEDs
	-- 01 = Display ALUControl_Reg on LEDs
	-- 10 = Display ALU_Result on LEDs
	-- 11 = Display ALU_Flags on LEDs
	with MUX_Select select
		LED <= 	Switch							when "00",
					"000000" & ALUControl_Reg	when "01",
					ALU_Result 						when "10",
					"0000" & ALU_Flags			when others;
	
	-- Display A_Reg and B_Reg on 7-Segment Displays
	HEXon7segDisp1: HEXon7segDisp PORT MAP(
		hex_data_in0 => A_Reg(7 downto 4),
		hex_data_in1 => A_Reg(3 downto 0),
		hex_data_in2 => B_Reg(7 downto 4),
		hex_data_in3 => B_Reg(3 downto 0),
		dp_in => "000",
		seg_out => Seg7_SEG,
		an_out => an_out3_0,
		dp_out => Seg7_DP,
		clk => Clk
	);
	
	Seg7_AN <= '1' & an_out3_0;  -- drive 5th anode high

end Behavioral;


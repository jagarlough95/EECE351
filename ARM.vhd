----------------------------------------------------------------------------------
-- Company: 		 Binghamton University
-- Engineer(s): 
-- 
-- Create Date:    23:13:36 11/13/2016 
-- Design Name: 
-- Module Name:    ARM - Behavioral 
-- Project Name: 	 ARM Processor (Single Cycle)
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

entity ARM is -- single cycle processor
  port(clk, reset, en_ARM: in  STD_LOGIC;
       PC:                out STD_LOGIC_VECTOR(31 downto 0);
       Instr:             in  STD_LOGIC_VECTOR(31 downto 0);
       MemWrite:          out STD_LOGIC;
       ALUResult, WriteData: out STD_LOGIC_VECTOR(31 downto 0);
       ReadData:          in  STD_LOGIC_VECTOR(31 downto 0));
end ARM;

architecture Behavioral of ARM is

	COMPONENT controller
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		Instr : IN std_logic_vector(31 downto 12);
		ALUFlags : IN std_logic_vector(3 downto 0);          
		RegSrc : OUT std_logic_vector(1 downto 0);
		RegWrite : OUT std_logic;
		ImmSrc : OUT std_logic_vector(1 downto 0);
		ALUSrc : OUT std_logic;
		ALUControl : OUT std_logic_vector(1 downto 0);
		MemWrite : OUT std_logic;
		MemtoReg : OUT std_logic;
		PCSrc : OUT std_logic
		);
	END COMPONENT;

	COMPONENT datapath
	PORT(
		clk, reset, en_ARM : IN std_logic;
		RegSrc : IN std_logic_vector(1 downto 0);
		RegWrite : IN std_logic;
		ImmSrc : IN std_logic_vector(1 downto 0);
		ALUSrc : IN std_logic;
		ALUControl : IN std_logic_vector(1 downto 0);
		MemtoReg : IN std_logic;
		PCSrc : IN std_logic;
		Instr : IN std_logic_vector(31 downto 0);
		ReadData : IN std_logic_vector(31 downto 0);          
		ALUFlags : OUT std_logic_vector(3 downto 0);
		PC : OUT std_logic_vector(31 downto 0);
		ALUResult : OUT std_logic_vector(31 downto 0);
		WriteData : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;

	-- Signals needed to make connections between the datapath and controller
	signal ALUFlags : std_logic_vector(3 downto 0);
	signal RegSrc : std_logic_vector(1 downto 0);
	signal RegWrite : std_logic; 
	signal ImmSrc : std_logic_vector(1 downto 0);
	signal ALUSrc : std_logic;
	signal ALUControl : std_logic_vector(1 downto 0);
	signal MemtoReg  : std_logic;
	signal PCSrc : std_logic;


begin

	-- Instantiate the Controller for the ARM Processor
	Inst_controller: controller PORT MAP(
		clk => clk,
		reset => reset,
		Instr => Instr(31 downto 12),
		ALUFlags => ALUFlags,
		RegSrc => RegSrc,
		RegWrite => RegWrite,
		ImmSrc => ImmSrc,
		ALUSrc => ALUSrc,
		ALUControl => ALUControl,
		MemWrite => MemWrite,
		MemtoReg => MemtoReg,
		PCSrc => PCSrc
	);

	-- Instantiate the Datapath for the ARM Processor
	Inst_datapath: datapath PORT MAP(
		clk => clk,
		reset => reset,
		en_ARM => en_ARM,
		RegSrc => RegSrc,
		RegWrite => RegWrite,
		ImmSrc => ImmSrc,
		ALUSrc => ALUSrc,
		ALUControl => ALUControl,
		MemtoReg => MemtoReg,
		PCSrc => PCSrc,
		ALUFlags => ALUFlags,
		PC => PC,
		Instr => Instr,
		ALUResult => ALUResult,
		WriteData => WriteData,
		ReadData => ReadData
	);

end Behavioral;


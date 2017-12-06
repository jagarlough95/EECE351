----------------------------------------------------------------------------------
-- Company: 		 Binghamton University
-- Engineer(s): 	 Carl Betcher
-- 
-- Create Date:    23:13:36 11/13/2016 
-- Design Name: 	 ARM Processor Datapath
-- Module Name:    Datapath - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

entity datapath is  
  port(clk, reset, en_ARM: in  STD_LOGIC;
       RegSrc:            in  STD_LOGIC_VECTOR(1 downto 0);
       RegWrite:          in  STD_LOGIC;
       ImmSrc:            in  STD_LOGIC_VECTOR(1 downto 0);
       ALUSrc:            in  STD_LOGIC;
       ALUControl:        in  STD_LOGIC_VECTOR(1 downto 0);
       MemtoReg:          in  STD_LOGIC;
       PCSrc:             in  STD_LOGIC;
       ALUFlags:          out STD_LOGIC_VECTOR(3 downto 0);
       PC:                out STD_LOGIC_VECTOR(31 downto 0);
       Instr:             in  STD_LOGIC_VECTOR(31 downto 0);
       ALUResult, WriteData: out STD_LOGIC_VECTOR(31 downto 0);
       ReadData:          in  STD_LOGIC_VECTOR(31 downto 0));
end;

architecture Behavioral of Datapath is
 
	COMPONENT Register_File
	GENERIC (word_size : natural := 32;
				address_size : natural := 4 );
	PORT(
		clk : IN std_logic;
		WE3 : IN std_logic;
		A1 : IN std_logic_vector(address_size-1 downto 0);
		A2 : IN std_logic_vector(address_size-1 downto 0);
		A3 : IN std_logic_vector(address_size-1 downto 0);
		WD3 : IN std_logic_vector(word_size-1 downto 0);
		R15 : IN std_logic_vector(word_size-1 downto 0);          
		RD1 : OUT std_logic_vector(word_size-1 downto 0);
		RD2 : OUT std_logic_vector(word_size-1 downto 0)
		);
	END COMPONENT;

	COMPONENT ALU
	PORT(
		A : IN std_logic_vector(31 downto 0);
		B : IN std_logic_vector(31 downto 0);
		ALUControl : IN std_logic_vector(1 downto 0);          
		Result : OUT std_logic_vector(31 downto 0);
		ALUFlags : OUT std_logic_vector(3 downto 0)
		);
	END COMPONENT;

	signal PCmux : std_logic_vector(31 downto 0);
	signal PCsig : std_logic_vector(31 downto 0) := (others => '0');
	signal PCplus4 : unsigned(31 downto 0);
	signal PCplus8 : std_logic_vector(31 downto 0);
	signal ExtImm : std_logic_vector(31 downto 0);
	signal ShiftedImm24 : signed(31 downto 0);
	signal RA1mux : std_logic_vector(3 downto 0);
	signal RA2mux : std_logic_vector(3 downto 0);
	signal SrcA : std_logic_vector(31 downto 0);
	signal SrcB : std_logic_vector(31 downto 0);
	signal ALUResultSig : std_logic_vector(31 downto 0);
	signal WriteDataSig : std_logic_vector(31 downto 0);
	signal Result : std_logic_vector(31 downto 0);	
	
	signal RF_WE3 : std_logic;

begin

	-- Output the Program Counter
	PC <= PCsig;
	-- Output the ALUResult for the Data Memory Address
	ALUResult <= ALUResultSig;
	-- Output the data to be written to Data Memory
	WriteData <= WriteDataSig;
	
	-- This Mux provides the data loaded into the PC
	-- When PCSrc = '1', the source of the PC in output of ALU or Data Memory
	--     Used for branching
	-- When PCSrc = '0', the source of the PC is PCPlus4
	--     Used when accessing the next consecutive instruction
	PCmux <= Result when PCSrc = '1' else std_logic_vector(PCplus4);
	
	-- Program Counter
	-- reset clears it to 0
	-- en_ARM allows PC to loaded with PCmux
	Process(clk) 
	begin 
		if rising_edge(clk) then
			if reset = '1' then
				PCsig <= (others => '0');
			elsif en_ARM = '1' then	
				PCsig <= PCmux;
			else
				PCsig <= PCsig;
			end if;
		end if; 
	end process;
	
	-- Adder adds 4 to the PC
	PCplus4 <= unsigned(PCsig) + 4;
	
	-- Adder adds 4 to PCplus4 to produce PC + 8
	PCplus8 <= std_logic_vector(PCplus4 + 4);
	
	-- Mux selects address for Port 1 of the Register File
	RA1mux <= Instr(19 downto 16) when RegSrc(0) = '0' else x"F";
	
	-- Mux selects address for Port 2 of the Register File
	RA2mux <= Instr(3 downto 0) when RegSrc(1) = '0' else Instr(15 downto 12);
	
	-- Write enable for Register File is gated by en_ARM
	RF_WE3 <= RegWrite and en_ARM;
	
	-- Instantiate Register File (16 registers x 32 bits)
	Inst_Register_File: Register_File PORT MAP(
		clk => clk,
		WE3 => RF_WE3,
		A1 => RA1mux,
		A2 => RA2mux,
		A3 => Instr(15 downto 12),
		WD3 => Result,
		R15 => PCplus8,
		RD1 => SrcA,
		RD2 => WriteDataSig 
	);
	
	-- 24-bit Immediate Field sign extended and shifted left twice
	ShiftedImm24 <= resize(signed(Instr(23 downto 0)),30) & "00";
	
	-- Extend function for Immediate data
	with ImmSrc select
	ExtImm <= std_logic_vector(resize(unsigned(Instr(7 downto 0)),ExtImm'length)) when "00",
				 std_logic_vector(resize(unsigned(Instr(11 downto 0)),ExtImm'length)) when "01",
				 std_logic_vector(ShiftedImm24) when others;
	
	-- Selects Source of ALU input B
	-- When ALUSrc = '1', selects Extended Immediate Data
	-- When ALUSrc = '0', selects data from register file on Port 2
	SrcB <= WriteDataSig when ALUSrc = '0' else ExtImm;
	
	-- Instantiate the ALU
	Inst_ALU: ALU PORT MAP(
		A => SrcA,
		B => SrcB,
		ALUControl => ALUControl,
		Result => ALUResultSig,
		ALUFlags => ALUFlags
	);	
	
	-- MUX "ReadData" from Data Memory and "ALUResult" from the ALU to produce "Result"
	-- Result is data written to the PC or the Register File
	Result <= ALUResultSig when MemtoReg = '0' else ReadData;
	
end Behavioral;


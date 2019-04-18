library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity top is
  port(
	HSYNC : out std_logic;
	VSYNC: out std_logic;
	RGB: out std_logic_vector (5 downto 0)
  );
end top;

architecture synth of top is 
    signal in1: std_logic := '1';
    signal in2: std_logic := '1';
    signal clk: std_logic;
	signal output: std_logic;
	
	signal pixclk: std_logic;
	signal row: unsigned(9 downto 0);
	signal col: unsigned(9 downto 0);
	signal valid: std_logic;
    component HSOSC is
    generic (
        CLKHF_DIV : String := "0b00"); -- Divide 48MHz clock by 2?N (0-3)
    port(
        CLKHFPU : in std_logic := 'X'; -- Set to 1 to power up
        CLKHFEN : in std_logic:= 'X'; -- Set to 1 to enable output
        CLKHF : out std_logic := 'X'); -- Clock output
	end component;
	
	component pll is
	port(outglobal_o: out std_logic;
		outcore_o: out std_logic;
		ref_clk_i: in std_logic;
		rst_n_i: in std_logic);
	end component;
	
	component vga is
	port (
		clk : in std_logic;
		hsync : out std_logic;
		vsync : out std_logic;
		row : out unsigned (9 downto 0); -- includes vsync rows
		col : out unsigned (9 downto 0); -- includes hsync rows
		valid : out std_logic);
	end component;
	
	component pattern_gen is
	port (
		clk: in std_logic;
		valid : in std_logic;
		row : in unsigned (9 downto 0); 
		col : in unsigned (9 downto 0); 
		rgb : out std_logic_vector (5 downto 0));
	end component;

begin
	clk_driver: HSOSC port map(in1, in2, clk);
	pll_driver: pll port map(outglobal_o=>pixclk, outcore_o=>output, ref_clk_i=>clk, rst_n_i=>'1');
	vga_driver: vga port map(pixclk, HSYNC, VSYNC, row, col, valid);
	pattern_generator: pattern_gen port map(pixclk, valid, row, col, RGB);
end;
	

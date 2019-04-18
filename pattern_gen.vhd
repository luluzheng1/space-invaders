library IEEE; use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all; 

entity pattern_gen is
    port (
	clk : in std_logic;
	valid : in std_logic;
	row : in unsigned(9 downto 0);
	col : in unsigned(9 downto 0);
	rgb : out std_logic_vector(5 downto 0)
    );
end entity;

architecture synth of pattern_gen is
constant RED: std_logic_vector(5 downto 0) := "110000";
constant GREEN: std_logic_vector(5 downto 0) := "001100";
constant BLUE: std_logic_vector(5 downto 0) := "000011";
signal is_on_ship, is_on_alien: std_logic;
component alien is
    port (
	clk : in std_logic;
	valid : in std_logic;
	row : in unsigned(9 downto 0);
	col : in unsigned(9 downto 0);
	output : out std_logic
    );
end component;	

component spaceship is
    port (
	clk : in std_logic;
	valid : in std_logic;
	row : in unsigned(9 downto 0);
	col : in unsigned(9 downto 0);
	output : out std_logic
    );
end component;

begin
	s: spaceship port map(clk, valid, row, col, is_on_ship);
	a: alien port map(clk, valid, row, col, is_on_alien); 
	rgb(5 downto 0) <= BLUE when(is_on_ship) else
					   RED when(is_on_alien) else "000000";
end;
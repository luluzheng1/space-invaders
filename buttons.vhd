library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all; 

entity buttons is 
    port (
	clk: in std_logic;
	row: in unsigned(9 downto 0);
	col: in unsigned(9 downto 0);
	leftbutton: in std_logic; 
	rightbutton : in std_logic;
	command: out unsigned(3 downto 0)
	);	
end entity;

architecture synth of buttons is

constant UPDATE_ROW: integer := 490;
	
constant LEFT_CMD: integer := 1;
constant RIGHT_CMD: integer := 2;
constant UP_CMD: integer := 3;
constant DOWN_CMD: integer := 4;
	
signal memory: integer;
	
begin
process (clk) is begin
	if rising_edge(clk) and row = to_unsigned(UPDATE_ROW,10) and col = to_unsigned(650,10) then
		if leftbutton = '1' then
			memory <= LEFT_CMD;
		elsif rightbutton = '1' then
			memory <= RIGHT_CMD;
		end if;
	end if;
end process;

command <= to_unsigned(memory,4);
end;
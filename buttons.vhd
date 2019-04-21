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
	resetbutton: in std_logic;
	a_button: in std_logic;
	command: out unsigned(3 downto 0)
	);	
end entity;

architecture synth of buttons is

-- Location to update the command input
constant UPDATE_ROW: integer := 490;
	
-- Commands from the controller
constant LEFT_CMD: integer := 1;
constant RIGHT_CMD: integer := 2;
constant UP_CMD: integer := 3;
constant DOWN_CMD: integer := 4;
constant A_CMD: integer :=5;
constant B_CMD: integer :=6;
constant START_CMD: integer :=7;
constant SELECT_CMD: integer :=8;
constant STANDBY_CMD: integer := 9;
	
signal choice: integer;
	
begin
-- Update memory in the dead zone
process (clk) is begin
	if rising_edge(clk) and row = to_unsigned(UPDATE_ROW,10) and col = to_unsigned(650,10) then
		
		-- Using pull up buttons so it's '0' instead of '1'
		if leftbutton = '0' then
			choice <= LEFT_CMD;
		elsif rightbutton = '0' then
			choice <= RIGHT_CMD;
		elsif resetbutton = '0' then
			choice <= START_CMD;
		elsif a_button <= '0' then
			choice <= A_CMD;
		else
			choice <= STANDBY_CMD;
		end if;
	end if;
end process;

-- Send out a command
command <= to_unsigned(choice,4);
end;
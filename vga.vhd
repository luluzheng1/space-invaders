library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity vga is
	port (
		clk : in std_logic;
		hsync : out std_logic;
		vsync : out std_logic;
		row : out unsigned (9 downto 0); -- includes vsync rows
		col : out unsigned (9 downto 0); -- includes hsync rows
		valid : out std_logic);
end entity;

architecture synth of vga is 
signal row_counter: unsigned(9 downto 0) :=to_unsigned(0, 10); -- 525 lines
signal col_counter: unsigned(9 downto 0) :=to_unsigned(0,10); -- 800 pixels
constant H_ROW_PIXELS: integer := 640;
constant V_COL_LINES: integer := 480;

begin
	process(clk) is 
	begin
		if rising_edge(clk) then
			col_counter <= col_counter + to_unsigned(1,10);
			if(col_counter > 800) then
				row_counter <= row_counter + to_unsigned(1, 10);
				col_counter <= to_unsigned(0,10);
			end if;
			
			if(row_counter >= 525) then
				row_counter <= to_unsigned(0,10);
			end if;
		end if;
	end process;
	
	hsync <= '1' when (col_counter < to_unsigned(656,10) or col_counter >= to_unsigned(752,10)) else '0';
	vsync <= '1' when (row_counter < to_unsigned(490,10) or row_counter >= to_unsigned(492,10)) else '0';
	valid <= '1' when (col_counter <= to_unsigned(H_ROW_PIXELS,10) and row_counter <= to_unsigned(V_COL_LINES,10)) else '0';
	row <= row_counter;
	col <= col_counter;
end;
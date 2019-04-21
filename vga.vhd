library IEEE; use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all; 

entity vga is
    port ( 
	inputclk : in std_logic;
	valid: out std_logic; 
	out_row : out unsigned(9 downto 0);
	out_col : out unsigned(9 downto 0);
	hsync : out std_logic;
	vsync : out std_logic
); 
end entity;

architecture synth of vga is
    signal row : unsigned(9 downto 0) := to_unsigned(0,10);
    signal col : unsigned(9 downto 0) := to_unsigned(0,10);
	constant COL_PIX : integer := 800;
	constant ROW_LIN : integer := 525;
	constant VISIBLE_PIX : integer := 640;
	constant VISIBLE_LIN : integer := 480;

begin
    process (inputclk) is
	begin
        if rising_edge(inputclk) then
		-- increment col every clock cycle
			col <= col + to_unsigned(1,10);

		-- increment row after 800 pixel
			if (col > COL_PIX) then
				row <= row + to_unsigned(1,10);
				col <= to_unsigned(0,10);
			end if;

		-- reset row when needed
			if (row > ROW_LIN) then
				row <= to_unsigned(0,10);
			end if;
		end if;
    end process;

    valid <= '1' when (col <= to_unsigned(VISIBLE_PIX,10) and row <= to_unsigned(VISIBLE_LIN,10)) else '0';
    hsync <= '1' when (col <= to_unsigned(656,10) or col > to_unsigned(752,10)) else '0';
    vsync <= '1' when (row <= to_unsigned(490,10) or row > to_unsigned(492,10)) else '0';
    out_row <= row;
    out_col <= col;
end;
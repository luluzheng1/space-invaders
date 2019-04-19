library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all; 

entity game_graphics is
    port (
	clk : in std_logic;
	valid : in std_logic;
	row : in unsigned(9 downto 0);
	col : in unsigned(9 downto 0);
	cmd : in unsigned(3 downto 0);
	rgb : out std_logic_vector(5 downto 0)
    );
end entity;

architecture synth of  game_graphics is

component spaceship_graphics is
	port(
	rd_addr_i: in std_logic_vector(4 downto 0);
	wr_clk_i: in std_logic;
	wr_clk_en_i: in std_logic;
	rd_clk_en_i: in std_logic;
	rd_en_i: in std_logic;
	rd_data_o: out std_logic_vector(31 downto 0);
	wr_data_i: in std_logic_vector(31 downto 0);
	wr_addr_i: in std_logic_vector(4 downto 0);
	wr_en_i: in std_logic;
	rd_clk_i: in std_logic
	);
end component;

constant RED: std_logic_vector(5 downto 0) := "110000";
constant GREEN: std_logic_vector(5 downto 0) := "001100";
constant BLUE: std_logic_vector(5 downto 0) := "000011";
	
constant SHIP_TOP_B: integer := 432; 
constant SHIP_BOT_B: integer := 464;	
constant SHIP_R_B: integer := 560;
constant SHIP_L_B: integer := 80;
	
constant UPDATE_ROW: integer := 500;
constant STEP: integer := 16;
	
constant LEFT_CMD: integer := 1;
constant RIGHT_CMD: integer := 2;
constant UP_CMD: integer := 3;
constant DOWN_CMD: integer := 4;
	
signal rom_x: integer := 0;
signal rom_y: std_logic_vector(4 downto 0) := "00000";
signal ship_x: unsigned(9 downto 0) := to_unsigned(304,10);
signal y_coord: integer;
signal x_coord: integer;
signal rom_valid: std_logic;
signal ship_valid: std_logic;
signal read_data: std_logic_vector(31 downto 0);
	
begin
	ship: spaceship_graphics port map(
	rd_addr_i=> rom_y,
	wr_clk_i=> clk,
	wr_clk_en_i=> '0',
	rd_clk_en_i=> '1',
	rd_en_i=> '1',
	rd_data_o=> read_data,
	wr_data_i=> 32x"0",
	wr_addr_i=> 5x"0",
	wr_en_i=> '0',
	rd_clk_i=> clk
	);
	
process (clk) is begin
	if rising_edge(clk) and row = to_unsigned(UPDATE_ROW,10) and col = to_unsigned(660,10)then
		if cmd = LEFT_CMD then
			ship_x <= ship_x - to_unsigned(STEP,10);
		elsif cmd = RIGHT_CMD then
			ship_x <= ship_x + to_unsigned(STEP,10);
		else
			ship_x <= ship_x;
		end if;
	end if;
end process;

	y_coord <= to_integer(row) - SHIP_TOP_B;
	x_coord <= to_integer(col) - to_integer(ship_x);

	rom_valid <= '1' when (y_coord >= 0 and y_coord < 32) and 
				(x_coord >= 0 and x_coord < 32) else '0';
	
	rom_y <= std_logic_vector(to_unsigned(y_coord,5)) when rom_valid ='1' else "00000";
	rom_x <= x_coord when rom_valid ='1' else 0;
	
	ship_valid <= '1' when (row >= to_unsigned(SHIP_TOP_B,10) and row < to_unsigned(SHIP_BOT_B,10))and 
				  (col >= ship_x and col < (ship_x + to_unsigned(32,10))) and
				  (ship_x >= SHIP_L_B and ship_x + to_unsigned(32,10) < SHIP_R_B) else '0';
				  
	rgb <= BLUE when valid ='1' and ship_valid='1' and read_data(rom_x)='1' else "000000";
end;
library IEEE; use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all; 

entity pattern_gen2 is
    port (
	clk : in std_logic;
	valid : in std_logic;
	row : in unsigned(9 downto 0);
	col : in unsigned(9 downto 0);
	rgb : out std_logic_vector(5 downto 0)
    );
end entity;

architecture synth of pattern_gen2 is

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

component alien_graphics is
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
	
	constant SHIP_TOP: integer := 432; 
	constant SHIP_BOT: integer := 464;	
	constant SHIP_R: integer := 560;
	constant SHIP_L: integer := 80;
	
	constant ALIEN_L: integer := 160;
	constant ALIEN_R: integer := 480;
	constant ALIEN_TOP: integer := 96;
	constant ALIEN_BOT: integer := 224;
	
	signal is_on1, is_on2: std_logic;
	signal valid_spaceship: std_logic;
	signal valid_alien: std_logic;	
	signal read_data1, read_data2: std_logic_vector(31 downto 0);
	
	constant x: unsigned(9 downto 0) := to_unsigned(320,10);
	constant y: unsigned(9 downto 0) := to_unsigned(448,10);
	signal xl,xr,yt,yb: unsigned(9 downto 0);
	signal location: std_logic;
	
begin
	ship: spaceship_graphics port map(
	rd_addr_i=> std_logic_vector(row(8 downto 4)),
	wr_clk_i=> clk,
	wr_clk_en_i=> '1',
	rd_clk_en_i=> '1',
	rd_en_i=> '1',
	rd_data_o=> read_data1,
	wr_data_i=> 32x"0",
	wr_addr_i=> 5x"0",
	wr_en_i=> '0',
	rd_clk_i=> clk
	);
	
	a1: alien_graphics port map(
	rd_addr_i=> std_logic_vector(row(8 downto 4)),
	wr_clk_i=> clk, 
	wr_clk_en_i=> '1', 
	rd_clk_en_i=> '1',
	rd_en_i=> '1', 
	rd_data_o=> read_data2, 
	wr_data_i=> 32x"0", 
	wr_addr_i=> 5x"0",
	wr_en_i=> '0',
	rd_clk_i=> clk
	);
	
	-- Location of ship
	xl <= x-16;
	xr <= x+16;
	yt <= y-16;
 	yb <= y+16;
	location <= '1' when (row <= yb and row >= yt and col >= xl and col <= xr) else '0';
	
	is_on1 <= read_data1(to_integer(6d"31" - col(9 downto 4)));
	is_on2 <= read_data2(to_integer(6d"31" - col(9 downto 4)));
	valid_spaceship	<= '1' when (row <= SHIP_BOT and row >= SHIP_TOP and col >= SHIP_L and col <= SHIP_R) else '0';
	valid_alien <= '1' when (row <= ALIEN_BOT and row >= ALIEN_TOP and col >= ALIEN_L and col <= ALIEN_R) else '0';
	
	rgb <= BLUE when (valid and is_on1 and valid_spaceship and location) else
		   RED when  (valid and is_on2 and valid_alien) else "000000";
end;
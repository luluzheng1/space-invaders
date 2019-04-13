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
signal valid_alien: std_logic;
constant RED: std_logic_vector(5 downto 0) := "110000";
constant GREEN: std_logic_vector(5 downto 0) := "001100";
constant BLUE: std_logic_vector(5 downto 0) := "000011";
constant ALIEN_L: integer := 160;constant ALIEN_R: integer := 480;
constant ALIEN_TOP: integer := 96;
constant ALIEN_BOT: integer := 224;

constant SHIP_TOP: integer := 432; 
constant SHIP_BOT: integer := 464;
constant SHIP_R: integer := 560;
constant SHIP_L: integer := 80;

component square is
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

	signal is_on: std_logic;
	signal read_data: std_logic_vector(31 downto 0);
	
begin
	alien: square port map(
	rd_addr_i=> std_logic_vector(row(8 downto 4)),
	wr_clk_i=> clk, 
	wr_clk_en_i=> '1', 
	rd_clk_en_i=> '1',
	rd_en_i=> '1', 
	rd_data_o=> read_data, 
	wr_data_i=> 32x"0", 
	wr_addr_i=> 5x"0",
	wr_en_i=> '0',
    rd_clk_i=> clk
	);
	
	is_on <= read_data(to_integer(6d"39" - col(9 downto 4)));
	--valid_spaceship <= '1' when (row <= SHIP_BOT and row >= SHIP_TOP and col >= SHIP_L and col <= SHIP_R) else '0';
	valid_alien <= '1' when (row <= ALIEN_BOT and row >= ALIEN_TOP and col >= ALIEN_L and col <= ALIEN_R) else '0';
	rgb(5 downto 0) <= RED when(valid = '1'and is_on= '1' and valid_alien = '1') else "000000";
end;
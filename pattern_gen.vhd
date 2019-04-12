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

component alien is
	port(
	rd_addr_i: in std_logic_vector(4 downto 0);
	wr_clk_i: in std_logic;
	wr_clk_en_i: in std_logic;
	rd_clk_en_i: in std_logic;
	rd_en_i: in std_logic;
	rd_data_o: out std_logic_vector(39 downto 0);
	wr_data_i: in std_logic_vector(39 downto 0);
	wr_addr_i: in std_logic_vector(4 downto 0);
	wr_en_i: in std_logic;
	rd_clk_i: in std_logic
	);
end component;

	signal is_on, is_on2: std_logic;
	signal read_data: std_logic_vector(39 downto 0);
begin
	board: alien port map(
	rd_addr_i=> std_logic_vector(row(8 downto 4)),
	wr_clk_i=> clk,
	wr_clk_en_i=> '1',
	rd_clk_en_i=> '1',
	rd_en_i=> '1',
	rd_data_o=> read_data,
	wr_data_i=> 40x"0",
	wr_addr_i=> 5x"0",
	wr_en_i=> '0',
	rd_clk_i=> clk
	);
	
	is_on <= read_data(to_integer(col(9 downto 4)));
	is_on2 <= row(5) xor col(5);
	rgb(5 downto 0) <= "111111" when(valid = '1'and is_on= '1') else "000000";
end;
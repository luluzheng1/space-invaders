library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all; 

entity Menu is
    port (
	clk : in std_logic;
	valid : in std_logic;
	row : in unsigned(9 downto 0);
	col : in unsigned(9 downto 0);
	cmd1 : in unsigned(3 downto 0);
	cmd2 : in unsigned(3 downto 0);
	selector : in std_logic;
	rgb : out std_logic_vector(5 downto 0)
    );
end entity;

architecture synth of Menu is
component game_graphics_1v1 is
   port (
	clk : in std_logic;
	valid : in std_logic;
	row : in unsigned(9 downto 0);
	col : in unsigned(9 downto 0);
	cmd1 : in unsigned(3 downto 0);
	cmd2 : in unsigned(3 downto 0);
	status: out unsigned(1 downto 0);
	rgb : out std_logic_vector(5 downto 0)
    );
end component;

component game_graphics is
   port (
	clk : in std_logic;
	valid : in std_logic;
	row : in unsigned(9 downto 0);
	col : in unsigned(9 downto 0);
	cmd : in unsigned(3 downto 0);
	status: out unsigned(1 downto 0);
	rgb : out std_logic_vector(5 downto 0)
    );
end component;

-- Colors
constant RED: std_logic_vector(5 downto 0) := "110000";
constant GREEN: std_logic_vector(5 downto 0) := "001100";
constant BLUE: std_logic_vector(5 downto 0) := "000011";
constant BLACK: std_logic_vector(5 downto 0) := "000000";
constant YELLOW: std_logic_vector(5 downto 0) := "111100";
constant WHITE: std_logic_vector(5 downto 0) := "111111";
constant PINK: std_logic_vector(5 downto 0) := "110010";

signal state: integer := 0;
signal game: integer;
signal rgb1, rgb2: std_logic_vector(5 downto 0);
signal status1, status2: unsigned(1 downto 0);
signal is_on: std_logic;

signal player: unsigned(3 downto 0);
signal player1, player2: unsigned(3 downto 0);

begin
classic: game_graphics port map(clk,valid,row,col,player,status1,rgb1);
multi: game_graphics_1v1 port map(clk,valid,row,col,player1,player2,status2,rgb2);

process(clk,state) is begin
	if rising_edge(clk)  and row = to_unsigned(500,10) and col = to_unsigned(680,10) then
		/*case state is
			when "00" => game <= 1;
			when "01" => game <= 2;
			when "10" => game <= 3;
			when "11" => game <= 4;
			when others => state <= "00";
		end case;*/
		if selector = '1' then
			player <= cmd1;
		elsif selector = '0' then
			player1 <= cmd1;
			player2 <= cmd2;
		end if;
	end if;
end process;

state <=  0 when selector = '1' and status1= "01" else 
		  1 when selector = '0' and status2= "10" else
		  2 when selector = '1' and status1= "11" else
		  3 when selector = '0' and status2= "11";
		  
is_on <= row(5) xor col(5);

rgb <= rgb1 when state = 0 else
	   rgb2 when state = 1 else 
	   RED when valid = '1'and is_on= '1' and (state = 2 or state = 3) else "000000";
	   --GREEN when valid= '1' and is_on= '1' and state = 2;
end;
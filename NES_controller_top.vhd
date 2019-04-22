library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity NES_controller_top is
	port(
		clk_full : in std_logic;
		data : in std_logic;
		
		latch : out std_logic;
		controller_clk : out std_logic;
		
		A_p : out std_logic;
		start_p : out std_logic;
		left_p : out std_logic;
		right_p : out std_logic
	);
end NES_controller_top;


architecture  synth of NES_controller_top is

	component NES_controller_clk is 
	port (
		clk_full : in std_logic;
		NESclk : out std_logic;
		NEScount : out unsigned(10 downto 0)
	);
	end component;
	
	signal NESclk : std_logic;
	signal NEScount : unsigned(10 downto 0);
	signal data_register : std_logic_vector(7 downto 0);
	signal up_p : std_logic;
	signal down_p : std_logic;
	signal B_p : std_logic;
	signal select_p : std_logic;

begin
	clocks : NES_controller_clk port map (clk_full, NESclk, NEScount);
	
	process (NESclk, clk_full) is
	begin
	
	if rising_edge(NESclk) then
		
		latch <= '1' when (NEScount = 0) else '0';
		
		if NEScount >= 0and NEScount <= 8 then
			data_register(0) <= data;
			data_register(1) <= data_register(0);
			data_register(2) <= data_register(1);
			data_register(3) <= data_register(2);
			data_register(4) <= data_register(3);
			data_register(5) <= data_register(4);
			data_register(6) <= data_register(5);
			data_register(7) <= data_register(6);
		end if;
		
		if NEScount = 9 then
			A_p <= not data_register(7);
			B_p <= not data_register(6);
			select_p <= not data_register(5);
			start_p <= not data_register(4);
			up_p <= not data_register(3);
			down_p <= not data_register(2);
			left_p <= not data_register(1);
			right_p <= not data_register(0);
		end if;
		
	end if;
	
	if rising_edge(clk_full) then
		controller_clk <= (not NESclk) when (NEScount > 1 and NEScount < 10) else '0';
	end if;
	
	end process;

end;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity NES_controller_clk is
	port(
		clk: in std_logic;
		NESclk : out std_logic;
		NEScount : out unsigned(10 downto 0);
		clk_full : out std_logic
	);
end NES_controller_clk;


architecture  synth of NES_controller_clk is
	signal counter_20 : unsigned(19 downto 0):= (others => '0');

	
begin	
	process (clk) is
	begin
		if rising_edge(clk) then
			if counter_20 = 1048574 then
				counter_20 <= (others => '0');
			else
				counter_20 <= counter_20 + 1;
			end if;
		end if;
	end process;

	NESclk <= counter_20(8);
	NEScount <= counter_20(19 downto 9);
	clk_full <= clk;
end;
library IEEE; 
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alien_shooting_generator is 
	port (
		gen_clk : in std_logic; 
		--gen_reset : in std_logic; 
		--gen_enable : in std_logic; 
		input_x : in integer; 
		input_y : in integer; 
		row_one : in std_logic_vector(9 downto 0); 
		row_two : in std_logic_vector(9 downto 0); 
		row_three : in std_logic_vector(9 downto 0); 
		output_x : out integer; 
		output_y : out integer
	); 
end entity;

architecture synth of alien_shooting_generator is 
	signal random_x : unsigned(4 downto 0);
	signal random_y : unsigned(4 downto 0);
	signal reset : std_logic; 
	signal count : unsigned(1 downto 0) := "00"; 
	signal shooting_x : integer := 0; 
	signal LSFR : std_logic_vector(4 downto 0); 
	constant increment : integer := 32; 
	signal alien_x : integer; 
	signal alien_y : integer; 
	signal shoot : std_logic := '0'; 
	
	component random_num_gen is 
    port (
        clk : in std_logic; 
        reset : in std_logic;
       -- enable : in std_logic;  
        count : out std_logic_vector (4 downto 0)
    ); 
	end component; 
	
begin 
	initLSFR : random_num_gen port map(gen_clk, reset, LSFR); 
	process (gen_clk) begin
		if (rising_edge(gen_clk)) then 
			if count = "00" then
				reset <= '1'; 
				count <= count + 1; 
			elsif count = "01" then 
				reset <= '0'; 
				--count <= "00"; 
			end if; 
			
			random_y <= unsigned(LSFR) mod 3; 
			random_x <= unsigned(LSFR) mod 10; 
			
			if random_y = "00000" then 
				if row_one(9-to_integer(random_x)) = '0' then 
					reset <= '1'; 
					--shoot <= '0'; 
				else 
					alien_y <= input_y; 
					shoot <= '1'; 
				end if; 
			elsif random_y = "00001" then 
				if row_two(9-to_integer(random_x)) = '0' then 
					reset <= '1'; 
					--shoot <= '0'; 
				else 
					alien_y <= input_y + 32; 
					shoot <= '1'; 
				end if; 
			elsif random_y = "00010" then 
				if row_three(9-to_integer(random_x)) = '0' then
					reset <= '1'; 
					--shoot <= '0'; 
				else 
					alien_y <= input_y + 64; 
					shoot <= '1'; 
				end if;
			end if; 
			
			--case random_y is 
			--	when "00000" => alien_y <= input_y; 
			--	when "00001" => alien_y <= input_y + 32; 
			--	when "00010" => alien_y <= input_y + 64;
			--	when others => alien_y <= 670; 
			--end case;
			
			if (shoot = '1') then 
				case random_x is 
					when "00000" => alien_x <= input_x; 
					when "00001" => alien_x <= input_x + 32; 
					when "00010" => alien_x <= input_x + 64; 
					when "00011" => alien_x <= input_x + 96; 
					when "00100" => alien_x <= input_x + 128; 
					when "00101" => alien_x <= input_x + 160; 
					when "00110" => alien_x <= input_x + 192; 
					when "00111" => alien_x <= input_x + 224; 
					when "01000" => alien_x <= input_x + 256; 
					when "01001" => alien_x <= input_x + 288; 
					when others => alien_x <= 670; 
				end case; 
			else
				alien_x <= -16; 
				alien_y <= 500; 
			end if; 
			
		end if; 
			
	end process;
		
	output_x <= alien_x; 
	output_y <= alien_y; 
	
end; 
	
	
		
		

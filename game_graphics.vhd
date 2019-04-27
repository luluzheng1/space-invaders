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
    rd_clk_i: in std_logic);
end component;

-- Colors
constant RED: std_logic_vector(5 downto 0) := "110000";
constant GREEN: std_logic_vector(5 downto 0) := "001100";
constant BLUE: std_logic_vector(5 downto 0) := "000011";
constant WHITE: std_logic_vector(5 downto 0) := "111111";

-- Ship boundaries
constant SHIP_TOP_B: integer := 432; 
constant SHIP_BOT_B: integer := 464;	
constant SHIP_R_B: integer := 560;
constant SHIP_L_B: integer := 80;

-- Alien boundaries
constant ALIEN_TOP_B: integer := 96;
constant ALIEN_BOT_B: integer := 432;
constant ALIEN_R_B: integer := 560;
constant ALIEN_L_B: integer := 80;

-- Row in dead space
constant UPDATE_ROW: integer := 500;
-- Distance ship travel per click
constant STEP: integer := 4;
-- Distance bullet travels
constant VELOCITY: integer := 6;
-- Commands from the controller
constant LEFT_CMD: integer := 1;
constant RIGHT_CMD: integer := 2;
constant UP_CMD: integer := 3;
constant DOWN_CMD: integer := 4;
constant A_CMD: integer :=5;
constant B_CMD: integer :=6;
constant START_CMD: integer :=7;
constant SELECT_CMD: integer :=8;
constant STANDBY_CMD: integer :=9;
	
--ship rom coordinates
signal rom_x: integer := 0;
signal rom_y: std_logic_vector(4 downto 0) := "00000";
signal y_coord: integer;
signal x_coord: integer;

--alien rom coordinates
signal alien_rom_x: integer := 0;
signal alien_rom_y: std_logic_vector(4 downto 0) := "00000";
signal alien_y_coord: integer;
signal alien_x_coord: integer;

-- ship location
constant START_X: integer := 304;
signal ship_x: integer;
signal ship_location: integer;

--signal ship_lives : integer range 0 to 3 := 3; --added for collisions

-- bullet location
signal ship_bullet_x: integer;
signal ship_bullet_y: integer;
signal bullet_location: integer;
--signal bullet_on : std_logic; --added for collisions

-- alien location
signal alien_x : integer;
signal alien_y : integer;
signal reverse : std_logic := '0';
signal counter : unsigned(25 downto 0);
signal count: integer;
--signal alien_on : std_logic <= '1'; --added for collisions

-- check if valid
signal rom_valid: std_logic;
signal alien_rom_valid: std_logic;
signal ship_on: std_logic;
signal alien_on: std_logic;
signal ship_lb, ship_rb: std_logic;
signal bullet_on: std_logic;

-- output 32 bits word from rom
signal read_data: std_logic_vector(31 downto 0);
signal alien_read_data: std_logic_vector(31 downto 0);	

--component collision_checker is
  --port (
    --clk : in std_logic;
    --bullet_on : in std_logic;
    --bullet_x : in integer;
    --bullet_y : in integer;
    --target_on : in std_logic;
    --target_x : in integer;
    --target_y : in integer;
    --target_off : out std_logic;
    --lives : out integer range 0 to 3
  --);
--end component;

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
	
	alien: alien_graphics port map(
	rd_addr_i=> alien_rom_y, 
	wr_clk_i=> clk, 
	wr_clk_en_i=> '0',
    rd_clk_en_i=> '1', 
	rd_en_i=> '1', 
	rd_data_o=> alien_read_data, 
	wr_data_i=> 32x"0", 
	wr_addr_i=> 5x"0",
    wr_en_i=> '0', 
	rd_clk_i=> clk
	);
	
    --collide: collision_checker port map (
      --clk => clk,
      --bullet_on => bullet_on,
      --bullet_x => ship_bullet_x,
      --bullet_y => ship_bullet_y,
      --target_on => alien_on,
      --target_x => alien_x,
      --target_y => alien_y,
      --target_off => alien_on,
      --lives => ship_lives
    --);

process (clk, cmd, ship_location, bullet_location) is begin
	-- Update memories when in the dead zone and some inputs occurs
	if rising_edge(clk) and row = to_unsigned(UPDATE_ROW,10) and col = to_unsigned(660,10) then
		-- Change ship's location when receives input
		if cmd = LEFT_CMD and ship_lb = '1' then
			ship_location <= ship_location - STEP;
		elsif cmd = RIGHT_CMD and ship_rb = '1' then
			ship_location <= ship_location + STEP;
		-- Make ship starts at the middle
		elsif cmd = START_CMD then
			ship_location <= START_X;
		end if;
	-- Ship stay in one place if no inputs
	elsif cmd = STANDBY_CMD then
		ship_location <= ship_location;
	end if;
	
	-- Shoot
	if rising_edge(clk) and row = to_unsigned(UPDATE_ROW,10) and col = to_unsigned(670,10) then
		if cmd = A_CMD and bullet_location <= 0 then --bullet starts
			--bullet_on <= '1'; --added for collisions
			bullet_location <= SHIP_TOP_B - 16;
			ship_bullet_x <= ship_location;
		elsif bullet_location > 0 then --bullet moves
			--bullet_on <= '1'; --added for collisions
			bullet_location <= bullet_location - VELOCITY;
			ship_bullet_x <= ship_bullet_x;
		elsif bullet_location <= 0 then --bullet hides
			--bullet_on <= '0'; --added for collisions
			bullet_location <= -16;
		end if;
	end if;
	
	--if rising_edge(clk) then
		--counter <= counter + to_unsigned(1,26);
		--if counter(25) = '1' and count < alien_x + 320 then
			--count <= count + 48;
			--alien_x <= alien_x + count;
		--elsif count >= 320 then
			--count <= 0;
		--end if;
	--end if;
	if rising_edge(clk) and row = to_unsigned(UPDATE_ROW,10) and col = to_unsigned(680,10) then
		if cmd = START_CMD then
			alien_y <= ALIEN_TOP_B;
			alien_x <= ALIEN_L_B + 80;
		elsif reverse = '0' then --elsif reverse = '0' and alien_on = '1'
			alien_x <= alien_x + 1;
		elsif reverse = '1' then --elsif reverse = '1' and alien_on = '1'
			alien_x <= alien_x - 1;
		end if;
	elsif cmd = STANDBY_CMD then
		alien_x <= alien_x;
		alien_y <= alien_y;
	end if;
end process;

-- Give ship_x the ship's stored location
ship_x <= ship_location;

-- Give bullet_y the ship's bullet stored loction
ship_bullet_y <= bullet_location;

-- Get the x and y coordinates for ship rom
y_coord <= to_integer(row) - SHIP_TOP_B;
x_coord <= to_integer(col) - ship_x;

-- Check if coordinates are 0<= x <32 and 0<= y <32
rom_valid <= '1' when (y_coord >= 0 and y_coord < 32) and 
				(x_coord >= 0 and x_coord < 32) else '0';

-- Update rom_x and rom_y if it is inside the ROM image
rom_y <= std_logic_vector(to_unsigned(y_coord,5)) when rom_valid ='1' else "00000";
rom_x <= x_coord when rom_valid ='1' else 0;
	
-- Valid size for the ship
ship_on <= '1' when row >= to_unsigned(SHIP_TOP_B,10) and row <= to_unsigned(SHIP_BOT_B,10)and 
				  col >= to_unsigned(ship_x,10) and col <= to_unsigned(ship_x + 32,10) else '0';
				  
-- Valid boundary for the ship
ship_lb <= '1' when ship_x > SHIP_L_B else '0';
ship_rb <= '1' when ship_x+32 < SHIP_R_B else '0';

-- Valid size of the ship's bullet
bullet_on <= '1' when row >= to_unsigned(ship_bullet_y,10) and row <= to_unsigned(ship_bullet_y + 8,10)and 
				  col >= to_unsigned(ship_bullet_x + 15,10) and col <= to_unsigned(ship_bullet_x + 17,10) else '0';

-- Get the x and y coordinates for alien rom
alien_y_coord <= to_integer(row) - alien_y;
alien_x_coord <= (to_integer(col) - alien_x)mod(32);

reverse <= '1' when alien_x + 320= ALIEN_R_B else '0' when alien_x = ALIEN_L_B;

-- Check if coordinates are 0<= x <32 and 0<= y <32
alien_rom_valid <= '1' when (alien_y_coord >= 0 and alien_y_coord < 32) and 
				(alien_x_coord >= 0 and alien_x_coord < 32) else '0';

-- Update alien_rom_x and alien_rom_y if it is inside the ROM image
alien_rom_y <= std_logic_vector(to_unsigned(alien_y_coord,5)) when alien_rom_valid ='1' else "00000";
alien_rom_x <= alien_x_coord when alien_rom_valid ='1' else 0;

-- Valid size for the alien
alien_on <= '1' when row >= to_unsigned(alien_y, 10) and row <= to_unsigned(alien_y +32,10)and 
				  col >= to_unsigned(alien_x,10) and col <= to_unsigned(alien_x + 320,10) else '0';
				  
-- Output color
rgb <= GREEN when valid ='1' and ship_on= '1' and read_data(rom_x)= '1' else 
	   WHITE when valid ='1' and bullet_on = '1' else
	   RED when valid = '1' and alien_on= '1' and alien_read_data(alien_rom_x)= '1' else "000000";
end;
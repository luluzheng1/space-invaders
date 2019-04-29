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
constant YELLOW: std_logic_vector(5 downto 0) := "111100";
constant WHITE: std_logic_vector(5 downto 0) := "111111";
constant PINK: std_logic_vector(5 downto 0) := "110011";

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

-- Determine number of aliens and spacing
constant NUM_MOD: integer := 32;
constant NUM_ALIEN: integer := 9;
	
--ship ROM coordinates
signal rom_x: integer := 0;
signal rom_y: std_logic_vector(4 downto 0) := "00000";
signal y_coord: integer;
signal x_coord: integer;

--alien ROM coordinates
signal alien_rom_x: integer := 0;
signal alien_rom_y: std_logic_vector(4 downto 0) := "00000";
signal alien_y_coord: integer;
signal alien_x_coord: integer;

-- ship location
constant START_X: integer := 304;
signal ship_x: integer;

-- bullet location
constant BULLET_OFF: integer :=-16;
signal ship_bullet_x: integer;
signal ship_bullet_y: integer;

-- alien location
signal alien_x : integer;
signal alien_y : integer;
signal reverse : std_logic := '0';

-- check if valid
signal rom_valid: std_logic;
signal alien_rom_valid: std_logic;
signal ship_on: std_logic;
signal alien_on: std_logic;
signal ship_lb, ship_rb: std_logic;
signal bullet_on: std_logic;

-- output 32-bit words from ROM
signal read_data: std_logic_vector(31 downto 0);
signal alien_read_data: std_logic_vector(31 downto 0);	

-- hit detection
signal count: integer := 1;
signal hit: std_logic;
signal effect: std_logic;
signal dead: integer;

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

process (clk, cmd, ship_x, ship_bullet_y) is begin
-- Update display from ROM when in the dead zone and some inputs occurs
if rising_edge(clk) and row = to_unsigned(UPDATE_ROW,10) and col = to_unsigned(650,10) then
	-- Make ship starts at the middle
	if cmd = START_CMD then
		ship_x <= START_X;
	-- Change ship's location when receives input
	elsif cmd = LEFT_CMD and ship_lb = '1' then
		ship_x <= ship_x - STEP;
	elsif cmd = RIGHT_CMD and ship_rb = '1' then
		ship_x <= ship_x + STEP;
	end if;
-- Ship stay in one place if no inputs
elsif cmd = STANDBY_CMD then
	ship_x <= ship_x;
end if;
	
-- Update ship_bullet's location when in dead zone
if rising_edge(clk) and row = to_unsigned(UPDATE_ROW,10) and col = to_unsigned(650,10) then
	-- Make ship shoot bullet when A is pressed
	if cmd = A_CMD and ship_bullet_y <= 0 then
		ship_bullet_y <= SHIP_TOP_B - 16;
		ship_bullet_x <= ship_x;
	-- Bullet travels upward until off screen
	elsif ship_bullet_y > -16 then
		ship_bullet_y <= ship_bullet_y - VELOCITY;
		ship_bullet_x <= ship_bullet_x;
	end if;
	-- If you hit something, turn bullet off
	if hit = '1' then
		ship_bullet_x <= BULLET_OFF;
		ship_bullet_y <= BULLET_OFF;
	end if;
end if;
end process;

process (clk, cmd, alien_x, alien_y) is begin
-- Update alien's location in the dead zone
if rising_edge(clk) and row = to_unsigned(UPDATE_ROW,10) and col = to_unsigned(650,10) and count = 0 then
	-- If Start is pressed, then reset the alien to the center
	if cmd = START_CMD then
		alien_y <= ALIEN_TOP_B;
		alien_x <= ALIEN_L_B+(480-NUM_ALIEN*32)/2;
	--elsif reverse = '0' then
		--alien_x <= alien_x + 1;
	--elsif reverse = '1' then
		--alien_x <= alien_x - 1;
	end if;
elsif cmd = STANDBY_CMD then
	alien_x <= alien_x;
	alien_y <= alien_y;
end if;

alien_y_coord <= to_integer(row) - alien_y;
alien_x_coord <= (to_integer(col) - alien_x)mod(NUM_MOD);
end process;

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
bullet_on <= '1' when row > to_unsigned(ship_bullet_y,10) and row <= to_unsigned(ship_bullet_y + 8,10)and 
				  col > to_unsigned(ship_bullet_x + 15,10) and col <= to_unsigned(ship_bullet_x + 17,10) else '0';

-- Get the x and y coordinates for alien rom


-- Reverse the direction of the aliens when they hit the bounds
--reverse <= '1' when alien_x+NUM_ALIEN*32= ALIEN_R_B else '0' when alien_x = ALIEN_L_B;

-- Check if coordinates are 0<= x <32 and 0<= y <32
alien_rom_valid <= '1' when (alien_y_coord >= 0 and alien_y_coord < 32) and 
				(alien_x_coord >= 0 and alien_x_coord < 32) else '0';


-- Update alien_rom_x and alien_rom_y if it is inside the ROM image
alien_rom_y <= std_logic_vector(to_unsigned(alien_y_coord,5)) when alien_rom_valid ='1' else "00000";
alien_rom_x <= alien_x_coord when alien_rom_valid ='1' else 0;


-- Valid size for the alien
alien_on <= '1' when row >= to_unsigned(alien_y, 10) and row <= to_unsigned(alien_y +32,10)and 
				  col >= to_unsigned(alien_x,10) and col <= to_unsigned(alien_x + (NUM_ALIEN-1)*NUM_MOD,10) else '0';

-- Count to determine which alien is hit
process (clk) is begin
if rising_edge(clk) and alien_x_coord = 0 then
	-- Counting the aliens
	--if alien_x_coord = 0 then
		count <= (count +1)mod(NUM_ALIEN-1);
	--end if;
end if;
end process;

-- Hit detection
hit <= '1' when (ship_bullet_x +2 >= alien_x-8+count*32) and (ship_bullet_x < alien_x+14+count*32) and 
				ship_bullet_y <= alien_y + 32 else '0';
				
-- Special effect when alien is hit
effect <= '1' when hit = '1' and row >= to_unsigned(alien_y, 10) and row <= to_unsigned(alien_y +32,10)and 
			 col >= to_unsigned(alien_x+count*32,10) and col <= to_unsigned(alien_x+32+count*32,10) else '0';

-- Output color
rgb <= "000000" when valid = '1' and effect = '1' and alien_on = '1' else
	   GREEN when valid ='1' and ship_on= '1' and read_data(rom_x)= '1' else 
	   WHITE when valid ='1' and bullet_on = '1' else
	   PINK when valid = '1' and alien_on= '1' and alien_read_data(alien_rom_x)= '1' else "000000";
end;
library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all; 

entity game_graphics_1v1 is
    port (
		clk : in std_logic;
		valid : in std_logic;
		row : in unsigned(9 downto 0);
		col : in unsigned(9 downto 0);
		cmd1 : in unsigned(3 downto 0);
		cmd2 : in unsigned(3 downto 0);
		status: out unsigned(2 downto 0);
		rgb : out std_logic_vector(5 downto 0)
    );
end entity;

architecture synth of game_graphics_1v1 is

component spaceship_graphics2 is
    port(
        wr_clk_i: in std_logic;
        rd_clk_i: in std_logic;
        wr_clk_en_i: in std_logic;
        rd_en_i: in std_logic;
        rd_clk_en_i: in std_logic;
        wr_en_i: in std_logic;
        wr_data_i: in std_logic_vector(31 downto 0);
        wr_addr_i: in std_logic_vector(4 downto 0);
        rd_addr_i: in std_logic_vector(4 downto 0);
        rd_data_o: out std_logic_vector(31 downto 0)
    );
end component;

component alien_graphics2 is
    port(
        wr_clk_i: in std_logic;
        rd_clk_i: in std_logic;
        wr_clk_en_i: in std_logic;
        rd_en_i: in std_logic;
        rd_clk_en_i: in std_logic;
        wr_en_i: in std_logic;
        wr_data_i: in std_logic_vector(31 downto 0);
        wr_addr_i: in std_logic_vector(4 downto 0);
        rd_addr_i: in std_logic_vector(4 downto 0);
        rd_data_o: out std_logic_vector(31 downto 0)
    );
end component;

component collision_check is
  port(
        clk : in std_logic;
        reset_game : in std_logic; -- add in externally in game graphics
        alien_bullet_on : in std_logic;
        ship_box_on : in std_logic; -- ship_on in game graphics
        ship_pixel_on : in std_logic; -- rom_on(rom_x) in game graphics
        endgame : out std_logic; -- have to check both endgames in game graphics
        lives : out integer range -3 to 10; 
		ship_hit : out std_logic
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

-- Ship boundaries
constant SHIP_TOP_B: integer := 432; 
constant SHIP_BOT_B: integer := 464;	
constant SHIP_R_B: integer := 560;
constant SHIP_L_B: integer := 80;

-- Alien boundaries
constant ALIEN_TOP_B: integer := 16;
constant ALIEN_BOT_B: integer := 48;
constant ALIEN_R_B: integer := 560;
constant ALIEN_L_B: integer := 80;

-- Lives counter
constant COUNTER_TOP_B: integer := 48; 
constant COUNTER_BOT_B: integer := 144;	
constant COUNTER_R_B: integer := 48;
constant COUNTER_L_B: integer := 16;

-- Row in dead space
constant UPDATE_ROW: integer := 500;

-- Distance ship travel per click
constant STEP: integer := 8;

-- Distance bullet travels
constant VELOCITY: integer := 12;

-- Commands from the controller
constant LEFT_CMD: integer := 1;
constant RIGHT_CMD: integer := 2;
constant UP_CMD: integer := 3;
constant DOWN_CMD: integer := 4;
constant A_CMD: integer := 5;
constant B_CMD: integer := 6;
constant START_CMD: integer := 7;
constant SELECT_CMD: integer := 8;
constant STANDBY_CMD: integer := 9;

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
constant BULLET_OFF: integer := -16;
signal ship_bullet_x: integer;
signal ship_bullet_y: integer;
signal ship_bullet_x2: integer;
signal ship_bullet_y2: integer;

signal alien_bullet_x: integer;
signal alien_bullet_y: integer;
signal alien_bullet_x2: integer;
signal alien_bullet_y2: integer;

-- alien location
signal alien_x : integer;

-- check if valid
signal rom_valid: std_logic;
signal alien_rom_valid: std_logic;
signal ship_on: std_logic;
signal alien_on: std_logic;
signal ship_lb, ship_rb: std_logic;
signal alien_lb, alien_rb: std_logic;
signal bullet_on: std_logic;
signal alien_bullet_on: std_logic;
signal s_a_bullet, s_b_bullet: std_logic;
signal beam1, beam2: std_logic;

-- output 32-bit words from ROM
signal read_data: std_logic_vector(31 downto 0);
signal alien_read_data: std_logic_vector(31 downto 0);

-- Status of both players
signal alive: unsigned(2 downto 0) := "010";

-- Hit Detection
signal reset_logic : std_logic;signal endgame : std_logic; 
signal ship_lives, alien_lives : integer range -3 to 10; 
signal ship_hit, alien_hit : std_logic; 

-- Life coutners
signal life_length: integer;
signal ship_health, red_health: std_logic;

signal alien_life_length: integer;
signal alien_health, alien_red_health: std_logic;

begin
	ship: spaceship_graphics2 port map(
		wr_clk_i=> clk,
		rd_clk_i=> clk,
		wr_clk_en_i=> '0',
		rd_en_i=> '1',
		rd_clk_en_i=> '1',
		wr_en_i=> '0',
		wr_data_i=> 32x"0",
		wr_addr_i=> 5x"0",
		rd_addr_i=> rom_y,
		rd_data_o=> read_data
	);
	
    alien: alien_graphics2 port map(
		wr_clk_i=> clk,
		rd_clk_i=> clk,
		wr_clk_en_i=> '0',
		rd_en_i=> '1',
		rd_clk_en_i=> '1',
		wr_en_i=> '0',
		wr_data_i=> 32x"0",
		wr_addr_i=> 5x"0",
		rd_addr_i=> alien_rom_y,
		rd_data_o=> alien_read_data
	);
	
	ship_collision: collision_check port map (
        clk => clk, 
        reset_game => reset_logic, -- add in externally in game graphics
        alien_bullet_on => alien_bullet_on, 
        ship_box_on => ship_on, -- ship_on in game graphics
        ship_pixel_on => read_data(rom_x), -- rom_on(rom_x) in game graphics
        endgame => endgame,  -- have to check both endgames in game graphics
        lives => ship_lives, 
		ship_hit => ship_hit
	);
	
	alien_collision: collision_check port map (
        clk => clk, 
        reset_game => reset_logic, -- add in externally in game graphics
        alien_bullet_on => bullet_on, 
        ship_box_on => alien_on, -- ship_on in game graphics
        ship_pixel_on => alien_read_data(alien_rom_x), -- rom_on(rom_x) in game graphics
        endgame => endgame,  -- have to check both endgames in game graphics
        lives => alien_lives, 
		ship_hit => alien_hit
	);
		
-----------------------------------------------------------------------------------------------SHIP
process (clk, cmd1) is begin

	-- Update display from ROM when in the dead zone and some inputs occurs
	if rising_edge(clk) and row = to_unsigned(UPDATE_ROW,10) and col = to_unsigned(650,10) then
		-- Make ship starts at the middle
		if cmd1 = START_CMD then
			ship_x <= START_X;
		-- Change ship's location when receives input
		elsif cmd1 = LEFT_CMD and ship_lb = '1' and ship_hit = '0' then
			ship_x <= ship_x - STEP;
		elsif cmd1 = RIGHT_CMD and ship_rb = '1' and ship_hit = '0' then
			ship_x <= ship_x + STEP;
		end if;
	-- Ship stay in one place if no inputs
	elsif cmd1 = STANDBY_CMD then
		ship_x <= ship_x;
	end if;
	
	-- end the reset signal after it's been sent
	if rising_edge(clk) then
		if cmd1 = START_CMD and cmd2 = START_CMD then
			reset_logic <= '1'; 
		else
			reset_logic <= '0';
		end if;
    end if;
	
	-- Update ship_bullet's location when in dead zone
	if rising_edge(clk) and row = to_unsigned(UPDATE_ROW,10) and col = to_unsigned(650,10) then
		-- Make ship shoot bullet when A is pressed
		if cmd1 = A_CMD and (ship_bullet_y < 0) and (ship_bullet_y2 < 0) and ship_lives > 0 and alien_lives > 0  then
			ship_bullet_y <= SHIP_TOP_B - 16;
			ship_bullet_x <= ship_x+15;
		-- Bullet travels upward until off screen
		elsif ship_bullet_y > -10 then
			ship_bullet_y <= ship_bullet_y - VELOCITY;
		else
			ship_bullet_y <= BULLET_OFF;
			ship_bullet_x <= BULLET_OFF;
		end if;
		
		-- Make ship shoot 3 bullet when B is pressed
		if cmd1 = B_CMD and (ship_bullet_y < 0) and ship_lives > 0 and alien_lives > 0 then
			ship_bullet_y2 <= SHIP_TOP_B;
			ship_bullet_x2 <= ship_x;
		-- Bullet travels upward until off screen
			ship_bullet_y2 <= ship_bullet_y2 - VELOCITY;
		else
			ship_bullet_y2 <= BULLET_OFF;
			ship_bullet_x2 <= -30;
		end if;	
	end if;

	-- Reset bullet
	if alien_hit = '1' then
		ship_bullet_y <= BULLET_OFF;
		ship_bullet_x <= BULLET_OFF;
	end if;
	
	-- Register for health length
	if rising_edge(clk) and row = to_unsigned(UPDATE_ROW,10) and col = to_unsigned(650,10) then
		life_length <= ship_lives;
	end if;
end process;

-------------------------------------------------------------------------------SHIP GRAPHICS LOGIC
-- Get the x and y coordinates for ship rom
y_coord <= to_integer(row) - SHIP_TOP_B;
x_coord <= to_integer(col) - ship_x;

-- Check if coordinates are 0<= x <32 and 0<= y <32
rom_valid <= '1' when (y_coord >= 0 and y_coord < 32) and 
				(x_coord >= 0 and x_coord < 32) else '0';

-- Update rom_y if it is inside the ROM image
rom_y <= std_logic_vector(to_unsigned(y_coord,5)) when rom_valid ='1' else "00000";
rom_x <= x_coord when rom_valid ='1' else 0;

-- Valid size for the ship
ship_on <= '1' when row >= to_unsigned(SHIP_TOP_B,10) and row <= to_unsigned(SHIP_BOT_B,10)and 
				  col >= to_unsigned(ship_x,10) and col <= to_unsigned(ship_x + 32,10) else '0';
				  
-- Valid boundary for the ship
ship_lb <= '1' when ship_x > SHIP_L_B else '0';
ship_rb <= '1' when ship_x+32 < SHIP_R_B else '0';

-- Valid size of the ship's bullet
bullet_on <= '1' when (row > to_unsigned(ship_bullet_y,10) and row <= to_unsigned(ship_bullet_y + 8,10) and
						col > to_unsigned(ship_bullet_x,10) and col <= to_unsigned(ship_bullet_x + 2,10)) or 
					  (row > to_unsigned(ship_bullet_y2+400,10) and row <= to_unsigned(SHIP_TOP_B,10)and 
					  ((col > to_unsigned(ship_bullet_x2+10,10) and col <= to_unsigned(ship_bullet_x2+12,10)) or 
					    (col > to_unsigned(ship_bullet_x2+20,10) and col <= to_unsigned(ship_bullet_x2 + 22,10)))) else '0';					

---------------------------------------------------------------------------------------------ALIEN
process (clk, cmd2) is begin

	-- Update display from ROM when in the dead zone and some inputs occurs
	if rising_edge(clk) and row = to_unsigned(UPDATE_ROW,10) and col = to_unsigned(660,10) then
		-- Make alien starts at the middle
		if cmd2 = START_CMD then
			alien_x <= START_X;
		-- Change alien's location when receives input
		elsif cmd2 = LEFT_CMD and alien_lb = '1' and ship_hit = '0' then
			alien_x <= alien_x - STEP;
		elsif cmd2 = RIGHT_CMD and alien_rb = '1' and ship_hit = '0' then
			alien_x <= alien_x + STEP;
		end if;
	-- Alien stay in one place if no inputs
	elsif cmd2 = STANDBY_CMD then
		alien_x <= alien_x;
	end if;
	
	-- Update alien's location when in dead zone
	if rising_edge(clk) and row = to_unsigned(UPDATE_ROW,10) and col = to_unsigned(650,10) then
		-- Make alien shoot bullet when A is pressed
		if cmd2 = A_CMD and  (alien_bullet_y > 480) and (alien_bullet_y2 > 524) and  ship_lives > 0 and alien_lives > 0  then
			alien_bullet_y <= ALIEN_BOT_B+8;
			alien_bullet_x <= alien_x+15;
		-- Bullet travels downward until off screen
		elsif alien_bullet_y < 490 then
			alien_bullet_y <= alien_bullet_y + VELOCITY;
		else
			alien_bullet_y <= 491;
			alien_bullet_x <= BULLET_OFF;
		end if;
	
		-- Make alien shoot a smaller, faster bullet when B is pressed
		if cmd2 = B_CMD and (alien_bullet_y > 480) and (alien_bullet_y2 > 524) and ship_lives > 0 and alien_lives > 0 then
			alien_bullet_y2 <= ALIEN_BOT_B+8;
			alien_bullet_x2 <= alien_x+15;
		-- Bullet travels downward until off screen
		elsif alien_bullet_y2 < 524 then
			alien_bullet_y2 <= alien_bullet_y2 + VELOCITY+8;
		else
			alien_bullet_y2 <= 525;
			alien_bullet_x2 <= BULLET_OFF;
		end if;
	end if;
	
	-- Reset bullet
	if ship_hit = '1' then
		alien_bullet_y <= 491;
		alien_bullet_x <= 670;
		alien_bullet_y2 <= 525;
		alien_bullet_x2 <= 670;
	end if; 	

	-- Register for health length
	if rising_edge(clk) and row = to_unsigned(UPDATE_ROW,10) and col = to_unsigned(650,10) then
			alien_life_length <= alien_lives;
	end if;
end process;

-------------------------------------------------------------------------------ALIEN GRAPHICS LOGIC
-- Get the x and y coordinates for alien ROM
alien_y_coord <= to_integer(row) - ALIEN_TOP_B;
alien_x_coord <= to_integer(col) - alien_x;

-- Check if coordinates are 0<= x <32 and 0<= y <32
alien_rom_valid <= '1' when (alien_y_coord >= 0 and alien_y_coord < 32) and 
				(alien_x_coord >= 0 and alien_x_coord < 32) else '0';

-- Update alien_rom_y if it is inside the ROM image
alien_rom_y <= std_logic_vector(to_unsigned(alien_y_coord,5)) when alien_rom_valid ='1' else "00000";
alien_rom_x <= alien_x_coord when alien_rom_valid ='1' else 0;

-- Valid size for the alien
alien_on <= '1' when row >= to_unsigned(ALIEN_TOP_B, 10) and row <= to_unsigned(ALIEN_BOT_B,10)and 
				  col >= to_unsigned(alien_x,10) and col <= to_unsigned(alien_x + 32,10) else '0';

-- Valid boundary for the alien
alien_lb <= '1' when alien_x > ALIEN_L_B else '0';
alien_rb <= '1' when alien_x+32 < ALIEN_R_B else '0';

-- Valid size of the alien's bullet
alien_bullet_on <= '1' when (row <= to_unsigned(alien_bullet_y,10) and row > to_unsigned(alien_bullet_y-8,10)and 
				  col > to_unsigned(alien_bullet_x,10) and col <= to_unsigned(alien_bullet_x + 2,10)) or
				  (row <= to_unsigned(alien_bullet_y2,10) and row > to_unsigned(alien_bullet_y2-8,10)and 
				  col > to_unsigned(alien_bullet_x2,10) and col <= to_unsigned(alien_bullet_x2 + 3,10)) else '0';

------------------------------------------------------------------------------------------------------EFFECTS
-- Ship health
ship_health <= '1' when row >= to_unsigned(SHIP_BOT_B+4,10) and row <= to_unsigned(SHIP_BOT_B+12,10)and 
				  col >= to_unsigned(ship_x,10) and col <= to_unsigned(ship_x + life_length*3,10) else '0';
red_health <= '1' when row >= to_unsigned(SHIP_BOT_B+4,10) and row <= to_unsigned(SHIP_BOT_B+12,10)and 
				  col >= to_unsigned(ship_x,10) and col <= to_unsigned(ship_x + 30,10) else '0';

-- Alien health
alien_health <= '1' when row >= to_unsigned(ALIEN_TOP_B-12,10) and row <= to_unsigned(ALIEN_TOP_B-4,10)and 
				  col >= to_unsigned(alien_x,10) and col <= to_unsigned(alien_x + alien_life_length*3,10) else '0';
-- Alien health
alien_red_health <= '1' when row >= to_unsigned(ALIEN_TOP_B-12,10) and row <= to_unsigned(ALIEN_TOP_B-4,10)and 
				  col >= to_unsigned(alien_x,10) and col <= to_unsigned(alien_x + 30,10) else '0';
------------------------------------------------------------------------------------------------------OUTPUTS
-- Output status
alive <= "010" when (ship_lives <= 0) else "011" when (alien_lives <= 0) else "001";
status <= alive;

-- Output color
rgb <= WHITE when valid = '1' and (col = SHIP_L_B or col = SHIP_R_B) else
	   GREEN when valid = '1' and ship_health = '1' else
	   GREEN when valid = '1' and alien_health = '1' else
	   RED when valid = '1' and red_health = '1' else
	   RED when valid = '1' and alien_red_health = '1' else
	   GREEN when valid = '1' and bullet_on = '1' else
	   YELLOW when valid = '1' and alien_bullet_on = '1' else
	   BLUE when valid = '1' and ship_on= '1' and read_data(rom_x)= '1' else
	   PINK when valid = '1' and alien_on= '1' and alien_read_data(alien_rom_x)= '1' else BLACK;
end;
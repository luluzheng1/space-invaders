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

component alien_graphics is
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

component alien_shooting_generator is 
    port (
	      gen_clk : in std_logic; 
	      input_x : in integer; 
	      input_y : in integer; 
	      row_one : in std_logic_vector(9 downto 0); 
	      row_two : in std_logic_vector(9 downto 0); 
	      row_three : in std_logic_vector(9 downto 0); 
	      output_x : out integer; 
	      output_y : out integer
    ); 
end component;

component collision_check_alien is
    port(
        clk : in std_logic;
        reset_game : in std_logic;
        ship_bullet_on : in std_logic;
        alien_box_on : in std_logic;
        alien_pixel_on : in std_logic;
        alien_x : in integer;
        alien_y : in integer;
        bullet_y : in unsigned(9 downto 0);
        bullet_x : in unsigned(9 downto 0);
        aliens_alive_row0 : in std_logic_vector(9 downto 0);
        aliens_alive_row1 : in std_logic_vector(9 downto 0);
        aliens_alive_row2 : in std_logic_vector(9 downto 0);
        aliens_updated_row0 : out std_logic_vector(9 downto 0);
        aliens_updated_row1 : out std_logic_vector(9 downto 0);
        aliens_updated_row2 : out std_logic_vector(9 downto 0);
        endgame : out std_logic;
		    alien_hit : out std_logic;
		    alien_activated : in std_logic
     );
end component;

component collision_check_ship is
    port(
        clk : in std_logic;
        reset_game : in std_logic;
        alien_bullet_on : in std_logic;
        ship_box_on : in std_logic;
        ship_pixel_on : in std_logic;
        endgame : out std_logic;
        lives : out integer range 0 to 2; 
		    ship_hit : out std_logic;
		    bullet_deactivated : in std_logic
    );
end component;

component alien_box_checker is 
    port (
	    clk : in std_logic; 
	    alien_x : in integer;
	    alien_y : in integer;
	    alien_box_on : in std_logic;
	    row : in unsigned(9 downto 0);
	    col : in unsigned(9 downto 0);
	    alien_on_x : out integer range 0 to 10;
	    alien_on_y : out integer range 0 to 3
    ); 
end component;

-- Colors
constant RED: std_logic_vector(5 downto 0) := "110000";
constant GREEN: std_logic_vector(5 downto 0) := "001100";
constant BLUE: std_logic_vector(5 downto 0) := "000011";
constant WHITE: std_logic_vector(5 downto 0) := "111111";
constant YELLOW: std_logic_vector(5 downto 0) := "111100";
constant BLACK: std_logic_vector(5 downto 0) := "000000";

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
constant STEP: integer := 8;
-- Distance bullet travels
constant VELOCITY: integer := 10;

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
signal ship_location: integer;

-- ship bullet location
signal ship_bullet_x: integer;
signal ship_bullet_y: integer;
signal bullet_location: integer;

-- alien location
signal alien_x : integer;
signal alien_y : integer;
signal reverse : std_logic := '0';

-- alien bullet location 
signal alien_bullet_x : integer;
signal alien_bullet_y : integer; 
signal alien_bullet_loc_x : integer; 
signal alien_bullet_loc_y : integer; 

-- array of which aliens are alive
signal aliens_alive_row0 : std_logic_vector(9 downto 0) := "1111111111";
signal aliens_alive_row1 : std_logic_vector(9 downto 0) := "1111111111";
signal aliens_alive_row2 : std_logic_vector(9 downto 0) := "1111111111";
signal aliens_alive_r0 : std_logic_vector(9 downto 0) := "1111111111";
signal aliens_alive_r1 : std_logic_vector(9 downto 0) := "1111111111";
signal aliens_alive_r2 : std_logic_vector(9 downto 0) := "1111111111";
signal alien_on_x : integer range 0 to 10;
signal alien_on_y : integer range 0 to 3;
signal alien_activated : std_logic := '1';

-- shooting alien location
signal alien_shooter_x : integer; 
signal alien_shooter_y : integer; 

-- check if valid
signal rom_valid: std_logic;
signal alien_rom_valid: std_logic;
signal ship_on: std_logic;
signal alien_on: std_logic;
signal ship_lb, ship_rb: std_logic;
signal bullet_on: std_logic;
signal alien_bullet_on: std_logic; 

-- hit detection for both alien and ship
signal lives : integer range 0 to 3;
signal reset_logic : std_logic;
signal endgame_win : std_logic;
signal endgame_lose : std_logic;
signal ship_hit : std_logic;
signal ship_hit_latch : std_logic;
signal alien_hit : std_logic; 
signal alien_hit_latch : std_logic;
signal bullet_deactivated : std_logic := '0';
signal during_hit : std_logic := '0';
signal during_hit_counter : unsigned(3 downto 0) := "0000";

-- output 32 bits word from rom
signal read_data: std_logic_vector(31 downto 0);
signal alien_read_data: std_logic_vector(31 downto 0);
signal rom_on:  std_logic_vector(31 downto 0);
signal alien_rom_on: std_logic_vector(31 downto 0);

-- Life coutners
signal life_length: integer;
signal ship_health, red_health: std_logic;

begin
ship: spaceship_graphics port map(
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
	
alien: alien_graphics port map(
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

shooting_alien : alien_shooting_generator port map(
	gen_clk => clk,
	input_x =>  alien_x, 
	input_y => alien_y, 
	row_one =>  aliens_alive_r0,
	row_two =>  aliens_alive_r1,
	row_three => aliens_alive_r2,
	output_x => alien_shooter_x, 
	output_y => alien_shooter_y
); 

collision_ship : collision_check_ship port map (
        clk => clk,
        reset_game => reset_logic,
        alien_bullet_on => alien_bullet_on,
        ship_box_on => ship_on,
        ship_pixel_on => rom_on(rom_x),
        endgame => endgame_lose,
        lives => lives,
		ship_hit => ship_hit,
		bullet_deactivated => bullet_deactivated
);

collision_alien : collision_check_alien port map (
        clk => clk,
        reset_game => reset_logic,
        ship_bullet_on => bullet_on,
        alien_box_on => alien_on,
        alien_pixel_on => alien_rom_on(alien_rom_x),
        alien_x => alien_x,
        alien_y => alien_y,
        bullet_y => row,
        bullet_x => col,
        aliens_alive_row0 => aliens_alive_row0,
        aliens_alive_row1 => aliens_alive_row1,
        aliens_alive_row2 => aliens_alive_row2,
        aliens_updated_row0 => aliens_alive_r0,
        aliens_updated_row1 => aliens_alive_r1,
        aliens_updated_row2 => aliens_alive_r2,
        endgame => endgame_win,
		alien_hit => alien_hit,
		alien_activated => alien_activated
    );

alien_finder : alien_box_checker port map (
		clk => clk,
		alien_x => alien_x,
		alien_y => alien_y,
		alien_box_on => alien_on,
		row => row,
		col => col,
		alien_on_x => alien_on_x,
		alien_on_y => alien_on_y
);
  
process (clk, cmd, ship_location, bullet_location, alien_x, alien_y, alien_bullet_loc_x, alien_bullet_loc_y) is begin
-- Update ship when in the dead zone and some inputs occurs
if rising_edge(clk) and row = to_unsigned(UPDATE_ROW,10) and col = to_unsigned(660,10) then
	if cmd = START_CMD then
	ship_location <= START_X; -- Make ship starts at the middle
	elsif cmd = LEFT_CMD and ship_lb = '1' and (endgame_lose = '0' and endgame_win = '0' and alien_activated = '0') then
	--elsif cmd = LEFT_CMD and ship_lb = '1' then
	ship_location <= ship_location - STEP; -- Change ship's location when receives input
	elsif cmd = RIGHT_CMD and ship_rb = '1' and (endgame_lose = '0' and endgame_win = '0' and alien_activated = '0') then
	--elsif cmd = RIGHT_CMD and ship_rb = '1' then
	ship_location <= ship_location + STEP;
	end if;
elsif cmd = STANDBY_CMD then
	ship_location <= ship_location; -- Ship stay in one place if no inputs
end if;

-- end the reset signal after it's been sent
if rising_edge(clk) then
	if cmd = START_CMD then
		reset_logic <= '1';
	else
		reset_logic <= '0';
	end if;
end if;

-- Update bullet when in the dead zone and some inputs occurs
if rising_edge(clk) and row = to_unsigned(UPDATE_ROW,10) and col = to_unsigned(670,10) then
	if alien_hit_latch = '1' then -- Check if an alien has been hit and make the bullet disappear
		bullet_location <= -16;
		ship_bullet_x <= -16;
		alien_hit_latch <= '0';
	elsif (cmd = A_CMD and bullet_location <= 0 and (endgame_lose = '0' and endgame_win = '0' and alien_activated = '0'))then
		--if cmd = A_CMD and bullet_location <= 0 then
		bullet_location <= SHIP_TOP_B - 16;
		ship_bullet_x <= ship_location;
	elsif bullet_location > 0 then
		bullet_location <= bullet_location - VELOCITY;
	elsif bullet_location <= 0 then
		bullet_location <= -16;
		ship_bullet_x <= -16;
	end if;
end if;

-- Update bullet when in the dead zone and some inputs occurs for the alien
if rising_edge(clk) and row = to_unsigned(UPDATE_ROW, 10) and col = to_unsigned(670, 10) then 
	if (cmd = START_CMD or alien_bullet_loc_y > 480) and (endgame_lose = '0' and endgame_win = '0' and alien_activated = '0') then 
		alien_bullet_loc_y <= alien_shooter_y + 16; 
		alien_bullet_loc_x <= alien_shooter_x;
		if bullet_deactivated = '1' then
			bullet_deactivated <= '0';
		end if;
	elsif ship_hit_latch = '1' then -- Check if an alien has been hit and make the bullet disappear
		alien_bullet_loc_y <= 500;
		ship_hit_latch <= '0';
		bullet_deactivated <= '1';
		during_hit <= '1';
		during_hit_counter <= "0000";
	elsif alien_bullet_loc_y <= 480  then 
		alien_bullet_loc_y <= alien_bullet_loc_y + VELOCITY; 
	elsif alien_bullet_loc_y > 480 then
		alien_bullet_loc_y <= 500; 
	end if; 
end if; 

-- Update aliens when in the dead zone and some inputs occurs for the alien
if rising_edge(clk) and row = to_unsigned(UPDATE_ROW,10) and col = to_unsigned(680,10) then
	if cmd = START_CMD then
		alien_y <= ALIEN_TOP_B;
		alien_x <= ALIEN_L_B; 
		alien_x <= ALIEN_L_B + 80;
	elsif reverse = '0' and (endgame_lose = '0' and endgame_win = '0' and alien_activated = '0') then
		alien_x <= alien_x + 1;
	elsif reverse = '1' and (endgame_lose = '0' and endgame_win = '0' and alien_activated = '0') then
		alien_x <= alien_x - 1;
	end if;
elsif cmd = STANDBY_CMD then
	alien_x <= alien_x;
	alien_y <= alien_y;
end if;


if rising_edge(clk) then
	rom_on <= read_data;
	-- Update rom_x if it is inside the ROM image
	rom_x <= x_coord when rom_valid ='1' else 0;

	-- Update alien_rom_x and alien_rom_y if it is inside the ROM image
	alien_rom_on <= alien_read_data;
	alien_rom_x <= alien_x_coord when alien_rom_valid ='1' else 0;
end if;

-- Detect when an alien/ship has been hit so the bullet can disappear
if rising_edge(clk) then
	if alien_hit = '1' then
		alien_hit_latch <= '1';
	end if;
	
	if ship_hit = '1' then
		ship_hit_latch <= '1';
	end if;
	
	if during_hit = '1' and row = to_unsigned(UPDATE_ROW,10) and col = to_unsigned(660,10) and during_hit_counter < "1111" then
		during_hit_counter <= during_hit_counter + 1;
	elsif during_hit = '1' and row = to_unsigned(UPDATE_ROW,10) and col = to_unsigned(660,10) and during_hit_counter = "1111" then
		during_hit <= '0';
		during_hit_counter <= "0000";
	end if;
	
	if cmd = START_CMD then
		during_hit_counter <= "0000";
	end if;
end if;

	-- Register for health length
	if rising_edge(clk) and row = to_unsigned(UPDATE_ROW,10) and col = to_unsigned(650,10) then
		life_length <= lives+1;
	end if;

end process;

-- Update rom_y if it is inside the ROM image
rom_y <= std_logic_vector(to_unsigned(y_coord,5)) when rom_valid ='1' else "00000";
   
-- Give ship_x the ship's stored location
ship_x <= ship_location;

-- Give bullet_y the ship's bullet stored location
ship_bullet_y <= bullet_location;

-- Give alien_bullet_y the alien's bullet stored location
alien_bullet_y <= alien_bullet_loc_y; 
alien_bullet_x <= alien_bullet_loc_x; 

-- Get the x and y coordinates for ship rom
y_coord <= to_integer(row) - SHIP_TOP_B;
x_coord <= to_integer(col) - ship_x;

-- Check if coordinates are 0<= x <32 and 0<= y <32
rom_valid <= '1' when (y_coord >= 0 and y_coord < 32) and 
(x_coord >= 0 and x_coord < 32) else '0';

-- Valid size for the ship
ship_on <= '1' when row >= to_unsigned(SHIP_TOP_B,10) and row <= to_unsigned(SHIP_BOT_B,10)and 
  col >= to_unsigned(ship_x,10) and col <= to_unsigned(ship_x + 32,10) else '0';

-- Valid boundary for the ship
ship_lb <= '1' when ship_x > SHIP_L_B else '0';
ship_rb <= '1' when ship_x+32 < SHIP_R_B else '0';

-- Valid size of the ship's bullet
bullet_on <= '1' when row >= to_unsigned(ship_bullet_y,10) and row <= to_unsigned(ship_bullet_y + 8,10)and 
  col >= to_unsigned(ship_bullet_x + 15,10) and col <= to_unsigned(ship_bullet_x + 17,10) else '0';
 
-- Valid size of the alien's bullet
alien_bullet_on <= '1' when row >= to_unsigned(alien_bullet_y,10) and row <= to_unsigned(alien_bullet_y + 8,10)and 
  col >= to_unsigned(alien_bullet_x + 15,10) and col <= to_unsigned(alien_bullet_x + 17,10) else '0';

-- Get the x and y coordinates for alien rom
alien_y_coord <= (to_integer(row) - alien_y)mod(32);
alien_x_coord <= (to_integer(col) - alien_x)mod(32);

reverse <= '1' when alien_x + 320= ALIEN_R_B else '0' when alien_x = ALIEN_L_B;

-- Check if coordinates are 0<= x <32 and 0<= y <32
alien_rom_valid <= '1' when (alien_y_coord >= 0 and alien_y_coord < 32) and 

(alien_x_coord >= 0 and alien_x_coord < 32) else '0';
    
-- Update alien_rom_x and alien_rom_y if it is inside the ROM image
alien_rom_y <= std_logic_vector(to_unsigned(alien_y_coord,5)) when alien_rom_valid ='1' else "00000";

-- Valid size for the alien
alien_on <= '1' when row >= to_unsigned(alien_y, 10) and row <= to_unsigned(alien_y +96,10)and 
  col >= to_unsigned(alien_x,10) and col <= to_unsigned(alien_x + 320,10) else '0';
  
-- Hit checking
alien_activated <= aliens_alive_row0(alien_on_x) when alien_on_y = 0 else
   aliens_alive_row1(alien_on_x) when alien_on_y = 1 else
   aliens_alive_row2(alien_on_x) when alien_on_y = 2 else
   '0';
   
aliens_alive_row0 <= aliens_alive_r0;
aliens_alive_row1 <= aliens_alive_r1;
aliens_alive_row2 <= aliens_alive_r2;

-- Ship health
ship_health <= '1' when row >= to_unsigned(SHIP_BOT_B+4,10) and row <= to_unsigned(SHIP_BOT_B+12,10)and 
				  col >= to_unsigned(ship_x,10) and col <= to_unsigned(ship_x + life_length*10,10) else '0';
red_health <= '1' when row >= to_unsigned(SHIP_BOT_B+4,10) and row <= to_unsigned(SHIP_BOT_B+12,10)and 
				  col >= to_unsigned(ship_x,10) and col <= to_unsigned(ship_x + 30,10) else '0';

-- Output color
rgb <=
   GREEN when valid = '1' and ship_health = '1' else
   RED when valid = '1' and red_health = '1' else
   GREEN when valid ='1' and ship_on= '1' and rom_on(rom_x)= '1' and endgame_lose = '0' and endgame_win = '0' else
   YELLOW when valid ='1' and ship_on= '1' and rom_on(rom_x)= '1' and endgame_lose = '0' and endgame_win = '1' else
   BLACK when valid ='1' and ship_on= '1' and rom_on(rom_x)= '1' and endgame_lose = '1' else
   BLACK when valid = '1' and alien_on = '1' and alien_rom_on(alien_rom_x) = '1' and alien_activated = '0' else
   RED when valid = '1' and alien_on= '1' and alien_rom_on(alien_rom_x)= '1' and alien_activated = '1' and endgame_lose = '0' else 
   YELLOW when valid = '1' and alien_on= '1' and alien_rom_on(alien_rom_x)= '1' and alien_activated = '1' and endgame_lose = '1' else 
   WHITE when valid ='1' and bullet_on = '1' else
   WHITE when valid = '1' and alien_bullet_on = '1' else "000000";
end;
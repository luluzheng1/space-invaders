library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity collision_checker is
  port(
        clk : in std_logic;
        bullet_on : in std_logic;
        bullet_x : in integer;
        bullet_y : in integer;
        target_on : in std_logic;
        target_x : in integer;
        target_y : in integer;
        target_off : out std_logic;
        lives : out integer range 0 to 3
  );
end collision_checker;

architecture synth of collision_checker is
        constant SHIP_TOP_B: integer := 432;

        signal state : integer range 0 to 31 := 0; --30 aliens
        signal lives_left : integer range 0 to 3 := 3;
        signal both_on : std_logic;
        signal within_x : std_logic;
        signal within_y : std_logic;

begin
process(clk) is begin
if rising_edge(clk) then

        if state = 0 then -- checking ship and alien bullet
                within_x <= '1' when ((bullet_x + 2 >= target_x) and (bullet_x <= target_x + 32) and (both_on = '1')) else '0';
                within_y <= '1' when ((bullet_y + 8 >= SHIP_TOP_B) and (both_on = '1')) else '0';
        elsif state > 0 then -- checking aliens and ship bullet
                within_x <= '1' when ((bullet_x + 2 >= target_x) and (bullet_x <= target_x + 32) and (both_on = '1')) else '0';
                within_y <= '1' when ((bullet_y <= target_y + 32) and (both_on = '1')) else '0';
        end if;

        target_off <= within_x and within_y;
        state <= 0 when (state = 31) else state + 1;

end if;
end process;

both_on <= '1' when (bullet_on = '1' and target_on = '1') else '0';
lives_left <= lives_left - 1 when ((state = 0) and (target_off = '1')) else lives_left;
lives <= lives_left;

end;
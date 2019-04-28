library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity random_num_gen is 
    port (
        clk : in std_logic; 
        reset : in std_logic;
        --enable : in std_logic;  
        count : out std_logic_vector(4 downto 0)
    ); 
end entity; 

architecture synth of random_num_gen is 
    signal random_temp : std_logic_vector(17 downto 0) := (0 => '1', others => '0'); 
    constant polynomial : std_logic_vector(0 to 17) := "100000010000000000"; 
begin 
    process (clk, reset)
        variable feedback : std_logic; 
    begin 
        feedback := random_temp(0); 
        for i in 1 to 17 loop
            feedback := feedback xor (random_temp(i) and polynomial(i)); 
            end loop; 
        if reset then 
            random_temp <= (0 => '1', others=> '0'); 
        elsif (rising_edge(clk)) then
                random_temp <= feedback & random_temp(17 downto 1); 
        end if; 
    end process; 
    count <= random_temp(9 downto 5); 
end; 
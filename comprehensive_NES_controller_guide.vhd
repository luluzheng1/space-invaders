-- COMPONENT DECLARATION

component NES_controller_top is
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



-- PORT MAP

NES_buttons : NES_controller_top
        port map (
        clk_full => inputclk,
        data => NES_data,

        latch => NES_latch,
        controller_clk => NES_controller_clk,

        A_p => a_button,
        start_p => resetbutton,
        left_p => leftbutton,
        right_p => rightbutton
        );
end component;


-- NOTES for top and using the NES controller ----------------

-- NES controller physical pin connections
        -- RED: Power (3.3 V)
        -- YELLOW: Ground
        -- BLUE: NES_controller_clk
        -- BLACK: NES_latch
        -- GREEN: NES_data

-- Remove all button ports from top and make them signals instead

-- Add ports to top:
        NES_data : in std_logic;
        NES_latch : out std_logic;
        NES_controller_clk : out std_logic;
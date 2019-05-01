library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all; 

entity top is 
    port ( 
		selector: in std_logic;
		NES_data1 : in std_logic;
		NES_data2 : in std_logic;
		NES_latch1 : out std_logic;
		NES_controller_clk1 : out std_logic;
		NES_latch2 : out std_logic;
		NES_controller_clk2 : out std_logic;
		HSYNC : out std_logic; 
		VSYNC : out std_logic;
		RGB : out std_logic_vector(5 downto 0) 
	); 
end entity;

architecture synth of top is

component HSOSC is
    generic ( 
    	CLKHF_DIV : String := "0b00"); -- Clock divider, see documentation for details 
    port( 
		CLKHFPU : in std_logic := 'X'; 
		CLKHFEN : in std_logic := 'X'; 
		CLKHF : out std_logic := 'X'
	); 
end component; 

component pllgen is 
	port( 
		outglobal_o: out std_logic; 
		outcore_o: out std_logic; 
		ref_clk_i: in std_logic; 
		rst_n_i: in std_logic
	); 
end component;

component vga is
	port ( 
		inputclk : in std_logic;
		valid: out std_logic; 
		out_row : out unsigned(9 downto 0);
		out_col :  out unsigned(9 downto 0);
		hsync : out std_logic;
		vsync : out std_logic
	); 
end component;

component Menu is
   port (
		clk : in std_logic;
		valid : in std_logic;
		row : in unsigned(9 downto 0);
		col : in unsigned(9 downto 0);
		cmd1 : in unsigned(3 downto 0);
		cmd2 : in unsigned(3 downto 0);
		selector : in std_logic;
		rgb : out std_logic_vector(5 downto 0)
   );
end component;

component buttons is 
    port (
		clk: in std_logic;
		row: in unsigned(9 downto 0);
		col: in unsigned(9 downto 0);
		leftbutton: in std_logic;
		rightbutton : in std_logic;
		resetbutton: in std_logic;
		a_button: in std_logic;
		b_button: in std_logic;
		up_button : in std_logic;
		down_button : in std_logic;
		command: out unsigned(3 downto 0)
	);	
end component;

component NES_controller_top is
	port(
		clk_full : in std_logic;
        data : in std_logic;
		latch : out std_logic;
		controller_clk : out std_logic;
		
		A_p : out std_logic;
		B_p : out std_logic;
		up_p : out std_logic;
		down_p : out std_logic;
		start_p : out std_logic;
		left_p : out std_logic;
		right_p : out std_logic
	);
end component;

signal inputclk: std_logic;
signal pixclk: std_logic;
signal pixvalid: std_logic;
signal pixrow: unsigned(9 downto 0);
signal pixcol: unsigned(9 downto 0);
signal OUTPUTWAVE: std_logic;
signal cmd1, cmd2: unsigned(3 downto 0);

-- Signals for NES
signal leftbutton1 : std_logic;
signal rightbutton1: std_logic;
signal resetbutton1: std_logic;
signal a_button1: std_logic;
signal b_button1: std_logic;
signal up_button1 : std_logic;
signal down_button1 : std_logic;

-- Signals for NES
signal leftbutton2 : std_logic;
signal rightbutton2: std_logic;
signal resetbutton2: std_logic;
signal a_button2: std_logic;
signal b_button2: std_logic;
signal up_button2 : std_logic;
signal down_button2 : std_logic;

begin 

    -- Instantiate the 48 MHz source clock 
    clkgen : HSOSC 
	port map (
		CLKHFPU => '1', -- Power up, 
		CLKHFEN => '1', -- Enable output 
		CLKHF => inputclk
    ); 
	
    -- Create a 25.175 MHz pixel clock 
    pll : pllgen 
    port map ( 
		outglobal_o=> pixclk,
		outcore_o=> OUTPUTWAVE, 
		ref_clk_i=> inputclk, 
		rst_n_i=> '1' 
    );

    -- Connect the VGA driver
    vgadriver : vga 
    port map ( 
		inputclk => pixclk,
		valid => pixvalid,
		out_row => pixrow, 
		out_col => pixcol, 
		hsync => HSYNC,
		vsync => VSYNC
    );

   -- Connnect the pattern generator
   mode: Menu 
   port map (
		clk => pixclk,
		valid => pixvalid,
		row => pixrow,
		col => pixcol,
		cmd1 => cmd1,
		cmd2 => cmd2,
		selector => selector,
		rgb => rgb
   );

  ---------------------------------------------Player 1

    -- Connect Controller 

	ship_NES_buttons : NES_controller_top
    port map (
		 clk_full => inputclk,
		 data => NES_data1,
		 latch => NES_latch1,
		 controller_clk => NES_controller_clk1,
		 A_p => a_button1,
		 B_p => b_button1,
		 up_p => up_button1,
		 down_p => down_button1,
		 start_p => resetbutton1,
		 left_p => leftbutton1,
		 right_p => rightbutton1
    );

   -- Connect the buttons
   ship_control: buttons 
   port map (
		clk => pixclk,
		row=> pixrow,
		col=> pixcol,
		leftbutton=> leftbutton1,
		rightbutton=> rightbutton1,
		resetbutton=> resetbutton1,
		a_button=> a_button1,
		b_button=> b_button1,
		up_button => up_button1,
		down_button => down_button1,
		command=> cmd1
	);	

	

	-------------------------------------------Player 2

	 -- Connect Controller 

	alien_NES_buttons : NES_controller_top
    port map (
		 clk_full => inputclk,
		 data => NES_data2,
		 latch => NES_latch2,
		 controller_clk => NES_controller_clk2,
		 A_p => a_button2,
		 B_p => b_button2,
		 up_p => up_button2,
		 down_p => down_button2,
		 start_p => resetbutton2,
		 left_p => leftbutton2,
		 right_p => rightbutton2
    );

   -- Connect the buttons
   alien_control: buttons 
   port map (
		clk => pixclk,
		row => pixrow,
		col => pixcol,
		leftbutton => leftbutton2,
		rightbutton => rightbutton2,
		resetbutton => resetbutton2,
		a_button => a_button2,
		b_button => b_button2,
		up_button => up_button2,
		down_button => down_button2,
		command => cmd2
	);

end;
library IEEE; use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all; 

entity top is 
    port ( 
	leftbutton : in std_logic;
	rightbutton: in std_logic;
	resetbutton: in std_logic;
	a_button: in std_logic;
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

component game_graphics is
   port (
	clk : in std_logic;
	valid : in std_logic;
	row : in unsigned(9 downto 0);
	col : in unsigned(9 downto 0);
	cmd : in unsigned(3 downto 0);
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
	command: out unsigned(3 downto 0)
	);	
end component;


signal inputclk: std_logic;
signal pixclk: std_logic;
signal pixvalid: std_logic;
signal pixrow: unsigned(9 downto 0);
signal pixcol: unsigned(9 downto 0);
signal OUTPUTWAVE: std_logic;
signal cmd: unsigned(3 downto 0);

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
    port map( 
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
   graphics: game_graphics
   port map (
	clk => pixclk,
	valid => pixvalid,
	row => pixrow,
	col => pixcol,
	cmd => cmd,
	rgb => RGB
   ); 
   
   -- Connect the buttons
    control: buttons 
	port map(
	clk => pixclk,
	row=> pixrow,
	col=> pixcol,
	leftbutton=> leftbutton,
	rightbutton=> rightbutton,
	resetbutton=> resetbutton,
	a_button=> a_button,
	command=> cmd
	);	
end;
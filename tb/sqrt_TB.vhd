library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;
entity TB is
    end entity;

architecture sqrt_TB of TB is
    signal reset   : std_logic ;
    signal clk     : std_logic ;
    signal start   : std_logic ;
    signal A       : std_logic ;
    signal result  : std_logic ; 
    signal finished: std_logic ;   
    begin 
    type table is array (natural range <>) of unsigned(NBITS-1 downto 0);
    constant test : table (0 to 4) := (3,15,127,4294967295) ;
    constant expected : table (0 to 4  ) :=(1,3,11,65535)   ;
    UUT : newton 
        port map () (
            reset   => 
            clk     =>
            start   =>
            A       =>
            result  =>
            finished=>
        )

    end sqrt_TB;


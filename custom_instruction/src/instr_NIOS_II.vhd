library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;
entity instruction is 
port (
        reset   : in std_logic                             ;
        clk     : in std_logic                             ;
        start   : in std_logic                             ;
        dataa   : in std_logic_vector (31 downto 0 )       ;
        datab   : in std_logic_vector (31 downto 0 )       ; 
        result  : out std_logic_vector (31 downto 0 )      ;
        done    : out std_logic                            
        );
end entity ;

architecture a1 of instruction is
    component it_sqrt is 
    generic(NBITS : integer := 32) ;
    port (
        reset   : in std_logic                             ;
        clk     : in std_logic                             ;
        start   : in std_logic                             ;
        A       : in std_logic_vector (2*NBITS-1 downto 0 );
        result  : out std_logic_vector (NBITS-1 downto 0 ) ;
        finished: out std_logic                            
        );
        end component;

    constant NBITS : integer := 16 ;


    begin
        sqrt : entity work.it_sqrt(a1) 
        generic map(NBITS =>NBITS)
        port map (
            reset   => reset,
            clk     => clk,
            start   => start,
            A       => dataa,
            result  => result,
            finished=> done
        );
end a1; 

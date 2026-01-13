library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;
entity alu is 
    generic(NBITS : integer := 32);
    port (
        E1   : in  std_logic_vector (NBITS downto 0);
        E2   : in  std_logic_vector (NBITS downto 0);
        sub  : in std_logic;
        RES  : out std_logic_vector (NBITS downto 0)
    );
end entity;
architecture a1 of alu is 
begin
    ADDER : process(E1,E2,sub)
    variable result : signed (NBITS downto 0);
    begin
        if (sub = '0') then 
            result := signed(E1) + signed(E2);
            RES <= std_logic_vector(result);
        else
            result := signed(E1) - signed(E2);
            RES <= std_logic_vector(result);
        end if ;
    end process;
end a1 ;
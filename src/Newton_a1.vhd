library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;
entity newton is
    generic(NBITS : integer := 32) 
    port (
        reset   : in std_logic                             ;
        clk     : in std_logic                             ;
        start   : in std_logic                             ;
        A       : in std_logic_vector (2*NBITS-1 downto 0 );
        result  : out std_logic_vector (NBITS-1 downto 0 ) ;
        finished: out std_logic                            
        )
end entity ;

architecture a1 of newton is 
type T_state  is (S_WAIT,S_INT,S_COMP,S_FIN);
signal state      : T_state;
signal X_reg      : unsigned (2*NBITS-1 downto 0 );
begin
    process(clk,rest) : FSM
    variable X_Next : unsigned (2*NBITS-1 downto 0);
    begin
        if (reset=0) then
            state      <= S_WAIT ; 
            X_reg      <= (others =>  0 );
            finished   <= 0 ;
        elsif (rising_edge(clk)) then
            case( state ) is
                when S_WAIT => if (start) then 
                                state <= S_INT ;
                                end if ;
                when S_INT  => X_reg <= to_unsigned(1,2*NBITS);      ;  
                               state <= S_COMP ;
                when S_COMP => X_Next := X_reg - (X_reg*X_reg-A)/2*X_reg;
                               if (X_reg = X_Next) then
                                    state <= S_FIN ; 
                               end if ;
                               X_reg <= X_Next;
                when S_FIN  => finished <=  1 ;
                               if (not(start)) then 
                                    finished <= 0 ;  
                                    state <= S_WAIT;
                               end if ;
                when others => (others =>  null) ;
            end case ;
        end if ;
    end process ;
    result <= X_reg(NBITS-1 downto 0);

end a1 ;
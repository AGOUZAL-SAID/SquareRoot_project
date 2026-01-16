library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;
entity sqrt_slave is
    generic(NBITS : integer := 16) ;
    port (
        reset              : in std_logic                             ;
        clk                : in std_logic                             ;
        -- avalon signals 
        write_av           : in std_logic;
        read_av            : in std_logic;
        wait_request_av    : out  std_logic;
        write_data_av      : in  std_logic_vector (2*NBITS-1 downto 0);
        read_data_av       : out  std_logic_vector (2*NBITS-1 downto 0)

        -- busrt_count :   out  std_logic_vector (2*NBITS-1 downto 0)
        );
end entity ;

architecture a1 of sqrt_slave is 
    component it_sqrt is
    generic (
        NBITS : integer := 16
    );
    port (
        reset    : in  std_logic;
        clk      : in  std_logic;
        start    : in  std_logic;
        A        : in  std_logic_vector(2*NBITS-1 downto 0);
        result   : out std_logic_vector(NBITS-1 downto 0);
        finished : out std_logic    
    );
    end component;
    type T_state  is (S_WAIT,S_WRITE);
    signal state   : T_state;
    signal start : std_logic ;
    signal finished : std_logic ;
    signal A        : std_logic_vector(2*NBITS-1 downto 0);
    signal result   : std_logic_vector (NBITS-1 downto 0 );
    
begin
    sqrt : entity work.it_sqrt(a1) 
    generic map(NBITS =>NBITS)
    port map (
        reset   => reset,
        clk     => clk,
        start   => start,
        A       => A,
        result  => result,
        finished=> finished
    );
    read_data_av <= std_logic_vector(resize(unsigned(result), 2*NBITS));
    wait_req : process( write_av,read_av,state )
    begin

        if (write_av ='1' and state = S_WRITE ) then
            wait_request_av <= '1';

        elsif (read_av ='1' and state = S_WRITE) then
            wait_request_av <= '1';
        else
            wait_request_av <= '0';
        end if ; 
    end process ; 


    fsm_avalon : process(clk,reset)
    begin
        if (reset='0') then
            state <= S_WAIT;
            start <= '0'; 
            A <=   ((2*NBITS-1) downto 0 => '0') ; 
        elsif (rising_edge(clk)) then
            case( state ) is
                when S_WAIT => if (write_av = '1') then 
                                    start <='1';
                                    A     <= write_data_av; 
                                    state <= S_WRITE;
                                    end if;
                when S_WRITE => if (finished = '1') then 
                                    state <= S_WAIT ;
                                    start <= '0';
                                    end if;               
                when others => null ;
            
            end case ;

        end if;
    end process ; 
end a1;
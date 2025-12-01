library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;



entity TB is
    generic(NBITS : integer := 32) ;
end entity;





architecture sqrt_TB of TB is

    component it_sqrt is
    generic (
        NBITS : integer := 32
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



    constant  N_test  : integer := 5;
    constant  PIPE_LINE  : integer := 1;
    signal reset   : std_logic   ;
    signal stop_sim: std_logic   ;
    signal clk     : std_logic :='0'   ;
    signal start   : std_logic   ;
    signal A       : std_logic_vector  (2*NBITS-1 downto 0 ) := x"0000000000000000" ;
    signal result  : std_logic_vector  (NBITS-1 downto 0 )   ; 
    signal finished: std_logic   ;   

    type table is array (natural range <>) of unsigned(2*NBITS-1 downto 0);                                                                  
    constant test : table (0 to N_test-1) := (to_unsigned(3,2*NBITS),to_unsigned(15,2*NBITS),to_unsigned(127,2*NBITS), x"00000000FFFFFFFF",x"FFFFFFFFFFFFFFFF" ) ;
    constant expected : table (0 to N_test-1) :=(to_unsigned(1,2*NBITS),to_unsigned(3,2*NBITS),to_unsigned(11,2*NBITS),to_unsigned(65535,2*NBITS), x"00000000FFFFFFFF" ) ;
    begin 
    UUT : entity work.it_sqrt(a3) 
        generic map(NBITS =>NBITS)
        port map (
            reset   => reset,
            clk     => clk,
            start   => start,
            A       => A,
            result  => result,
            finished=> finished
        );
    clk_gen : process
        begin
            wait for 1 ns ;
            clk <= not(clk);
            if (stop_sim = '1') then
                 wait;
            end if;
        end process;
    
    
    testing : process 
    begin
    wait until  (reset ='1');
    if (PIPE_LINE = 0) then
        for i in 0 to N_test-1 loop 
            start <='0';
            A <= std_logic_vector(test(i));
            wait on clk until  rising_edge(clk);

            start <= '1';

            wait  until (finished = '1');


            if (unsigned(result)= expected(i)) then 
                report "test number :" & integer'image(i) & " done succesfully" ;
                if (i=N_test-1) then 
                    stop_sim <= '1';
                end if ;

            else
                report "test number :" & integer'image(i) & " failed";
                if (i=N_test-1) then 
                    stop_sim <= '1';
                end if ;
            end if ;
        end loop;

    else
        for i in 0 to N_test-1 loop
            start <= '1';
            A <= std_logic_vector(test(i));
            wait  until  rising_edge(clk);
        end loop;
        if (finished = '1') then
            report "testage";
        end if;
        wait until finished = '1';
        for i in 0 to N_test-1 loop
            wait until  rising_edge(clk);
            if (unsigned(result)= expected(i)) then 
                report "test number :" & integer'image(i) & " done succesfully" ;
                if (i=N_test-1) then 
                    stop_sim <= '1';
                end if ;

            else
                report "test number :" & integer'image(i) & " failed";
                if (i=N_test-1) then 
                    stop_sim <= '1';
                end if ;
            end if ;
        end loop;
    end if ;
    end process;
    reset <= '0','1' after 30 ns;
end sqrt_TB;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SendCaps is
    port
    (
        clk         : in std_logic;                     -- clock 100 mhz
        res         : in std_logic;                     -- reset (high active)
        data        : in std_logic_vector(7 downto 0);  -- data
        data_ready  : in std_logic;                     -- data ready
        ser_out     : out std_logic;                    -- serial data (tx line)
        data_sent   : out std_logic
    );
end entity SendCaps;

architecture Behavioral of SendCaps is
type STATE_TYP is (INIT,START,TX0,TX1,TX2,TX3,TX4,TX5,TX6,TX7,STOP,COMPLETE);
signal STATE , NEXTSTATE : STATE_TYP;
signal enable : std_logic;    -- enable is the timer overflow for the communication set to c.a. 9600 Baud. 
signal resetcount : std_logic;-- reset count will decouple time for communication.
signal count : integer range 0 to 10416; 
begin


-- process to make a counter that overflows at 9600 baudrate. enable is the overflow bit. 
-- Reset count will be used to start the count from the start bit of Tx.
cntr : process(clk,res)
		begin
       
		if res='1' then
			count <= 0; 
		elsif rising_edge(clk) then

		enable <= '0';

			if resetcount = '1' then
			
				count <= 0;
				
			elsif count < 10416 then
			
				count <= count + 1;
		 
			else
			
     			count <= 0;
				enable <= '1';
			
			end if;
			
      end if;
end process cntr;		
		
-- State synchronous process - #1.
reg : process(clk,res)
		begin
  		if res='1' then
			STATE <= INIT; 
		elsif rising_edge(clk) then
			STATE <= NEXTSTATE;
		end if;
end process reg;		

-- state combinatorial process with outputs 
--(note: generally it is a good practice to write output as a separate process but 'C' got the better of me and the below resulted in a single process. Works but confusing.)
cmb : process(STATE,data_ready,enable)
      begin
		NEXTSTATE <= STATE;
		data_sent <= '0';
		resetcount <= '0';
		case STATE is 
        when INIT => ser_out <= '1';     -- protocol to keep serial Tx line always high.
				   if data_ready = '1' then
                     NEXTSTATE <= START;
						   resetcount <= '1';  -- the counting begins ;)
				   end if;
		when START => ser_out <= '0';   -- Protocol start bit is '0'
					if enable = '1' then
				     NEXTSTATE <= TX0;
				    end if;
	    when TX0  => ser_out <= data(0); 
				   if enable = '1' then
				     NEXTSTATE <= TX1;
				    end if;
		when TX1  => ser_out <= data(1); 
				   if enable = '1' then
				     NEXTSTATE <= TX2;
					end if;
		when TX2  => ser_out <= data(2); 
				   if enable = '1' then
				     NEXTSTATE <= TX3;
					end if;
		when TX3  => ser_out <= data(3); 
				   if enable = '1' then
				     NEXTSTATE <= TX4;
					end if;
		when TX4  => ser_out <= data(4); 
				   if enable = '1' then
				     NEXTSTATE <= TX5;
					end if;
		when TX5  => ser_out <= data(5); 
				   if enable = '1' then
				     NEXTSTATE <= TX6;
					end if;
		when TX6  => ser_out <= data(6); 
				   if enable = '1' then
				     NEXTSTATE <= TX7;
					end if;
		when TX7  => ser_out <= data(7); 
				   if enable = '1' then
				     NEXTSTATE <= STOP;
				   end if;
		when STOP => ser_out <= '1';
					if enable = '1' then
				     NEXTSTATE <= COMPLETE;
				    end if;
	    
		when COMPLETE => data_sent <= '1';  -- notify MC that the job is done.
				   if data_ready = '0' then   -- MC notifies the Hardware that it is safe to stop communicating.
					 NEXTSTATE <= INIT;			 -- roll back to initial to repeat again.
				   end if; 
		when others => NEXTSTATE <= INIT;
		end case;
end process cmb;		

end Behavioral;

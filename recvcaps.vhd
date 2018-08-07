library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RecvCaps is
    port
    (
        clk             : in  std_logic;                    -- clock 100 mhz
        res             : in  std_logic;                    -- reset (high active)
        serial_in       : in  std_logic;                    -- serial data (rx line)
        parallel_out    : out std_logic_vector(7 downto 0); -- data
        int_recv        : out std_logic;                    -- interrupt received
        int_ack         : in  std_logic                     -- interrupt acknowledge
    );
end entity RecvCaps;

architecture Behavioral of RecvCaps is
type STATE_TYP is (INIT,START,RX0,RX1,RX2,RX3,RX4,RX5,RX6,RX7,STOP,COMPLETE); -- state machine for the entire protocol.
signal STATE , NEXTSTATE : STATE_TYP; 
signal enable,resetcount : std_logic; -- reset count will decouple time for communication. Enable is the timer overflow for the communication set to c.a. 9600 Baud. 
signal midmeasure : std_logic;  -- this is for sampling at the middle - refer to the concurrent statement that follows.
signal count : integer range 0 to 10416;  -- set baud rate.
begin

-- process to make a counter that overflows at 9600 baudrate. enable is the overflow bit. 
-- Reset count will be used to start the count from the start bit of Rx.
cntr : process(clk,res)
		begin
       
		if res='1' then
			count <= 0;
			enable <= '0';
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

-- concurrent for sampling in the middle of the message timeline.
midmeasure <= '1' when count = 5208 else '0';

-- state combinatorial process with outputs 
--(note: generally it is a good practice to write output as a separate process but 'C' got the better of me and the below resulted in a single process. Works but confusing.)
cmb : process(STATE,int_ack,enable,midmeasure,serial_in)  
      begin
		NEXTSTATE <= STATE;
		int_recv <= '0';
		resetcount <= '0';
		case STATE is 
        when INIT => parallel_out <= x"00"; 
				   if serial_in = '0' then
                     NEXTSTATE <= START;
					      resetcount<='1';
				   end if;
		 when START => 
					if enable = '1' then
				     NEXTSTATE <= RX0;
				    end if;		   
	    when RX0  => 
		          if midmeasure = '1' then  
		            parallel_out(0)<=serial_in; 
				    end if;
					 
					 if enable = '1' then
				     NEXTSTATE <= RX1;
				    end if;
					
		when RX1  => 
		          if midmeasure = '1' then  
					 parallel_out(1)<=serial_in; 
			       end if;
					 
				    if enable = '1' then
				     NEXTSTATE <= RX2;
				  	 end if;
					
		when RX2  => if midmeasure = '1' then  
					     parallel_out(2)<=serial_in;
			          end if;
					  
				   if enable = '1' then
				     NEXTSTATE <= RX3;
					end if;
					
		when RX3  => 
		             if midmeasure = '1' then  
					     parallel_out(3)<=serial_in;
			          end if;
					 
				   if enable = '1' then
				     NEXTSTATE <= RX4;
					end if;
					
		when RX4  => if midmeasure = '1' then  
					 parallel_out(4)<=serial_in; 
			       end if; 
				   if enable = '1' then
				     NEXTSTATE <= RX5;
					end if;
					
		when RX5  => if midmeasure = '1' then  
					 parallel_out(5)<=serial_in; 
			       end if;
					 
				   if enable = '1' then
				     NEXTSTATE <= RX6;
					end if;
					
		when RX6  => if midmeasure = '1' then  
					 parallel_out(6)<=serial_in; 
			       end if;
					 
				   if enable = '1' then
				     NEXTSTATE <= RX7;
					end if;
					
		when RX7  => if midmeasure = '1' then  
					 parallel_out(7)<=serial_in; 
			       end if;
					 
				   if enable = '1' then
				     NEXTSTATE <= STOP;
				   end if;
					
		when STOP => if midmeasure = '1' and serial_in = '1' then   -- follows protocol to read active stop bit. 
				        NEXTSTATE <= COMPLETE;                        
						 elsif midmeasure = '1' and serial_in = '0' then
						  NEXTSTATE <=INIT;
						end if;
		when COMPLETE => int_recv <= '1';                           -- follows protocol to set interrupt pin until ack is set.
				          if  int_ack = '1' then
					         NEXTSTATE <= INIT;			 
				          end if; 
				   
		when others   => NEXTSTATE <= INIT;
		end case;
		
end process cmb;		

end Behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mppt is
    port (
        clk      : in  std_logic;
        reset    : in  std_logic; 
        enable   : in  std_logic; 
       
        -- Sensores
        v_curr     : in  unsigned(11 downto 0);
        p_curr     : in  unsigned(23 downto 0);
       
        -- Atuador
        duty_out   : out integer range 0 to 1000
    );
end entity;

architecture rtl of mppt is

    constant PWM_PERIOD : integer := 1000;
    constant STEP_SIZE  : integer := 2;
   
    signal duty_cycle : integer range 0 to PWM_PERIOD := 700;
    signal p_prev     : unsigned(23 downto 0) := (others => '0');
    signal v_prev     : unsigned(11 downto 0) := (others => '0');

begin

    duty_out <= duty_cycle;

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                -- Reset Síncrono
                duty_cycle <= 700;
                p_prev     <= (others => '0');
                v_prev     <= (others => '0');
               
            elsif enable = '1' then
                -- P&O Logic
                if p_curr > p_prev then
                    if v_curr > v_prev then
                        if duty_cycle > STEP_SIZE then
                            duty_cycle <= duty_cycle - STEP_SIZE;
                        end if;
                    else
                        if duty_cycle < (PWM_PERIOD - STEP_SIZE) then
                            duty_cycle <= duty_cycle + STEP_SIZE;
                        end if;
                    end if;
                elsif p_curr < p_prev then
                    if v_curr > v_prev then
                        if duty_cycle < (PWM_PERIOD - STEP_SIZE) then
                            duty_cycle <= duty_cycle + STEP_SIZE;
                        end if;
                    else
                        if duty_cycle > STEP_SIZE then
                            duty_cycle <= duty_cycle - STEP_SIZE;
                        end if;
                    end if;
                else
                    if duty_cycle < (PWM_PERIOD - STEP_SIZE) then
                        duty_cycle <= duty_cycle + STEP_SIZE;
                    end if;
                end if;
               
                -- Memory update
                p_prev <= p_curr;
                v_prev <= v_curr;
            end if;
        end if;
    end process;

end architecture;










library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pv is
    port (
        clk   : in  std_logic;
        key_input  : in  std_logic_vector(2 downto 0); 
        sw_load    : in  std_logic_vector(2 downto 0);
        duty_cycle : in  integer range 0 to 1000;
        v_pv_out   : out unsigned(11 downto 0);
        i_pv_out   : out unsigned(11 downto 0);
        power_out  : out unsigned(23 downto 0)
    );
end entity;

architecture rtl of pv is

    constant V_OC_MAX : integer := 2650;
    constant V_MPP    : integer := 2350;
   
    signal i_max_current : integer range 0 to 1000 := 500;
    signal R_LOAD        : integer range 0 to 1000 := 64;  
   
    signal v_pv_int : unsigned(11 downto 0);
    signal i_pv_int : unsigned(11 downto 0);

begin

    v_pv_out  <= v_pv_int;
    i_pv_out  <= i_pv_int;
    power_out <= v_pv_int * i_pv_int;

    process(clk)
    begin
        if rising_edge(clk) then
            if key_input(2) = '0' then i_max_current <= 250;
            elsif key_input(1) = '0' then i_max_current <= 375;
            elsif key_input(0) = '0' then i_max_current <= 500; end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if sw_load(2) = '1' then R_LOAD <= 10;  
            elsif sw_load(1) = '1' then R_LOAD <= 16;  
            elsif sw_load(0) = '1' then R_LOAD <= 64;  
            else R_LOAD <= 64; end if;
        end if;
    end process;

    process(clk)
        variable v_calc : integer;
        variable i_calc : integer;
        variable term_k : integer;
        variable temp_math : unsigned(63 downto 0);
    begin
        if rising_edge(clk) then

            term_k := 1000 - duty_cycle;
           
            temp_math := to_unsigned(i_max_current, 16) * to_unsigned(R_LOAD, 16) * to_unsigned(term_k, 16) * to_unsigned(term_k, 16);
            temp_math := temp_math / 1000000;
            v_calc := to_integer(temp_math(31 downto 0));

            -- Voltage Clamping 
            if v_calc > V_OC_MAX then v_calc := V_OC_MAX; end if;
            v_pv_int <= to_unsigned(v_calc, 12);

            if v_calc < V_MPP then
                i_pv_int <= to_unsigned(i_max_current, 12);
            elsif v_calc >= V_OC_MAX then
                i_pv_int <= (others => '0');
            else
                i_calc := i_max_current - (i_max_current * (v_calc - V_MPP) / 300);
                if i_calc < 0 then i_calc := 0; end if;
                i_pv_int <= to_unsigned(i_calc, 12);
            end if;
        end if;
    end process;

end architecture;








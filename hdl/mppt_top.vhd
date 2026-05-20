library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mppt_top is
    port (
        CLOCK_50   : in std_logic; -- 50MHz
        KEY        : in std_logic_vector(2 downto 0);
        SW         : in std_logic_vector(3 downto 0);
       
        pwm_out    : out std_logic;
        LEDR       : out std_logic_vector(9 downto 0);
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : out std_logic_vector(6 downto 0)
    );
end entity;

architecture rtl of mppt_top is

    component pv
        port (
            clk        : in std_logic;
            key_input  : in std_logic_vector(2 downto 0);
            sw_load    : in std_logic_vector(2 downto 0);
            duty_cycle : in integer range 0 to 1000;
            v_pv_out   : out unsigned(11 downto 0);
            i_pv_out   : out unsigned(11 downto 0);
            power_out  : out unsigned(23 downto 0)
        );
    end component;

    component mppt
        port (
            clk      : in std_logic;
            reset    : in std_logic;
            enable   : in std_logic;
            v_curr   : in unsigned(11 downto 0);
            p_curr   : in unsigned(23 downto 0);
            duty_out : out integer range 0 to 1000
        );
    end component;

    signal duty_wire   : integer range 0 to 1000;
    signal v_wire      : unsigned(11 downto 0);
    signal i_wire      : unsigned(11 downto 0);
    signal p_wire      : unsigned(23 downto 0);
   
    signal slow_clk_cnt : integer range 0 to 25000000 := 0;
    signal sample_en    : std_logic := '0';
    signal pwm_cnt      : integer range 0 to 1000 := 0;

    signal d_dig0, d_dig1, d_dig2, d_dig3 : integer range 0 to 9;
    signal p_dig0, p_dig1                 : integer range 0 to 9;

    function seg7_dec(digit : integer) return std_logic_vector is
        variable segments : std_logic_vector(6 downto 0);
    begin
        case digit is
            when 0 => segments := "1000000"; when 1 => segments := "1111001";
            when 2 => segments := "0100100"; when 3 => segments := "0110000";
            when 4 => segments := "0011001"; when 5 => segments := "0010010";
            when 6 => segments := "0000010"; when 7 => segments := "1111000";
            when 8 => segments := "0000000"; when 9 => segments := "0010000";
            when others => segments := "1111111";
        end case;
        return segments;
    end function;

begin

    u_pv : pv
    port map (
        clk        => CLOCK_50,
        key_input  => KEY,
        sw_load    => SW(2 downto 0),
        duty_cycle => duty_wire,
        v_pv_out   => v_wire,
        i_pv_out   => i_wire,
        power_out  => p_wire
    );

    u_mppt : mppt
    port map (
        clk        => CLOCK_50,
        reset      => SW(3),     
        enable     => sample_en,
        v_curr     => v_wire,
        p_curr     => p_wire,
        duty_out   => duty_wire
    );

    -- CLOCK GENERATOR (5 Hz = 5 steps per second)
    process(CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then
            if slow_clk_cnt >= 9999999 then
                slow_clk_cnt <= 0;
                sample_en <= '1';
            else
                slow_clk_cnt <= slow_clk_cnt + 1;
                sample_en <= '0';
            end if;
        end if;
    end process;

    -- PWM
    process(CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then
            if pwm_cnt < 999 then pwm_cnt <= pwm_cnt + 1; else pwm_cnt <= 0; end if;
            if pwm_cnt < duty_wire then pwm_out <= '1'; else pwm_out <= '0'; end if;
        end if;
    end process;

    LEDR <= std_logic_vector(to_unsigned(duty_wire, 10));

    process(CLOCK_50)
        variable p_scaled : integer;
    begin
        if rising_edge(CLOCK_50) then
            if sample_en = '1' or SW(3) = '1' then
                -- Separa dígitos do Duty
                d_dig0 <= duty_wire mod 10;
                d_dig1 <= (duty_wire / 10) mod 10;
                d_dig2 <= (duty_wire / 100) mod 10;
                d_dig3 <= (duty_wire / 1000);

                -- Separa dígitos da Potência
                p_scaled := to_integer(p_wire) / 10000;
                if p_scaled > 99 then p_scaled := 99; end if;
                p_dig0 <= p_scaled mod 10;
                p_dig1 <= (p_scaled / 10) mod 10;
            end if;
        end if;
    end process;

    HEX0 <= seg7_dec(d_dig0);
    HEX1 <= seg7_dec(d_dig1);
    HEX2 <= seg7_dec(d_dig2);
    HEX3 <= seg7_dec(d_dig3);
    HEX4 <= seg7_dec(p_dig0);
    HEX5 <= seg7_dec(p_dig1);

end architecture;

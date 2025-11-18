library ieee;
use ieee.std_logic_1164.all;

-- Testbench não possui portas, é uma entidade "fechada"
entity tb_FPMult_Wrapper is
end entity tb_FPMult_Wrapper;

architecture test of tb_FPMult_Wrapper is

    -- 1. Declarar o Componente que vamos testar (a sua UUT)
    component FPMult_32bit_Wrapper
        port (
            X_in  : in  std_logic_vector(31 downto 0);
            Y_in  : in  std_logic_vector(31 downto 0);
            R_out : out std_logic_vector(31 downto 0)
        );
    end component;

    -- 2. Sinais internos do testbench para conectar na UUT
    signal s_X_in  : std_logic_vector(31 downto 0) := (others => '0');
    signal s_Y_in  : std_logic_vector(31 downto 0) := (others => '0');
    signal s_R_out : std_logic_vector(31 downto 0);

    -- Constante para definir o "passo" da simulação
    constant STEP_TIME : time := 10 ns;

begin

    -- 3. Instanciar a UUT
    u_uut: FPMult_32bit_Wrapper
        port map (
            X_in  => s_X_in,
            Y_in  => s_Y_in,
            R_out => s_R_out
        );

    -- 4. Processo de Estímulo (onde os testes acontecem)
    stim_proc: process
    begin
        -- Os valores são 32-bit (8 dígitos hex) no padrão IEEE 754
        
        -- Teste 1: 2.0 * 3.0 = 6.0
        s_X_in <= x"40000000"; -- 2.0
        s_Y_in <= x"40400000"; -- 3.0
        wait for STEP_TIME;
        -- Resultado Esperado em s_R_out: x"40C00000" (6.0)

        -- Teste 2: 0.5 * 0.5 = 0.25
        s_X_in <= x"3F000000"; -- 0.5
        s_Y_in <= x"3F000000"; -- 0.5
        wait for STEP_TIME;
        -- Resultado Esperado em s_R_out: x"3E800000" (0.25)

        -- Teste 3: -4.0 * 5.0 = -20.0
        s_X_in <= x"C0800000"; -- -4.0
        s_Y_in <= x"40A00000"; -- 5.0
        wait for STEP_TIME;
        -- Resultado Esperado em s_R_out: x"C1A00000" (-20.0)

        -- Teste 4: 12.5 * -1.0 = -12.5
        s_X_in <= x"41480000"; -- 12.5
        s_Y_in <= x"BF800000"; -- -1.0
        wait for STEP_TIME;
        -- Resultado Esperado em s_R_out: x"C1480000" (-12.5)

        -- Teste 5: Multiplicação por Zero (10.0 * 0.0 = 0.0)
        s_X_in <= x"41200000"; -- 10.0
        s_Y_in <= x"00000000"; -- 0.0
        wait for STEP_TIME;
        -- Resultado Esperado em s_R_out: x"00000000" (0.0)

        -- Teste 6: Multiplicação por Infinito (5.0 * Inf = Inf)
        s_X_in <= x"40A00000"; -- 5.0
        s_Y_in <= x"7F800000"; -- +Infinito
        wait for STEP_TIME;
        -- Resultado Esperado em s_R_out: x"7F800000" (+Infinito)

        -- Teste 7: Multiplicação por NaN (10.0 * NaN = NaN)
        s_X_in <= x"41200000"; -- 10.0
        s_Y_in <= x"7FC00000"; -- NaN (Not a Number)
        wait for STEP_TIME;
        -- Resultado Esperado em s_R_out: x"7FC00000" (ou outro NaN)

        -- Teste 8: Operação Inválida (0.0 * Inf = NaN)
        s_X_in <= x"00000000"; -- 0.0
        s_Y_in <= x"7F800000"; -- +Infinito
        wait for STEP_TIME;
        -- Resultado Esperado em s_R_out: x"7FC00000" (ou outro NaN)

        -- Fim da simulação
        report "Simulacao concluida." severity failure; -- 'failure' força o fim
        wait;
        
    end process stim_proc;

end architecture test;
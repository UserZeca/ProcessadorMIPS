library ieee;
use ieee.std_logic_1164.all;

-- Testbench da ALU principal
entity tb_FP_ALU_Wrapper is
end entity tb_FP_ALU_Wrapper;

architecture test of tb_FP_ALU_Wrapper is

    -- 1. Declarar o Componente que vamos testar (a UUT)
    component FP_ALU_Wrapper
        port (
            X_in    : in  std_logic_vector(31 downto 0);
            Y_in    : in  std_logic_vector(31 downto 0);
            Op_sel  : in  std_logic; 
            R_out   : out std_logic_vector(31 downto 0)
        );
    end component;

    -- 2. Sinais internos do testbench para conectar na UUT
    signal s_X_in    : std_logic_vector(31 downto 0) := (others => '0');
    signal s_Y_in    : std_logic_vector(31 downto 0) := (others => '0');
    signal s_Op_sel  : std_logic := '0';
    signal s_R_out   : std_logic_vector(31 downto 0);

    -- Constante para definir o "passo" da simulação
    constant STEP_TIME : time := 10 ns;

begin

    -- 3. Instanciar a UUT
    u_uut: FP_ALU_Wrapper
        port map (
            X_in    => s_X_in,
            Y_in    => s_Y_in,
            Op_sel  => s_Op_sel,
            R_out   => s_R_out
        );

    -- 4. Processo de Estímulo (onde os testes acontecem)
    stim_proc: process
    begin
        report "Iniciando simulacao da FP_ALU..." severity note;
        
        -- Teste 1: SOMA (Op_sel = '0')
        -- 2.0 + 3.0 = 5.0
        s_X_in   <= x"40966666"; -- 4.7
        s_Y_in   <= x"40400000"; -- 3.0
        s_Op_sel <= '0';         -- '0' = SOMA
        wait for STEP_TIME;
        -- Resultado Esperado em s_R_out: x"40F66666" (7.7)

        -- Teste 2: MULTIPLICAÇÃO (Op_sel = '1')
        -- 2.0 * 3.0 = 6.0 (usando as mesmas entradas)
        s_X_in   <= x"40966666"; -- 4.7
        s_Y_in   <= x"40400000"; -- 3.0
        s_Op_sel <= '1';         -- '1' = MULT
        wait for STEP_TIME;
        -- Resultado Esperado em s_R_out: x"4161999A" (14.1)

        -- Teste 3: SOMA (Op_sel = '0')
        -- Cancelamento: 10.0 + (-10.0) = 0.0
        s_X_in   <= x"41200000"; -- 10.0
        s_Y_in   <= x"C1200000"; -- -10.0
        s_Op_sel <= '0';         -- '0' = SOMA
        wait for STEP_TIME;
        -- Resultado Esperado em s_R_out: x"00000000" (0.0)
        
        -- Teste 4: MULTIPLICAÇÃO (Op_sel = '1')
        -- 10.0 * (-10.0) = -100.0
        s_X_in   <= x"41200000"; -- 10.0
        s_Y_in   <= x"C1200000"; -- -10.0
        s_Op_sel <= '1';         -- '1' = MULT
        wait for STEP_TIME;
        -- Resultado Esperado em s_R_out: x"C2C80000" (-100.0)

        -- Teste 5: MULTIPLICAÇÃO (Op_sel = '1')
        -- 0.5 * 0.5 = 0.25
        s_X_in   <= x"3F000000"; -- 0.5
        s_Y_in   <= x"3F000000"; -- 0.5
        s_Op_sel <= '1';         -- '1' = MULT
        wait for STEP_TIME;
        -- Resultado Esperado em s_R_out: x"3E800000" (0.25)
        
        -- Teste 6: SOMA (Op_sel = '0')
        -- 0.5 + 0.5 = 1.0
        s_X_in   <= x"3F000000"; -- 0.5
        s_Y_in   <= x"3F000000"; -- 0.5
        s_Op_sel <= '0';         -- '0' = SOMA
        wait for STEP_TIME;
        -- Resultado Esperado em s_R_out: x"3F800000" (1.0)
        
        -- Fim da simulação
        report "Simulacao (ALU) concluida." severity note;
        wait;
        
    end process stim_proc;

end architecture test;
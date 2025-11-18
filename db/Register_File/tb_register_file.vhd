library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; -- Para usar 'to_unsigned'

-- Linha 5
entity tb_register_file is
end entity tb_register_file;

-- Linha 9
architecture register_file of tb_register_file is

  -- Constante para o período do clock (ex: 10 ns)
  constant CLK_PERIOD : time := 10 ns;

  -- Sinais para conectar ao nosso Register File
  signal s_Clock     : std_logic := '0';
  signal s_RegWrite  : std_logic := '0';
  signal s_ReadReg1  : std_logic_vector(4 downto 0) := (others => '0');
  signal s_ReadReg2  : std_logic_vector(4 downto 0) := (others => '0');
  signal s_WriteReg  : std_logic_vector(4 downto 0) := (others => '0');
  signal s_WriteData : std_logic_vector(31 downto 0) := (others => '0');
  signal s_ReadData1 : std_logic_vector(31 downto 0);
  signal s_ReadData2 : std_logic_vector(31 downto 0);

begin

  -- 1. Instanciar o Device Under Test (DUT)
  DUT : entity work.register_file
    port map (
      Clock     => s_Clock,
      RegWrite  => s_RegWrite,
      ReadReg1  => s_ReadReg1,
      ReadReg2  => s_ReadReg2,
      WriteReg  => s_WriteReg,
      WriteData => s_WriteData,
      ReadData1 => s_ReadData1,
      ReadData2 => s_ReadData2
    );

  -- 2. Processo de Geração de Clock
  clock_process : process
  begin
    s_Clock <= '0';
    wait for CLK_PERIOD / 2;
    s_Clock <= '1';
    wait for CLK_PERIOD / 2;
  end process clock_process;
  
  -- 3. Processo de Estímulo (Testes)
  stimulus_process : process
  begin
    
    -- Teste 1: Escrever 123 no registrador $t0 (reg 8)
    wait until rising_edge(s_Clock); -- Espera o início do próximo ciclo
    s_RegWrite  <= '1';
    s_WriteReg  <= std_logic_vector(to_unsigned(8, 5)); -- Endereço 8 ($t0)
    s_WriteData <= std_logic_vector(to_unsigned(123, 32)); -- Valor 123
    
    -- Teste 2: Escrever 456 no registrador $t1 (reg 9)
    wait until rising_edge(s_Clock); -- No próximo ciclo...
    s_RegWrite  <= '1';
    s_WriteReg  <= std_logic_vector(to_unsigned(9, 5)); -- Endereço 9 ($t1)
    s_WriteData <= std_logic_vector(to_unsigned(456, 32)); -- Valor 456

    -- Teste 3: Tentar escrever 999 no registrador $zero (reg 0)
    wait until rising_edge(s_Clock);
    s_RegWrite  <= '1';
    s_WriteReg  <= "00000"; -- Endereço 0 ($zero)
    s_WriteData <= std_logic_vector(to_unsigned(999, 32)); -- Valor 999
    
    -- Teste 4: Ler $t0 (8) e $t1 (9). Desliga a escrita.
    wait until rising_edge(s_Clock);
    s_RegWrite  <= '0'; -- Desliga a escrita
    s_ReadReg1  <= std_logic_vector(to_unsigned(8, 5)); -- Ler $t0
    s_ReadReg2  <= std_logic_vector(to_unsigned(9, 5)); -- Ler $t1
    
    -- Resultado esperado: s_ReadData1 = 123, s_ReadData2 = 456
    
    wait for 10 ns; -- Espera um pouco para ver a saída se propagar
    
    -- Teste 5: Ler $zero (0) e $t0 (8)
    s_ReadReg1  <= "00000"; -- Ler $zero
    s_ReadReg2  <= std_logic_vector(to_unsigned(8, 5)); -- Ler $t0
    
    -- Resultado esperado: s_ReadData1 = 0 (teste do $zero), s_ReadData2 = 123

    wait; -- Para a simulação
  end process stimulus_process;

end architecture register_file;
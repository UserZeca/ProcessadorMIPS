library ieee;
use ieee.std_logic_1164.all;

-- Testbench simples para a Unidade de Controle (Final, com LUI, BNE, etc.)
entity tb_Control_Unit is
end entity tb_Control_Unit;

architecture test of tb_Control_Unit is

    -- 1. Declarar o Componente que vamos testar (a UUT)
    component Control_Unit
        port (
            Opcode : in  std_logic_vector(5 downto 0);
            Funct  : in  std_logic_vector(5 downto 0);
            
            -- Saídas de Controle
            RegWrite      : out std_logic;
            FP_RegWrite   : out std_logic;
            RegDst        : out std_logic;
            Branch        : out std_logic;
            Branch_Cond   : out std_logic; -- Novo
            Jump          : out std_logic;
            MemWrite      : out std_logic;
            MemRead       : out std_logic;
            ALUSrc        : out std_logic;
            ALU_Sel       : out std_logic_vector(3 downto 0);
            FP_Op_Sel     : out std_logic;
            WriteBack_Sel : out std_logic_vector(1 downto 0) 
        );
    end component;

    -- 2. Sinais internos do testbench
    
    -- Entradas
    signal s_Opcode : std_logic_vector(5 downto 0) := "000000";
    signal s_Funct  : std_logic_vector(5 downto 0) := "000000";

    -- Saídas
    signal s_RegWrite      : std_logic;
    signal s_FP_RegWrite   : std_logic;
    signal s_RegDst        : std_logic;
    signal s_Branch        : std_logic;
    signal s_Branch_Cond   : std_logic; -- Novo
    signal s_Jump          : std_logic;
    signal s_MemWrite      : std_logic;
    signal s_MemRead       : std_logic;
    signal s_ALUSrc        : std_logic;
    signal s_ALU_Sel       : std_logic_vector(3 downto 0);
    signal s_FP_Op_Sel     : std_logic;
    signal s_WriteBack_Sel : std_logic_vector(1 downto 0);

    -- Constante para definir o "passo" da simulação
    constant STEP_TIME : time := 10 ns;

begin

    -- 3. Instanciar a UUT
    u_uut: Control_Unit
        port map (
            Opcode => s_Opcode,
            Funct  => s_Funct,
            
            RegWrite      => s_RegWrite,
            FP_RegWrite   => s_FP_RegWrite,
            RegDst        => s_RegDst,
            Branch        => s_Branch,
            Branch_Cond   => s_Branch_Cond, -- Novo
            Jump          => s_Jump,
            MemWrite      => s_MemWrite,
            MemRead       => s_MemRead,
            ALUSrc        => s_ALUSrc,
            ALU_Sel       => s_ALU_Sel,
            FP_Op_Sel     => s_FP_Op_Sel,
            WriteBack_Sel => s_WriteBack_Sel
        );

    -- 4. Processo de Estímulo
    stim_proc: process
    begin
        report "Iniciando simulacao (Control_Unit Final)..." severity note;
        
        -- Teste 1: TIPO-R (add)
        s_Opcode <= "000000"; s_Funct  <= "100000";
        wait for STEP_TIME;
        -- Esperado: RegWrite='1', RegDst='1', ALUSrc='0', ALU_Sel="0010", WriteBack_Sel="00"

        -- Teste 2: TIPO-I (lw)
        s_Opcode <= "100011"; s_Funct  <= "XXXXXX";
        wait for STEP_TIME;
        -- Esperado: RegWrite='1', ALUSrc='1', MemRead='1', ALU_Sel="0010", WriteBack_Sel="01"

        -- Teste 3: TIPO-I (sw)
        s_Opcode <= "101011";
        wait for STEP_TIME;
        -- Esperado: MemWrite='1', ALUSrc='1', ALU_Sel="0010"

        -- Teste 4: TIPO-I (beq)
        s_Opcode <= "000100";
        wait for STEP_TIME;
        -- Esperado: Branch='1', Branch_Cond='0', ALUSrc='0', ALU_Sel="0110"
        
        -- Teste 5: TIPO-J (jump)
        s_Opcode <= "000010";
        wait for STEP_TIME;
        -- Esperado: Jump='1'

        -- Teste 6: PONTO FLUTUANTE (add.s)
        s_Opcode <= "010001"; s_Funct  <= "000000";
        wait for STEP_TIME;
        -- Esperado: FP_RegWrite='1', RegDst='1', FP_Op_Sel='0', WriteBack_Sel="10"

        -- Teste 7: PONTO FLUTUANTE (mul.s)
        s_Opcode <= "010001"; s_Funct  <= "000010";
        wait for STEP_TIME;
        -- Esperado: FP_RegWrite='1', RegDst='1', FP_Op_Sel='1', WriteBack_Sel="10"

        -- Teste 8: PONTO FLUTUANTE (l.s / lwc1)
        s_Opcode <= "110001"; s_Funct  <= "XXXXXX";
        wait for STEP_TIME;
        -- Esperado: FP_RegWrite='1', RegDst='0', ALUSrc='1', MemRead='1', ALU_Sel="0010", WriteBack_Sel="01"

        -- ==========================================================
        -- === NOVOS TESTES ===
        -- ==========================================================

        -- Teste 9: TIPO-I (lui - Load Upper Immediate)
        s_Opcode <= "001111";
        wait for STEP_TIME;
        -- Esperado: RegWrite='1', RegDst='0', WriteBack_Sel="11"

        -- Teste 10: TIPO-I (ori - OR Immediate)
        s_Opcode <= "001101";
        wait for STEP_TIME;
        -- Esperado: RegWrite='1', RegDst='0', ALUSrc='1', ALU_Sel="0001", WriteBack_Sel="00"

        -- Teste 11: TIPO-I (andi - AND Immediate)
        s_Opcode <= "001100";
        wait for STEP_TIME;
        -- Esperado: RegWrite='1', RegDst='0', ALUSrc='1', ALU_Sel="0000", WriteBack_Sel="00"

        -- Teste 12: TIPO-I (bne - Branch on Not Equal)
        s_Opcode <= "000101";
        wait for STEP_TIME;
        -- Esperado: Branch='1', Branch_Cond='1', ALUSrc='0', ALU_Sel="0110"

        -- ==========================================================
        
        -- Teste 13: NOP (Instrução desconhecida)
        s_Opcode <= "111111"; s_Funct  <= "111111";
        wait for STEP_TIME;
        -- Esperado: Todos os sinais de controle '0' (ou 'X' / 'Z' onde for 'don't care')
        
        -- Fim da simulação
        report "Simulacao (Control_Unit Final) concluida." severity note;
        wait;
        
    end process stim_proc;

end architecture test;
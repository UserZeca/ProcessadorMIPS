# Trabalho de Arquitetura e Organização de Computadores

Esse trabalho tem como objetivo principal o projeto e a implementação de um processador MIPS de 32 bits.

O processador conta com um Instruction Set Architecture (ISA) customizado e estendido. O foco desta extensão é a integração de uma Unidade Lógica Aritmética (ULA) de Ponto Flutuante de 32 bits, proveniente do projeto FloPoCo.

O desenvolvimento e a simulação do processador foram realizados utilizando o Quartus II e o ModelSim.

## Detalhes teóricos

### FPU

A Unidade de Ponto Flutuante (FPU) gerada pelo FloPoCo utiliza um formato interno estendido de 34 bits para representar números, em vez do padrão IEEE-754 de 32 bits.

Este formato é composto pelos 32 bits numéricos padrão mais 2 bits de exceção (exn). Estes bits extras são usados para sinalizar explicitamente casos excepcionais:

00: Número normal ou subnormal

01: Zero

10: Infinito (Infinity)

11: NaN (Not a Number)

Vantagens do Formato Estendido
O uso deste formato interno de 34 bits traz vantagens significativas, especialmente em FPGAs:

Simplificação da Lógica de Exceção: Ter os bits de exceção separados permite que o hardware da ULA trate esses casos de forma mais direta e eficiente, resultando em comparadores e lógica mais simples, em vez de verificar combinações complexas no expoente e na mantissa (como exige o IEEE-754).

Melhor Precisão Intermediária: O FloPoCo utiliza bits de guarda (guard bits) e precisão interna ligeiramente maior durante os cálculos. Isso garante que o arredondamento final para 32 bits esteja correto até o último bit (last-bit accuracy).

Otimização para FPGAs: O FloPoCo é um gerador de cores focado em otimizar a relação precisão/área/frequência em FPGAs. Um formato intermediário estendido pode resultar em uma implementação VHDL/Verilog mais otimizada para os building blocks do FPGA.

Conversão para 32 bits
Como o formato de 34 bits é interno do FloPoCo, é necessária uma etapa de conversão na saída da FPU. Esta conversão combina os 2 bits de exceção (exn) com os 32 bits numéricos para gerar o padrão final de 32 bits IEEE-754, garantindo a interoperabilidade com outros componentes do processador.

## Execução do Código

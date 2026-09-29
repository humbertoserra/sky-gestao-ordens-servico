# SKY — Gestão de Ordens de Serviço

Projeto desenvolvido para a prova técnica de Desenvolvedor Delphi 2026.

## Objetivo

Gerenciar clientes, ordens de serviço e seus itens, com pesquisa,
totalização automática, identificação de atrasos e relatório gerencial.

Este README registra as decisões aprovadas. Não significa que todas
as funcionalidades descritas já estejam implementadas.

## Tecnologias

- Delphi 13 Community Edition - Ambiente disponível para desenvolvimento. 
- VCL - Interface desktop para Windows. 
- Win32 - Plataforma escolhida para esta implementação. 
- Firebird 2.5.9 - Versão definida para o projeto, instalada localmente. 
- FireDAC - Componentes disponíveis e preferidos pelo enunciado. 
- ADO via MSDASQL - Implementação alternativa de acesso ao Firebird, com teste de conexão realizado com sucesso.
- Driver ODBC Firebird/InterBase(r) 2.0.5.156 (32 bits) - Instalado no Windows para a conexão ADO em Win32.
- Relatórios - Componente ainda em avaliação, priorizando uma alternativa sem custo. 

A implementação atual será exclusivamente em Delphi 13.
Uma eventual versão Delphi 7 será tratada separadamente.

## Teste de conexão FireDAC

Foi realizado teste de abertura da conexão FireDAC com o banco SKY.FDB.
O teste retornou `[FireDAC][Phys][FB] bad parameters on attach or create database`,
indicando que o caminho do banco não era um CHARACTER SET definido.

A análise identificou que o método `TModelConfiguracaoFiredac.Charset`
retornava `FBanco` em vez de `FCharset`. Assim, o caminho do arquivo FDB era
enviado ao parâmetro `CharacterSet`, embora o INI contivesse `CHARSET=UTF8`.

Foi orientada a correção do retorno para `FCharset`, seguida de recompilação
e reinício da aplicação. O sucesso da conexão FireDAC após essa correção
ainda não foi confirmado pelo desenvolvedor nesta documentação.

O desenvolvedor informou sucesso nos testes de charset UTF8 pelo isql.
Esse resultado é separado do teste de conexão da aplicação. O erro FireDAC
identificado não exige mudança do charset do banco nem instalação de ODBC.

## Preparação do acesso ADO via ODBC (Win32)

A implementação ADO utiliza MSDASQL e o driver ODBC Firebird, com conexão
sem DSN. O driver é instalado no Windows, não na paleta do Delphi.

1. Na [página oficial do driver ODBC](https://www.firebirdsql.org/en/odbc-driver/),
   localize a versão 2.0.5 e baixe `Firebird_ODBC_2.0.5.156_Win32.exe`.
   O driver 3.0 não aceita a biblioteca cliente do Firebird 2.5.
2. Execute o instalador, aceite a elevação do Windows quando solicitada
   e conclua o assistente mantendo a pasta padrão.
3. Disponibilize a `fbclient.dll` do Firebird 2.5 de 32 bits na pasta do
   executável, junto das dependências exigidas pelo pacote cliente oficial.
   Não use a DLL de 64 bits com o executável Win32.
4. No Windows de 64 bits, abra pelo Win+R:
   `%windir%\SysWOW64\odbcad32.exe`.
5. Na aba **Drivers**, confirme `Firebird/InterBase(r) driver`.
   Não é necessário criar uma fonte de dados (DSN): o código informa
   `DRIVER`, banco, usuário, senha, charset e dialeto diretamente.
6. Confirme a plataforma Win32 no Delphi e o `config.ini` na pasta do
   executável, com servidor, caminho do banco no servidor, credenciais,
   `CHARSET=UTF8` e `DIALECT=3`. Não versione credenciais reais.
7. Reinicie a aplicação e repita o teste ADO. A instalação e a conexão
   somente estarão validadas após esse teste retornar sucesso.

O driver ODBC e a biblioteca cliente devem corresponder à arquitetura da
aplicação, mesmo quando o servidor Firebird utiliza outra arquitetura.
Referência: [manual oficial ODBC 2.0](https://www.firebirdsql.org/file/documentation/html/en/refdocs/fbodbc20/firebird-odbc-driver-20-manual.html).

Resultado do teste ADO:

- Inicialmente, a conexão retornou "Nome de fonte de dados não encontrado
  e nenhum driver padrão especificado"; o driver Firebird não constava
  na lista apresentada.
- Após a instalação, foi confirmada por captura a presença de
  `Firebird/InterBase(r) driver`, versão `2.00.05.156`.
- O desenvolvedor repetiu o teste e confirmou a conexão ADO com sucesso.

Esse resultado valida a abertura da conexão testada; não representa teste
de CRUD, transações ou leitura/gravação de acentos. O acesso FireDAC não
depende de ODBC.

## Organização prevista

- Formulários: interface e interação com o usuário.
- DataModules: conexão, consultas e persistência.
- Serviços/regras: validações, totalização e controle das operações.
- Banco de dados: armazenamento e integridade dos relacionamentos.
- Relatórios: apresentação, agrupamentos, totais e exportação.

A separação busca evitar regras de negócio concentradas nos formulários
e reduzir a repetição de SQL.

## Preparação do banco de dados

### Ambiente confirmado

- Servidor: Firebird 2.5.9 — WI-V2.5.9.27139.
- Execução: servidor local, acessado por localhost.
- Banco: D:\Desenvolvimento\Projects\Sky\Database\SKY.FDB.
- Charset: UTF8.
- Tamanho de página: 4096 bytes.
- ODS: 11.2.
- Dialeto SQL: 3 - confirmado pelo isql.

O caminho informado corresponde ao ambiente de desenvolvimento.
A configuração de conexão da aplicação ainda será implementada.

### Procedimento realizado

1. Verificada a conexão com o servidor pelo IBOConsole.
2. Confirmada a versão do Firebird nas propriedades do servidor.
3. Tentada a criação do banco pela interface do IBOConsole.
4. A ferramenta rejeitou UTF8 com a mensagem “Invalid option value”.
5. A criação foi realizada pelo utilitário isql do Firebird.
6. O resultado foi conferido com SHOW DATABASE.

### Justificativas

- UTF8: permitir armazenamento de textos Unicode, incluindo acentos.
- isql: definir explicitamente o charset que a interface do IBOConsole
  não aceitou.
- localhost: conectar ao servidor Firebird instalado na mesma máquina.
- Página de 4096 bytes: manter o valor inicialmente apresentado,
  sem realizar ajustes de desempenho sem evidências.
- Pasta Database: organizar o arquivo do banco dentro da estrutura local.

A rejeição de UTF8 ocorreu na ferramenta administrativa utilizada,
não no servidor Firebird, que criou o banco com essa codificação.

O script `Database/01_estrutura.sql` contém a criação do banco, tabelas,
constraints, generators, triggers e índices, com dialeto 3 explícito e
COMMIT final. Usa o marcador SUA_SENHA; credenciais reais não devem ser
versionadas. Exige ajuste do caminho e criação prévia da pasta de destino.
Deve ser executado pelo isql para criar um banco novo, nunca repetido sobre
o SKY.FDB existente. A execução integral em um banco novo ainda não foi testada.

### Codificação da conexão e do terminal

Na criação da tabela ORDEM_SERVICO, o literal Concluída provocou o erro
“Malformed string”. O valor interno adotado foi `Concluida`, sem acento;
telas e relatórios deverão apresentá-lo como “Concluída”. Consultas e
validações deverão respeitar o valor interno.

O terminal Windows informou página de código 850. O isql foi reaberto
com `-ch DOS850`, mantendo UTF8 no banco. Uma consulta comparou o texto
Concluída com seu literal hexadecimal UTF8 e retornou CORRETO, sem gravar
dados. Isso confirmou a interpretação do texto nessa consulta, embora
a saída do terminal ainda exibisse o acento incorretamente.

Foi decidido manter UTF8 no banco. A divergência de exibição do terminal
permanece pendente. A conexão FireDAC e os testes de acentuação na aplicação
ainda serão configurados e realizados.

## Modelo de dados criado

### Cliente

Dados definidos pelo enunciado:

- ID.
- Nome.
- Documento.
- Email.
- Telefone.
- DataCadastro.

Foi acrescentado o campo ATIVO para permitir desativação e reativação
sem exclusão física. A operação na aplicação ainda será implementada.

### Ordem de serviço

Dados definidos pelo enunciado:

- ID.
- ClienteID.
- DataAbertura.
- DataPrevista.
- DataFechamento.
- Status.
- DescricaoProblema.
- ValorTotal.

Foi acrescentado o campo ATIVO para exclusão lógica.

### Item da ordem

Dados definidos pelo enunciado:

- ID.
- OrdemID.
- Descricao.
- Quantidade.
- ValorUnitario.

Foi acrescentado o campo ATIVO para exclusão lógica.

Os itens pertencem diretamente à OS. Não haverá cadastro independente
de produtos nem controle de estoque no escopo atual.

### Compatibilidade com Firebird 2.5

O DDL de exemplo utiliza GENERATED BY DEFAULT AS IDENTITY, recurso
incompatível com Firebird 2.5.

A geração dos identificadores utiliza generators e triggers BEFORE INSERT,
ativas na posição 0, que atribuem o próximo valor somente quando NEW.ID
é nulo:

| Tabela | Generator | Trigger |
|---|---|---|
| CLIENTE | GEN_CLIENTE_ID | BI_CLIENTE |
| ORDEM_SERVICO | GEN_ORDEM_SERVICO_ID | BI_ORDEM_SERVICO |
| ITEM_ORDEM | GEN_ITEM_ORDEM_ID | BI_ITEM_ORDEM |

Generators não são revertidos por ROLLBACK. Intervalos nos IDs são normais;
os generators não devem ser reinicializados para reaproveitar números.

### Integridade e índices

- Chaves primárias nas três tabelas.
- Chaves estrangeiras de OS para cliente e de item para OS, sem cascata.
- ATIVO obrigatório, com padrão 1 e CHECK permitindo somente 0 ou 1.
- Nome do cliente e descrição do item definidos como NOT NULL.
- Datas de abertura e previsão obrigatórias; previsão não anterior à abertura.
- Status restrito a Aberta, Em Andamento, Concluida e Cancelada.
- Quantidade maior que zero; valor unitário e total da OS não negativos.
- Índices IDX_OS_STATUS e IDX_OS_DATA_ABERTURA para apoiar os filtros.
- Não foi duplicado o índice de CLIENTE_ID, já criado pela chave estrangeira.

Essas restrições não implementam todas as regras de negócio abaixo.
NOT NULL, por exemplo, não impede texto vazio ou composto apenas de espaços.
O campo ATIVO, isoladamente, também não impede DELETE físico por SQL.

## Regras de negócio aprovadas

### Exclusão lógica e preservação dos registros

Nenhum cliente, OS ou item será excluído fisicamente.

A ação Excluir realizará desativação lógica. A interface deverá
informar esse comportamento ao usuário.

Justificativa: preservar os registros e seus relacionamentos para
consulta, evitando a perda do histórico de atendimento.

Essa escolha é uma interpretação deliberada do requisito de exclusão
do CRUD. A justificativa será apresentada ao avaliador.

A exclusão lógica preserva registros, mas não constitui auditoria
completa das alterações. Auditoria de status é um bônus separado.

### Clientes

- Nome obrigatório.
- Documento, email e telefone opcionais.
- Documento não será limitado exclusivamente a CPF/CNPJ.
- Não será exigida unicidade do documento.
- Listagem padrão somente de clientes ativos.
- Filtros permitirão consultar inativos ou todos.
- Clientes inativos não poderão receber novas OS.
- Será permitida a reativação do cliente.
- A desativação será bloqueada enquanto houver OS ativa com status
  Aberta ou Em Andamento.
- Desativar um cliente não desativará automaticamente suas OS ou itens.
- As OS existentes continuarão identificando o cliente inativo.

Justificativa: separar a disponibilidade do cadastro para novos
atendimentos do histórico dos serviços já registrados.

### Status da OS

Toda nova OS começará como Aberta.

Transições permitidas:

| Status atual | Destinos permitidos |
|---|---|
| Aberta | Em Andamento ou Cancelada |
| Em Andamento | Concluída ou Cancelada |
| Concluída | Nenhum |
| Cancelada | Nenhum |

Ao concluir ou cancelar, DataFechamento receberá a data atual.

Não haverá reabertura de OS Concluída ou Cancelada.

Essas transições detalham um comportamento não definido pelo enunciado.

### Desativação e reativação de OS

- Excluir uma OS realizará sua desativação lógica.
- A OS e seus itens permanecerão disponíveis para consulta.
- Cancelamento e desativação serão operações distintas.
- Reativar uma OS exigirá que o cliente esteja ativo.
- A reativação preservará o status anterior.
- Reativar uma OS Concluída ou Cancelada não a reabrirá.

### Datas e atraso

- DataPrevista será obrigatória.
- DataPrevista não poderá ser anterior à DataAbertura.
- A OS estará atrasada quando a data atual for maior que DataPrevista
  e seu status não for Concluída nem Cancelada.
- Vencimento na data atual não caracteriza atraso.
- Em Atraso será uma condição calculada, não um status adicional.
- OS atrasadas terão destaque visual.

O modelo de exemplo permite DataPrevista nula. Sua obrigatoriedade
é uma decisão do projeto para permitir avaliar o prazo de toda OS.

Não haverá cálculo de horas úteis, feriados ou prazos por prioridade.

### Itens e totalização

- Itens só poderão ser incluídos, alterados ou desativados em OS ativa
  com status Aberta ou Em Andamento.
- OS Concluída, Cancelada ou desativada terá itens apenas para consulta.
- Quantidade deverá ser maior que zero.
- Valor unitário deverá ser maior ou igual a zero.
- Itens gratuitos serão permitidos.
- Quantidade e valor unitário terão duas casas decimais.
- O subtotal será Quantidade × ValorUnitario, arredondado para duas
  casas decimais.
- ValorTotal será a soma dos subtotais dos itens ativos.
- Item desativado permanecerá consultável, mas não comporá o total.
- A desativação do item e o recálculo do total ocorrerão na mesma
  transação.
- Será permitido abrir OS sem itens, com total zero.
- A conclusão exigirá pelo menos um item ativo, inclusive gratuito.

Justificativa: permitir registrar o atendimento antes de definir os
serviços, exigindo seu detalhamento para concluir a OS.

### Contadores

Serão apresentados:

- Abertas.
- Em Andamento.
- Concluídas.
- Em Atraso.

Os contadores considerarão todas as OS ativas, independentemente dos
filtros da pesquisa.

OS desativadas permanecerão consultáveis, mas não entrarão nesses
indicadores.

Uma OS pode estar Em Andamento e Em Atraso simultaneamente; portanto,
os contadores não representam categorias mutuamente exclusivas.

### Relatório

- Considerará OS ativas por padrão.
- Permitirá consultar somente desativadas ou todas.
- Terá filtros por período de abertura, status com multisseleção
  e parte do nome do cliente.
- Apresentará quantidade e soma dos valores por status.
- Apresentará total geral e data/hora de geração.
- Quantidades e valores respeitarão os filtros selecionados.
- Terá exportação em formato permitido pelo enunciado.
- Se utilizado CSV, haverá cabeçalho.

## Consistência e tratamento de erros

Requisitos a implementar:

- Gravação de OS e itens na mesma transação.
- Reversão da operação em caso de falha.
- Queries parametrizadas.
- Mensagens de erro compreensíveis.
- Registro técnico das falhas em log.
- Centralização do SQL para evitar duplicação.

## Componente de relatórios

FastReport não está instalado e não foi encontrado na pesquisa
realizada no GetIt do Delphi Community.

FortesReport Community Edition está sendo considerado como alternativa
sem custo.

A aceitação será esclarecida com o avaliador em 28/09/2026, pois o
enunciado menciona “FastReport ou similar” no objetivo e lista
FastReport ou QuickReport na seção de stack.

A escolha e a instalação ficaram adiadas. As etapas anteriores ao
relatório poderão prosseguir.

## Situação atual

Atualização: 24/09/2026.

Concluído:

- Leitura e análise da especificação.
- Definição das regras descritas neste documento.
- Verificação do servidor Firebird.
- Criação do banco em UTF8 e confirmação do dialeto 3 no banco e na sessão.
- Criação e conferência das três tabelas, constraints, generators e triggers.
- Criação e conferência dos índices de pesquisa de OS.
- Preparação e revisão do script de estrutura.
- Testes manuais de inclusão e rollback descritos abaixo.
- Testes de rejeição por NOT NULL, CHECK e chaves estrangeiras descritos abaixo.
- ROLLBACK final e confirmação de zero registros nas três tabelas.

Pendente:

- Validar o script completo em um banco separado e novo.
- Confirmar o versionamento dos arquivos de entrega.
- Resolver a divergência de exibição dos acentos no terminal.
- Implementar a aplicação.
- Implementar totalização, transições de status e demais regras de negócio.
- Selecionar e integrar o componente de relatórios.
- Validar os fluxos e preparar a entrega.
- Documentar os passos finais de configuração e execução.

### Testes manuais realizados

Resultados informados pelo desenvolvedor durante a execução no isql:

| Teste | Resultado |
|---|---|
| Cliente informando somente NOME | ID 1, ATIVO 1 e DATA_CADASTRO preenchida automaticamente. |
| ROLLBACK do primeiro cliente | CLIENTE retornou zero registros; generator permaneceu em 1. |
| Novo cliente de teste | ID 2, ATIVO 1 e data preenchida. |
| OS vinculada ao cliente 2 | ID 1, status Aberta, VALOR_TOTAL 0.00 e ATIVO 1. |
| Item vinculado à OS 1 | ID 1, quantidade 2.00, valor unitário 50.00 e ATIVO 1. |
| ROLLBACK conjunto | As três tabelas retornaram zero registros. |

Os testes verificaram geração de IDs, valores padrão, inserções com vínculos
válidos e reversão das inclusões. O total da OS não foi recalculado:
essa funcionalidade ainda não foi implementada.

### Testes de constraints realizados

Resultados retornados pelo isql e informados pelo desenvolvedor:

| Tabela | Entrada testada | Resultado |
|---|---|---|
| CLIENTE | NOME omitido | Rejeitada por NOT NULL em NOME. |
| CLIENTE | ATIVO = 2 | Rejeitada por CK_CLIENTE_ATIVO. |
| CLIENTE | ATIVO = NULL explícito | Rejeitada por NOT NULL em ATIVO. |
| ORDEM_SERVICO | Previsão anterior à abertura | Rejeitada por CK_ORDEM_SERVICO_PREVISAO. |
| ORDEM_SERVICO | STATUS = 'Invalido' | Rejeitada por CK_ORDEM_SERVICO_STATUS. |
| ORDEM_SERVICO | VALOR_TOTAL = -1 | Rejeitada por CK_ORDEM_SERVICO_VALOR. |
| ORDEM_SERVICO | DATA_PREVISTA, DATA_ABERTURA ou CLIENTE_ID omitido, em testes separados | Rejeitada por NOT NULL no respectivo campo. |
| ORDEM_SERVICO | CLIENTE_ID = -1, inexistente | Rejeitada por FK_ORDEM_SERVICO_CLIENTE. |
| ORDEM_SERVICO | ATIVO = 2 | Rejeitada por CK_ORDEM_SERVICO_ATIVO. |
| ORDEM_SERVICO | ATIVO, STATUS ou VALOR_TOTAL = NULL explícito, em testes separados | Rejeitada por NOT NULL no respectivo campo. |
| ITEM_ORDEM | QUANTIDADE = 0 | Rejeitada por CK_ITEM_ORDEM_QUANTIDADE. |
| ITEM_ORDEM | VALOR_UNITARIO = -1 | Rejeitada por CK_ITEM_ORDEM_VALOR. |
| ITEM_ORDEM | ATIVO = 2 | Rejeitada por CK_ITEM_ORDEM_ATIVO. |
| ITEM_ORDEM | ORDEM_ID = -1, inexistente | Rejeitada por FK_ITEM_ORDEM_OS. |
| ITEM_ORDEM | ORDEM_ID, DESCRICAO, QUANTIDADE ou VALOR_UNITARIO omitido, em testes separados | Rejeitada por NOT NULL no respectivo campo. |
| ITEM_ORDEM | ATIVO = NULL explícito | Rejeitada por NOT NULL em ATIVO. |

Todas as rejeições acima retornaram SQLSTATE 23000, conforme esperado.
Para apoiar os testes, foram inseridos um cliente válido com ID 6 e uma OS
válida com ID 13, vinculada a esse cliente, sem COMMIT. Ao final, foi executado
ROLLBACK e as consultas COUNT(*) confirmaram zero registros em CLIENTE,
ORDEM_SERVICO e ITEM_ORDEM.

Os resultados cobrem os casos listados, não uma validação exaustiva de todas
as constraints ou regras de negócio. A execução integral do script em banco
novo continua pendente.

### Ponto de retomada

As três tabelas estão sem registros após os testes. Os valores consumidos
pelos generators foram preservados, conforme o comportamento do Firebird.

Os testes de constraints listados acima foram concluídos. O próximo passo
é iniciar a estrutura da aplicação Delphi 13 VCL/Win32. A criação e execução
do projeto Delphi ainda não foram confirmadas pelo desenvolvedor.

O trabalho seguirá por etapas: o candidato escreve e executa a solução;
a IA orienta e revisa, fornecendo código corrigido apenas quando solicitado.

## Uso de inteligência artificial

Foi utilizada IA para análise do enunciado, discussão de regras,
orientação técnica, consultas auxiliares de diagnóstico e revisão do SQL
escrito pelo candidato. Também foi utilizada para elaborar o modelo deste
README, o comentário inicial do script e atualizar esta documentação
mediante solicitação explícita.

O desenvolvimento será realizado pelo candidato, com orientação por
etapas. Esta seção será atualizada conforme o uso efetivo durante
o projeto.

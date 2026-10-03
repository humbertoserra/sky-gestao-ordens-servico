# SKY — Gestão de Ordens de Serviço

Projeto desenvolvido para a prova técnica de Desenvolvedor Delphi 2026.

## Objetivo

Gerenciar clientes, ordens de serviço e seus itens, com pesquisa,
totalização automática, identificação de atrasos e relatório gerencial.

Este README descreve a implementação, as decisões e os testes realizados.
Limitações e verificações pendentes estão indicadas em seções próprias.

## Tecnologias

- Delphi 13 Community Edition - Ambiente disponível para desenvolvimento.
- VCL - Interface desktop para Windows.
- Win32 - Plataforma escolhida para esta implementação.
- Firebird 2.5.9 - Versão definida para o projeto, instalada localmente.
- FireDAC - Componentes disponíveis e preferidos pelo enunciado.
- ADO via MSDASQL - Implementação alternativa de acesso ao Firebird, com teste de conexão realizado com sucesso.
- Driver ODBC Firebird/InterBase(r) 2.0.5.156 (32 bits) - Instalado no Windows para a conexão ADO em Win32.
- FortesReport Community Edition - Relatórios e exportação PDF.

A implementação atual é exclusivamente em Delphi 13.
Uma eventual versão Delphi 7 será tratada separadamente.

## Acesso padrão: FireDAC

A aplicação utiliza FireDAC, selecionado em `Sky.dpr`. A conexão foi utilizada
nos testes funcionais de clientes, OS, itens e relatórios.

O problema inicial de charset foi corrigido: `TModelConfiguracaoFiredac.Charset`
retorna `FCharset`, em vez do caminho do banco. Foi mantido UTF8.
FireDAC não depende de ODBC.

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

## Organização e arquitetura

A organização segue MVC, com interfaces e factories:

- `src/View`: formulários VCL, interação e apresentação do relatório.
- `src/Controller`: coordenação das operações, estado de edição, regras e transações.
- `src/Model/Entity`: entidades de cliente, OS e item.
- `src/Model/DAO`: SQL, consultas parametrizadas e persistência.
- `src/Model/Connection`: configuração, conexões, queries e tabelas em memória.
- `src/Service`: utilitários e log.
- `Database/01_estrutura.sql`: criação do banco, estrutura e cadastro inicial.
- `bin`: executável e configuração.

`Sky.dpr` compõe as dependências e inicializa a aplicação. As views utilizam
controllers, que coordenam os DAOs e disponibilizam datasets para apresentação.
O acesso a dados está encapsulado em classes, sem DataModules por formulário.
O SQL fica concentrado nos DAOs.

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
A conexão é configurada pelo arquivo config.ini junto ao executável.

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
a interface apresenta “Concluída”. Consultas e validações respeitam
o valor interno.

O terminal Windows informou página de código 850. O isql foi reaberto
com `-ch DOS850`, mantendo UTF8 no banco. Uma consulta comparou o texto
Concluída com seu literal hexadecimal UTF8 e retornou CORRETO, sem gravar
dados. Isso confirmou a interpretação do texto nessa consulta, embora
a saída do terminal ainda exibisse o acento incorretamente.

Foi decidido manter UTF8 no banco. A divergência de exibição do terminal
não teve resolução registrada neste histórico. A conexão FireDAC atual
utiliza UTF8, sem alterar o charset do banco.

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
sem exclusão física, pelo campo Ativo na tela de clientes.

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

| Tabela        | Generator            | Trigger          |
|---------------|----------------------|------------------|
| CLIENTE       | GEN_CLIENTE_ID       | BI_CLIENTE       |
| ORDEM_SERVICO | GEN_ORDEM_SERVICO_ID | BI_ORDEM_SERVICO |
| ITEM_ORDEM    | GEN_ITEM_ORDEM_ID    | BI_ITEM_ORDEM    |

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

A aplicação não exclui fisicamente clientes, OS ou itens persistidos.
A exclusão utiliza `ATIVO = 0`; clientes são desativados pelo campo Ativo.

Justificativa: preservar registros e relacionamentos no banco, evitando perda
do histórico de atendimento. Esta é uma interpretação deliberada do requisito
de exclusão do CRUD.

Preservação no banco não implica consulta de todos os registros na interface.
Clientes inativos podem ser pesquisados; OS e itens desativados não possuem
tela de consulta ou restauração nesta versão.

Exclusão lógica não constitui auditoria completa das alterações.

### Clientes

- Nome obrigatório.
- Documento, email e telefone opcionais.
- Documento não é limitado exclusivamente a CPF/CNPJ.
- Não é exigida unicidade do documento.
- Listagem padrão somente de clientes ativos.
- Filtros permitem consultar inativos ou todos.
- Clientes inativos não podem receber novas OS.
- É permitida a reativação do cliente.
- A desativação é bloqueada enquanto houver OS ativa com status
  Aberta ou Em Andamento.
- Desativar um cliente não desativa automaticamente suas OS ou itens.
- Clientes inativos não aparecem na lista de seleção de clientes da OS.
- OS concluídas/canceladas exibem o nome do cliente inativo, sem permitir edição.
- O cliente ID 1, AO CONSUMIDOR, é protegido contra alteração e desativação.

Justificativa: separar a disponibilidade do cadastro para novos
atendimentos do histórico dos serviços já registrados.

### Status da OS

Toda nova OS começa como Aberta.

Transições permitidas:

| Status atual | Destinos permitidos       |
|--------------|---------------------------|
| Aberta       | Em Andamento ou Cancelada |
| Em Andamento | Concluída ou Cancelada    |
| Concluída    | Nenhum                    |
| Cancelada    | Nenhum                    |

Ao concluir ou cancelar, DataFechamento recebe a data atual.

Não há reabertura de OS Concluída ou Cancelada.

Essas transições detalham um comportamento não definido pelo enunciado.

### Desativação de OS

- Excluir uma OS realiza sua desativação lógica.
- Os registros da OS e dos itens permanecem no banco.
- Cancelamento e desativação são operações distintas.
- Não há consulta de OS desativadas nem reativação pela interface atual.

A reativação prevista inicialmente não foi implementada nesta versão.

### Datas e atraso

- DataPrevista é obrigatória.
- DataPrevista não pode ser anterior à DataAbertura.
- A OS está atrasada quando a data atual for maior que DataPrevista
  e seu status não for Concluída nem Cancelada.
- Vencimento na data atual não caracteriza atraso.
- Em Atraso é uma condição calculada, não um status adicional.
- OS atrasadas têm destaque visual.

O modelo de exemplo permite DataPrevista nula. Sua obrigatoriedade
é uma decisão do projeto para permitir avaliar o prazo de toda OS.

Não há cálculo de horas úteis, feriados ou prazos por prioridade.

### Itens e totalização

- Itens só podem ser incluídos, alterados ou desativados em OS ativa
  com status Aberta ou Em Andamento.
- OS Concluída ou Cancelada tem itens apenas para consulta.
- OS desativada não é apresentada na listagem normal.
- Quantidade deve ser maior que zero.
- Valor unitário deve ser maior ou igual a zero.
- Itens gratuitos são permitidos.
- Quantidade e valor unitário têm duas casas decimais.
- O subtotal é Quantidade × ValorUnitario, arredondado para duas
  casas decimais.
- ValorTotal é a soma dos subtotais dos itens ativos.
- Item desativado permanece no banco, fora da grade e do total.
- A desativação do item e o recálculo do total ocorrem na mesma
  transação.
- É permitido abrir OS sem itens, com total zero.
- A conclusão exige pelo menos um item ativo, inclusive gratuito.

Justificativa: permitir registrar o atendimento antes de definir os
serviços, exigindo seu detalhamento para concluir a OS.

### Contadores

São apresentados:

- Abertas.
- Em Andamento.
- Concluídas.
- Em Atraso.

Os contadores consideram todas as OS ativas, independentemente dos
filtros da pesquisa.

OS desativadas não entram nesses indicadores.

Uma OS pode estar Em Andamento e Em Atraso simultaneamente; portanto,
os contadores não representam categorias mutuamente exclusivas.

### Relatório

- Considera somente OS ativas, por meio de `VW_OS_RESUMO`.
- Filtra por abertura, status com multisseleção e parte do nome do cliente.
- Nenhum status marcado significa todos.
- Apresenta quantidade e subtotal por status, com separadores entre grupos.
- Apresenta quantidade e valor total geral, data/hora de geração e paginação.
- Quantidades e valores respeitam os filtros selecionados.
- Permite visualizar e exportar PDF.
- Valida período invertido e informa quando não há resultados.

A seleção de OS desativadas ou todas, prevista inicialmente, não foi implementada.

## Consistência e tratamento de erros

Recursos implementados:

- Gravação de OS e itens na mesma transação.
- Tentativa de rollback em caso de falha durante a gravação.
- Queries parametrizadas.
- Mensagens de erro compreensíveis.
- Registro técnico das falhas em log.
- Centralização do SQL para evitar duplicação.

## Componente de relatórios

Foi adotado o FortesReport Community Edition, alternativa sem custo para
visualização, agrupamentos, totalização e exportação PDF.

O enunciado menciona “FastReport ou similar” no objetivo e FastReport ou
QuickReport na stack. O FortesReport fornece as funcionalidades solicitadas;
não há confirmação de aceite específico do avaliador registrada neste documento.

O layout está em `src/View/Sky.View.ImpressaoOS.pas` e no respectivo `.dfm`.
Não depende de arquivo `.fr3`.

## Configuração, compilação e execução

### Criar um banco novo

1. Instale e inicie o servidor Firebird 2.5.
2. Crie a pasta de destino do banco no servidor.
3. Ajuste o caminho de `CREATE DATABASE` e `SUA_SENHA` em uma cópia local de
   `Database/01_estrutura.sql`.
4. Execute essa cópia pelo isql do Firebird, sem banco conectado.

Exemplo, ajustando os caminhos:

```bat
"C:\Program Files\Firebird\Firebird_2_5\bin\isql.exe" -i "C:\Sky\Database\01_estrutura.sql"
```

Não execute sobre um banco existente. O serviço Firebird precisa de acesso à
pasta do FDB. Não versione a cópia contendo credenciais reais.

O script inclui `VW_OS_RESUMO` e o cliente reservado `AO CONSUMIDOR`, ID 1.

### Configurar a aplicação

Disponibilize `config.ini` junto ao `Sky.exe`:

```ini
[CONFIG]
SERVIDOR=localhost
DATABASE=C:\Sky\Database\SKY.FDB
USUARIO=SYSDBA
SENHA=SUA_SENHA
DIALECT=3
CHARSET=UTF8
```

Ajuste caminho e credenciais. `DATABASE` é o caminho no servidor Firebird.
Esses campos alimentam `Server`, `Database`, `User_Name`, `Password`,
`SQLDialect` e `CharacterSet` do FireDAC, com `DriverID=FB`.
Para localhost/127.0.0.1, o código usa `Protocol=LOCAL`; para outros servidores,
`Protocol=TCPIP`.

Disponibilize a `fbclient.dll` do Firebird 2.5 de 32 bits e suas dependências
junto ao executável. O cliente deve corresponder à arquitetura Win32.
Execute `Sky.exe`. A pasta deve permitir criar e gravar a subpasta `Logs`.
Não é necessário instalador.

ADO/ODBC é uma alternativa no código; o INI não troca o driver padrão
selecionado em `Sky.dpr`.

### Compilar

1. Abra `Sky.dproj` no Delphi 13, com FireDAC disponível.
2. Instale o FortesReport Community Edition no ambiente.
3. Ajuste o Search Path para a pasta `Source` da instalação local do FortesReport.
   O projeto contém um caminho específico do ambiente de desenvolvimento.
4. Selecione Win32 e execute Build.
5. Confira o executável em `bin`, conforme a configuração de saída Win32.

## Roteiro de uso e testes

### Clientes e OS

1. Acesse `Cadastro > Clientes`, inclua um cliente e salve.
2. Use `Nova OS`, selecione o cliente e informe as datas e o problema.
3. Inclua itens com quantidade e valor unitário; confira o total e salve.
4. Recarregue a OS e pesquise por cliente, status e abertura.
5. Para desativar um cliente, desmarque Ativo e salve; a operação é bloqueada
   se houver OS ativa aberta ou em andamento.
6. Para excluir logicamente uma OS, carregue-a e use `Ordem de Serviço > Excluir OS`.

### Funcionalidade não CRUD obrigatória: SLA/atraso

1. Cadastre uma OS aberta com abertura e previsão anteriores à data atual.
2. Salve e atualize a pesquisa; confira o destaque e o contador de atrasadas.
3. Altere a previsão para hoje e salve; ela deixa de estar atrasada.
4. OS concluídas ou canceladas não devem contar como atrasadas, mesmo vencidas.

### Relatório e extra: barra de progresso

1. Acesse `Relatórios > Ordem de Serviço`.
2. Selecione período, cliente e status desejados.
3. Use `Visualizar` e confira grupos, quantidades e totais.
4. Use `Exportar PDF`, escolha o destino e confira o arquivo gerado.
5. Observe a barra de progresso. Em relatórios pequenos ela pode avançar
   rapidamente; não existe atraso artificial.

### Concorrência

1. Abra duas instâncias no mesmo banco e carregue a mesma OS editável.
2. Altere e salve na primeira.
3. Tente salvar na segunda: deve haver recusa, orientando a recarga.
4. Recarregue para conferir a alteração gravada e consulte o WARN no log.

As listas não se sincronizam automaticamente entre instâncias; use Filtrar.
A gravação verifica alterações concorrentes na OS e nos itens.

## Log e diagnóstico

Arquivo diário junto ao executável: `Logs/Sky_YYYYMMDD.log`, em UTF8.
Novos registros são acrescentados ao arquivo do dia.

```text
data/hora | nivel | rotina | contexto | mensagem | extra
```

- `INFO`: operações relevantes concluídas, como gravação e exportação.
- `WARN`: validações e recusas operacionais, incluindo conflitos de concorrência.
- `ERROR`: falhas técnicas.
- `FATAL`: acesso inválido à memória, ponteiro inválido ou falta de memória.

Quando aplicável, o campo extra identifica a classe da exceção. Não são
registradas mensagens genéricas de início e fim de cada rotina.
Falha de escrita no log é enviada à saída de depuração e não substitui
a exceção da aplicação.

Falhas de atualização da interface após commit são tratadas separadamente
da gravação. Se o rollback ou a restauração de itens também falhar, essa
falha é registrada, preservando a classe da exceção original.

## Situação atual

Atualização: 03/10/2026.

Implementado e utilizado em testes manuais:

- Cadastro, pesquisa e manutenção de clientes.
- OS e itens com totalização, regras de status e gravação transacional.
- SLA, destaque de atraso e contadores.
- Bloqueio de concorrência entre instâncias.
- Relatório, filtros, agrupamentos, totais, PDF e barra de progresso.
- Log diário e classificação de exceções.
- Seleção de clientes ativos e exibição do cliente inativo em OS encerrada.

As correções de tratamento de exceções e de falhas após commit tiveram Build
confirmado. O teste de concorrência de 03/10 registrou a primeira gravação
como INFO e a segunda, recusada, como WARN (`EOperacaoRecusada`). Esse teste
não exercita falha do próprio rollback ou da restauração.

### Verificações pendentes para entrega

- Executar o script completo em um banco separado e novo.
- Validar relatório com múltiplas páginas.
- Exercitar falhas após commit e falhas do próprio rollback/restauração.
- Conferir versionamento e composição do pacote final.
- Testar o pacote em ambiente limpo.

### Limitações conhecidas

- ADO validado apenas quanto à abertura da conexão.
- Sem sincronização automática das listas entre instâncias.
- Sem interface para consultar/restaurar OS e itens desativados.
- Relatório somente de OS ativas, com exportação PDF.
- Sem paginação ou filtro por valor total na interface.
- Sem auditoria histórica de status ou importação/exportação de clientes via CSV.
- SLA sem calendário de dias úteis, feriados ou prioridades.

## Histórico de validação do banco — 24/09/2026

Os testes abaixo são evidências da estruturação inicial do banco.
Os IDs e contagens refletem aquela sessão, anterior ao cadastro reservado
atual e aos testes funcionais; não descrevem o conteúdo atual do banco.

### Testes manuais realizados

Resultados informados pelo desenvolvedor durante a execução no isql:

| Teste                           | Resultado                                                   |
|---------------------------------|-------------------------------------------------------------|
| Cliente informando somente NOME | ID 1, ATIVO 1 e DATA_CADASTRO preenchida automaticamente.   |
| ROLLBACK do primeiro cliente    | CLIENTE retornou zero registros; generator permaneceu em 1. |
| Novo cliente de teste           | ID 2, ATIVO 1 e data preenchida.                            |
| OS vinculada ao cliente 2       | ID 1, status Aberta, VALOR_TOTAL 0.00 e ATIVO 1.            |
| Item vinculado à OS 1           | ID 1, quantidade 2.00, valor unitário 50.00 e ATIVO 1.      |
| ROLLBACK conjunto               | As três tabelas retornaram zero registros.                  |

Os testes verificaram geração de IDs, valores padrão, inserções com vínculos
válidos e reversão das inclusões. Naquela etapa, a totalização da aplicação
ainda não estava implementada e não foi exercitada nesses testes SQL.

### Testes de constraints realizados

Resultados retornados pelo isql e informados pelo desenvolvedor:

| Tabela        | Entrada testada | Resultado |
|---------------|-----------------|-----------|
| CLIENTE       | NOME omitido | Rejeitada por NOT NULL em NOME. |
| CLIENTE       | ATIVO = 2 | Rejeitada por CK_CLIENTE_ATIVO. |
| CLIENTE       | ATIVO = NULL explícito | Rejeitada por NOT NULL em ATIVO. |
| ORDEM_SERVICO | Previsão anterior à abertura | Rejeitada por CK_ORDEM_SERVICO_PREVISAO. |
| ORDEM_SERVICO | STATUS = 'Invalido' | Rejeitada por CK_ORDEM_SERVICO_STATUS. |
| ORDEM_SERVICO | VALOR_TOTAL = -1 | Rejeitada por CK_ORDEM_SERVICO_VALOR. |
| ORDEM_SERVICO | DATA_PREVISTA, DATA_ABERTURA ou CLIENTE_ID omitido, em testes separados | Rejeitada por NOT NULL no respectivo campo. |
| ORDEM_SERVICO | CLIENTE_ID = -1, inexistente | Rejeitada por FK_ORDEM_SERVICO_CLIENTE. |
| ORDEM_SERVICO | ATIVO = 2 | Rejeitada por CK_ORDEM_SERVICO_ATIVO. |
| ORDEM_SERVICO | ATIVO, STATUS ou VALOR_TOTAL = NULL explícito, em testes separados | Rejeitada por NOT NULL no respectivo campo. |
| ITEM_ORDEM    | QUANTIDADE = 0 | Rejeitada por CK_ITEM_ORDEM_QUANTIDADE. |
| ITEM_ORDEM    | VALOR_UNITARIO = -1 | Rejeitada por CK_ITEM_ORDEM_VALOR. |
| ITEM_ORDEM    | ATIVO = 2 | Rejeitada por CK_ITEM_ORDEM_ATIVO. |
| ITEM_ORDEM    | ORDEM_ID = -1, inexistente | Rejeitada por FK_ITEM_ORDEM_OS. |
| ITEM_ORDEM    | ORDEM_ID, DESCRICAO, QUANTIDADE ou VALOR_UNITARIO omitido, em testes separados | Rejeitada por NOT NULL no respectivo campo. |
| ITEM_ORDEM    | ATIVO = NULL explícito | Rejeitada por NOT NULL em ATIVO. |

Todas as rejeições acima retornaram SQLSTATE 23000, conforme esperado.
Para apoiar os testes, foram inseridos um cliente válido com ID 6 e uma OS
válida com ID 13, vinculada a esse cliente, sem COMMIT. Ao final, foi executado
ROLLBACK e as consultas COUNT(*) confirmaram zero registros em CLIENTE,
ORDEM_SERVICO e ITEM_ORDEM.

Os resultados cobrem os casos listados, não uma validação exaustiva de todas
as constraints ou regras de negócio. A execução integral do script em banco
novo continua pendente.

### Resultado daquela etapa

Ao final da sessão de testes de 24/09, as três tabelas ficaram sem registros
após o rollback. Os generators mantiveram os valores consumidos. Essa contagem
não representa o banco atual.

## Uso de inteligência artificial

Foi utilizado ChatGPT/Codex para análise do enunciado, discussão de regras e
arquitetura, orientação técnica, geração e revisão de trechos de código e SQL,
diagnóstico de erros, planejamento de testes e elaboração desta documentação.

O candidato adaptou e incorporou sugestões e realizou compilações e testes
manuais. Permanece responsável por compreender e validar o código entregue.

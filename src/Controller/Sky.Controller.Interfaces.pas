unit Sky.Controller.Interfaces;

interface

uses
  Data.DB;

type
  TCampoPesquisaCliente = (
    pcNome,
    pcDocumento,
    pcEmail,
    pcTelefone
  );

  TSituacaoPesquisaCliente = (
    scTodos,
    scAtivos,
    scInativos
  );

  TStatusOrdemServico = (
    soAberta,
    soEmAndamento,
    soConcluida,
    soCancelada
  );

  TStatusOrdemServicoSelecionados = set of TStatusOrdemServico;

  TFiltroRelatoriosOS = record
    FiltraPeriodo: Boolean;
    DataInicial: TDateTime;
    DataFinal: TDateTime;
    NomeCliente: String;
    StatusSelecionados: TStatusOrdemServicoSelecionados;
  end;

  TDadosCliente = record
    ID: Integer;
    Nome: string;
    Documento: string;
    Email: string;
    Telefone: string;
    Ativo: Boolean;
  end;

  TFiltroOrdemServico = record
    NomeCliente: string;
    FiltrarPeriodo: Boolean;
    DataInicial: TDateTime;
    DataFinal: TDateTime;
    FiltrarStatus: Boolean;
    Status: TStatusOrdemServico;
  end;

  TDadosOrdemServico = record
    ID: Integer;
    ClienteID: Integer;
    NomeCliente: String;
    DataAbertura: TDateTime;
    DataPrevista: TDateTime;
    Problema: string;
    Status: TStatusOrdemServico;
    TemDataFechamento: Boolean;
    DataFechamento: TDateTime;
    ValorTotal: Currency;
  end;

  TIndicadoresOrdemServico = record
    Abertas: Integer;
    EmAndamento: Integer;
    Concluidas: Integer;
    Atrasadas: Integer;
  end;

  TDadosItemOrdem = record
    ID: Integer;
    Descricao: string;
    Quantidade: Double;
    ValorUnitario: Currency;
  end;

  iControllerCliente = interface
    procedure Pesquisar(
      ACampo: TCampoPesquisaCliente;
      const ATermo: string;
      ASituacao: TSituacaoPesquisaCliente);
    procedure Novo;
    procedure Carregar(const AID: Integer);
    function Dados: TDadosCliente;
    function PodeEditar: Boolean;
    procedure Salvar(const ADados: TDadosCliente);
    procedure Limpar;
    function DataSet: TDataSet;
  end;

  iControllerOrdemServico = interface
    procedure Pesquisar(
      const AFiltro: TFiltroOrdemServico);
    procedure Novo;
    procedure Carregar(const AID: Integer);
    function Dados: TDadosOrdemServico;
    function PodeEditar: Boolean;
    function PodeAlterarStatus(
      ANovoStatus: TStatusOrdemServico): Boolean;
    procedure NovoItem;
    function DadosItem(const AIndice: Integer): TDadosItemOrdem;
    procedure AtualizarItem(const AIndice: Integer;
      const ADados: TDadosItemOrdem);
    procedure ExcluirItem(const AIndice: Integer);
    function QuantidadeItens: Integer;
    procedure RecalcularTotal;
    procedure Salvar(const ADados: TDadosOrdemServico);
    procedure Excluir;
    procedure Descartar;
    procedure AtualizarClientes;
    procedure AtualizarIndicadores;
    function Indicadores: TIndicadoresOrdemServico;
    function DataSetListagem: TDataSet;
    function DataSetClientes: TDataSet;
    function DataSetItens: TDataSet;
    function ListagemEmAtraso: Boolean;
  end;

  iControllerRelatoriosOS = interface
    procedure Pesquisar(const aFiltro: TFiltroRelatoriosOS);
    function DataSet: TDataSet;
  end;

  iControllerFactory = interface
    function Cliente: iControllerCliente;
    function OrdemServico: iControllerOrdemServico;
    function RelatorioOS: iControllerRelatoriosOS;
  end;

implementation

end.

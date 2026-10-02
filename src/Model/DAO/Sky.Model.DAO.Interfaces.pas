unit Sky.Model.DAO.Interfaces;

interface

uses
  Data.DB,
  Sky.Model.Entity.Interfaces;

type
  TOperadorFiltro = (
    ofIgual,
    ofMaiorOuIgual,
    ofMenorOuIgual,
    ofContem
  );

  TFiltro = record
    Campo: string;
    Operador: TOperadorFiltro;
    Valor: Variant;
  end;

  TFiltros = array of TFiltro;

  iDAO = interface
    function Listar: iDAO;
    function BuscarPorId(const AID: Integer): iDAO;
    function BuscarPor(const AFiltros: array of TFiltro): iDAO;
    function DataSet: TDataSet;
  end;

  iDAOCliente = interface(iDAO)
    procedure Inserir(const ACliente: iCliente);
    procedure Atualizar(const ACliente: iCliente);
    procedure Excluir(const AID: Integer);
  end;

  iDAOOrdemServico = interface(iDAO)
    procedure Inserir(const AOrdem: iOrdemServico);
    procedure Atualizar(const AOrdem: iOrdemServico);
    procedure Excluir(const AID: Integer);
    procedure Bloquear(const AID: Integer);
  end;

  iDAOItemOrdem = interface(iDAO)
    procedure Inserir(const AItem: iItemOrdem);
    procedure Atualizar(const AItem: iItemOrdem);
    procedure Excluir(const AID: Integer);
  end;

  iDAORelatorioOS = interface
    procedure Pesquisar(
      const AFiltrarPeriodo: Boolean;
      const ADataInicial, ADataFinal: TDateTime;
      const ANomeCliente: string;
      const AStatus: array of string);
    function DataSet: TDataSet;
  end;

implementation

end.

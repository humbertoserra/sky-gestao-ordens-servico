unit Sky.Model.Entity.Interfaces;

interface

type
  iCliente = interface
    function ID: integer; overload;
    function ID(Value: integer): iCliente; overload;
    function Nome: string; overload;
    function Nome(Value: string): iCliente; overload;
    function Documento: string; overload;
    function Documento(Value: string): iCliente; overload;
    function Email: string; overload;
    function Email(Value: string): iCliente; overload;
    function Telefone: string; overload;
    function Telefone(Value: string): iCliente; overload;
    function DataCadastro: TDateTime; overload;
    function DataCadastro(Value: TDateTime): iCliente; overload;
    function Ativo: Boolean; overload;
    function Ativo(Value: Boolean): iCliente; overload;
  end;

  iOrdemServico = interface
    function ID: integer; overload;
    function ID(Value: integer): iOrdemServico; overload;
    function ClienteID: integer; overload;
    function ClienteID(Value: integer): iOrdemServico; overload;
    function NomeCliente: String; overload;
    function NomeCliente(Value: string): iOrdemServico; overload;
    function DataAbertura: TDateTime; overload;
    function DataAbertura(Value: TDateTime): iOrdemServico; overload;
    function DataPrevista: TDateTime; overload;
    function DataPrevista(Value: TDateTime): iOrdemServico; overload;
    function DataFechamento: TDateTime; overload;
    function DataFechamento(Value: TDateTime): iOrdemServico; overload;
    function TemDataFechamento: Boolean;
    function LimparDataFechamento: iOrdemServico;
    function Problema: string; overload;
    function Problema(Value: string): iOrdemServico; overload;
    function ValorTotal: currency; overload;
    function ValorTotal(Value: currency): iOrdemServico; overload;
    function Status: String; overload;
    function Status(Value: String): iOrdemServico; overload;
    function Ativo: Boolean; overload;
    function Ativo(Value: Boolean): iOrdemServico; overload;
  end;

  iItemOrdem = interface
    function ID: integer; overload;
    function ID(Value: integer): iItemOrdem; overload;
    function OrdemID: integer; overload;
    function OrdemID(Value: integer): iItemOrdem; overload;
    function Descricao: string; overload;
    function Descricao(Value: string): iItemOrdem; overload;
    function Quantidade: Double; overload;
    function Quantidade(Value: Double): iItemOrdem; overload;
    function ValorUnitario: currency; overload;
    function ValorUnitario(Value: currency): iItemOrdem; overload;
    function Ativo: Boolean; overload;
    function Ativo(Value: Boolean): iItemOrdem; overload;
  end;

  iEntidade = interface
    function Cliente: iCliente;
    function OrdemServico: iOrdemServico;
    function ItemOrdem: iItemOrdem;
  end;

implementation

end.

unit Sky.Model.Connection.Interfaces;

interface

uses
  Data.DB;

type
  iConfiguracao = interface
    ['{1A0E640F-0842-4D4F-87E5-EC4D9C65272B}']
    function Servidor: string;
    function Banco: string;
    function Usuario: string;
    function Senha: string;
    function Charset: string;
    function Dialeto: Integer;
  end;

  iConexao = interface
    ['{FB0CE5D8-52E0-46DC-AA81-B33891031B1F}']
    procedure Conectar;
    procedure Desconectar;
    function Conectada: Boolean;
    procedure IniciarTransacao;
    procedure ConfirmarTransacao;
    procedure DesfazerTransacao;
    function EmTransacao: Boolean;
  end;

  iQuery = interface
    ['{F1B5D51E-8755-4364-BAF3-6C78A4865B93}']
    function SQL(const aTexto: string): iQuery;
    function Parametro(const aNome: string; const aValor: Variant): iQuery;
    function ParametroNulo(const aNome: string; aTipo: TFieldType): iQuery;
    procedure Abrir;
    procedure Executar;
    procedure Fechar;
    function DataSet: TDataSet;
  end;

  iMemTable = interface
    ['{E28246E8-8AA5-49F4-A71B-BD9EB9E5565F}']
    function DefinirCampo(const aNome: string; aTipo: TFieldType;
      const aTamanho: Integer = 0;
      const aObrigatorio: Boolean = False): iMemTable;
    procedure Criar;
    procedure Limpar;
    function DataSet: TDataSet;
  end;

implementation

end.

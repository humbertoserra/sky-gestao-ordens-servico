unit Sky.Model.Connection.Interfaces;

interface

uses
  Data.DB;

type
  iConfiguracao = interface
    function Servidor: string;
    function Banco: string;
    function Usuario: string;
    function Senha: string;
    function Charset: string;
    function Dialeto: Integer;
  end;

  iConexao = interface
    procedure Conectar;
    procedure Desconectar;
    function Conectada: Boolean;

    procedure IniciarTransacao;
    procedure ConfirmarTransacao;
    procedure DesfazerTransacao;
    function EmTransacao: Boolean;
  end;

  iQuery = interface
    function SQL(const ATexto: string): iQuery;

    function Parametro(
      const ANome: string;
      const AValor: Variant): iQuery;

    function ParametroNulo(
      const ANome: string;
      ATipo: TFieldType): iQuery;

    procedure Abrir;
    procedure Executar;
    procedure Fechar;

    function DataSet: TDataSet;

  end;

implementation

end.

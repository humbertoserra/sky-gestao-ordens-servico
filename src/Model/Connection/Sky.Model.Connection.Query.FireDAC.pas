unit Sky.Model.Connection.Query.FireDAC;

interface

uses
  System.SysUtils,
  Sky.Model.Connection.Interfaces,
  Sky.Model.Connection.FireDAC, Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TModelQueryFireDAC = class(TInterfacedObject, iQuery)
  private
    FConexao: iConexao;
    FQuery: TFDQuery;

    procedure VerificarConexao;
    constructor Create(const aConexao: iConexao);
  public
    destructor Destroy; override;
    class function New(const aConexao: iConexao): iQuery;
    function SQL(const aTexto: string): iQuery;

    function Parametro(
      const aNome: string;
      const aValor: Variant): iQuery;

    function ParametroNulo(
      const aNome: string;
      aTipo: TFieldType): iQuery;

    procedure Abrir;
    procedure Executar;
    procedure Fechar;

    function DataSet: TDataSet;
  end;

implementation

{ TModelQueryFireDAC }

constructor TModelQueryFireDAC.Create(const AConexao: iConexao);
var
  ConexaoFireDAC: iConexaoFireDAC;
begin
  inherited Create;

  if AConexao = nil then
    raise Exception.Create('Conexao nao informada.');

  if not Supports(AConexao, iConexaoFireDAC, ConexaoFireDAC) then
    raise Exception.Create('A Query exige uma conexao FireDAC.');

  FConexao := AConexao;
  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := ConexaoFireDAC.ObterConexaoNativa;

  if FQuery.Connection = nil then
    raise Exception.Create('Conexao nativa FireDAC nao informada.');
end;

destructor TModelQueryFireDAC.Destroy;
begin
  FQuery.Free;
  inherited Destroy;
end;

class function TModelQueryFireDAC.New(
  const AConexao: iConexao): iQuery;
begin
  Result := Self.Create(AConexao);
end;

procedure TModelQueryFireDAC.VerificarConexao;
begin
  if not FConexao.Conectada then
    raise Exception.Create('Conexao fechada.');
end;

function TModelQueryFireDAC.SQL(const ATexto: string): iQuery;
begin
  FQuery.Close;
  FQuery.SQL.Text := ATexto;
  Result := Self;
end;

function TModelQueryFireDAC.Parametro(
  const ANome: string;
  const AValor: Variant): iQuery;
begin
  FQuery.ParamByName(ANome).Value := AValor;
  Result := Self;
end;

function TModelQueryFireDAC.ParametroNulo(
  const ANome: string;
  ATipo: TFieldType): iQuery;
begin
  if ATipo = ftUnknown then
    raise Exception.Create('Informe o tipo do parametro nulo.');

  with FQuery.ParamByName(ANome) do
  begin
    DataType := ATipo;
    Clear;
    Bound := True;
  end;

  Result := Self;
end;

procedure TModelQueryFireDAC.Abrir;
begin
  VerificarConexao;
  FQuery.Open;
end;

procedure TModelQueryFireDAC.Executar;
begin
  VerificarConexao;
  FQuery.ExecSQL;
end;

procedure TModelQueryFireDAC.Fechar;
begin
  FQuery.Close;
end;

function TModelQueryFireDAC.DataSet: TDataSet;
begin
  Result := FQuery;
end;

end.


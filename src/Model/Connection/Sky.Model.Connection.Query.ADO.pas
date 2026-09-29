unit Sky.Model.Connection.Query.ADO;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Variants,
  Data.DB,
  Data.Win.ADODB,
  Sky.Model.Connection.Interfaces,
  Sky.Model.Connection.ADO;

type
  TModelQueryADO = class(TInterfacedObject, iQuery)
  private
    FConexao: iConexao;
    FQuery: TADOQuery;

    constructor Create(const AConexao: iConexao);
    procedure VerificarConexao;
  public
    destructor Destroy; override;
    class function New(const AConexao: iConexao): iQuery;

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

constructor TModelQueryADO.Create(const AConexao: iConexao);
var
  ConexaoADO: iConexaoADO;
begin
  inherited Create;

  if AConexao = nil then
    raise Exception.Create('Conexao nao informada.');

  if not Supports(AConexao, iConexaoADO, ConexaoADO) then
    raise Exception.Create('A Query exige uma conexao ADO.');

  FConexao := AConexao;
  FQuery := TADOQuery.Create(nil);
  FQuery.Connection := ConexaoADO.ObterConexaoNativa;

  if FQuery.Connection = nil then
    raise Exception.Create('Conexao nativa ADO nao informada.');

  FQuery.ParamCheck := True;
end;

destructor TModelQueryADO.Destroy;
begin
  FQuery.Free;
  inherited Destroy;
end;

class function TModelQueryADO.New(
  const AConexao: iConexao): iQuery;
begin
  Result := Self.Create(AConexao);
end;

procedure TModelQueryADO.VerificarConexao;
begin
  if not FConexao.Conectada then
    raise Exception.Create('Conexao fechada.');
end;

function TModelQueryADO.SQL(const ATexto: string): iQuery;
begin
  FQuery.Close;
  FQuery.SQL.Text := ATexto;
  Result := Self;
end;

function TModelQueryADO.Parametro(
  const ANome: string;
  const AValor: Variant): iQuery;
var
  I: Integer;
  Encontrado: Boolean;
begin
  Encontrado := False;

  for I := 0 to FQuery.Parameters.Count - 1 do
    if SameText(FQuery.Parameters[I].Name, ANome) then
    begin
      FQuery.Parameters[I].Direction := pdInput;
      FQuery.Parameters[I].Value := AValor;
      Encontrado := True;
    end;

  if not Encontrado then
    raise Exception.CreateFmt(
      'Parametro nao encontrado: %s', [ANome]);

  Result := Self;
end;

function TModelQueryADO.ParametroNulo(
  const ANome: string;
  ATipo: TFieldType): iQuery;
var
  I: Integer;
  Encontrado: Boolean;
begin
  if ATipo = ftUnknown then
    raise Exception.Create('Informe o tipo do parametro nulo.');

  Encontrado := False;

  for I := 0 to FQuery.Parameters.Count - 1 do
    if SameText(FQuery.Parameters[I].Name, ANome) then
    begin
      FQuery.Parameters[I].Direction := pdInput;
      FQuery.Parameters[I].DataType := ATipo;

      if ATipo in [ftString, ftFixedChar, ftWideString] then
        if FQuery.Parameters[I].Size = 0 then
          FQuery.Parameters[I].Size := 1;

      FQuery.Parameters[I].Value := Null;
      Encontrado := True;
    end;

  if not Encontrado then
    raise Exception.CreateFmt(
      'Parametro nao encontrado: %s', [ANome]);

  Result := Self;
end;

procedure TModelQueryADO.Abrir;
begin
  VerificarConexao;
  FQuery.Open;
end;

procedure TModelQueryADO.Executar;
begin
  VerificarConexao;
  FQuery.ExecSQL;
end;

procedure TModelQueryADO.Fechar;
begin
  FQuery.Close;
end;

function TModelQueryADO.DataSet: TDataSet;
begin
  Result := FQuery;
end;

end.

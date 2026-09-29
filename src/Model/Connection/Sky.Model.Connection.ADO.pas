unit Sky.Model.Connection.ADO;

interface

uses
  System.SysUtils,
  Data.Win.ADODB,
  Sky.Model.Connection.Interfaces;

type
  iConexaoADO = interface
    ['{C30212BF-0024-47AD-9308-7F41667F9C97}']
    function ObterConexaoNativa: TADOConnection;
  end;

  TModelConexaoADO = class(TInterfacedObject, iConexao, iConexaoADO)
  private
    FConfiguracao: iConfiguracao;
    FConexao: TADOConnection;

    constructor Create(const AConfiguracao: iConfiguracao);
  public
    destructor Destroy; override;

    class function New(
      const AConfiguracao: iConfiguracao): iConexao;

    procedure Conectar;
    procedure Desconectar;
    function Conectada: Boolean;

    procedure IniciarTransacao;
    procedure ConfirmarTransacao;
    procedure DesfazerTransacao;
    function EmTransacao: Boolean;
    function ObterConexaoNativa: TADOConnection;

    property ConexaoNativa: TADOConnection read FConexao;
  end;

implementation

var
  Instancia: iConexao;


{ TModelConexaoADO }

function ValorODBC(const AValor: string): string;
begin
  Result := '{' +
    StringReplace(AValor, '}', '}}', [rfReplaceAll]) + '}';
end;

function ValorOLEDB(const AValor: string): string;
begin
  Result := '"' +
    StringReplace(AValor, '"', '""', [rfReplaceAll]) + '"';
end;

constructor TModelConexaoADO.Create(const AConfiguracao: iConfiguracao);
var
  ConexaoODBC: string;
begin
  inherited Create;

  if AConfiguracao = nil then
    raise Exception.Create('Configuracao nao informada.');

  FConfiguracao := AConfiguracao;
  FConexao := TADOConnection.Create(nil);
  FConexao.LoginPrompt := False;
  FConexao.KeepConnection := True;

  ConexaoODBC :=
    'DRIVER={Firebird/InterBase(r) driver};' +
    'DBNAME=' + ValorODBC(
      FConfiguracao.Servidor + ':' + FConfiguracao.Banco) + ';' +
    'UID=' + ValorODBC(FConfiguracao.Usuario) + ';' +
    'PWD=' + ValorODBC(FConfiguracao.Senha) + ';' +
    'CHARSET=' + ValorODBC(FConfiguracao.Charset) + ';' +
    'DIALECT=' + IntToStr(FConfiguracao.Dialeto) + ';';

  FConexao.ConnectionString :=
    'Provider=MSDASQL.1;' +
    'Persist Security Info=False;' +
    'Extended Properties=' + ValorOLEDB(ConexaoODBC) + ';';
end;

destructor TModelConexaoADO.Destroy;
begin
  FConexao.Free;

  inherited;
end;

class function TModelConexaoADO.New(const AConfiguracao: iConfiguracao): iConexao;
begin
  if Instancia = nil then
    Instancia := TModelConexaoADO.Create(AConfiguracao);

  Result := Instancia;
end;

function TModelConexaoADO.ObterConexaoNativa: TADOConnection;
begin
  Result := FConexao;
end;

function TModelConexaoADO.Conectada: Boolean;
begin
  Result := FConexao.Connected;
end;

procedure TModelConexaoADO.Conectar;
begin
  if not Conectada then
    FConexao.Connected := True;
end;

procedure TModelConexaoADO.ConfirmarTransacao;
begin
  if not EmTransacao then
    raise Exception.Create('Nao existe transacao ativa.');

  FConexao.CommitTrans;
end;

procedure TModelConexaoADO.Desconectar;
begin
  if EmTransacao then
    raise Exception.Create(
      'Finalize a transacao antes de desconectar.');

  FConexao.Connected := False;
end;

procedure TModelConexaoADO.DesfazerTransacao;
begin
  if EmTransacao then
    FConexao.RollbackTrans;
end;

function TModelConexaoADO.EmTransacao: Boolean;
begin
  Result := False;

  if Conectada then
    Result := FConexao.InTransaction;
end;

procedure TModelConexaoADO.IniciarTransacao;
begin
  if not Conectada then
    raise Exception.Create('Conexao fechada.');

  if EmTransacao then
    raise Exception.Create('Ja existe uma transacao ativa.');

  FConexao.BeginTrans;
end;

initialization

finalization
  Instancia := nil;

end.

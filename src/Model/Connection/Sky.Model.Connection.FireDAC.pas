unit Sky.Model.Connection.FireDAC;

interface

uses
  Sky.Model.Connection.Interfaces, System.SysUtils, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, FireDAC.Comp.Client, FireDAC.Phys.FBDef,
  FireDAC.Phys.IBBase, FireDAC.Phys.FB, FireDAC.Comp.UI;

type
  iConexaoFireDAC = interface
    ['{58BE0F96-362D-42F7-B89A-6104BA8CDF85}']
    function ObterConexaoNativa: TFDConnection;
  end;

  TModelConexaoFireDAC = class(TInterfacedObject, iConexao, iConexaoFireDAC)
  private
    FConfiguracao: iConfiguracao;
    FConexao: TFDConnection;

    constructor Create(const aConfiguracao: iConfiguracao);
  public
    destructor Destroy; override;
    class function New(const aConfiguracao: iConfiguracao): iConexao;
    procedure Conectar;
    procedure Desconectar;
    function Conectada: Boolean;

    procedure IniciarTransacao;
    procedure ConfirmarTransacao;
    procedure DesfazerTransacao;
    function EmTransacao: Boolean;
    function ObterConexaoNativa: TFDConnection;

    property ConexaoNativa: TFDConnection read FConexao;
  end;

var
  Instancia: iConexao;

implementation

{ TModelConexaoFireDAC }

constructor TModelConexaoFireDAC.Create(const aConfiguracao: iConfiguracao);
begin
  inherited Create;

  if AConfiguracao = nil then
    raise Exception.Create('Configuracao nao informada.');

  FConfiguracao := aConfiguracao;
  FConexao := TFDConnection.Create(nil);
  FConexao.LoginPrompt := False;

  FConexao.Params.Values['DriverID'] := 'FB';
  FConexao.Params.Values['Server'] := FConfiguracao.Servidor;

  if (LowerCase(FConexao.Params.Values['Server']) = 'localhost') or
     (FConexao.Params.Values['Server'] = '127.0.0.1') then
    FConexao.Params.Values['Protocol'] := 'LOCAL'
  else
    FConexao.Params.Values['Protocol'] := 'TCPIP';

  FConexao.Params.Values['Database'] := FConfiguracao.Banco;
  FConexao.Params.Values['User_Name'] := FConfiguracao.Usuario;
  FConexao.Params.Values['Password'] := FConfiguracao.Senha;
  FConexao.Params.Values['CharacterSet'] := FConfiguracao.Charset;
  FConexao.Params.Values['SQLDialect'] :=
    IntToStr(FConfiguracao.Dialeto);
end;

destructor TModelConexaoFireDAC.Destroy;
begin
  FConexao.Free;
  inherited;
end;

class function TModelConexaoFireDAC.New(const aConfiguracao: iConfiguracao): iConexao;
begin
  if Instancia = nil then
    Instancia := Self.Create(AConfiguracao);

  Result := Instancia;
end;

function TModelConexaoFireDAC.ObterConexaoNativa: TFDConnection;
begin
  Result := FConexao;
end;

function TModelConexaoFireDAC.Conectada: Boolean;
begin
  Result:= FConexao.Connected;
end;

procedure TModelConexaoFireDAC.Conectar;
begin
  if not Conectada then
    FConexao.Connected := True;
end;

procedure TModelConexaoFireDAC.ConfirmarTransacao;
begin
  if not EmTransacao then
    raise Exception.Create('Nao existe transacao ativa.');

  FConexao.Commit;
end;

procedure TModelConexaoFireDAC.Desconectar;
begin
  if EmTransacao then
    raise Exception.Create(
      'Finalize a transacao antes de desconectar.');

  FConexao.Connected := False;
end;

procedure TModelConexaoFireDAC.DesfazerTransacao;
begin
  if EmTransacao then
    FConexao.Rollback;
end;

function TModelConexaoFireDAC.EmTransacao: Boolean;
begin
  Result := False;

  if Conectada then
    Result := FConexao.InTransaction;
end;

procedure TModelConexaoFireDAC.IniciarTransacao;
begin
  if not Conectada then
    raise Exception.Create('Conexao fechada.');

  if EmTransacao then
    raise Exception.Create('Ja existe uma transacao ativa.');

  FConexao.StartTransaction;
end;

initialization

finalization
  Instancia := nil;

end.

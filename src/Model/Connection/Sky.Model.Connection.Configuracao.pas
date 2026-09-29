unit Sky.Model.Connection.Configuracao;

interface

uses
  System.SysUtils,
  System.IniFiles,
  Sky.Model.Connection.Interfaces;

type
  TModelConfiguracaoFiredac = class(TInterfacedObject, iConfiguracao)
  private
    FServidor: string;
    FBanco: string;
    FUsuario: string;
    FSenha: string;
    FCharset: string;
    FDialeto: Integer;

    constructor Create(const aArquivo: string);
  public
    destructor Destroy; override;
    class function New(const aArquivo: string): iConfiguracao;
    function Servidor: string;
    function Banco: string;
    function Usuario: string;
    function Senha: string;
    function Charset: string;
    function Dialeto: Integer;
  end;

implementation

{ TModelConfiguracaoFiredac }

constructor TModelConfiguracaoFiredac.Create(const aArquivo: string);
var
  lArquivoIni: TIniFile;
begin
  inherited Create;

  if not FileExists(aArquivo) then
    raise Exception.CreateFmt(
      'Arquivo de configuracao nao encontrado: %s', [aArquivo]);

  lArquivoIni := TIniFile.Create(AArquivo);
  try
    FServidor := Trim(
      lArquivoIni.ReadString('CONFIG', 'SERVIDOR', 'localhost'));

    FBanco := Trim(
      lArquivoIni.ReadString('CONFIG', 'DATABASE', ''));

    FUsuario := Trim(
      lArquivoIni.ReadString('CONFIG', 'USUARIO', ''));

    FSenha := lArquivoIni.ReadString('CONFIG', 'SENHA', '');

    FCharset := Trim(
      lArquivoIni.ReadString('CONFIG', 'CHARSET', 'UTF8'));

    FDialeto := StrToIntDef(
      Trim(lArquivoIni.ReadString('CONFIG', 'DIALECT', '3')), 0);
  finally
    lArquivoIni.Free;
  end;

  if FServidor = '' then
    raise Exception.Create('Informe SERVIDOR no arquivo de configuracao.');

  if FBanco = '' then
    raise Exception.Create('Informe DATABASE no arquivo de configuracao.');

  if FUsuario = '' then
    raise Exception.Create('Informe USUARIO no arquivo de configuracao.');

  if FCharset = '' then
    raise Exception.Create('Informe CHARSET no arquivo de configuracao.');

  if FDialeto <> 3 then
    raise Exception.Create('Este projeto utiliza DIALECT=3.');

end;

destructor TModelConfiguracaoFiredac.Destroy;
begin

  inherited;
end;

function TModelConfiguracaoFiredac.Banco: string;
begin
  Result := FBanco;
end;

function TModelConfiguracaoFiredac.Charset: string;
begin
  Result := FCharset;
end;

function TModelConfiguracaoFiredac.Dialeto: Integer;
begin
  Result := FDialeto;
end;

class function TModelConfiguracaoFiredac.New(
  const aArquivo: string): iConfiguracao;
begin
  Result := Self.Create(aArquivo);
end;

function TModelConfiguracaoFiredac.Senha: string;
begin
  Result := FSenha;
end;

function TModelConfiguracaoFiredac.Servidor: string;
begin
  Result := FServidor;
end;

function TModelConfiguracaoFiredac.Usuario: string;
begin
  Result := FUsuario;
end;

end.

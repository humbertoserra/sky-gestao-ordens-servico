unit Sky.Service.Log;

interface

uses
  SysUtils;

type
  EOperacaoRecusada = class(Exception);

  TLogLevel = (llInfo, llWarn, llError, llFatal);

  TLog = class
  public
    class procedure Registrar(aNivel: TLogLevel; const aRotina, aContexto,
      aMensagem: string; const aExtra: string = '');

    class procedure Excecao(aNivel: TLogLevel; const aRotina, aContexto: string;
      aErro: Exception; const aExtra: string = '');
  end;

implementation

uses
  windows;

{ TLog }

procedure GravarLinha(const AArquivo, ALinha: string);
var
  Arquivo: THandle;
  Dados: UTF8String;
  Gravados: DWORD;
begin
  Dados := UTF8Encode(WideString(ALinha + #13#10));

  // Acesso somente para acrescentar, sem sobrescrever o arquivo.
  Arquivo := CreateFile(
    PChar(AArquivo),
    FILE_APPEND_DATA,
    FILE_SHARE_READ or FILE_SHARE_WRITE,
    nil,
    OPEN_ALWAYS,
    FILE_ATTRIBUTE_NORMAL,
    0);

  if Arquivo = INVALID_HANDLE_VALUE then
    RaiseLastOSError;

  try
    if not WriteFile(
      Arquivo, Dados[1], Length(Dados), Gravados, nil) then
      RaiseLastOSError;

    if Gravados <> DWORD(Length(Dados)) then
      raise Exception.Create('Gravacao incompleta do log.');
  finally
    CloseHandle(Arquivo);
  end;
end;

function LimparCampo(const ATexto: string): string;
begin
  Result := StringReplace(ATexto, #13, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, #10, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, '|', '/', [rfReplaceAll]);
  Result := Trim(Result);
end;

function NomeNivel(ANivel: TLogLevel): string;
begin
  case aNivel of
    llInfo:  Result := 'INFO';
    llWarn:  Result := 'WARN';
    llFatal: Result := 'FATAL';
  else
    Result := 'ERROR';
  end;
end;

class procedure TLog.Excecao(aNivel: TLogLevel; const aRotina,
  aContexto: string; aErro: Exception; const aExtra: string);
var
  Extra: string;
begin
  if AErro = nil then
    Exit;

  if AErro is EAbort then
    Exit;

  try
    if (AErro is EAccessViolation) or
       (AErro is EInvalidPointer) or
       (AErro is EOutOfMemory) then
      ANivel := llFatal
    else if AErro is EOperacaoRecusada then
      ANivel := llWarn;

    Extra := 'Exception=' + AErro.ClassName;

    if AExtra <> '' then
      Extra := Extra + '; ' + AExtra;

    Registrar(ANivel, ARotina, AContexto, AErro.Message, Extra);
  except
    on E: Exception do
      OutputDebugString(
        PChar('Sky.Log: falha ao registrar excecao.'));
  end;
end;

class procedure TLog.Registrar(aNivel: TLogLevel; const aRotina, aContexto,
  aMensagem, aExtra: string);
var
  Instante: TDateTime;
  Pasta: string;
  Arquivo: string;
  Linha: string;
begin
  try
    Instante := Now;
    Pasta := ExtractFilePath(ParamStr(0)) + 'Logs';

    if not DirectoryExists(Pasta) then
      if not ForceDirectories(Pasta) then
        if not DirectoryExists(Pasta) then
          raise Exception.Create('Nao foi possivel criar a pasta Logs.');

    Arquivo := Pasta + '\Sky_' +
      FormatDateTime('yyyymmdd', Instante) + '.log';

    Linha :=
      FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Instante) +
      ' | ' + NomeNivel(ANivel) +
      ' | ' + LimparCampo(ARotina) +
      ' | ' + LimparCampo(AContexto) +
      ' | ' + LimparCampo(AMensagem) +
      ' | ' + LimparCampo(AExtra);

    GravarLinha(Arquivo, Linha);
  except
    // Uma falha no log nao substitui o erro da aplicacao.
    on E: Exception do
      OutputDebugString(
        PChar('Sky.Log: ' + E.Message));
  end;
end;

end.

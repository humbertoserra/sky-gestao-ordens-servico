unit Sky.Service.Utils;

interface

uses
  Vcl.Forms;

function TratarNavegacao(
  AFormulario: TCustomForm;
  ATecla: Word): Boolean;
function SomenteDigitos(const ATexto: string): string;
function FormatarTelefone(const ATelefone: string): string;

implementation

uses
  Winapi.Windows,
  Winapi.Messages,
  Data.DB,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Buttons,
  Vcl.ComCtrls,
  Vcl.DBGrids;

function TratarNavegacao(
  AFormulario: TCustomForm;
  ATecla: Word): Boolean;
var
  Controle: TWinControl;
  Ancestral: TWinControl;
  Grid: TDBGrid;
  Consulta: TDataSet;
begin
  Result := False;

  if AFormulario = nil then
    Exit;

  if not (ATecla in [VK_RETURN, VK_ESCAPE]) then
    Exit;

  { Preserva combinacoes com Alt, Ctrl ou Shift. }
  if (GetKeyState(VK_MENU) < 0) or
     (GetKeyState(VK_CONTROL) < 0) or
     (GetKeyState(VK_SHIFT) < 0) then
    Exit;

  Controle := AFormulario.ActiveControl;

  if Controle = nil then
    Exit;

  { Combo aberto: deixa o proprio controle tratar a tecla. }
  if Controle is TComboBox then
    if TComboBox(Controle).DroppedDown then
      Exit;

  { Calendario aberto: preserva sua operacao normal. }
  if Controle is TDateTimePicker then
    if TDateTimePicker(Controle).DroppedDown then
      Exit;

  { Localiza o grid, inclusive quando o foco esta no editor interno. }
  Grid := nil;
  Ancestral := Controle;

  while Ancestral <> nil do
  begin
    if Ancestral is TDBGrid then
    begin
      Grid := TDBGrid(Ancestral);
      Break;
    end;

    Ancestral := Ancestral.Parent;
  end;

  if Grid <> nil then
  begin
    { Enter permanece sob responsabilidade do grid. }
    if ATecla = VK_RETURN then
      Exit;

    { Durante a edicao, Esc permanece sob responsabilidade do grid. }
    if Grid.EditorMode then
      Exit;

    Consulta := nil;

    if Grid.DataSource <> nil then
      Consulta := Grid.DataSource.DataSet;

    if Consulta <> nil then
      if Consulta.State in [dsEdit, dsInsert] then
        Exit;

    { Grid em consulta: Esc retorna ao controle anterior. }
    Result := True;
    AFormulario.Perform(WM_NEXTDLGCTL, 1, 0);
    Exit;
  end;

  { Enter no memo continua inserindo uma nova linha. }
  if (Controle is TCustomMemo) and
     (ATecla = VK_RETURN) then
    Exit;

  { Enter no botao continua executando sua acao. }
  if ((Controle is TButton) or
      (Controle is TBitBtn)) and
     (ATecla = VK_RETURN) then
    Exit;

  { Controles contemplados pela navegacao. }
  if not (
    (Controle is TCustomEdit) or
    (Controle is TComboBox) or
    (Controle is TDateTimePicker) or
    (Controle is TCustomCheckBox) or
    (Controle is TButton) or
    (Controle is TBitBtn)
  ) then
    Exit;

  Result := True;

  if ATecla = VK_RETURN then
    AFormulario.Perform(WM_NEXTDLGCTL, 0, 0)
  else
    AFormulario.Perform(WM_NEXTDLGCTL, 1, 0);
end;

function SomenteDigitos(const ATexto: string): string;
var
  I: Integer;
begin
  Result := '';

  for I := 1 to Length(ATexto) do
    if (ATexto[I] >= '0') and (ATexto[I] <= '9') then
      Result := Result + ATexto[I];
end;

function FormatarTelefone(const ATelefone: string): string;
var
  Numero: string;
begin
  Numero := SomenteDigitos(ATelefone);

  case Length(Numero) of
    10:
      Result :=
        '(' + Copy(Numero, 1, 2) + ') ' +
        Copy(Numero, 3, 4) + '-' +
        Copy(Numero, 7, 4);

    11:
      Result :=
        '(' + Copy(Numero, 1, 2) + ') ' +
        Copy(Numero, 3, 5) + '-' +
        Copy(Numero, 8, 4);
  else
    Result := Numero;
  end;
end;

end.

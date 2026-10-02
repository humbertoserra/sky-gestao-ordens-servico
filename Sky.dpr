program Sky;

uses
  System.SysUtils,
  Vcl.Dialogs,
  Vcl.Forms,
  Sky.View.Principal in 'src\View\Sky.View.Principal.pas' {FrmPrincipal},
  Sky.Model.Entity.Cliente in 'src\Model\Entity\Sky.Model.Entity.Cliente.pas',
  Sky.Model.Entity.Interfaces in 'src\Model\Entity\Sky.Model.Entity.Interfaces.pas',
  Sky.Model.Entity.OrdemServico in 'src\Model\Entity\Sky.Model.Entity.OrdemServico.pas',
  Sky.Model.Entity.ItemOrdem in 'src\Model\Entity\Sky.Model.Entity.ItemOrdem.pas',
  Sky.Model.Entity in 'src\Model\Entity\Sky.Model.Entity.pas',
  Sky.Model.DAO.Interfaces in 'src\Model\DAO\Sky.Model.DAO.Interfaces.pas',
  Sky.Model.DAO in 'src\Model\DAO\Sky.Model.DAO.pas',
  Sky.Model.Connection.Interfaces in 'src\Model\Connection\Sky.Model.Connection.Interfaces.pas',
  Sky.Model.Connection.Configuracao in 'src\Model\Connection\Sky.Model.Connection.Configuracao.pas',
  Sky.Model.Connection.FireDAC in 'src\Model\Connection\Sky.Model.Connection.FireDAC.pas',
  Sky.Model.Connection.ADO in 'src\Model\Connection\Sky.Model.Connection.ADO.pas',
  Sky.Model.Connection.Query.ADO in 'src\Model\Connection\Sky.Model.Connection.Query.ADO.pas',
  Sky.Model.Connection.Query.FireDAC in 'src\Model\Connection\Sky.Model.Connection.Query.FireDAC.pas',
  Sky.Model.DAO.Cliente in 'src\Model\DAO\Sky.Model.DAO.Cliente.pas',
  Sky.Model.DAO.ItemOrdem in 'src\Model\DAO\Sky.Model.DAO.ItemOrdem.pas',
  Sky.Model.DAO.OrdemServico in 'src\Model\DAO\Sky.Model.DAO.OrdemServico.pas',
  Sky.View.Clientes in 'src\View\Sky.View.Clientes.pas' {FrmClientes},
  Sky.Controller.Interfaces in 'src\Controller\Sky.Controller.Interfaces.pas',
  Sky.Controller.Clientes in 'src\Controller\Sky.Controller.Clientes.pas',
  Sky.Controller.Factory in 'src\Controller\Sky.Controller.Factory.pas',
  Sky.Service.Utils in 'src\Service\Sky.Service.Utils.pas',
  Sky.Controller.OrdemServico in 'src\Controller\Sky.Controller.OrdemServico.pas',
  Sky.Model.Connection.MemTable.ADO in 'src\Model\Connection\Sky.Model.Connection.MemTable.ADO.pas',
  Sky.Model.Connection.MemTable.FireDAC in 'src\Model\Connection\Sky.Model.Connection.MemTable.FireDAC.pas',
  Sky.View.Relatorios in 'src\View\Sky.View.Relatorios.pas' {FrmRelatoriosOS},
  Sky.Model.DAO.RelatorioOS in 'src\Model\DAO\Sky.Model.DAO.RelatorioOS.pas',
  Sky.Controller.RelatorioOS in 'src\Controller\Sky.Controller.RelatorioOS.pas',
  Sky.View.ImpressaoOS in 'src\View\Sky.View.ImpressaoOS.pas' {FrmImpressaoOS},
  Sky.Service.Log in 'src\Service\Sky.Service.Log.pas';

{$R *.res}

var
  ControllerFactory: iControllerFactory;

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;

  try
    try
      ControllerFactory := TControllerFactory.New(
        ExtractFilePath(ParamStr(0)) + 'config.ini',
        adFireDAC);

      Application.CreateForm(TFrmPrincipal, FrmPrincipal);
      FrmPrincipal.Inicializar(ControllerFactory);

      Application.Run;
    except
      on E: Exception do
      begin
        TLog.Excecao(llError, 'Sky.Inicializar', 'Inicializacao da aplicacao', E);
        ShowMessage('Nao foi possivel executar a aplicacao: ' +
          E.Message);

        ExitCode := 1;
      end;
    end;
  finally
    ControllerFactory := nil;
  end;

end.

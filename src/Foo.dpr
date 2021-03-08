program Foo;

uses
  Vcl.Forms,
  Main in 'Main.pas' {fMain},
  DatasetLoop in 'DatasetLoop.pas' {fDatasetLoop},
  ClienteServidor in 'ClienteServidor.pas' {fClienteServidor},
  ExceptionManager in 'ExceptionManager.pas',
  FileLogger in 'FileLogger.pas',
  Foo.Contract in 'Foo.Contract.pas',
  Foo.Utils in 'Foo.Utils.pas',
  Threads in 'Threads.pas' {fThreads},
  ThreadManager in 'ThreadManager.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfMain, fMain);
  Application.CreateForm(TfDatasetLoop, fDatasetLoop);
  Application.CreateForm(TfClienteServidor, fClienteServidor);
  Application.Run;
end.

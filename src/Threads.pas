unit Threads;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, System.UITypes,
  Vcl.ExtCtrls, Vcl.Samples.Spin, ThreadManager;

type
  TfThreads = class(TForm)
    pnlActions: TPanel;
    bCriarThreads: TButton;
    edNumeroThreads: TSpinEdit;
    lblNumeroThreads: TLabel;
    edIntervaloMaximoThreads: TSpinEdit;
    lblIntervaloThreads: TLabel;
    pnlLogger: TPanel;
    ProgressBar: TProgressBar;
    Memo: TMemo;
    procedure bCriarThreadsClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FThreadManager: TThreadManager;
    function ExisteThreadsEmExecucao: Boolean;
    procedure AtualizaProgresso(IDThread: Integer; PercentualDeExecucao: Currency);
    procedure InicializaExecucao(NumeroMaximoDeIteracoes: Integer);
    procedure ExecucaoFinalizada(Sender: TObject);
    procedure FecharFormularioAoFinalizarExecucao(Sender: TObject);
  public
    { Public declarations }
    class procedure OpenForm;
  end;

implementation

{$R *.dfm}

{ TfThreads }

procedure TfThreads.AtualizaProgresso(IDThread: Integer; PercentualDeExecucao: Currency);
const
  THREAD_INICIADA = 'Processamento Iniciado';
  THREAD_FINALIZADA = 'Processamento Finalizado';
  MASK_LOG = '%d=%s';
begin
  if (PercentualDeExecucao > 0) then
    ProgressBar.Position := ProgressBar.Position + 1;

  var i: integer := Memo.Lines.IndexOfName(IDThread.ToString);
  if (i = -1) then
    Memo.Lines.Add(Format(MASK_LOG, [IDThread, THREAD_INICIADA]))
  else
  if (PercentualDeExecucao >= 100) then
    Memo.Lines[i] := Format(MASK_LOG, [IDThread, THREAD_FINALIZADA, Trunc(PercentualDeExecucao), '%']);

end;

procedure TfThreads.bCriarThreadsClick(Sender: TObject);
begin
  if (edNumeroThreads.Value > 0) and (edIntervaloMaximoThreads.Value > 0) then 
  begin
    FThreadManager := TThreadManager.Create(True, edNumeroThreads.Value, edIntervaloMaximoThreads.Value);
    FThreadManager.EventoParaAtualizarProgresso := AtualizaProgresso;
    FThreadManager.EventoParaIniciarProgresso := InicializaExecucao;
    FThreadManager.OnTerminate := ExecucaoFinalizada;
    FThreadManager.Start;
  end
  else
    MessageDlg('O número de threads e o intervalo máximo devem ser informados!', mtError, [mbOk], 0, mbOk);
end;

procedure TfThreads.FecharFormularioAoFinalizarExecucao(Sender: TObject);
begin
  Self.Close;
end;

procedure TfThreads.ExecucaoFinalizada(Sender: TObject);
begin
  bCriarThreads.Enabled := True;
end;

function TfThreads.ExisteThreadsEmExecucao: Boolean;
begin
  Result := False;
  if Assigned(FThreadManager) and (FThreadManager.IsRunning) then
  begin
    Result := True;
    if MessageDlg('Existem threads em execução no momento. Deseja encerrar a execução e fechar o formaulário?',  mtConfirmation, [mbYes, mbCancel], 0, mbCancel) = mrYes then
    begin
      FThreadManager.CancelaExecucao( FecharFormularioAoFinalizarExecucao );
    end;
  end;
end;

procedure TfThreads.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (ExisteThreadsEmExecucao) then
    Action := caNone;
end;

procedure TfThreads.InicializaExecucao(NumeroMaximoDeIteracoes: Integer);
begin
  bCriarThreads.Enabled := False;
  Memo.Clear;
  ProgressBar.Max := NumeroMaximoDeIteracoes;
  ProgressBar.Position := 0;
end;

class procedure TfThreads.OpenForm;
var
  fThreads: TfThreads;
begin
  fThreads := TfThreads.Create(nil);
  try
    fThreads.ShowModal;
  finally
    fThreads.Free;
  end;
end;

end.

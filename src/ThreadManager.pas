unit ThreadManager;

interface

uses
  System.Classes, System.Generics.Collections, System.SysUtils, Vcl.ComCtrls;

type

  TUpdateProgressEvent = reference to procedure (IDThread: Integer; PercentualDeExecucao: Currency);
  TBeginProgressEvent = reference to procedure (NumeroMaximoDeIteracoes: Integer);

  TThreadJob = class;

  TThreadManager = class(TThread)
  private
    FNumeroDeThreads: Integer;
    FIntervaloMaximo: Integer;
    TListaDeThreads: TList<TThreadJob>;
    FEventoParaAtualizarProgresso: TUpdateProgressEvent;
    FEventoParaIniciarProgresso: TBeginProgressEvent;
    function GetIsRunning: Boolean;
    procedure AguardeAFinalizacaoDasThreads;
    procedure ClearList;
  protected
    procedure Execute; override;
  public
    destructor Destroy; override;
    constructor Create(CreateSuspended: Boolean; NumeroDeThreads, IntervaloMaximo: Integer);
    procedure CancelaExecucao(EventoDeCancelamento: TNotifyEvent);
    procedure AtualizarProgresso(IDThread: Integer; PercentualDeExecucao: Currency);
    property EventoParaAtualizarProgresso: TUpdateProgressEvent Read FEventoParaAtualizarProgresso write FEventoParaAtualizarProgresso;
    property EventoParaIniciarProgresso: TBeginProgressEvent Read FEventoParaIniciarProgresso write FEventoParaIniciarProgresso;
    property IsRunning: Boolean read GetIsRunning;
  end;

  TThreadJob = class(TThread)
  private
    FNumeroDeInteracoes: Integer;
    FIntervaloMaximo: Integer;
    FThreadPrincipal: TThreadManager;
  public
    constructor Create(CreateSuspended: Boolean; ThreadPrincipal: TThreadManager; NumeroDeInteracoes, IntervaloMaximo: Integer);
    procedure Execute; override;
  end;

implementation

{ TListThread }

procedure TThreadManager.AguardeAFinalizacaoDasThreads;
begin
  while (Self.IsRunning) do
  begin
    Sleep(25);
  end;
end;

procedure TThreadManager.AtualizarProgresso(IDThread: Integer; PercentualDeExecucao: Currency);
begin
  if (Assigned(Self.EventoParaAtualizarProgresso)) then
  begin
    Synchronize(procedure
    begin
      Self.EventoParaAtualizarProgresso(IDThread, PercentualDeExecucao);
    end);
  end;
end;

procedure TThreadManager.CancelaExecucao(EventoDeCancelamento: TNotifyEvent);
var
  ThreadJob: TThreadJob;
begin
  Self.OnTerminate := EventoDeCancelamento;
  for ThreadJob in TListaDeThreads do
    ThreadJob.Terminate;
end;

procedure TThreadManager.ClearList;
var
  ThreadJob: TThreadJob;
begin
  for ThreadJob in TListaDeThreads do
    ThreadJob.Free;
  TListaDeThreads.Clear;
end;

constructor TThreadManager.Create(CreateSuspended: Boolean; NumeroDeThreads, IntervaloMaximo: Integer);
begin
  inherited Create(CreateSuspended);
  FreeOnTerminate := True;
  FNumeroDeThreads := NumeroDeThreads;
  FIntervaloMaximo := IntervaloMaximo;
  TListaDeThreads := TList<TThreadJob>.Create;
end;

destructor TThreadManager.Destroy;
begin
  ClearList;
  TListaDeThreads.Free;
  inherited;
end;

procedure TThreadManager.Execute;
const
  TOTAL_DE_ITERACOES = 100;
var
  i: Integer;
  ThreadJob: TThreadJob;
begin
  inherited;
  for I := 0 to FNumeroDeThreads-1 do
  begin
    ThreadJob := TThreadJob.Create(True, Self, TOTAL_DE_ITERACOES, FIntervaloMaximo);
    TListaDeThreads.Add( ThreadJob );
  end;

  if (Assigned(FEventoParaIniciarProgresso)) then
  begin
    Synchronize(procedure
    begin
      FEventoParaIniciarProgresso( TListaDeThreads.Count * (TOTAL_DE_ITERACOES+1));
    end);
  end;

  for ThreadJob in TListaDeThreads do
    ThreadJob.Start;

  AguardeAFinalizacaoDasThreads;

end;

function TThreadManager.GetIsRunning: Boolean;
var
  ThreadJob: TThreadJob;
begin
  inherited;
  Result := False;
  if (Assigned(TListaDeThreads)) then
  begin
    for ThreadJob in TListaDeThreads do
    begin
      if (not ThreadJob.Terminated)then
      begin
        Result := True;
        Break;
      end;
    end;
  end;
end;

{ TThreadJob }

constructor TThreadJob.Create(CreateSuspended: Boolean; ThreadPrincipal: TThreadManager; NumeroDeInteracoes, IntervaloMaximo: Integer);
begin
  inherited Create(CreateSuspended);
  FreeOnTerminate := False;
  FThreadPrincipal := ThreadPrincipal;
  FNumeroDeInteracoes := NumeroDeInteracoes;
  FIntervaloMaximo := IntervaloMaximo;
end;

procedure TThreadJob.Execute;
begin
  inherited;
  FThreadPrincipal.AtualizarProgresso(Self.ThreadID, 0);
  Randomize;
  for var i: Integer := 0 to FNumeroDeInteracoes do
  begin
    if (not Self.Terminated)then
    begin
      var Percentual: Currency := ((i+1) / (FNumeroDeInteracoes+1)) * 100;
      var IntervaloRandom: Integer := Round(Random( FIntervaloMaximo ));
      FThreadPrincipal.AtualizarProgresso(Self.ThreadID, Percentual);
      Sleep(IntervaloRandom);
    end;
  end;
  Self.Terminate;
end;

end.

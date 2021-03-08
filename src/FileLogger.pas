unit FileLogger;

interface

uses
  Foo.Contract, System.SysUtils, System.UITypes, Vcl.Dialogs;

type
  TFileLogger = class(TInterfacedObject, ILogger, ILoggerShow)
  private
    FFileName: string;
    FArquivoLog: TextFile;
    FExceptionMessage: string;
    function RegistraLog(Sender: TObject; E: Exception): ILoggerShow;
    procedure ShowExcept;
  public
    constructor Create;
    class function New: ILogger;
  end;

const
  PATH_LOG = 'Log\';
  FILE_LOG = 'Exception.log';

implementation

{ TFileLogger }

constructor TFileLogger.Create;
begin
  FFileName := Format('%s%s%s',[ExtractFilePath(ParamStr(0)), PATH_LOG, FILE_LOG]);

  if (not DirectoryExists(ExtractFileDir(FFileName))) then
    CreateDir(ExtractFileDir(FFileName));

  AssignFile(FArquivoLog, FFileName);
end;

class function TFileLogger.New: ILogger;
begin
  Result := Self.Create;
end;

function TFileLogger.RegistraLog(Sender: TObject; E: Exception): ILoggerShow;
begin
  Result := Self;

  FExceptionMessage := Format('(%s) %s', [Sender.ClassName, E.Message]);

  if FileExists(FFileName) then
    Append(FArquivoLog)
  else
    Rewrite(FArquivoLog);

  WriteLn(FArquivoLog, Format('%s - ERROR: %s', [FormatDateTime('d/mm/yy hh:nn:ss', Now), FExceptionMessage]));

  CloseFile(FArquivoLog);

end;

procedure TFileLogger.ShowExcept;
begin
  MessageDlg(FExceptionMessage, mtError, [mbOk], 0, mbOk);
end;

end.

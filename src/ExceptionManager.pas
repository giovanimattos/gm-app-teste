unit ExceptionManager;

interface

uses System.SysUtils, Foo.Contract;

type
   TExceptionManager = class
   private
     FLogger: ILogger;
   public
     constructor Create(Logger: ILogger);
     procedure DoException(Sender: TObject; E: Exception);
   end;

var
  ExceptionManagerInstance: TExceptionManager;

implementation

uses
  Forms, Vcl.Dialogs, FileLogger;

{ TExceptionManager }

constructor TExceptionManager.Create(Logger: ILogger);
begin
  FLogger := Logger;
  Application.OnException := Self.DoException;
end;

procedure TExceptionManager.DoException(Sender: TObject; E: Exception);
begin
  FLogger
    .RegistraLog(Sender, E)
      .ShowExcept;
end;

initialization
  ExceptionManagerInstance := TExceptionManager.Create( TFileLogger.New );

finalization
  ExceptionManagerInstance.Free;

end.

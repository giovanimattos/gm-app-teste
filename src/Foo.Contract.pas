unit Foo.Contract;

interface

uses
  System.SysUtils;

type

  ILoggerShow = interface
    ['{4E01856F-EDB4-4080-A467-320E5F221D58}']
    procedure ShowExcept;
  end;

  ILogger = interface
    ['{F1CBEA08-8F4D-4E74-AD1B-9CE305CE9E52}']
    function RegistraLog(Sender: TObject; E: Exception): ILoggerShow;
  end;

implementation

end.

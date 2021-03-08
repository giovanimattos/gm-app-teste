unit Foo.Utils;

interface

uses
  System.Types, System.IOUtils, System.SysUtils;

procedure DeleteAllFilesFromDir(const Path: String);

implementation

procedure DeleteAllFilesFromDir(const Path: String);
var
  i: Integer;
  ListaDeArquivos: TStringDynArray;
begin
  ListaDeArquivos := TDirectory.GetFiles(Path);
  for i := 0  to High(ListaDeArquivos) do
  begin
    if TFile.Exists(ListaDeArquivos[i]) then
      TFile.Delete(ListaDeArquivos[i]);
  end;
end;

end.

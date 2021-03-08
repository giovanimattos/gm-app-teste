unit ClienteServidor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Datasnap.DBClient, Data.DB;

type
  TServidor = class
  private
    FPath: AnsiString;
  public
    constructor Create;
    //Tipo do parâmetro não pode ser alterado
    function SalvarArquivos(AData: OleVariant): Boolean;
    procedure DeletaArquivos;
  end;

  TfClienteServidor = class(TForm)
    ProgressBar: TProgressBar;
    btEnviarSemErros: TButton;
    btEnviarComErros: TButton;
    btEnviarParalelo: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btEnviarSemErrosClick(Sender: TObject);
    procedure btEnviarComErrosClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btEnviarParaleloClick(Sender: TObject);
  private
    FPath: AnsiString;
    FServidor: TServidor;

    function InitDataset: TClientDataset;
  public
  end;

var
  fClienteServidor: TfClienteServidor;

const
  QTD_ARQUIVOS_ENVIAR = 100;
  PDF_EXTENSION = '.pdf';
  FILE_NAME = 'pdf.pdf';
  PATH_SERVER = 'Servidor\';
  QTD_MAX_ARQUIVOS_POR_LOTE_DE_ENVIO = 5;

implementation

uses
  IOUtils, Foo.Contract, Foo.Utils;

{$R *.dfm}

procedure TfClienteServidor.btEnviarComErrosClick(Sender: TObject);
var
  cds: TClientDataset;
  i: Integer;
begin
  cds := InitDataset;
  try
    try
      ProgressBar.Position := 0;
      ProgressBar.Max := QTD_ARQUIVOS_ENVIAR;
      for i := 1 to QTD_ARQUIVOS_ENVIAR do
      begin

        cds.Append;
        cds.FieldByName('FileName').AsString := i.ToString;
        TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(String(FPath));
        cds.Post;

        {$REGION Simulação de erro, não alterar}
        if i = (QTD_ARQUIVOS_ENVIAR/2) then
          FServidor.SalvarArquivos(NULL);
        {$ENDREGION}

        if (i mod QTD_MAX_ARQUIVOS_POR_LOTE_DE_ENVIO = 0) or (i = QTD_ARQUIVOS_ENVIAR) then
        begin
          FServidor.SalvarArquivos(cds.Data);
          cds.EmptyDataSet;
        end;

        TThread.Queue(nil, procedure
        begin
          ProgressBar.Position := i;
        end);

      end;

      TThread.Queue(nil, procedure
      begin
        TThread.Synchronize(TThread.CurrentThread, procedure
        begin
          ProgressBar.Position := ProgressBar.Max;
          ShowMessage('Envio Finalizado!');
        end);
      end);
    except
      FServidor.DeletaArquivos;
      raise;
    end;
  finally
    cds.Free;
  end;
end;

procedure TfClienteServidor.btEnviarParaleloClick(Sender: TObject);
begin
  TThread.CreateAnonymousThread(procedure
  begin
    btEnviarSemErrosClick(Sender);
  end).Start;
end;

procedure TfClienteServidor.btEnviarSemErrosClick(Sender: TObject);
var
  cds: TClientDataset;
  i: Integer;
begin
  cds := InitDataset;  
  try
    ProgressBar.Position := 0;
    ProgressBar.Max := QTD_ARQUIVOS_ENVIAR;
    for i := 1 to QTD_ARQUIVOS_ENVIAR do
    begin    
      cds.Append;
      cds.FieldByName('FileName').AsString := i.ToString;
      TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(String(FPath));
      cds.Post;

      if (i mod QTD_MAX_ARQUIVOS_POR_LOTE_DE_ENVIO = 0) or (i = QTD_ARQUIVOS_ENVIAR) then
      begin
        FServidor.SalvarArquivos(cds.Data);
        cds.EmptyDataSet;
      end;

      TThread.Queue(nil, procedure
      begin
        ProgressBar.Position := i;
      end);

    end;

    TThread.Queue(nil, procedure
    begin
      TThread.Synchronize(TThread.CurrentThread, procedure
      begin
        ProgressBar.Position := ProgressBar.Max;
        ShowMessage('Envio Finalizado!');
      end);
    end);

  finally
    cds.Free;
  end;
end;

procedure TfClienteServidor.FormCreate(Sender: TObject);
begin
  inherited;
  FPath := AnsiString(Format('%s%s',[IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))), FILE_NAME]));
  FServidor := TServidor.Create;
end;

procedure TfClienteServidor.FormDestroy(Sender: TObject);
begin
  FServidor.Free;
end;

function TfClienteServidor.InitDataset: TClientDataset;
begin
  Result := TClientDataset.Create(nil);
  Result.FieldDefs.Add('FileName', ftString, 255);
  Result.FieldDefs.Add('Arquivo', ftBlob);
  Result.CreateDataSet;
end;

{ TServidor }

constructor TServidor.Create;
begin
  FPath := AnsiString(Format('%s%s',[ExtractFilePath(ParamStr(0)), PATH_SERVER]));
end;

function TServidor.SalvarArquivos(AData: OleVariant): Boolean;
var
  cds: TClientDataSet;
  FileName: string;
begin
  Result := False;
  cds := TClientDataset.Create(nil);
  try
    try
      cds.Data := AData;

      {$REGION Simulação de erro, não alterar}
      if cds.RecordCount = 0 then
        Exit;
      {$ENDREGION}

      cds.First;

      while not cds.Eof do
      begin
        FileName := Format('%s%s%s',[FPath, cds.FieldByName('FileName').AsString, PDF_EXTENSION]);
        if TFile.Exists(FileName) then
          TFile.Delete(FileName);

        if (not DirectoryExists(ExtractFileDir(FileName))) then
          CreateDir(ExtractFileDir(FileName));

        TBlobField(cds.FieldByName('Arquivo')).SaveToFile(FileName);

        cds.Next;
      end;

      Result := True;
    except
      on e: Exception do
      begin
        Self.DeletaArquivos;
        raise;
      end;
    end;
  finally
    cds.Free;
  end;
end;

procedure TServidor.DeletaArquivos;
begin
  Foo.Utils.DeleteAllFilesFromDir(string(FPath));
end;

end.

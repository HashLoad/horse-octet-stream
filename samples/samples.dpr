program samples;

{$APPTYPE CONSOLE}

uses
  Horse,
  Horse.OctetStream,
  System.Classes,
  System.SysUtils,
  Winapi.Windows;

{$R *.res}

function GetPath: string;
begin
  SetLength(Result, MAX_PATH+1);
  GetModuleFileName(hInstance, PChar(Result), MAX_PATH+1);
  SetLength(Result, Length(PChar(Result)));
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(Result));
end;

var
  App: THorse;

begin
  App := THorse.Create(9000);

  App.Use(OctetStream);

  App.Get('pdf',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      LStream: TFileStream;
    begin
      LStream := TFileStream.Create(GetPath + 'horse.pdf', fmOpenRead);
      Res.Send(LStream);
    end);

  App.Start;
end.

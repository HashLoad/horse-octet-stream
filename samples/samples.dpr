program samples;

{$APPTYPE CONSOLE}

uses
  Horse,
  Horse.OctetStream,
  System.Classes,
  System.SysUtils;

{$R *.res}

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
      LStream := TFileStream.Create(ExtractFilePath(ParamStr(0)) + 'horse.pdf', fmOpenRead);
      Res.Send(LStream);
    end);

  App.Start;
end.

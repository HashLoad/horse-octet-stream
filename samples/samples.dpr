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
      LStream := TFileStream.Create('D:\Embarcadero Conference\2019\samples-octet-stream\horse.pdf', fmOpenRead);
      Res.Send(LStream);
    end);

  App.Start;
end.

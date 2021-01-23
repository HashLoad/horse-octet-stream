program samples;

{$APPTYPE CONSOLE}

uses
  Horse,
  Horse.OctetStream,
  System.Classes,
  System.SysUtils;

{$R *.res}

begin
  THorse.Use(OctetStream);

  THorse.Get('/stream',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      LStream: TFileStream;
    begin
      LStream := TFileStream.Create(ExtractFilePath(ParamStr(0)) + 'horse.pdf', fmOpenRead);
      Res.Send<TStream>(LStream);
    end);

  THorse.Listen(9000);
end.

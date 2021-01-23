program Samples;

{$MODE DELPHI}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Horse, Horse.OctetStream, SysUtils, Classes;

procedure GetStream(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
  LStream: TFileStream;
begin
  LStream := TFileStream.Create(ExtractFilePath(ParamStr(0)) + 'horse.pdf', fmOpenRead);
  Res.Send<TStream>(LStream);
end;

begin
  THorse.Get('/stream', GetStream);
  THorse.Listen(9000);
end.


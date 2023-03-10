program Samples;

{$MODE DELPHI}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Horse,
  Horse.OctetStream, // It's necessary to use the unit
  SysUtils, Classes;

procedure GetStream(Req: THorseRequest; Res: THorseResponse);
var
  LStream: TFileStream;
begin
  // Now you can send your stream:
  LStream := TFileStream.Create(ExtractFilePath(ParamStr(0)) + 'horse.pdf', fmOpenRead);
  Res.Send<TStream>(LStream);
end;

begin
  // It's necessary to add the middleware in the Horse:
  THorse.Use(OctetStream);

  THorse.Get('/stream', GetStream);

  THorse.Listen(9000);
end.


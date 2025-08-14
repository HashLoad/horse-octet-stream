program Samples;

{$MODE DELPHI}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Horse,
  Horse.OctetStream, // It's necessary to use the unit
  SysUtils,
  Classes;

procedure GetStream(Req: THorseRequest; Res: THorseResponse);
var
  LStream: TFileStream;
begin
  // Now you can send your stream:
  LStream := TFileStream.Create(ExtractFilePath(ParamStr(0)) + 'horse.pdf', fmOpenRead);
  Res.Send<TStream>(LStream).ContentType('application/pdf');
end;

procedure PostStream(Req: THorseRequest; Res: THorseResponse);
var
  LType: string;
begin
  // here you could get the Req.ContentType and save the file based on that
  LType := Copy(Req.RawWebRequest.ContentType, Pos('/', Req.RawWebRequest.ContentType) + 1, Req.RawWebRequest.ContentType.Length);
  Req.Body<TBytesStream>.SaveToFile(ExtractFilePath(ParamStr(0)) + 'horse-post.' + LType);
  Res.Status(THTTPStatus.NoContent);
end;

begin
  // It's necessary to add the middleware in the Horse:
  THorse.Use(OctetStream);

  // Add new ContentTypes to work with, the default is always application/octet-stream
  // Please, be careful of adding ContentTypes that exist
  THorseOctetStreamConfig.GetInstance.AcceptContentType.Add('application/pdf');

  THorse.Get('/stream', GetStream);
  THorse.Post('/stream', PostStream);

  THorse.Listen(9000);
end.


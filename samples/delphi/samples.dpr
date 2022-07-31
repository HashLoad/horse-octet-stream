program samples;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  Horse,
  Horse.OctetStream, // It's necessary to use the unit
  System.Classes,
  System.SysUtils,
  System.StrUtils;

begin
  // It's necessary to add the middleware in the Horse:
  THorse.Use(OctetStream);
  
  (*
  Add new ContentTypes to work with, the default is always application/octet-stream
  Please, be careful of adding ContentTypes that exist
  *)
  THorseOctetStreamConfig.GetInstance.AcceptContentType.Add('application/pdf');

  THorse.Get('/stream',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      LStream: TFileStream;
    begin
      // Now you can send your stream:
      LStream := TFileStream.Create(ExtractFilePath(ParamStr(0)) + 'horse.pdf', fmOpenRead);
      Res.Send<TStream>(LStream);
    end);

    THorse.Post('/stream',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      LType: string;
    begin
      // here you could get the Req.ContentType and save the file based on that

      if
      not (MatchText(Req.RawWebRequest.ContentType, THorseOctetStreamConfig.GetInstance.AcceptContentType.ToArray))
      then
        raise Exception.Create('Unknown content type: ' + Req.RawWebRequest.ContentType);

      LType := Copy(Req.RawWebRequest.ContentType, Pos('/', Req.RawWebRequest.ContentType) + 1, Req.RawWebRequest.ContentType.Length);

      Req.Body<TBytesStream>.SaveToFile('horse-post.' + LType);
      Res.Send('OK');
    end);

  THorse.Listen(9000);
end.

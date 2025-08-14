program samples;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  Horse,
  Horse.OctetStream,
  System.Classes,
  System.SysUtils,
  System.StrUtils;

begin
{$IFDEF MSWINDOWS}
  IsConsole := False;
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}

  // It's necessary to add the middleware in the Horse:
  THorse.Use(OctetStream);

  // Add new ContentTypes to work with, the default is always application/octet-stream
  // Please, be careful of adding ContentTypes that exist
  THorseOctetStreamConfig.GetInstance.AcceptContentType.Add('application/pdf');

  THorse.Get('/stream',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      LStream: TFileStream;
    begin
      // Now you can send your stream:
      LStream := TFileStream.Create(ExtractFilePath(ParamStr(0)) + 'horse.pdf', fmOpenRead);
      Res.Send<TStream>(LStream).ContentType('application/pdf');
    end);

  THorse.Post('/stream',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      LType: string;
    begin
      if not MatchText(Req.RawWebRequest.ContentType, THorseOctetStreamConfig.GetInstance.AcceptContentType.ToArray) then
        raise EHorseException.New.Error('Unknown Content-Type: ' + Req.RawWebRequest.ContentType).Status(THTTPStatus.BadRequest);
      // here you could get the Req.ContentType and save the file based on that
      LType := Copy(Req.RawWebRequest.ContentType, Pos('/', Req.RawWebRequest.ContentType) + 1, Req.RawWebRequest.ContentType.Length);
      Req.Body<TBytesStream>.SaveToFile(ExtractFilePath(ParamStr(0)) + 'horse-post.' + LType);
      Res.Status(THTTPStatus.NoContent);
    end);

  THorse.Listen(9000,
    procedure
    begin
      Writeln(Format('Server is running on %s:%d', [THorse.Host, THorse.Port]));
      Readln;
    end);
end.

unit Horse.OctetStream;

interface

uses
  System.SysUtils, Horse, System.Classes;

type
  TFileReturn = class
    Stream: TStream;
    Name: string;
  end;

procedure OctetStream(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

uses
  Web.HTTPApp;

function StreamToString(aStream: TStream): string;
var
  SS: TStringStream;
begin
  if aStream <> nil then
  begin
    SS := TStringStream.Create('');
    try
      SS.CopyFrom(aStream, 0);  // No need to position at 0 nor provide size
      Result := SS.DataString;
    finally
      SS.Free;
    end;
  end else
  begin
    Result := '';
  end;
end;

procedure OctetStream(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  LWebRequest: TWebRequest;
  LWebResponse: TWebResponse;
  LContent: TObject;
  LWriter: TBinaryWriter;
begin
  LWebRequest := THorseHackRequest(Req).GetWebRequest;

  if (LWebRequest.MethodType in [mtPost, mtPut]) and
    (LWebRequest.ContentType = 'application/octet-stream') then
  begin

    LContent := TMemoryStream.Create;
    LWriter := TBinaryWriter.Create(TStream(LContent));
    LWriter.Write(LWebRequest.RawContent);
    THorseHackRequest(Req).SetBody(LContent);
  end;

  Next;

  LWebResponse := THorseHackResponse(Res).GetWebResponse;
  LContent := THorseHackResponse(Res).GetContent;
   if Assigned(LContent) and LContent.InheritsFrom(TStream) then
  begin
    LWebResponse.ContentType := 'application/octet-stream';
    LWebResponse.SetCustomHeader('Content-Disposition','attachment; filename="file"');
    LWebResponse.ContentLength := TStream(LContent).Size;
    LWebResponse.Content := StreamToString(TStream(LContent));
    LContent.Free;
  end;
   if Assigned(LContent) and LContent.InheritsFrom(TFileReturn) then
  begin
    LWebResponse.ContentType := 'application/octet-stream';
    LWebResponse.SetCustomHeader('Content-Disposition','attachment; '+
      'filename="' + TFileReturn(LContent).Name + '"');
    LWebResponse.ContentLength := TFileReturn(LContent).Stream.Size;
    LWebResponse.Content := StreamToString(TFileReturn(LContent).Stream);
    LContent.Free;
  end;
  TFileReturn

end;


end.

unit Horse.OctetStream;

interface

uses System.SysUtils, Horse, System.Classes;

type
  TFileReturn = class
  private
    FName: string;
    FStream: TStream;
  public
    property Stream: TStream read FStream write FStream;
    property Name: string read FName write FName;
    constructor Create(AName: string; AStream: TStream);
  End;

procedure OctetStream(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

uses Web.HTTPApp;

procedure OctetStream(Req: THorseRequest; Res: THorseResponse; Next: TProc);
const
  CONTENT_TYPE = 'application/octet-stream';
var
  LWebRequest: TWebRequest;
  LWebResponse: TWebResponse;
  LContent: TObject;
  LWriter: TBinaryWriter;
begin
  LWebRequest := THorseHackRequest(Req).GetWebRequest;

  if (LWebRequest.MethodType in [mtPost, mtPut]) and (LWebRequest.ContentType = CONTENT_TYPE) then
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
    LWebResponse.ContentType := CONTENT_TYPE;
    LWebResponse.SetCustomHeader('Content-Disposition', 'attachment');
    LWebResponse.ContentStream := TStream(LContent);
    LWebResponse.SendResponse;
    LContent.Free;
  end;

  if Assigned(LContent) and LContent.InheritsFrom(TFileReturn) then
  begin
    LWebResponse.ContentType := CONTENT_TYPE;
    LWebResponse.SetCustomHeader('Content-Disposition', 'attachment; ' + 'filename="' + TFileReturn(LContent).Name + '"');
    LWebResponse.ContentStream := TFileReturn(LContent).Stream;
    LWebResponse.SendResponse;
  end;
end;

{ TFileReturn }

constructor TFileReturn.Create(AName: string; AStream: TStream);
begin
  Name := AName;
  Stream := AStream;
end;

end.

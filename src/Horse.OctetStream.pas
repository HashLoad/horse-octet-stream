unit Horse.OctetStream;

interface

uses System.SysUtils, Horse, System.Classes;

type
  TFileReturn = class
  private
    FName: string;
    FStream: TStream;
    FInline: Boolean;
  public
    property Stream: TStream read FStream write FStream;
    property Name: string read FName write FName;
    property &Inline: Boolean read FInline write FInline;
    constructor Create(AName: string; AStream: TStream; const AInline: Boolean = False); reintroduce;
  end;

procedure OctetStream(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

uses Web.HTTPApp, System.Math;

procedure GetAllDataAsStream(ARequest: TWebRequest; AStream: TMemoryStream);
var
  BytesRead, ContentLength: Integer;
  Buffer: array [0 .. 1023] of Byte;
begin
  AStream.Clear;

  ARequest.ReadTotalContent;
  ContentLength := ARequest.ContentLength;
  while ContentLength > 0 do
  begin
    BytesRead := ARequest.ReadClient(Buffer[0], Min(ContentLength, SizeOf(Buffer)));
    if BytesRead < 1 then
      Break;
    AStream.WriteBuffer(Buffer[0], BytesRead);
    Dec(ContentLength, BytesRead);
  end;
  AStream.Position := 0;
end;

procedure OctetStream(Req: THorseRequest; Res: THorseResponse; Next: TProc);
const
  CONTENT_TYPE = 'application/octet-stream';
var
  LWebRequest: TWebRequest;
  LWebResponse: TWebResponse;
  LContent: TObject;
begin
  LWebRequest := THorseHackRequest(Req).GetWebRequest;

  if (LWebRequest.MethodType in [mtPost, mtPut]) and (LWebRequest.ContentType = CONTENT_TYPE) then
  begin
    LContent := TMemoryStream.Create;
    GetAllDataAsStream(LWebRequest, TMemoryStream(LContent));
    THorseHackRequest(Req).SetBody(LContent);
  end;

  Next;

  LWebResponse := THorseHackResponse(Res).GetWebResponse;
  LContent := THorseHackResponse(Res).GetContent;

  if Assigned(LContent) and LContent.InheritsFrom(TStream) then
  begin
    if LWebResponse.ContentType.Trim.IsEmpty then
    begin
      LWebResponse.ContentType := CONTENT_TYPE;
    end;

    LWebResponse.SetCustomHeader('Content-Disposition', 'attachment');
    LWebResponse.FreeContentStream := False;
    LWebResponse.ContentStream := TStream(LContent);
    LWebResponse.SendResponse;
  end;

  if Assigned(LContent) and LContent.InheritsFrom(TFileReturn) then
  begin
    if LWebResponse.ContentType.Trim.IsEmpty then
    begin
      LWebResponse.ContentType := CONTENT_TYPE;
    end;

    if TFileReturn(LContent).&Inline then
    begin
      LWebResponse.SetCustomHeader('Content-Disposition', 'inline; ' + 'filename="' + TFileReturn(LContent).Name + '"');
    End
    else
    begin
      LWebResponse.SetCustomHeader('Content-Disposition', 'attachment; ' + 'filename="' + TFileReturn(LContent).Name + '"');
    end;

    LWebResponse.ContentStream := TFileReturn(LContent).Stream;
    LWebResponse.SendResponse;
  end;
end;

{ TFileReturn }

constructor TFileReturn.Create(AName: string; AStream: TStream; const AInline: Boolean = False);
begin
  Name := AName;
  Stream := AStream;
  &Inline := AInline;
end;

End.

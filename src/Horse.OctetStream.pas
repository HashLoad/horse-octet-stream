unit Horse.OctetStream;

interface

uses
  {$IF DEFINED(FPC)}
    SysUtils, Classes,
  {$ELSE}
    System.SysUtils, System.Classes,
  {$ENDIF}
  Horse, Horse.Commons;

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

procedure OctetStream(Req: THorseRequest; Res: THorseResponse; Next: {$IF DEFINED(FPC)}TNextProc{$ELSE}  TProc {$ENDIF});

implementation

uses
  {$IF DEFINED(FPC)}
    httpdefs, Math;
  {$ELSE}
    Web.HTTPApp, System.Math;
  {$ENDIF}

procedure GetAllDataAsStream(ARequest: {$IF DEFINED(FPC)}TRequest{$ELSE}  TWebRequest {$ENDIF}; AStream: TMemoryStream);
var
  BytesRead, ContentLength: Integer;
  Buffer: array [0 .. 1023] of Byte;
  LStringStream: TStringStream;
begin
  AStream.Clear;
  {$IF  DEFINED(FPC)}
   LStringStream := TStringStream.Create(ARequest.Content);
   try
     LStringStream.SaveToStream(AStream);
   finally
     LStringStream.Free;
   end;
  {$ELSE}
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
  {$ENDIF}
  AStream.Position := 0;
end;

procedure OctetStream(Req: THorseRequest; Res: THorseResponse; Next: {$IF DEFINED(FPC)}TNextProc{$ELSE}  TProc {$ENDIF});
const
  CONTENT_TYPE = 'application/octet-stream';
var
  LWebRequest: {$IF DEFINED(FPC)}TRequest{$ELSE}  TWebRequest {$ENDIF};
  LWebResponse: {$IF DEFINED(FPC)}TResponse{$ELSE}  TWebResponse {$ENDIF};
  LContent: TObject;
  LContentTMemoryStream: TMemoryStream;
begin
  LWebRequest := THorseHackRequest(Req).GetWebRequest;

  if ({$IF DEFINED(FPC)} StringCommandToMethodType(LWebRequest.Method) {$ELSE} LWebRequest.MethodType{$ENDIF} in [mtPost, mtPut]) and (LWebRequest.ContentType = CONTENT_TYPE) then
  begin
    LContent := TMemoryStream.Create;
    LContentTMemoryStream :=  TMemoryStream(LContent);
    GetAllDataAsStream(LWebRequest, LContentTMemoryStream);
    THorseHackRequest(Req).SetBody(LContent);
  end;

  Next;

  LWebResponse := THorseHackResponse(Res).GetWebResponse;
  LContent := THorseHackResponse(Res).GetContent;

  if Assigned(LContent) and LContent.InheritsFrom(TStream) then
  begin
    if Trim(LWebResponse.ContentType).IsEmpty then
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
    if Trim(LWebResponse.ContentType).IsEmpty then
    begin
      LWebResponse.ContentType := CONTENT_TYPE;
    end;

    if TFileReturn(LContent).&Inline then
    begin
      LWebResponse.SetCustomHeader('Content-Disposition', 'inline; ' + 'filename="' + TFileReturn(LContent).Name + '"');
    end
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

end.

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

procedure GetAllDataAsStream(ARequest: THorseRequest; AStream: TMemoryStream);
var
{$IF DEFINED(FPC)}
  LStringStream: TStringStream;
{$ELSE}
  BytesRead, ContentLength: Integer;
  Buffer: array [0 .. 1023] of Byte;
{$ENDIF}
begin
  AStream.Clear;
  {$IF DEFINED(FPC)}
   LStringStream := TStringStream.Create(ARequest.RawWebRequest.Content);
   try
     LStringStream.SaveToStream(AStream);
   finally
     LStringStream.Free;
   end;
  {$ELSE}
  ARequest.RawWebRequest.ReadTotalContent;

  ContentLength := ARequest.RawWebRequest.ContentLength;
  while ContentLength > 0 do
  begin
    BytesRead := ARequest.RawWebRequest.ReadClient(Buffer[0], Min(ContentLength, SizeOf(Buffer)));
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
  CONTENT_DISPOSITION = 'Content-Disposition';
var
  LContent: TObject;
  LContentTMemoryStream: TMemoryStream;
begin
  if (Req.MethodType in [mtPost, mtPut, mtPatch]) and (Req.RawWebRequest.ContentType = CONTENT_TYPE) then
  begin
    LContent := TMemoryStream.Create;
    LContentTMemoryStream :=  TMemoryStream(LContent);
    GetAllDataAsStream(Req, LContentTMemoryStream);
    Req.Body(LContent);
  end;

  Next;

  LContent := Res.Content;

  if Assigned(LContent) and LContent.InheritsFrom(TStream) then
  begin
    if Trim(Res.RawWebResponse.ContentType).IsEmpty then
      Res.ContentType(CONTENT_TYPE);

    if Res.RawWebResponse.GetCustomHeader(CONTENT_DISPOSITION).IsEmpty then
      Res.RawWebResponse.SetCustomHeader(CONTENT_DISPOSITION, 'attachment');
    Res.RawWebResponse.FreeContentStream := False;
    Res.RawWebResponse.ContentStream := TStream(LContent);
    Res.RawWebResponse.SendResponse;
  end;

  if Assigned(LContent) and LContent.InheritsFrom(TFileReturn) then
  begin
    if Trim(Res.RawWebResponse.ContentType).IsEmpty then
      Res.ContentType(CONTENT_TYPE);

    if TFileReturn(LContent).&Inline then
      Res.RawWebResponse.SetCustomHeader(CONTENT_DISPOSITION, 'inline; ' + 'filename="' + TFileReturn(LContent).Name + '"')
    else
      Res.RawWebResponse.SetCustomHeader(CONTENT_DISPOSITION, 'attachment; ' + 'filename="' + TFileReturn(LContent).Name + '"');

    Res.RawWebResponse.ContentStream := TFileReturn(LContent).Stream;
    Res.RawWebResponse.SendResponse;
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

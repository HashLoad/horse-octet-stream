unit Horse.OctetStream;

{$IF DEFINED(FPC)}
  {$MODE DELPHI}{$H+}
{$ENDIF}

interface

uses
{$IF DEFINED(FPC)}
  SysUtils,
  StrUtils,
  Classes,
  httpdefs,
  Math,
{$ELSE}
  Web.HTTPApp,
  System.Math,
  System.SysUtils,
  System.Classes,
  System.StrUtils,
{$ENDIF}
  Horse,
  Horse.Commons,
  Horse.OctetStream.Config;

type
  THorseOctetStreamConfig = Horse.OctetStream.Config.THorseOctetStreamConfig;

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
    {$IF CompilerVersion <= 28}
      Assert(Length(ARequest.RawWebRequest.RawContent) = ARequest.RawWebRequest.ContentLength);
    {$ELSE}
      ARequest.RawWebRequest.ReadTotalContent;
    {$ENDIF}
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
  LContentType: string;
begin
  LContentType := CONTENT_TYPE;

  if THorseOctetStreamConfig.GetInstance.AcceptContentType.Count = 0 then
    THorseOctetStreamConfig.GetInstance.AcceptContentType.Add(CONTENT_TYPE);

  if (Req.MethodType in [mtPost, mtPut, mtPatch]) then
  begin
    if (MatchText(Req.RawWebRequest.ContentType, THorseOctetStreamConfig.GetInstance.AcceptContentType.ToArray)) then
    begin
      LContentType := Req.RawWebRequest.ContentType;
      LContent := TMemoryStream.Create;
      LContentTMemoryStream :=  TMemoryStream(LContent);
      GetAllDataAsStream(Req, LContentTMemoryStream);
      Req.Body(LContent);
    end
    else
      raise EHorseException.New.Error('Unknown Content-Type: ' + Req.RawWebRequest.ContentType).Status(THTTPStatus.BadRequest);
  end;

  Next;

  LContent := Res.Content;

  if Assigned(LContent) and LContent.InheritsFrom(TStream) then
  begin
    TStream(LContent).Position := 0;

    if Trim(Res.RawWebResponse.ContentType).IsEmpty then
      Res.ContentType(LContentType);

    if Res.RawWebResponse.GetCustomHeader(CONTENT_DISPOSITION).IsEmpty then
      Res.RawWebResponse.SetCustomHeader(CONTENT_DISPOSITION, 'attachment');
    Res.RawWebResponse.FreeContentStream := False;
    Res.RawWebResponse.ContentStream := TStream(LContent);
    Res.RawWebResponse.SendResponse;
  end;

  if Assigned(LContent) and LContent.InheritsFrom(TFileReturn) then
  begin
    TFileReturn(LContent).Stream.Position := 0;

    if Trim(Res.RawWebResponse.ContentType).IsEmpty then
      Res.ContentType(LContentType);

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

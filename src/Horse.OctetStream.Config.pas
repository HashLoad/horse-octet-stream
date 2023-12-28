unit Horse.OctetStream.Config;

{$IF DEFINED(FPC)}
  {$MODE DELPHI}{$H+}
{$ENDIF}

interface

uses
{$IF DEFINED(FPC)}
  SysUtils,
  Classes,
{$ELSE}
  System.SysUtils,
  System.Classes,
{$ENDIF}
  Generics.Collections;

type
  TAcceptContentType = class(TList<string>)
  end;

  THorseOctetStreamConfig = class
  strict private
    class var FInstance: THorseOctetStreamConfig;
    function GetAcceptContentType: TAcceptContentType;
    var FAcceptContentType: TAcceptContentType;
  protected
    class function GetDefaultInstance: THorseOctetStreamConfig;
  public
    constructor Create;
    destructor Destroy; override;
    class function GetInstance: THorseOctetStreamConfig;
    class destructor OnDestroy;
    property AcceptContentType: TAcceptContentType read GetAcceptContentType;
  end;

implementation

constructor THorseOctetStreamConfig.Create;
begin
  if not Assigned(FAcceptContentType) then
    FAcceptContentType := TAcceptContentType.Create;
end;

destructor THorseOctetStreamConfig.Destroy;
begin
  if Assigned(FAcceptContentType) then
    FreeAndNil(FAcceptContentType);
  inherited;
end;

function THorseOctetStreamConfig.GetAcceptContentType: TAcceptContentType;
begin
  Result := FAcceptContentType;
end;

class function THorseOctetStreamConfig.GetDefaultInstance: THorseOctetStreamConfig;
begin
  if not Assigned(FInstance) then
    FInstance := THorseOctetStreamConfig.Create;
  Result := FInstance;
end;

class function THorseOctetStreamConfig.GetInstance: THorseOctetStreamConfig;
begin
  Result := THorseOctetStreamConfig.GetDefaultInstance;
end;

class destructor THorseOctetStreamConfig.OnDestroy;
begin
  if Assigned(FInstance) then
    FreeAndNil(FInstance);
end;

end.

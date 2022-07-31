unit Horse.OctetStream.Config;

interface

uses
  {$IF DEFINED(FPC)}
    SysUtils, Classes,
  {$ELSE}
    System.SysUtils, System.Classes
  {$ENDIF},
  Generics.Collections;

type
  TAcceptContentType = class(TList<string>)
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
  published
    { published declarations }
  end;

  THorseOctetStreamConfig = class
  private
    class var FInstance: THorseOctetStreamConfig;
    function GetAcceptContentType: TAcceptContentType;
    var
    FAcceptContentType: TAcceptContentType;
    { private declarations }
  protected
    constructor Create;
    destructor Destroy; override;

    class function GetDefaultInstance: THorseOctetStreamConfig;
    { protected declarations }
  published
    { published declarations }
  public
    class function GetInstance: THorseOctetStreamConfig;
    class destructor OnDestroy;

    /// <summary> Controls which ContentType to work with
    /// </summary>
    /// <remarks>
    /// Please, be careful of adding ContentTypes that exist
    /// <see cref="REST.Types"/>
    /// </remarks>
    property AcceptContentType: TAcceptContentType read GetAcceptContentType;
    { public declarations }
  end;

  { THorseOctetStreamConfig = class
    private
    {FCaseNameDefinition: TCaseNameDefinition;
    FDataSetPrefix: TArray<string>;
    FDateInputIsUTC: Boolean;
    FDateIsFloatingPoint: Boolean;
    FExport: TDataSetSerializeConfigExport;
    FImport: TDataSetSerializeConfigImport;
    class var FInstance: TDataSetSerializeConfig;
    protected
    //class function GetDefaultInstance: TDataSetSerializeConfig;
    public
    constructor Create;
    destructor Destroy; override;
    {property DataSetPrefix: TArray<string> read FDataSetPrefix write FDataSetPrefix;
    property CaseNameDefinition: TCaseNameDefinition read FCaseNameDefinition write FCaseNameDefinition;
    property DateInputIsUTC: Boolean read FDateInputIsUTC write FDateInputIsUTC;
    property DateIsFloatingPoint: Boolean read FDateIsFloatingPoint write FDateIsFloatingPoint;
    property &Export: TDataSetSerializeConfigExport read FExport write FExport;
    property Import: TDataSetSerializeConfigImport read FImport write FImport;
    class function GetInstance: TDataSetSerializeConfig;
    class destructor UnInitialize;
    end; }

implementation

{ THorseOctetStreamConfig }

constructor THorseOctetStreamConfig.Create;
begin
  FAcceptContentType := TAcceptContentType.Create;

end;

destructor THorseOctetStreamConfig.Destroy;
begin
  FreeAndNil(FAcceptContentType);
  inherited;
end;

function THorseOctetStreamConfig.GetAcceptContentType: TAcceptContentType;
begin
  if FAcceptContentType.Count = 0 then
    FAcceptContentType.Add('application/octet-stream');
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

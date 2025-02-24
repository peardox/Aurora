unit NwnERF;

interface

uses SysUtils, Types, Classes, System.Generics.Collections,
     NWNTypes;

type
  // SubObjects of ERF
  TLocString = class
  strict private
    FLanguageID: UInt32;
    FLocSize: Uint32;
    FLocString: String;
  public
    constructor Create;
    destructor Destroy; override;
    procedure FromRawString(Str: TBytes);
    function Language: TLanguageAndGender;
    procedure Read(AStream: TStream);
    property LanguageID: UInt32 read FLanguageID write FLanguageID;
    property LocSize: Uint32 read FLocSize write FLocSize;
    property LocString: String read FLocString write FLocString;
  end;

  TResKey = class
  strict private
    FResRef: String;  //  16 bytes   Filename
    FResID: UInt32;   //  32 bit   Resource ID, starts at 0 and increments
    FResType: UInt16;   //  16 bit   File type
  public
    constructor Create;
    destructor Destroy; override;
    procedure Read(AStream: TStream);
    procedure FromRawString(Str: Array of AnsiChar);
    property ResRef: String read FResRef write FResRef;
    property ResID: Uint32 read FResID write FResID;
    property ResType: UInt16 read FResType write FResType;
  end;

  TResOffset = class
  strict private
    FOffsetToResource: UInt32; // 32 bit offset to file data from beginning of ERF
    FResourceSize: UInt32;     // 32 bit number of bytes
  public
    constructor Create;
    destructor Destroy; override;
    procedure Read(AStream: TStream);
    property OffsetToResource: UInt32 read FOffsetToResource write FOffsetToResource;
    property ResourceSize: UInt32 read FResourceSize write FResourceSize;
  end;

  // Objects for ERF Lists
  TLocStringList = TObjectList<TLocString>;
  TResKeyList = TObjectList<TResKey>;
  TResOffsetList = TObjectList<TResOffset>;

  TERF = class
    FFilename: String;
    FHeader: TERFHeader;
    FLocStrings: TLocStringList;
    FResKeys: TResKeyList;
    FResOffsets: TResOffsetList;
    FSize: UInt32;
    FHeadSize: UInt32;
  private
    procedure DecodeStream(FStream: TStream);
  public
    constructor Create;
    destructor Destroy; override;
    function Open: Boolean;
    property Filename: String read FFilename write FFilename;
    property Header: TERFHeader read FHeader write FHeader;
    property LocStrings: TLocStringList read FLocStrings write FLocStrings;
    property ResKeys: TResKeyList read FResKeys write FResKeys;
    property ResOffsets: TResOffsetList read FResOffsets write FResOffsets;
    property Size: UInt32 read FSize;
    property HeadSize: UInt32 read FHeadSize;
  end;

  TResRefIndexID = TDictionary<UInt16, TResType>;
  TResRefIndexExt = TDictionary<String, TResType>;

  TResRefIndex = class
    strict private
      FID: TResRefIndexID;
      FExt: TResRefIndexExt;
      function GetExt(Index: Cardinal): String;
      function GetID(Ext: String): Cardinal;
    public
      constructor Create;
      destructor Destroy; override;
      function IsValid(Index: Cardinal): Boolean;
      property ResID: TResRefIndexID read FID;
      property ResExt: TResRefIndexExt read FExt;
      property Ext[Index: Cardinal]: String read GetExt;
      property ID[Ext: String]: Cardinal read GetID;
  end;

  var
    ResRef: TResRefIndex;

implementation

uses IOUtils;

{ TERF }

constructor TERF.Create;
begin
  FLocStrings := TLocStringList.Create(True);
  FResKeys := TResKeyList.Create(True);
  FResOffsets := TResOffsetList.Create(True);
end;

procedure TERF.DecodeStream(FStream: TStream);
var
  I: Integer;
  ALocString: TLocString;
  AResKey: TResKey;
  AResOffset: TResOffset;
begin
  try
    FStream.Position := 0;
    FSize := FStream.Size;
    if FStream.Size >= SizeOf(FHeader) then
      begin
        // Read Header
        FStream.Read(FHeader, SizeOf(FHeader));

        if FHeader.LanguageCount > 0 then
          begin
            FStream.Position := FHeader.OffsetToLocalizedString;
            for I := 0 to FHeader.LanguageCount - 1 do
              begin
                ALocString := TLocString.Create;
                ALocString.Read(FStream);
                FLocStrings.Add(ALocString);
              end;
          end;

        if FHeader.EntryCount > 0 then
          begin
            FStream.Position := FHeader.OffsetToKeyList;
            for I := 0 to FHeader.EntryCount - 1 do
              begin
                AResKey := TResKey.Create;
                AResKey.Read(FStream);
                FResKeys.Add(AResKey);
              end;

            for I := 0 to FHeader.EntryCount - 1 do
              begin
                AResOffset := TResOffset.Create;
                AResOffset.Read(FStream);
                FResOffsets.Add(AResOffset);
              end;
          end;
        FHeadSize := FStream.Position;
      end;
  finally
  end;

end;

destructor TERF.Destroy;
begin
  FreeAndNil(FLocStrings);
  FreeAndNil(FResKeys);
  FreeAndNil(FResOffsets);
  inherited;
end;

function TERF.Open: Boolean;
var
  FS: Int64;
  FStream: TStream;
begin
  Result := False;
  FStream := Nil;

  if not(FFilename.IsEmpty) and FileExists(FFilename) then
    begin
      FS := TFile.GetSize(FFilename);
      if FS > 0 then
        begin
          try
            if FS < BIG_FILE then
              begin
                FStream := TMemoryStream.Create as TStream;
                TMemoryStream(FStream).LoadFromFile(FFilename);
              end
            else
              FStream := TFileStream.Create(FFilename, fmOpenRead) as TStream;
          finally
            if Assigned(FStream) then
              begin
                DecodeStream(FStream);
                FreeAndNil(FStream);
                Result := True;
              end;
          end;
        end;
    end;
end;

{ TLocString }

constructor TLocString.Create;
begin
end;

destructor TLocString.Destroy;
begin
  inherited;
end;

procedure TLocString.FromRawString(Str: TBytes);
var
  I: Integer;
begin
  for I := 0 to FLocSize - 1 do
    FLocString := FLocString + String(AnsiChar(Str[I]));
end;

function TLocString.Language: TLanguageAndGender;
begin
  Result.Sex := TSex(FLanguageID and 1);
  Result.Lang := TLanguageID(FLanguageID shr 1);
end;

procedure TLocString.Read(AStream: TStream);
var
  Bytes: TBytes;
begin
  try
    AStream.Read(FLanguageID, SizeOf(FLanguageID));
    AStream.Read(FLocSize, SizeOf(FLocSize));
    SetLength(Bytes, FLocSize);
    AStream.Read(Bytes, FLocSize);
    FromRawString(Bytes);
  finally
    SetLength(Bytes, 0);
  end;
end;

{ TResKey }

constructor TResKey.Create;
begin
end;

destructor TResKey.Destroy;
begin
  inherited;
end;

procedure TResKey.FromRawString(Str: array of AnsiChar);
var
  I: Integer;
  C: AnsiChar;
begin
  for I := 0 to 15 do
    begin
      C := AnsiChar(Str[I]);
      if C = Chr(0) then
        break;
      FResRef := FResRef + String(C);
    end;
end;

procedure TResKey.Read(AStream: TStream);
var
  Bytes: Array[0..15] of AnsiChar;
  W: UInt16;
begin
  try
    AStream.Read(Bytes, 16);
    FromRawString(Bytes);
    AStream.Read(FResID, SizeOf(FResID));
    AStream.Read(FResType, SizeOf(FResType));
    // Read one last Word - unused so ignore it
    AStream.Read(W, SizeOf(W));
  finally

  end;

end;

{ TResOffset }

constructor TResOffset.Create;
begin
end;

destructor TResOffset.Destroy;
begin
  inherited;
end;

procedure TResOffset.Read(AStream: TStream);
begin
  try
    AStream.Read(FOffsetToResource, SizeOf(FOffsetToResource));
    AStream.Read(FResourceSize, SizeOf(FResourceSize));
  finally

  end;
end;


{ TResRefIndex }

constructor TResRefIndex.Create;
var
  I: Integer;
begin
  FID := TResRefIndexID.Create;
  FExt:= TResRefIndexExt.Create;
  for I := Low(CResType) to High(CResType) do
    begin
      if not FID.TryAdd(CResType[I].res, CResType[I]) then
        Raise Exception.CreateFmt('Can''t create TResRefIndexID for key : %d', [CResType[I].res]);
      if not FExt.TryAdd(String(CResType[I].ext), CResType[I]) then
        Raise Exception.CreateFmt('Can''t create TResRefIndexID for key : %s', [String(CResType[I].ext)]);
    end;
end;

destructor TResRefIndex.Destroy;
begin
  FreeAndNil(FID);
  FreeAndNil(FExt);
  inherited;
end;

function TResRefIndex.GetExt(Index: Cardinal): String;
var
  V: TResType;
begin
  if FID.TryGetValue(Index, V) then
    Result := V.ext
  else
    Result := Format('DECODE_ERROR (%X/%d)', [Index,Index]);
end;

function TResRefIndex.IsValid(Index: Cardinal): Boolean;
var
  V: TResType;
begin
  if FID.TryGetValue(Index, V) then
    Result := True
  else
    Result := False;
end;

function TResRefIndex.GetID(Ext: String): Cardinal;
var
  V: TResType;
begin
  if FExt.TryGetValue(Ext, V) then
    Result := V.res
  else
    Result := $FFFF;
end;

initialization
  ResRef := TResRefIndex.Create;
finalization
  FreeAndNil(ResRef);

end.

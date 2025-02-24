unit NWNTypes;

interface
  Uses Classes, SysUtils;

type
  Nullx116 = Array[0..115] of Byte;

  TFourCC = packed record
  public
    function ToString: String;
  var
    case Cardinal of
      0: (AsInt: UInt32);
      1: (AsChar: Array [0..3] of AnsiChar);
  end;

  TERFHeader = packed record
    FileType:  					      TFourCC; 	//	4 char     "ERF ", "MOD ", "SAV ", "HAK " as appropriate
    Version:   					      TFourCC; 	//	4 char     "V1.0"
    LanguageCount: 				    UInt32; 	  //  Number of Strings in the Localized String Table
    LocalizedStringSize: 		  UInt32;		//	Total size (bytes) of Localized String Table
    EntryCount:					      UInt32; 	//	Number of files packed into ERF
    OffsetToLocalizedString: 	UInt32;
    OffsetToKeyList:  			  UInt32;
    OffsetToResourceList:		  UInt32;
    BuildYear:  				      UInt32; 	//	since 1900
    BuildDay:	  				      UInt32; 	//	since January 1st
    DescriptionStr:				    UInt32; 	//	Ref 4 bytes  strref for file description
    Reserved:					        Nullx116; // 116 zero bytes
  end;

  TLanguageID = (
    English = 0,
    French = 1,
    German = 2,
    Italian = 3,
    Spanish = 4,
    Polish = 5,
    Korean = 128,
    ChineseTraditional = 129,
    ChineseSimplified = 130,
    Japanese = 131
    );

  TSex = (
    Male,
    Female
    );

  TLanguageAndGender = record
    Sex: TSex;
    Lang: TLanguageID;
  end;

  TEncodingType = (
    bin, ini, txt, mdl, gff, bad
  );

  TExtension = String[3];

  TResType = record
    res: UInt16;
    ext: TExtension;
    enc: TEncodingType;
    desc: String;
  end;

const
  BIG_FILE: UInt64 = 100*1024*1024; // 100M

  CResType:  array[0..42] of TResType = (
    (res : 1 		; ext : 'bmp'; 	enc : bin; 	desc : 'Windows BMP file'),
    (res : 3 		; ext : 'tga'; 	enc : bin; 	desc : 'TGA image format'),
    (res : 4 		; ext : 'wav'; 	enc : bin; 	desc : 'WAV sound file'),
    (res : 6 		; ext : 'plt'; 	enc : bin; 	desc : 'Packed Layered Texture, used for player character skins, allows for multiple color layers'),
    (res : 7 	  ; ext : 'ini'; 	enc : ini;	desc : 'Windows INI file format'),
    (res : 10 	; ext : 'txt';	enc : txt; 	desc : 'Text file'),
    (res : 2002 ; ext : 'mdl'; 	enc : mdl; 	desc : 'Aurora model'),
    (res : 2009 ; ext : 'nss';	enc : txt; 	desc : 'NWScript Source'),
    (res : 2010 ; ext : 'ncs'; 	enc : bin; 	desc : 'NWScript Compiled Script'),
    (res : 2012 ; ext : 'are'; 	enc : gff; 	desc : 'Aurora Engine Area file. Contains information on what tiles are located in an area, as well as other static area properties that cannot change via scripting. For each .are file in a .mod, there must also be a corresponding .git and .gic file having the same ResRef.'),
    (res : 2013 ; ext : 'set'; 	enc : ini;	desc : 'Aurora Engine Tileset'),
    (res : 2014 ; ext : 'ifo'; 	enc : gff; 	desc : 'Module Info File. See the IFO Format document.'),
    (res : 2015 ; ext : 'bic'; 	enc : gff; 	desc : 'Character/Creature'),
    (res : 2016 ; ext : 'wok'; 	enc : mdl; 	desc : 'Walkmesh'),
    (res : 2017 ; ext : '2da'; 	enc : txt; 	desc : '2-D Array'),
    (res : 2022 ; ext : 'txi'; 	enc : txt; 	desc : 'Extra Texture Info'),
    (res : 2023 ; ext : 'git'; 	enc : gff; 	desc : 'Game Instance File. Contains information for all object instances in an area, and all area properties that can change via scripting.'),
    (res : 2025 ; ext : 'uti'; 	enc : gff; 	desc : 'Item Blueprint'),
    (res : 2027 ; ext : 'utc'; 	enc : gff; 	desc : 'Creature Blueprint'),
    (res : 2029 ; ext : 'dlg'; 	enc : gff; 	desc : 'Conversation File'),
    (res : 2030 ; ext : 'itp'; 	enc : gff; 	desc : 'Tile/Blueprint Palette File'),
    (res : 2032 ; ext : 'utt'; 	enc : gff; 	desc : 'Trigger Blueprint'),
    (res : 2033 ; ext : 'dds'; 	enc : bin; 	desc : 'Compressed texture file'),
    (res : 2035 ; ext : 'uts'; 	enc : gff; 	desc : 'Sound Blueprint'),
    (res : 2036 ; ext : 'ltr'; 	enc : bin; 	desc : 'Letter-combo probability info for name generation'),
    (res : 2037 ; ext : 'gff'; 	enc : gff; 	desc : 'Generic File Format. Used when undesirable to create a new file extension for a resource, but the resource is a GFF. (Examples of GFFs include itp, utc, uti, ifo, are, git)'),
    (res : 2038 ; ext : 'fac'; 	enc : gff; 	desc : 'Faction File'),
    (res : 2040 ; ext : 'ute'; 	enc : gff; 	desc : 'Encounter Blueprint'),
    (res : 2042 ; ext : 'utd'; 	enc : gff; 	desc : 'Door Blueprint'),
    (res : 2044 ; ext : 'utp'; 	enc : gff; 	desc : 'Placeable Object Blueprint'),
    (res : 2045 ; ext : 'dft'; 	enc : ini;	desc : 'Default Values file. Used by area properties dialog'),
    (res : 2046 ; ext : 'gic'; 	enc : gff; 	desc : 'Game Instance Comments. Comments on instances are not used by the game, only the toolset, so they are stored in a gic instead of in the git with the other instance properties.'),
    (res : 2047 ; ext : 'gui'; 	enc : gff; 	desc : 'Graphical User Interface layout used by game'),
    (res : 2051 ; ext : 'utm'; 	enc : gff; 	desc : 'Store/Merchant Blueprint'),
    (res : 2052 ; ext : 'dwk'; 	enc : mdl; 	desc : 'Door walkmesh'),
    (res : 2053 ; ext : 'pwk'; 	enc : mdl; 	desc : 'Placeable Object walkmesh'),
    (res : 2056 ; ext : 'jrl'; 	enc : gff; 	desc : 'Journal File'),
    (res : 2058 ; ext : 'utw'; 	enc : gff; 	desc : 'Waypoint Blueprint. See Waypoint GFF document.'),
    (res : 2060 ; ext : 'ssf'; 	enc : bin; 	desc : 'Sound Set File. See Sound Set File Format document'),
    (res : 2064 ; ext : 'ndb'; 	enc : bin; 	desc : 'Script Debugger File'),
    (res : 2065 ; ext : 'ptm'; 	enc : gff; 	desc : 'Plot Manager file/Plot Instance'),
    (res : 2066 ; ext : 'ptt'; 	enc : gff; 	desc : 'Plot Wizard Blueprint'),
    (res : $FFFF; ext : ''; 	  enc : bad; 	desc : 'Invalid resource type')
  );

implementation

{ TFourCC }

function TFourCC.ToString: String;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to 3 do
    Result := Result + String(AsChar[I]);
end;

end.

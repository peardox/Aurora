unit NWNMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  NwnERF, FMX.Memo.Types, FMX.StdCtrls, FMX.Controls.Presentation,
  FMX.ScrollBox, FMX.Memo, FMX.Layouts;

type
  TForm1 = class(TForm)
    Layout1: TLayout;
    Layout2: TLayout;
    Memo1: TMemo;
    Button1: TButton;
    procedure Test;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

const
  TestERF00: String = 'C:\\Users\\simon\\Documents\\Neverwinter Nights\\modules\\TestModule.mod';
  TestERF01: String = 'C:\\Users\\simon\\Documents\\Neverwinter Nights\\saves\\000002 - Start\\Doom of Icewind Dale.sav';
  TestERF02: String = 'D:\\SteamLibrary\\steamapps\\common\\Neverwinter Nights\\data\\nwm\\Neverwinter Nights - Doom of Icewind Dale.nwm';
  TestERF03: String = 'D:\\SteamLibrary\\steamapps\\common\\Neverwinter Nights\\data\\nwm\\Chapter1.nwm';
  TestERF04: String = 'C:\Users\simon\Documents\Neverwinter Nights\saves\000003 - Community\\AHTD - Character Generator.sav';

implementation

{$R *.fmx}

procedure TForm1.FormCreate(Sender: TObject);
begin
  Test;
end;

procedure TForm1.Test;
var
  ERF: TERF;
  I: Integer;
begin
  ERF := TERF.Create;
  try
    ERF.Filename := TestERF02;
    if ERF.Open then
      begin
        Memo1.Lines.Add(Format('SizeOf ERF = %X (%d)',[ERF.Size,ERF.Size]));
        Memo1.Lines.Add(Format('SizeOf All Headers = %X (%d)',[ERF.HeadSize,ERF.HeadSize]));
        Memo1.Lines.Add(Format('SizeOf ERF Header = %X (%d)',[SizeOf(ERF.Header), SizeOf(ERF.Header)]));
        Memo1.Lines.Add('');
        Memo1.Lines.Add(Format('FileType    : %s (%X)',[ERF.Header.FileType.ToString, ERF.Header.FileType.AsInt]));
        Memo1.Lines.Add(Format('Version     : %s (%X)',[ERF.Header.Version.ToString, ERF.Header.Version.AsInt]));
        Memo1.Lines.Add(Format('Languages   : %d',[ERF.Header.LanguageCount]));
        Memo1.Lines.Add(Format('Loc Size    : %d',[ERF.Header.LocalizedStringSize]));
        Memo1.Lines.Add(Format('EntryCount  : %d',[ERF.Header.EntryCount]));
        Memo1.Lines.Add(Format('Loc Strings : %d (%X)',[ERF.Header.OffsetToLocalizedString, ERF.Header.OffsetToLocalizedString]));
        Memo1.Lines.Add(Format('Keylist     : %d (%X)',[ERF.Header.OffsetToKeyList, ERF.Header.OffsetToKeyList]));
        Memo1.Lines.Add(Format('ResList     : %d (%X)',[ERF.Header.OffsetToResourceList, ERF.Header.OffsetToResourceList]));
        Memo1.Lines.Add(Format('Year        : %d',[ERF.Header.BuildYear + 1900]));
        Memo1.Lines.Add(Format('Day         : %d',[ERF.Header.BuildDay]));
        Memo1.Lines.Add(Format('StrRef      : %d',[ERF.Header.DescriptionStr]));
        if ERF.LocStrings.Count > 0 then
          begin
            Memo1.Lines.Add('');
            Memo1.Lines.Add(Format('Strings (%d)', [ERF.Header.LanguageCount]));
            for I := 0 to ERF.LocStrings.Count -1 do
              if ERF.LocStrings[I].LocSize > 60 then
                Memo1.Lines.Add(Format('[%d] : ' + sLineBreak + '%s', [I, ERF.LocStrings[I].LocString]))
              else
                Memo1.Lines.Add(Format('[%d] : %s', [I, ERF.LocStrings[I].LocString]));
          end;
        if ERF.ResKeys.Count > 0 then
          begin
            Memo1.Lines.Add('');
            Memo1.Lines.Add(Format('Keys (%d)', [ERF.Header.EntryCount]));
            if not DirectoryExists('export') then
              CreateDir('export');

            for I := 0 to ERF.ResKeys.Count -1 do
              if ResRef.IsValid(ERF.ResKeys[I].ResType) then
                begin
                  Memo1.Lines.Add(Format('[%d] : %s.%s = %d - %d', [I, ERF.ResKeys[I].ResRef, ResRef.Ext[ERF.ResKeys[I].ResType], ERF.ResOffsets[I].OffsetToResource, ERF.ResOffsets[I].ResourceSize]));
                  ERF.Grab('export\\'+ ERF.ResKeys[I].ResRef + '.' + ResRef.Ext[ERF.ResKeys[I].ResType], I);
                end
              else
                begin
                  Memo1.Lines.Add(Format('[%d] : %s.%s = %d - %d', [I, ERF.ResKeys[I].ResRef, ResRef.Ext[ERF.ResKeys[I].ResType], ERF.ResOffsets[I].OffsetToResource, ERF.ResOffsets[I].ResourceSize]));
                  ERF.Grab('export\\' + ERF.ResKeys[I].ResRef + '.' + IntToStr(ERF.ResKeys[I].ResType), I);
                end;
          end;
      end;
  finally
    ERF.Free;
  end;
end;

end.

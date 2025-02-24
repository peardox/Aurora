program NWN;

uses
  System.StartUpCopy,
  FMX.Forms,
  NWNMain in 'NWNMain.pas' {Form1},
  NWNTypes in 'NWNTypes.pas',
  NwnERF in 'NwnERF.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

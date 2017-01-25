program DVac;

uses
  Forms,
  main in 'main.pas' {mainForm},
  FolderTreeClass in 'FolderTreeClass.pas',
  FileUtilUnit in 'FileUtilUnit.pas',
  ThumbViewerClass in 'ThumbViewerClass.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TmainForm, mainForm);
  Application.Run;
end.

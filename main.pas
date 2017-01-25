unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FolderTreeClass, ThumbViewerClass, ComCtrls, ExtCtrls, TypInfo;

type
  TRefreshThread = class ( TThread )
  TreeNode: TTreeNode;
  path: string;
  procedure Execute; override;
  end;

type
  TThumbThread = class ( TThread )
  path: string;
  terminated: boolean;
    procedure Execute; override;
  end;


type
  TmainForm = class(TForm)

    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure OnTreeClick(Sender: TObject);
    procedure OnThumbDblClick(Sender: TObject);
    procedure OnThumbTerminate(Sender:TObject);
  end;

const

  APP_TITLE     = 'DVac Viewer';
  APP_VERSION   = '1.0.0.0';
  APP_COPYRIGHT = 'knight';

var
  mainForm: TmainForm;
  FolderTree: TFolderTreeClass;
  ThumbViewer: TThumbViewerClass;
  Splitter: TSplitter;
  ImageList: TImageList;
  ThumbThread: TThumbThread;
  RefreshThread: TRefreshThread;

implementation

{$R *.dfm}



procedure TRefreshThread.Execute;
var
  path: string;
begin

  path := FolderTree.GetSelectedPath(TreeNode);
  FolderTree.Refresh(TreeNode, path);
end;

procedure TThumbThread.Execute;
begin
   ThumbViewer.Clear;
   ThumbViewer.Prepare(path);
   repeat
   until Terminated or not ThumbViewer.GetNextItem;
   ThumbViewer.Done;

end;

procedure TmainForm.OnThumbTerminate(Sender:TObject);
begin
  ThumbThread.Terminated := True;
end;


procedure TmainForm.FormCreate(Sender: TObject);
begin
  Caption := APP_TITLE;

  FolderTree := TFolderTreeClass.Create(mainForm);
  FolderTree.Left := 10;
  FolderTree.Top  := 10;
  FolderTree.Width := mainForm.ClientWidth div 2 - 20;
  FolderTree.Height := mainForm.ClientHeight - 20;
  FolderTree.ReadOnly := True;
  FolderTree.Align := alLeft;
  FolderTree.Parent := mainForm;
  FolderTree.Refresh(nil, '');
  FolderTree.Show;
  FolderTree.OnClick := OnTreeClick;

  ThumbViewer := TThumbViewerClass.Create(mainForm);
  ThumbViewer.Left := 10;
  ThumbViewer.Top  := 10;
  ThumbViewer.Align := alClient;
  ThumbViewer.Parent := mainForm;
  ThumbViewer.ViewStyle := vsIcon;
  ThumbViewer.OnItemDblClick := OnThumbDblClick;
  ThumbViewer.Show;

  Splitter := TSplitter.Create(mainForm);
  Splitter.Left := FolderTree.Left + FolderTree.Width + 10;
  Splitter.Parent := mainForm;
  Splitter.Align := alLeft;

  RefreshThread := TRefreshThread.Create(True);
  ThumbThread   := TThumbThread.Create(True);

end;



procedure TmainForm.OnTreeClick(Sender: TObject);
var
  path: string;

begin


  if RefreshThread <> nil then RefreshThread.Terminate;
  if ThumbThread <> nil then ThumbThread.Terminate;

  if FolderTree.TopItem = FolderTree.Selected then Exit;

  path := FolderTree.GetSelectedPath(FolderTree.Selected);

  Caption := APP_TITLE + ' [' + path + ']';

  RefreshThread := TRefreshThread.Create(True);
  RefreshThread.path := path;
  RefreshThread.TreeNode := FolderTree.Selected;
  //RefreshThread.FreeOnTerminate := True;
  RefreshThread.Resume;


  ThumbThread := TThumbThread.Create(True);
  ThumbThread.path := path;
  ThumbThread.OnTerminate := OnThumbTerminate;
  //ThumbThread.FreeOnTerminate := True;
  ThumbThread.Resume;

 
end;

procedure TmainForm.OnThumbDblClick(Sender: TObject);
var
  ViewForm: TForm;
  Image: TImage;
 begin

   ViewForm:= TForm.Create(mainForm);
   ViewForm.Parent := nil;

   ViewForm.Caption := ExtractFileName( TItemData ( TListItem(Sender).Data ).str );

   Image := TImage.Create(ViewForm);
   Image.Parent := ViewForm;
   try
     Image.Picture.LoadFromFile(  TItemData ( TListItem(Sender).Data ).str  );
   except
     on E: Exception do;
   end;
   Image.Align := alClient;
   Image.Stretch := True;
   Image.Proportional := True;
   Image.Center := True;
   Image.Show;
   ViewForm.ShowModal;
   Image.Free;
   ViewForm.Free;
end;

end.

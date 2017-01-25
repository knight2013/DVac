unit FolderTreeClass;

interface

uses ComCtrls, Classes, FileUtilUnit, SysUtils, Dialogs;

const
  LABEL_MY_COMPUTER = 'My computer';
  DRIVE_ITEM_FORMAT = '%4:s (%1:s)';

type
  TNodeData = class
    str: string;
    check: boolean;
  end;


type
  TFolderTreeClass = class(TTreeView)

 private

 public
    constructor Create(AOwner: TComponent); override;
    destructor Free;

    procedure Refresh(ATreeNode: TTreeNode; APath: string);
    function GetSelectedPath(ATreeNode: TTreeNode): string;
    function ChechPathChild(ATreeNode: TTreeNode; APath: string) : boolean; //Еслть ли ветка для пути
    function ChechChildPath(ATreeNode: TTreeNode) : boolean; //Есть ли путь для ветки
    procedure DeleteNotExistsDir(ATreeNode: TTreeNode);

end;



implementation

uses Controls;



constructor TFolderTreeClass.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor TFolderTreeClass.Free;
begin
end;

function TFolderTreeClass.GetSelectedPath(ATreeNode: TTreeNode): string;
var
  path: string;
  tree: TTreeNode;
begin
  Result := LABEL_MY_COMPUTER;

  if TopItem = ATreeNode then   Exit;
  //Получить путь
  tree := ATreeNode;
  repeat
       path := TNodeData(tree.Data).str + '\' + path;
       tree := tree.Parent;
       if tree.Data = nil then Break;
  until False;

  Result := path;
end;


function TFolderTreeClass.ChechPathChild(ATreeNode: TTreeNode; APath: string) : boolean;
var
  tree: TTreeNode;
begin
  REsult := False;
  tree := ATreeNode.getFirstChild;
  repeat
  if  tree = nil then Break;
    if APath = TNodeData(tree.Data).str then
      begin
        REsult := True;
        Break;
      end;
      tree := tree.getNextSibling;

  until tree = nil;

end;

function TFolderTreeClass.ChechChildPath(ATreeNode: TTreeNode) : boolean;
begin
 Result := False;
 if DirectoryExists( GetSelectedPath(ATreeNode) ) then Result := True;
end;


procedure TFolderTreeClass.DeleteNotExistsDir(ATreeNode: TTreeNode);
var
  delTree, tree: TTreeNode;
  APath: string;
begin
  tree := ATreeNode.getFirstChild;
  repeat
  if  tree = nil then Break;

   if not ChechChildPath(tree) then
      begin
        delTree := tree;
        delTree.Delete;
      end;
      tree := tree.getNextSibling;

  until tree = nil;
end;


procedure TFolderTreeClass.Refresh(ATreeNode: TTreeNode; APath: string);
var
  i: integer;
  rootTreeNode, currTreeNode: TTreeNode;
  driveList: ADriveRec;
  searchResult : TSearchRec;
  NodeData: TNodeData;
begin

  if APath = '' then
    begin
       //Добавим все диски
       rootTreeNode := Items.AddObjectFirst(Items.GetFirstNode , LABEL_MY_COMPUTER, nil);
       GetAllDrive(driveList);

       for i := 0 to length(driveList) - 1 do
         begin

           NodeData := TNodeData.Create;
           NodeData.str := driveList[i].Name;

           Items.AddChildObject(rootTreeNode, Format( DRIVE_ITEM_FORMAT,
                                        [
                                        driveList[i].ID,
                                        driveList[i].Name,
                                        driveList[i].Path,
                                        driveList[i].DriveType,
                                        driveList[i].VolumeLabel,
                                        driveList[i].SerialNumber,
                                        driveList[i].FileSystem
                                        ]
                                        ),
                                        NodeData
                                      );
           //NodeData.Free;
         end;
    end
  else
    begin
      //Обновим ветку
      Updating;

      //Удалим несуществующие ветки
      DeleteNotExistsDir(ATreeNode);

      if FindFirst(APath + '\*.*', faDirectory, searchResult) = 0 then
       begin
        repeat
          if (searchResult.Name <> '.') and (searchResult.Name <> '..') then
           if (searchResult.Attr and faDirectory ) > 0 then
              begin
                NodeData := TNodeData.Create;
                NodeData.str := searchResult.Name;

                //Добавим недостающие ветки
                if not ChechPathChild(ATreeNode, searchResult.Name) then
                  Items.AddChildObject(ATreeNode, searchResult.Name, NodeData);

              end;
        until FindNext(searchResult) <> 0;
      FindClose(searchResult);
      end;

     Update;
   end;



end;


end.

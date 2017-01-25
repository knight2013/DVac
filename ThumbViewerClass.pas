unit ThumbViewerClass;


interface

uses  Windows, jpeg, ComCtrls, Classes, FileUtilUnit, SysUtils, Dialogs,
      Graphics, ExtCtrls, TypInfo, Controls;

const IMAGE_FILE_MASKS = '.jpeg,.jpg,.bmp';
      THUMB_WIDTH  = 128;
      THUMB_HEIGHT = 128;



type
  TItemData = class
    str: string;
    check: boolean;
  end;


type TThumbViewerClass = class(TListView)

 private
    FImageList: TImageList;
    FOnItemDblClick : TNotifyEvent;
    FTerminate: boolean;
    FsearchResult: TSearchRec;
    FPath: string;
 public
    constructor Create(AOwner: TComponent); override;
    destructor Free;

    function Prepare(APath: string): boolean;
    function GetNextItem: boolean;
    procedure Done;    

    procedure ThumbDblClick(Sender: TObject);
    procedure Clear;override;
    procedure DoTerminate;



    property Terminate: boolean read FTerminate write FTerminate;

   published
      property OnItemDblClick: TNotifyEvent read FOnItemDblClick write FOnItemDblClick;


end;


implementation


constructor TThumbViewerClass.Create(AOwner: TComponent);
begin
  inherited;
  FTerminate := False;
  FImageList := TImageList.Create(Owner);
  FImageList.Width := THUMB_WIDTH;
  FImageList.Height := THUMB_HEIGHT;
  LargeImages := FImageList;
  OnDblClick := ThumbDblClick;
end;

destructor TThumbViewerClass.Free;
begin
 FImageList.Free;
end;


procedure TThumbViewerClass.Clear;
begin
  inherited;
  FImageList.Clear;
end;


procedure TThumbViewerClass.DoTerminate;
begin
  FTerminate := True;
end;

procedure TThumbViewerClass.ThumbDblClick;
var
   hts : THitTests;
   ht : THitTest;
   sht : string;
   ListViewCursosPos : TPoint;

   selectedItem : TListItem;
 begin
   ListViewCursosPos := ScreenToClient(Mouse.CursorPos) ;

   hts := GetHitTestInfoAt(ListViewCursosPos.X, ListViewCursosPos.Y) ;

   for ht in hts do
     sht := GetEnumName(TypeInfo(THitTest), Integer(ht)) ;

   if hts <= [htOnIcon, htOnItem, htOnLabel, htOnStateIcon] then
      if Assigned(FOnItemDblClick) then
         FOnItemDblClick(Selected);
end;


//Поиск файлов, да - существуют, нет - не существуют
function TThumbViewerClass.Prepare(APath: string): boolean;
begin
   FPath := APath;
   //Обновим
   //Удалим несуществующие
   Clear;
   if FindFirst(FPath + '\*.*', faAnyFile, FsearchResult) = 0
    then Result := True
    else Result := False;
end;

//взять миниатюру, да - положил, нет - кончились
function TThumbViewerClass.GetNextItem: boolean;
var
 ListItem: TListItem;
 ItemData:TItemData;
 Bitmap: TBitmap;
 Image: TImage;
 i: integer;
begin
          if IsFileMasked(FsearchResult.Name, IMAGE_FILE_MASKS ) then
           if (FsearchResult.Attr and faDirectory ) = 0 then
              begin

                  ItemData := TItemData.Create;
                  ItemData.str :=FPath + '\' + FsearchResult.Name;

                  ListItem := Items.Add;
                  ListItem.Caption := FsearchResult.Name;
                  ListItem.Data := ItemData;
                  ListItem.ImageIndex := -1;


                  Image := TImage.Create(self);
                  Bitmap := TBitmap.Create;
                  Bitmap.SetSize(THUMB_WIDTH, THUMB_HEIGHT);
                  try
                    Image.Picture.LoadFromFile( ItemData.str );
                    Bitmap.Canvas.StretchDraw(
                         Bitmap.Canvas.ClipRect,
                         Image.Picture.Graphic
                       );

                  except
                    on E: Exception do
                      begin
                       Bitmap.Canvas.Pen.Color := clRed;
                       Bitmap.Canvas.MoveTo(0,0);
                       Bitmap.Canvas.LineTo(Bitmap.Width,Bitmap.Height);
                       Bitmap.Canvas.MoveTo(Bitmap.Width,0);
                       Bitmap.Canvas.LineTo(0,Bitmap.Height);
                      end;
                  end;


                  FImageList.Add(Bitmap, nil );
                  ListItem.ImageIndex := FImageList.Count-1;
                  ListItem.Update;

                  Bitmap.Free;
                  Image.Free;

              end;

        if FindNext(FsearchResult) <> 0
        then
           begin
            Result := False;
           end
       else Result := True;

end;

procedure TThumbViewerClass.Done;
begin
   FindClose(FsearchResult);
end;



end.

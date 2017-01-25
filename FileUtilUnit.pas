unit FileUtilUnit;

interface

uses Classes, Windows, SysUtils, StrUtils;

type TDriveRec = record
    ID: integer;
    Name: string;
    Path: string;
    DriveType: string;
    VolumeLabel: string;
    SerialNumber: string;
    FileSystem: string;
  end;

type
   ADriveRec = array of TDriveRec;

  procedure GetDriveInfo(VolumeName: string;var VolumeLabel, SerialNumber, FileSystem: string);
  function GetAllDrive(var ADrive: ADriveRec): byte;
  function IsFileMasked(AFileName, AMasks: string): boolean;

implementation



procedure GetDriveInfo(VolumeName: string;
  var VolumeLabel, SerialNumber, FileSystem: string);
var
  VolLabel, FileSysName: array[0..255] of char;
  SerNum: pdword;
  MaxCompLen, FileSysFlags: dword;
begin
  New(SerNum);
  GetVolumeInformation(PChar(VolumeName), VolLabel,
    255, SerNum, MaxCompLen, FileSysFlags, FileSysName, 255);
  VolumeLabel := VolLabel;
  SerialNumber := Format('%x', [SerNum^]);
  FileSystem := FileSysName;
  Dispose(SerNum);

end;


function GetAllDrive(var ADrive: ADriveRec): byte;
var
  VolLabel, SN, FS: string;

  i, mask: integer;
  s: string;

  lenArr: byte;
begin
  lenArr := 0;
  SetLength(ADrive, lenArr);

  mask := GetLogicalDrives;
  i := 0;
  while mask <> 0 do
  begin
    s := chr(ord('a') + i) + ':\';
    if (mask and 1) <> 0 then
      begin
      GetDriveInfo(S, VolLabel, SN, FS);

      lenArr := lenArr + 1;
      SetLength(ADrive, lenArr);


      with ADrive[ lenArr -1 ] do
       begin
         ID := ord('a') + i;
         Name := chr(ord('a') + i) + ':';
         Path := s;
         VolumeLabel := VolLabel;
         SerialNumber:= SN;
         FileSystem := FS;
       end;

      case GetDriveType(PChar(s)) of
        0: ADrive[ lenArr -1 ].DriveType := 'unknown';
        1: ADrive[ lenArr -1 ].DriveType := 'not exist';
        DRIVE_REMOVABLE: ADrive[ lenArr -1 ].DriveType := 'removable';
        DRIVE_FIXED: ADrive[ lenArr -1 ].DriveType :='fixed';
        DRIVE_REMOTE: ADrive[ lenArr -1 ].DriveType :='network';
        DRIVE_CDROM: ADrive[ lenArr -1 ].DriveType :='CD-ROM';
        DRIVE_RAMDISK: ADrive[ lenArr -1 ].DriveType :='RAM';
      end;
      end;
    inc(i);
    mask := mask shr 1;
  end;
  Result := lenArr;
end;


function IsFileMasked(AFileName, AMasks: string): boolean;
var
  maskIndex: integer;
  maskList : TStringList;
  maskExists: boolean;
begin
 maskList := TStringList.Create;
 maskList.CommaText := AMasks;

 maskExists := False;
 for maskIndex := 0 to maskList.Count - 1 do
   if ExtractFileExt(AFileName) = maskList[ maskIndex ]
    then  maskExists := True;

 Result := maskExists;
end;

end.


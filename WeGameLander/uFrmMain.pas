unit uFrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TFrmMain = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

const
  CON_INPUT_X = 800;
  CON_INPUT_ACC_Y = 215;
  CON_INPUT_PWD_Y = 240;

implementation

uses uWinIO;

{$R *.dfm}

function MsShowMessage(AMsg: string): Integer;
begin
  //ClipCursor(nil);
  Result := MessageBox(FrmMain.Handle, PWideChar(AMsg), '����', MB_ICONWARNING);
end;

function fnForeWindow(AGameHandle: THandle): Boolean;
begin
  ShowWindow(AGameHandle, SW_RESTORE);
  Sleep(100);
  Result := SetForegroundWindow(AGameHandle);
  Sleep(100);
end;

function fnLeftClick(APoint: TPoint): Boolean;
begin
  SetCursorPos(APoint.X, APoint.Y); //����Ŀ�ĵ�λ�á�
  Sleep(50);
  mouse_event(MOUSEEVENTF_LEFTDOWN, APoint.X, APoint.Y, 0, GetMessageExtraInfo()); // ģ�ⰴ����������
  Sleep(20);
  mouse_event(MOUSEEVENTF_LEFTUP, APoint.X, APoint.Y, 0, GetMessageExtraInfo());  // ģ��ſ���������
end;

function fnDelText(): Boolean;
var
  I: Integer;
begin
  for I := 0 to 20 do
  begin
    Sleep(20);
    uWinIO.MsKeyPress(VK_BACK);
  end;

  for I := 0 to 10 do
  begin
    Sleep(20);
    uWinIO.MsKeyPress(VK_DELETE);
  end;
end;

function fnGetColor(AHandle: THandle; APoint: TPoint): DWORD;
var
  C  : TColor;
  DC : HDC;
begin
  DC := GetDC(AHandle);
  C := GetPixel(DC, APoint.x, APoint.y);
  {$IFDEF DEBUG}
  FrmMain.edit1.text := FORMAT('%.6x',[C]);
  {$ENDIF}
  Result := DWORD(C);
end;

function fnCheckWeGame(AGameHandle: THandle): Boolean;
const
  CON_CHECK_COLOR = $393737;
var
  hTmp, hEdit: HWND;
  vPoint: TPoint;
  dwColor1, dwColor2: DWORD;
begin
  Result := False;
  try
    fnForeWindow(AGameHandle);
    vPoint.X := CON_INPUT_X;
    vPoint.Y := CON_INPUT_PWD_Y;
    dwColor1 := fnGetColor(AGameHandle, vPoint);   //-- ��ȡ��������ɫ
    vPoint.Y := CON_INPUT_ACC_Y;
    dwColor2 := fnGetColor(AGameHandle, vPoint);   //-- ��ȡ��������ɫ
    if (dwColor1 <> CON_CHECK_COLOR) or (dwColor2 <> CON_CHECK_COLOR) then
    begin
      MsShowMessage('���л����˺�����ҳ��, �ٽ��г���!');
      Exit;
    end;

    {$REGION 'У�������'}
    hTmp := FindWindowEx(AGameHandle, 0, 'Normal', '');
    hEdit := FindWindowEx(hTmp, 0, 'Edit', '');
    if not IsWindowVisible(hEdit) then
      hEdit := FindWindowEx(hTmp, hEdit, 'Edit', '');
    {$IFDEF DEBUG}
    FrmMain.Edit1.Text := Format('%.8X', [hEdit]);
    {$ENDIF}
    if not IsWindow(hEdit) then
    begin
      MsShowMessage('û���л����˺�����ҳ��?');
      Exit;
    end;

    if not IsWindowVisible(hEdit) then
    begin
      MsShowMessage('���������ʧ��, WeGame�Ƿ�������?');
      Exit;
    end;
    {$ENDREGION}
    Result := True;
  except
  end;
end;

function fnLoginGame(AAccount: string; APassword: string): Boolean;
var
  hGame: HWND;
  vPoint: TPoint;
  I: Integer;
  cRect: TRect;
begin
  Result := False;
  cRect.Top := 0;
  cRect.Left := 0;
  cRect.Height := 5;
  cRect.Width := 5;
  ClipCursor(@cRect);
  try
    try
      if AAccount.IsEmpty then
      begin
        MsShowMessage('�˺Ų���Ϊ��');
        Exit;
      end;

      if APassword.IsEmpty then
      begin
        MsShowMessage('���벻��Ϊ��');
        Exit;
      end;

//      hGame := FindWindow('TWINCONTROL', 'WeGame');
//
//      if not IsWindow(hGame) then
//      begin
//        MsShowMessage('��������WeGame');
//        Exit
//      end;
//
//      if not fnCheckWeGame(hGame) then Exit;
//
//      vPoint.X := CON_INPUT_X;
//      vPoint.Y := CON_INPUT_ACC_Y;
//
//      Winapi.Windows.ClientToScreen(hGame, vPoint);

//      for I := 0 to 3 do
//      begin
//        Sleep(50);
//        fnLeftClick(vPoint);
//      end;

      //--ɾ���˺�
      fnDelText();
      //--�����˺�
      uWinIO.IoPressPwd(AAccount);
      //--����л��������
      uWinIO.MsKeyPress(VK_TAB);
      //--��������
      uWinIO.IoPressPwd(APassword);
      //--�س���¼
      uWinIO.MsKeyPress(VK_RETURN);
      Result := True;
    except
      //---
    end;
  finally
    ClipCursor(nil);
  end;
end;

procedure TFrmMain.Button1Click(Sender: TObject);
begin
  Sleep(3000);
  //uWinIO.IoPressPwd('Aa09137320286');
  fnLoginGame(Edit1.Text, Edit2.Text);
//  TThread.Queue(nil,
//    procedure
//    begin
//      fnLoginGame('275175822', 'Aa09137320286');
//    end
//    );
end;

procedure TFrmMain.FormCreate(Sender: TObject);
var
  sAccount, sPassword: string;
begin
{$IFNDEF DEBUG}
  try
    Self.Visible := False;
    if ParamCount < 2 then
    begin
      MsShowMessage('������������ȷ');
      Exit;
    end;
    sAccount := ParamStr(1);
    sPassword := ParamStr(2);
    fnLoginGame(sAccount, sPassword);
  finally
    Application.Terminate;
  end;
{$ENDIF}
end;

end.

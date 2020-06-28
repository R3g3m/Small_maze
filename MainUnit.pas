unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Menus, ComCtrls, ExtCtrls, ExtDlgs, Jpeg;

const
  Max = 49;
  MaxSide = 499;
  
type
  TMainForm = class(TForm)
    btnFindWay: TButton;
    btnPointEnter: TButton;
    lbXEnterCoor: TLabel;
    lbYEnterCoor: TLabel;
    lbXExitCoor: TLabel;
    lbYExitCoor: TLabel;
    edXEnter: TEdit;
    edYEnter: TEdit;
    edXExit: TEdit;
    edYExit: TEdit;
    btnPointExit: TButton;
    btnPointEnterOK: TButton;
    btnPointExitOK: TButton;
    imYAxis: TImage;
    imXAxis: TImage;
    lbNumX: TLabel;
    lbNumY: TLabel;
    Image1: TImage;
    procedure imLabirintMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnPointEnterClick(Sender: TObject);
    procedure btnPointExitClick(Sender: TObject);
    procedure btnPointEnterOKClick(Sender: TObject);
    procedure btnPointExitOKClick(Sender: TObject);
    procedure btnFindWayClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edXEnterKeyPress(Sender: TObject; var Key: Char);
    procedure edYEnterKeyPress(Sender: TObject; var Key: Char);
    procedure edXExitKeyPress(Sender: TObject; var Key: Char);
    procedure edYExitKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
  TLABIR_PART = record
                  num: integer;
                  _type: byte;  // 0-стена, 1-проход, 2-вход, 3-выход, 4-пройденная, 5-путь
                end;
  TLABIRINT = array [0..MAX, 0..MAX] of TLABIR_PART;

  PInteger = ^Integer;
var
  MainForm: TMainForm;
  labirint: TLABIRINT;
  x_cursor, y_cursor: integer;

implementation
{$R *.dfm}

procedure ScanPicture(var field: TLABIRINT; var pic: TImage);
var
  i, j: integer;
begin
  i:= 5;
  repeat
    j:= 5;
    repeat
      if pic.Canvas.Pixels[i, j]=clBlack then
        begin
          field[Trunc((i-5)/10), Trunc((j-5)/10)]._type:= 0;
          field[Trunc((i-5)/10), Trunc((j-5)/10)].num:= -1;
        end
      else field[Trunc((i-5)/10), Trunc((j-5)/10)]._type:= 1;
      j:= j+10;
    until(j>=MaxSide+1);
    i:= i+10;
  until(i>=MaxSide+1);
end;

procedure Check(var field: TLABIRINT; x, y, d: integer);
begin
  if (x>=1) and (field[x-1, y]._type=1) then
    begin
      field[x-1, y]._type:= 4;
      field[x-1, y].num:= d;
    end;
  if (y>=1) and (field[x, y-1]._type=1) then
    begin
      field[x, y-1]._type:= 4;
      field[x, y-1].num:= d;
    end;
  if (x<=Max) and (field[x+1, y]._type=1) then
    begin
      field[x+1, y]._type:= 4;
      field[x+1, y].num:= d;
    end;
  if (y<=Max) and (field[x, y+1]._type=1) then
    begin
      field[x, y+1]._type:= 4;
      field[x, y+1].num:= d;
    end;
end;

procedure SpreadWave(var field: TLABIRINT; x_enter, y_enter, x_exit, y_exit: integer);
var
  x, y, a, i, j: integer;
begin
  field[x_enter, y_enter]._type:= 4;
  field[x_enter, y_enter].num:= 0;
  field[x_exit, y_exit]._type:= 1;
  x:= x_enter;
  y:= y_enter;
  Check(field, x, y, 1);
  a:= 1;
  repeat
    for i:= 1 to Max do
      for j:= 1 to Max do
        begin
          if (field[i, j].num = a) then Check(field, i, j, a+1);
        end;
    a:= a+1;
  until (field[x_exit, y_exit]._type=4);
end;

procedure RestoreWay(var field: TLABIRINT; x_enter, y_enter, x_exit, y_exit: integer);
var
  x, y, a: integer;
  f: boolean;
begin
  x:= x_exit;
  y:= y_exit;
  a:= field[x_exit, y_exit].num;
  repeat
    f:= true;
    if (y<=Max) and (field[x, y+1].num = a-1) then
      begin
        y:= y+1;
        field[x, y]._type:= 5;
        f:= false;
      end;
    if (y>=1) and (field[x, y-1].num = a-1) and f then
      begin
        y:= y-1;
        field[x, y]._type:= 5;
        f:= false;
      end;
    if (x<=Max) and (field[x+1, y].num = a-1) and f then
      begin
        x:= x+1;
        field[x, y]._type:= 5;
        f:= false
      end;
    if (x>=1) and (field[x-1, y].num = a-1) and f then
      begin
        x:= x-1;
        field[x, y]._type:= 5;
      end;
    a:= a-1;
  until(x=x_enter) and (y=y_enter);
end;

procedure DisplayWay(var field: TLABIRINT; var Image: TImage);
var
  i, j, x, y: integer;
begin
  for i:= 0 to Max do
    for j:= 0 to Max do
      if field[i, j]._type = 5 then
        begin
          with Image do
            begin
              Canvas.Brush.Color:= clRed;
              Canvas.Brush.Style:= bsSolid;
              Canvas.Pen.Color:= clRed;
              x:= i*10+9;
              y:= j*10+9;
              Canvas.Rectangle(i*10, j*10, x, y);
            end;
        end;
end;

procedure TMainForm.imLabirintMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  x_cursor:= x;
  y_cursor:= y;
end;


procedure TMainForm.btnPointEnterClick(Sender: TObject);
begin
  MainForm.Canvas.TextOut(8, 70, 'Укажите вход в лабиринт курсором');
  btnPointEnterOK.Visible:= true;
end;

procedure TMainForm.btnPointExitClick(Sender: TObject);
begin
  MainForm.Canvas.TextOut(8, 158, 'Укажите выход из лабиринта курсором');
  btnPointExitOK.Visible:= true;
end;

procedure TMainForm.btnPointEnterOKClick(Sender: TObject);
var
  x1, x2, y1, y2, x_otn, y_otn: integer;
begin
  if imLabirint.Canvas.Pixels[x_cursor, y_cursor]= clWhite then
    begin
      x_otn:= x_cursor div 10;
      y_otn:= y_cursor div 10;
      edXEnter.Text:= IntToStr(x_otn);
      edYEnter.Text:= IntToStr(y_otn);
      x1:= 10 * x_otn;
      y1:= 10 * y_otn;
      x2:= 10 + 10 * x_otn;
      y2:= 10 + 10 * y_otn;
      with imLabirint.Canvas do
      begin
        Brush.Color:= clGreen;
        Brush.Style:= bsSolid;
        Pen.Color:= clGreen;
        Rectangle(x1, y1, x2, y2);
        Rectangle(x1, y1-10, x2, y2-10);
        Polygon([Point(x2, y2-10), Point(x2, y2-20), Point(x2+10, y2-20)]);
      end;
    end
  else MessageBox(MainForm.Handle, PChar('Стенка не может быть входом! Укажите другую точку.'), PChar('Внимание!'), MB_OK+MB_ICONWARNING);
end;

procedure TMainForm.btnPointExitOKClick(Sender: TObject);
var
  x1, x2, y1, y2, x_otn, y_otn: integer;
begin
  if imLabirint.Canvas.Pixels[x_cursor, y_cursor]= clWhite then
    begin
      x_otn:= x_cursor div 10;
      y_otn:= y_cursor div 10;
      edXExit.Text:= IntToStr(x_otn);
      edYExit.Text:= IntToStr(y_otn);
      x1:= 10 * x_otn;
      y1:= 10 * y_otn;
      x2:= 10 + 10 * x_otn;
      y2:= 10 + 10 * y_otn;
      with imLabirint.Canvas do
      begin
        Brush.Color:= clGreen;
        Brush.Style:= bsSolid;
        Pen.Color:= clGreen;
        Rectangle(x1, y1, x2, y2);
        Rectangle(x1, y1-10, x2, y2-10);
        Polygon([Point(x2, y2-10), Point(x2, y2-20), Point(x2+10, y2-20)]);
      end;
    end
  else MessageBox(MainForm.Handle, PChar('Стенка не может быть выходом! Укажите другую точку.'), PChar('Внимание!'), MB_OK+MB_ICONWARNING);
end;

procedure TMainForm.btnFindWayClick(Sender: TObject);
var
  x_enter, y_enter, x_exit, y_exit: integer;
begin
  try
    x_enter:= StrToInt(edXEnter.Text);
    y_enter:= StrToInt(edYEnter.Text);
    x_exit:= StrToInt(edXExit.Text);
    y_exit:= StrToInt(edYExit.Text);
  except
    MessageBox(MainForm.Handle, PChar('Ошибка ввода координат'), PChar('Внимание!'), MB_OK+MB_ICONWARNING);
  end;
  SpreadWave(labirint, x_enter, y_enter, x_exit, y_exit);
  RestoreWay(labirint, x_enter, y_enter, x_exit, y_exit);
  DisplayWay(labirint, imLabirint);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  ScanPicture(labirint, imLabirint);
end;

procedure TMainForm.edXEnterKeyPress(Sender: TObject; var Key: Char);
begin
  key:= chr(0);
end;

procedure TMainForm.edYEnterKeyPress(Sender: TObject; var Key: Char);
begin
  key:= chr(0);
end;

procedure TMainForm.edXExitKeyPress(Sender: TObject; var Key: Char);
begin
  key:= chr(0);
end;

procedure TMainForm.edYExitKeyPress(Sender: TObject; var Key: Char);
begin
  key:= chr(0);
end;

end.

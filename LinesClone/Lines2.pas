unit Lines2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ImgList, ExtCtrls, StdCtrls;

type
  TForm1 = class(TForm)
    Image1: TImage;
    ImageList1: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure OnClose(Sender: TObject; var Action: TCloseAction);
    procedure OnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Label3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BMP:TBitmap;
  Form1: TForm1;
  a:array [0..8,0..8] of integer;  // масив для расположения шаров
  b:array [0..8,0..8] of integer;  // дополнительный массив для поиска пути и удаления шаров
  TempX,TempY,TempZ:integer;       // переменные временного хранения параметров шара
  Dollar,KolvoStep:integer;        // количество очков и количество шаров на поле
  BALLClick:boolean;               // переменная отвечающая за то,что выбран шар или нет для его дальнейшего перемещения

function DeleteBALLLine:boolean;   // функция возвращает true если были удалены шары

procedure NewGameForSer;           // новая игра
procedure RandomBALL;              // процедура дополнения шаров
procedure FindZero(x1,y1:integer); // процедура поиска дозволенных ходов

implementation

{$R *.DFM}

procedure NewGameForSer;
var x,y:integer;
begin
Form1.Label1.Caption:='Очки: 0';
BALLClick:=false;
KolvoStep:=0;
Dollar:=0;

Form1.Imagelist1.GetBitmap(0,BMP);
for x:=0 to 8 do
 for y:=0 to 8 do
   begin
    a[x,y]:=0;
    b[x,y]:=0;
    Form1.Image1.Canvas.Draw(x*32,y*32,BMP);
   end;
RandomBALL;
end;


procedure RandomBALL;
var x,y,z:integer;
    NumberBALL:integer; // количество появляемых шаров
begin
if DeleteBALLLine=false then begin
 NumberBALL:=0;
 repeat
 x:=random(9);
 y:=random(9);
 z:=random(6)+1;
 if a[x,y]=0 then begin
 a[x,y]:=z;
 Form1.Imagelist1.GetBitmap(z,BMP);
 Form1.Image1.Canvas.Draw(x*32,y*32,BMP);
 NumberBALL:=NumberBALL+1;
 KolvoStep:=KolvoStep+1;
 end;
 until (NumberBALL=3) or (KolvoStep=81);
 DeleteBALLLine;
end;
if KolvoStep=81 then begin ShowMessage('ПОХОЖЕ НА ТО, ЧТО ТЫ ПРОИГРАЛ!'); NewGameForSer; end;
end;


function DeleteBALLLine:boolean;
var i,j:integer;
begin
DeleteBALLLine:=false;
Form1.Imagelist1.GetBitmap(0,BMP);
//метка шаров к удалению

//по горизонталям
for i:=0 to 4 do
for j:=0 to 8 do
if (a[i,j]=a[i+1,j]) and (a[i,j]=a[i+2,j]) and (a[i,j]=a[i+3,j]) and (a[i,j]=a[i+4,j]) and (a[i,j]>0) then
begin
b[i,j]:=-20;
b[i+1,j]:=-20;
b[i+2,j]:=-20;
b[i+3,j]:=-20;
b[i+4,j]:=-20;
end;

//по вертикалям
for i:=0 to 8 do
for j:=0 to 4 do
if (a[i,j]=a[i,j+1]) and (a[i,j]=a[i,j+2]) and (a[i,j]=a[i,j+3]) and (a[i,j]=a[i,j+4]) and (a[i,j]>0) then
begin
b[i,j]:=-20;
b[i,j+1]:=-20;
b[i,j+2]:=-20;
b[i,j+3]:=-20;
b[i,j+4]:=-20;
end;

//по диагоналям
for i:=0 to 4 do
for j:=0 to 4 do
if (a[i,j]=a[i+1,j+1]) and (a[i,j]=a[i+2,j+2]) and (a[i,j]=a[i+3,j+3]) and (a[i,j]=a[i+4,j+4]) and (a[i,j]>0) then
begin
b[i,j]:=-20;
b[i+1,j+1]:=-20;
b[i+2,j+2]:=-20;
b[i+3,j+3]:=-20;
b[i+4,j+4]:=-20;
end;

for i:=8 downto 4 do
for j:=0 to 4 do
if (a[i,j]=a[i-1,j+1]) and (a[i,j]=a[i-2,j+2]) and (a[i,j]=a[i-3,j+3]) and (a[i,j]=a[i-4,j+4]) and (a[i,j]>0) then
begin
b[i,j]:=-20;
b[i-1,j+1]:=-20;
b[i-2,j+2]:=-20;
b[i-3,j+3]:=-20;
b[i-4,j+4]:=-20;
end;

//удаление
for i:=0 to 8 do
for j:=0 to 8 do
if b[i,j]=-20 then
begin
 Form1.Image1.Canvas.Draw(i*32,j*32,BMP);
 DeleteBALLLine:=true;
 KolvoStep:=KolvoStep-1;
 Dollar:=Dollar+20;
 a[i,j]:=0;
 b[i,j]:=0;
end;

Form1.Label1.Caption:='Очки: '+IntToStr(Dollar);
Form1.Label2.Caption:='Шары: '+ IntToStr(KolvoStep);
end;



procedure TForm1.FormCreate(Sender: TObject);
begin
Bmp := TBitmap.Create;
randomize;
NewGameForSer;
end;


procedure TForm1.OnClose(Sender: TObject; var Action: TCloseAction);
begin
Bmp.Free;
end;


procedure TForm1.OnMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var i,j:integer;
begin
x:=x div 32;
y:=y div 32;

if a[x,y]>0 then
begin

//очистка массива для последующего поиска пути
for i:=0 to 8 do
for j:=0 to 8 do
b[i,j]:=0;

TempX:=x;
TempY:=y;
TempZ:=a[x,y];
BALLClick:=true;
FindZero(x,y);
end;

if (a[x,y]=0) and (BALLClick=true) and (b[x,y]=1) then
begin
Form1.Imagelist1.GetBitmap(0,BMP);
Form1.Image1.Canvas.Draw(TempX*32,TempY*32,BMP);
Form1.Imagelist1.GetBitmap(TempZ,BMP);
Form1.Image1.Canvas.Draw(x*32,y*32,BMP);
BALLClick:=false;
a[TempX,TempY]:=0;
a[x,y]:=TempZ;
RandomBALL; //добавляем шарики
end;






end;


procedure FindZero(x1,y1:integer);
var Colonka, Stolbik:integer;
begin
for Colonka:=x1-1 to x1+1 do
for Stolbik:=y1-1 to y1+1 do begin

if (Colonka >= 0) and (Colonka <9) and
   (Stolbik >= 0) and (Stolbik <9) and (b[Colonka,Stolbik]=0) and (a[Colonka,Stolbik]=0) then begin

  if (Colonka=x1-1) and (Stolbik=y1-1) then continue;
  if (Colonka=x1+1) and (Stolbik=y1-1) then continue;
  if (Colonka=x1+1) and (Stolbik=y1+1) then continue;
  if (Colonka=x1-1) and (Stolbik=y1+1) then continue;

    b[Colonka,Stolbik]:=1;
    FindZero(Colonka,Stolbik);
 end;
end;
end;


procedure TForm1.Label3Click(Sender: TObject);
begin
NewGameForSer;
end;

end.

// Made in СССР  :-)
// [K.I.N.G]ForSer
// Волков Сергей

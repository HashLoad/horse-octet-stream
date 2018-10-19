# horse-octet-stream
Middleware for work with application/octet-stream in HORSE

### For install in your project using [boss](https://github.com/HashLoad/boss):
``` sh
$ boss install github.com/HashLoad/horse-octet-stream
```

### Sample Horse Server with octet-steam middleware
```delphi
uses
  Horse, Horse.OctetStrem;

var
  App: THorse;

begin
  App := THorse.Create(9000);
  
  App.Use(OctetStrem);
  
  App.Post('marco',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var 
      LStrem: TFileStream;
    begin
      LStrem := TFileStream.Create('c:\sample\demo.txt', fmOpenRead);
      Res.Send<TStrem>(LStrem);
    end);

  App.Start;
```

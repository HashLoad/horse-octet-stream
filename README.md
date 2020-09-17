# horse-octet-stream
Middleware for work with application/octet-stream in HORSE

### For install in your project using [boss](https://github.com/HashLoad/boss):
``` sh
$ boss install github.com/HashLoad/horse-octet-stream
```

### Sample Horse Server with octet-stream middleware
```delphi
uses Horse, Horse.OctetStream, System.Classes, System.SysUtils;

begin
  THorse.Use(OctetStream);

  THorse.Get('/stream',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      LStream: TFileStream;
    begin
      LStream := TFileStream.Create('c:\sample\demo.txt', fmOpenRead);
      Res.Send<TStream>(LStream);
    end);

  THorse.Listen(9000);
end.
```

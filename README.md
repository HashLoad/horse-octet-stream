# horse-octet-stream
<b>horse-octet-stream</b> is a official middleware for working with Stream in APIs developed with the <a href="https://github.com/HashLoad/horse">Horse</a> framework.
<br>We created a channel on Telegram for questions and support:<br><br>
<a href="https://t.me/hashload">
  <img src="https://img.shields.io/badge/telegram-join%20channel-7289DA?style=flat-square">
</a>

## ⚙️ Installation
Installation is done using the [`boss install`](https://github.com/HashLoad/boss) command:
``` sh
boss install horse-octet-stream
```
If you choose to install manually, simply add the following folders to your project, in *Project > Options > Resource Compiler > Directories and Conditionals > Include file search path*
```
../horse-octet-stream/src
```

## ✔️ Compatibility
This middleware is compatible with projects developed in:
- [X] Delphi
- [X] Lazarus

## ⚡️ Quickstart
```delphi
uses
  Horse,
  Horse.OctetStream, // It's necessary to use the unit
  System.Classes,
  System.SysUtils;

begin
  // It's necessary to add the middleware in the Horse:
  THorse.Use(OctetStream);

  THorse.Get('/stream',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      LStream: TFileStream;
    begin
      // Now you can send your stream:
      LStream := TFileStream.Create(ExtractFilePath(ParamStr(0)) + 'horse.pdf', fmOpenRead);
      Res.Send<TStream>(LStream);
    end);

  THorse.Listen(9000);
end;
```

## ⚠️ License
`horse-octet-stream` is free and open-source middleware licensed under the [MIT License](https://github.com/HashLoad/horse-octet-stream/blob/master/LICENSE). 

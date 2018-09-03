# 🙂📚  Emoji-D

Unicode Emoji enum library for the [D Programming Language](https://dlang.rg/).

This library has been generated with the bundled [list processor](tools/listprocessor).


## Usage

Just add this library as dependency to your DUB project file.

```d
import std.stdio;
import emojid;

void main()
{
    writeln(cast(string)(Smileys.slightlySmilingFace));
    
    string message = "Hello World " ~ People.wavingHand;
    writeln(message);
}
```

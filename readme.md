# SpellbookTUI

A word search utility written in Free Pascal

![preview](./preview.png)

## Getting started

Download the ZIP file from [releases](https://github.com/Hevanafa/SpellbookTUI/releases/)

In order for the app to work as for now, use Peter Norvig's ngram word list, which can be obtained from here:

[https://www.norvig.com/ngrams/](https://www.norvig.com/ngrams/)

This app specifically uses the `count_1w.txt`

## Building

Since this app is mainly using the console/terminal, using either FPC itself or Lazarus can work

### Lazarus IDE

At least Lazarus IDE v4.6 (bundled with FPC 3.2.2) is required to build this app

1. Open `project.lpi` with Lazarus
2. Change the build mode to release
3. Press `Shift+F9` or **Run menu > Build**

### Free Pascal Compiler

If you prefer to use the plain Free Pascal Compiler, you can use this command:

```powershell
fpc "-oSpellbookTUI.exe" -O3 .\project.lpr
```

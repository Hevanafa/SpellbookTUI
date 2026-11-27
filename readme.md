# SpellbookTUI

A word search utility written in Free Pascal

![preview](./preview.png)

## Getting started

1. Download the ZIP file from the [Releases](https://github.com/Hevanafa/SpellbookTUI/releases/) page
2. SpellbookTUI currently requires Peter Norvig's English word frequency list `count_1w.txt`, which can be obtained from here:

   [https://www.norvig.com/ngrams/](https://www.norvig.com/ngrams/)

3. Place the word list `count_1w.txt` in the same directory as the exe
4. Run `SpellbookTUI.exe`

Enter a word or a search term to perform a search, enter `.help` to list the available commands

## Building

SpellbookTUI is a console app that can be built using either Lazarus or the standalone Free Pascal Compiler

Developed and tested with Lazarus IDE v4.6 and FPC 3.2.2

### Lazarus IDE

1. Open `project.lpi` with Lazarus
2. Select the **Release** build mode
3. Press `Shift+F9` or **Run menu > Build**

### Free Pascal Compiler

If you prefer to use the plain Free Pascal Compiler, you can use this command:

```powershell
fpc "-oSpellbookTUI.exe" -O3 .\project.lpr
```

## Acknowledgements

SpellbookTUI uses the `count_1w.txt` word frequency list made available by Peter Norvig as supplementary material for his chapter "Natural Language Corpus Data" (2009)

The word list is derived from the Google Web Trillion Word Corpus by Thorsten Brants and Alex Franz

Source: [https://www.norvig.com/ngrams/](https://www.norvig.com/ngrams/)

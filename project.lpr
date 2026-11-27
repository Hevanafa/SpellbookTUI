program SpellbookTUI;

{$Mode ObjFPC}
{$H+}{$J-}

uses
  SysUtils, Classes, Math, Crt, Windows, StrUtils;

const
  AppName = 'SpellbookTUI';
  AppVersion = '0.1';
  WordListFile = 'count_1w.txt';
  SearchLimit = 100;
  ItemsPerRow = 4;
  ColumnGap = 2;

type
  TSearchMode = (
    SearchModeStartsWith,
    SearchModeEndsWith,
    SearchModeContains
  );

{ Global app state }

var
  searchMode: TSearchMode;
  wordlist: TStringList;


function ExeRelative(const filename: string): string;
begin
  ExeRelative := ConcatPaths([ExtractFilePath(ParamStr(0)), filename])
end;

procedure LoadWordList;
var
  fullPath: string;
  lines: TStringList;
  line: string;
  pair: TStringArray;
begin
  {
    User-facing path: use the plain WordListFile const
    Internal use: fullPath
  }
  fullPath := ExeRelative(WordListFile);

  writeln(format('Loading word list %s...', [WordListFile]));

  if not FileExists(fullPath) then begin
    MessageBox(
      0,
      PChar(Format(
        'Couldn''t find %s. It must be in the same folder as the programme', [
          WordListFile
        ])),
      'Error',
      MB_OK or MB_ICONERROR);

    Halt(1)
  end;

  lines := TStringList.create;
  lines.LoadFromFile(fullPath);

  for line in lines do begin
    pair := line.Split(#9);

    if (length(pair[0]) < 3)
      or (StrToInt64(pair[1]) < 1000000) then continue;

    wordlist.Add(pair[0]);
  end;

  lines.Free
end;

procedure SetSearchMode(const value: TSearchMode);
begin
  searchMode := value;

  write('Search mode has been changed to: ');

  case value of
    SearchModeStartsWith:
      write('starts with');
    SearchModeEndsWith:
      write('ends with');
    SearchModeContains:
      write('contains');
  end;

  writeln
end;

procedure PrintHelpPage;
begin
  TextColor(LightGray);

  WriteLn(
    'Any input without a dot prefix triggers a search' + LineEnding +
    LineEnding +
    '.help      list all the available commands' + LineEnding +
    '.clear     clear the screen' + LineEnding +
    LineEnding +
    '.starts    search by prefix' + LineEnding +
    '.contains  search by substring' + LineEnding +
    '.ends      search by suffix' + LineEnding +
    LineEnding +
    '.exit      exit this programme');
end;

procedure MainLoop;
var
  filtered: TStringList;
  prompt, s: string;
  a, padding, limit: longint;
  done: boolean;
  startHighlight, endHighlight: longint;
  longest: longint;
begin
  filtered := TStringList.create;
  done := false;

  repeat
    TextColor(LightGreen);
    Write('spellbook> ');
    Flush(stdout);

    TextColor(white);
    ReadLn(prompt);

    prompt := LowerCase(Trim(prompt));

    if prompt.IsEmpty then continue;

    if prompt.StartsWith('.') then begin
      if prompt = '.exit' then
        done := true
      else if prompt = '.starts' then
        SetSearchMode(SearchModeStartsWith)
      else if prompt = '.ends' then
        SetSearchMode(SearchModeEndsWith)
      else if prompt = '.contains' then
        SetSearchMode(SearchModeContains)
      else if prompt = '.help' then
        PrintHelpPage
      else if prompt = '.clear' then begin
        ClrScr;
        continue
      end else begin
        TextColor(DarkGray);
        WriteLn('Unknown command: ' + prompt);
      end;
    end else begin
      filtered.Clear;

      case searchMode of
        SearchModeStartsWith:
          for s in wordlist do
            if s.StartsWith(prompt) then
              filtered.add(s);
        SearchModeEndsWith:
          for s in wordlist do
            if s.EndsWith(prompt) then
              filtered.add(s);
        SearchModeContains:
          for s in wordlist do
            if s.Contains(prompt) then
              filtered.add(s);
      end;

      if filtered.count > 0 then begin
        TextColor(Brown);

        if filtered.count > SearchLimit then begin
          writeln(
            format(
              'Found %d results (limited to %d):', [
              filtered.Count, SearchLimit
            ]));
        end else
          writeln(format('Found %d results:', [filtered.Count]));

        limit := min(filtered.Count - 1, SearchLimit - 1);

        {
        s := '';

        for a:=0 to limit do begin
          if a < limit then
            s := s + filtered[a] + '  |  '
          else
            s := s + filtered[a];
        end;

        writeln(s);
        }

        longest := 0;

        for a:=0 to limit do
          if longest < length(filtered[a]) then
            longest := length(filtered[a]);

        for a:=0 to limit do begin
          startHighlight := pos(prompt, filtered[a]);
          endHighlight := startHighlight + length(prompt);

          if startHighlight > 1 then begin
            TextColor(White);
            write(copy(filtered[a], 1, startHighlight - 1));
          end;

          TextColor(LightGreen);
          write(copy(filtered[a], startHighlight, length(prompt)));

          TextColor(white);
          write(copy(filtered[a], endHighlight));

          {
          TextColor(DarkGray);
          if a < limit then
            write('  |  ');
          }

          { if longest - length(filtered[a]) > 0 then }
          write(PadRight('', longest - length(filtered[a]) + ColumnGap));

          if a mod ItemsPerRow = ItemsPerRow - 1 then
            writeln;
        end;

        if (limit + 1) mod ItemsPerRow > 0 then
          writeln
      end else begin
        TextColor(LightGray);
        WriteLn('Found 0 results');
      end;
    end;

    writeln
  until done;

  filtered.Free
end;


{$R *.res}

begin
  WriteLn(format('%s v%s - By Hevanafa (Nov 2026)', [AppName, AppVersion]));

  wordlist := TStringList.create;

  LoadWordList;

  TextColor(LightGreen);
  writeln(format('Lexicon loaded: %d entries', [wordlist.Count]));

  TextColor(LightGray);
  writeln('Type .help for available commands');

  writeln('Filter by: starts with');
  writeln(format('Length: 3+  |  Limit: %d', [SearchLimit]));

  searchMode := SearchModeStartsWith;

  MainLoop;

  wordlist.Free;
end.


program SpellbookTUI;

uses
  SysUtils, Classes, Math, Crt, Windows;

const
  AppName = 'SpellbookTUI';
  AppVersion = '0.1';
  WordListFile = 'count_1w.txt';
  SearchLimit = 100;
  { ItemsPerRow = 6; }  { Unused for now }

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

procedure LoadWordList;
var
  lines: TStringList;
  line: string;
  pair: TStringArray;
begin
  writeln(format('Loading word list %s...', [WordListFile]));

  if not FileExists(WordListFile) then begin
    MessageBox(
      0,
      PChar(format('Couldn''t find the word list %s!', [WordListFile])),
      'Error',
      MB_OK or MB_ICONERROR);

    Halt(1)
  end;

  lines := TStringList.create;
  lines.LoadFromFile(WordListFile);

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
  writeln(
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
  a, limit: longint;
  done: boolean;
begin
  filtered := TStringList.create;
  done := false;

  repeat
    write('spellbook> ');
    flush(stdout);
    readln(prompt);

    prompt := lowercase(trim(prompt));

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
      end else
        writeln('Unknown command: ' + prompt);
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
        if filtered.count > SearchLimit then begin
          writeln(
            format(
              'Found %d results (limited to %d):', [
              filtered.Count, SearchLimit
            ]));
        end else
          writeln(format('Found %d results:', [filtered.Count]));

        s := '';
        limit := min(filtered.Count - 1, SearchLimit - 1);

        for a:=0 to limit do begin
          if a < limit then
            s := s + filtered[a] + '  |  '
          else
            s := s + filtered[a];
        end;

        writeln(s);
      end else
        WriteLn('Found 0 results');
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

  writeln(format('Loaded %d lines', [wordlist.Count]));
  writeln('Filter by: starts with');
  writeln('Type .help for available commands');
  writeln(format('Length: 3+  |  Limit: %d', [SearchLimit]));

  searchMode := SearchModeStartsWith;

  MainLoop;

  wordlist.Free;
end.


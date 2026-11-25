program SpellbookTUI;

uses
  SysUtils, Classes, Math;

const
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

  if not FileExists(WordListFile) then
    raise Exception.Create('Couldn''t find the word list!');

  lines := TStringList.create;
  lines.LoadFromFile(WordListFile);

  wordlist := TStringList.create;

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

    prompt := trim(prompt);

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
      else
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


begin
  WriteLn('Spellbook TUI - By Hevanafa (Nov 2026)');

  LoadWordList;

  writeln(format('Loaded %d lines', [wordlist.Count]));
  writeln('Filter by: starts with');
  writeln('Type .exit to exit');
  writeln(format('Length: 3+  |  Limit: %d', [SearchLimit]));

  searchMode := SearchModeStartsWith;

  MainLoop;

  wordlist.Free;
end.


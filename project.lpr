program project;

uses
  SysUtils, Classes;

const
  WordListFile = 'count_1w.txt';
  SearchLimit = 100;
  { ItemsPerRow = 6; }  { Unused for now }


var
  words: TStringList;

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

  words := TStringList.create;

  for line in lines do begin
    pair := line.Split(#9);

    if (length(pair[0]) < 3)
      or (StrToInt64(pair[1]) < 1000000) then continue;

    words.Add(pair[0]);
  end;

  lines.Free
end;


var
  filtered: TStringList;
  prompt, s: string;
  a: longint;
  done: boolean;
begin
  writeln('Spellbook TUI - By Hevanafa (Nov 2026)');

  LoadWordList;

  filtered := TStringList.create;

  writeln(format('Loaded %d lines', [words.Count]));
  writeln('Filter by: starts with');
  writeln('Type .exit to exit');

  { Begin prompt loop }

  done := false;

  repeat
    write('> ');
    flush(stdout);
    readln(prompt);

    prompt := trim(prompt);

    if prompt.StartsWith('.') then begin
      if prompt = '.exit' then
        done := true
      else
        writeln('Unknown command: ' + prompt);
    end else begin
      filtered.Clear;

      { Filter by "starts with" }
      for s in words do
        if s.StartsWith(prompt) then
          filtered.add(s);

      if filtered.count > 0 then begin
        if filtered.count > SearchLimit then begin
          writeln(
            format(
              'Found %d results (limited to %d):', [
              filtered.Count, SearchLimit
            ]));

          s := '';

          for a:=0 to SearchLimit - 1 do begin
            if a < SearchLimit - 1 then
              s := s + filtered[a] + '  |  '
            else
              s := s + filtered[a];
          end;

          writeln(s);
        end else begin
          writeln(format('Found %d results:', [filtered.Count]));

          s := '';

          for a:=0 to filtered.Count - 1 do
            if a < filtered.Count - 1 then
              s := s + filtered[a] + '  |  '
            else
              s := s + filtered[a];

          writeln(s);
        end;
      end;
    end;
  until done;

  filtered.Free;
  words.Free;
end.


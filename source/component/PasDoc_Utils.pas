{
  Copyright 1998-2018 PasDoc developers.

  This file is part of "PasDoc".

  "PasDoc" is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  "PasDoc" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with "PasDoc"; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA

  ----------------------------------------------------------------------------
}

{
  @author(Johannes Berg <johannes@sipsolutions.de>)
  @author(Michalis Kamburelis)
  @author(Arno Garrels <first name.name@nospamgmx.de>)
  @abstract(Utility functions.)
}
unit PasDoc_Utils;

{$I pasdoc_defines.inc}

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  Classes,
  SysUtils,
  PasDoc_Types;

{ TMethod is not defined for FPC 1.0.x and Delphi < 6, so we have to define
  it here. }

{$define GOT_TMETHOD}
{$ifdef VER1_0} {$undef GOT_TMETHOD} {$endif}
{$ifndef FPC} {$ifndef DELPHI_6_UP} {$undef GOT_TMETHOD} {$endif} {$endif}

{$ifndef GOT_TMETHOD}
type
  TMethod = record
    code, data: Pointer;
  end;
{$endif}

{$ifndef DELPHI_6_UP}
{$ifndef FPC}
{$ifndef LINUX}
const
  PathDelim = '\';
{$endif}
{$endif}
{$endif}

{ string empty means it contains only whitespace }
function IsStrEmptyA(const AString: string): boolean;
{ count occurences of AChar in AString }
function StrCountCharA(const AString: string; const AChar: Char): Integer;
{ Position of the ASub in AString. Return 0 if not found }
function StrPosIA(const ASub, AString: string): Integer;
{ creates a "method pointer" }
function MakeMethod(const AObject: Pointer; AMethod: Pointer): TMethod;

{$ifndef DELPHI_6_UP}
{$ifndef KYLIX}
{$ifndef FPC}
function IncludeTrailingPathDelimiter(const S: string): string;
function ExcludeTrailingPathDelimiter(const S: string): string;
{$endif}
{$endif}
{$endif}

{$ifndef FPC}
const
  LineEnding = {$ifdef LINUX} #10 {$endif}
               {$ifdef MSWINDOWS} #13#10 {$endif};
{$endif}

type
  TCharReplacement =
  record
    cChar: Char;
    sSpec: string;
  end;

{ Returns S with each char from ReplacementArray[].cChar replaced
  with ReplacementArray[].sSpec. }
function StringReplaceChars(const S: string;
  const ReplacementArray: array of TCharReplacement): string;

{ Comfortable shortcut for Index <= Length(S) and S[Index] = C. }
function SCharIs(const S: string; Index: integer; C: char): boolean; overload;
{ Comfortable shortcut for Index <= Length(S) and S[Index] in Chars. }
function SCharIs(const S: string; Index: integer;
  const Chars: TCharSet): boolean; overload;

{ Extracts all characters up to the first white-space encountered
  (ignoring white-space at the very beginning of the string)
  from the string specified by S.

  If there is no white-space in S (or there is white-space
  only at the beginning of S, in which case it is ignored)
  then the whole S is regarded as it's first word.

  Both S and result are trimmed, i.e. they don't have any
  excessive white-space at the beginning or end.}
function ExtractFirstWord(var s: string): string; overload;

{ Another version of ExtractFirstWord.

  Splits S by it's first white-space (ignoring white-space at the
  very beginning of the string). No such white-space means that
  whole S is regarded as the FirstWord.

  Both FirstWord and Rest are trimmed. }
procedure ExtractFirstWord(const S: string;
  out FirstWord, Rest: string); overload;

const
  AllChars = [Low(AnsiChar)..High(AnsiChar)];

  { Whitespace that is not any part of newline. }
  WhiteSpaceNotNL = [' ', #9];
  { Whitespace that is some part of newline. }
  WhiteSpaceNL = [#10, #13];
  { Any whitespace (that may indicate newline or not) }
  WhiteSpace = WhiteSpaceNotNL + WhiteSpaceNL;

  { Flag Start- and Endsigns for parameters
  (Feature request "direction of parameter": https://github.com/pasdoc/pasdoc/issues/8) }
  FlagStartSigns = ['['];
  FlagEndSigns = [']'];

{$IFNDEF STRING_UNICODE}
{ Interpret and skip the BOM in the InputStream.
  Assumes that initial position is at the beginning of the InputStream,
  and will change the position to the one immediately after BOM
  (or 0, if no BOM was detected).

  @raises EPasDoc When BOM indicates UTF encoding that we cannot handle (UTF-32, UTF-16 now). }
procedure SkipBOM(const InputStream: TStream);
{$ENDIF}

{ Read the given FileName contents into a String.
  Use this only with text files -- it does automatic UTF BOM skipping,
  so it assumes it is a text file, not a binary file with random contents. }
function FileToString(const FileName: string): string;

{ Save the String content into a file.
  Overwrites the FileName, if it already exists. }
procedure StringToFile(const FileName, S: string);

{ Save the binary Data into a file.
  Overwrites the FileName, if it already exists. }
procedure DataToFile(const FileName: string; const Data: array of Byte);

{ Returns S with all Chars replaced by ReplacementChar }
function SCharsReplace(const S: String; const Chars: TCharSet;
  const ReplacementChar: Char): string; overload;
function SCharsReplace(const S: String; const SearchChar: Char;
  const ReplacementChar: Char): string; overload;

procedure CopyFile(const SourceFileName, DestinationFileName: string);

{$ifdef DELPHI_1_UP}
{ Default Delphi (under Windows) implementation of ExtractFilePath
  has a problem --- it doesn't treat '/' as a valid path delimiter
  under Windows (yes, it is valid path delimiter under Windows, just like '\').
  This is the fixed version (actually taken from FPC sources). }
function ExtractFilePath(const FileName: string): string;

{ Just like @link(ExtractFilePath), also default Delphi (under Windows)
  implementation of ExtractFileName  is buggy.
  This is the fixed version (actually taken from FPC sources). }
function ExtractFileName(const FileName: string): string;
{$endif}

{ Checks is Prefix a prefix of S. Not case-sensitive. }
function IsPrefix(const Prefix, S: string): boolean;

{ If IsPrefix(Prefix, S), then remove the prefix, otherwise return unmodifed S. }
function RemovePrefix(const Prefix, S: string): string;

{$ifdef DELPHI_5}
{ BoolToStr for Delphi 5 compat.
  According to
  [https://sourceforge.net/tracker/?func=detail&atid=104213&aid=1595890&group_id=4213]
  Delphi 5 RTL doesn't have this implemented. }
function BoolToStr(Value: Boolean): string;
{$endif DELPHI_5}

{ SEnding returns S contents starting from position P.
  Returns '' if P > length(S).
  Yes, this is simply equivalent to Copy(S, P, MaxInt). }
function SEnding(const s: string; P: integer): string;

{ Check is the given Path absolute.

  Path may point to directory or normal file,
  it doesn't matter. Also it doesn't matter whether Path ends with PathDelim or not.

  Note for Windows: while it's obvious that @code('c:\autoexec.bat') is an
  absolute path, and @code('autoexec.bat') is not, there's a question
  whether path like @code('\autoexec.bat') is absolute? It doesn't specify
  drive letter, but it does specify full directory hierarchy on some drive.
  This function treats this as @italic(not absolute), on the reasoning that
  "not all information is contained in Path".

  @seealso IsPathAbsoluteOnDrive }
function IsPathAbsolute(const Path: string): boolean;

{ Just like IsPathAbsolute, but on Windows accepts also paths that specify
  full directory tree without drive letter.

  @seealso IsPathAbsolute }
function IsPathAbsoluteOnDrive(const Path: string): boolean;

{ Combines BasePath with RelPath. BasePath MUST be an absolute path,
  on Windows it must contain at least drive specifier (like 'c:'),
  on Unix it must begin with "/". RelPath can be relative and can
  be absolute. If RelPath is absolute, result is RelPath.
  Else the result is an absolute path calculated by combining RelPath
  with BasePath. }
function CombinePaths(BasePath, RelPath: string): string;

{ Remove from the FileName the last extension (including the dot).
  Note that if the FileName had a couple of extensions (e.g. @code(blah.x3d.gz))
  this will remove only the last one.
  Will remove nothing if filename has no extension. }
function DeleteFileExt(const FileName: string): string;

{ Remove common indentation (whitespace prefix) from a multiline string. }
function RemoveIndentation(const Code: string): string;

procedure Swap16Buf(Src, Dst: PWord; WordCount: Integer);
function IsCharInSet(C: AnsiChar; const CharSet: TCharSet): Boolean;
  overload; {$IFDEF USE_INLINE} inline; {$ENDIF}
function IsCharInSet(C: WideChar; const CharSet: TCharSet): Boolean; overload;
  {$IFDEF USE_INLINE} inline; {$ENDIF}
function IsUtf8LeadByte(const B: Byte): Boolean; {$IFDEF USE_INLINE} inline; {$ENDIF}
function IsUtf8TrailByte(const B: Byte): Boolean; {$IFDEF USE_INLINE} inline; {$ENDIF}
function Utf8Size(const LeadByte: Byte): Integer; {$IFDEF USE_INLINE} inline; {$ENDIF}
{$IFNDEF COMPILER_12_UP}
function IsLeadChar(Ch: WideChar): Boolean; overload;
  {$IFDEF USE_INLINE} inline; {$ENDIF}
{$ENDIF}
{$IFDEF MSWINDOWS}
function  AnsiToUnicode(const Str: PAnsiChar; ACodePage: LongWord): UnicodeString; overload;
function  AnsiToUnicode(const Str: RawByteString; ACodePage: LongWord): UnicodeString; overload;
function  AnsiToUnicode(const Str: RawByteString): UnicodeString;
  {$IFDEF USE_INLINE} inline; {$ENDIF} overload;
function  UnicodeToAnsi(const Str: PWideChar; ACodePage: LongWord;
  SetCodePage: Boolean = False): RawByteString; overload;
function  UnicodeToAnsi(const Str: UnicodeString; ACodePage: LongWord;
  SetCodePage: Boolean = False): RawByteString; overload;
function  UnicodeToAnsi(const Str: UnicodeString): RawByteString;
  {$IFDEF USE_INLINE} inline; {$ENDIF} overload;
{$ENDIF}
{$IFDEF COMPILER_10_UP}
function CheckGetFileDate(const AFileName: string): TDateTime;
  {$IFDEF USE_INLINE} inline; {$ENDIF}
{$ENDIF}

{ Strip HTML elements from the string.

  Assumes that the HTML content is correct (all elements are nicely closed,
  all < > inside attributes are escaped to &lt; &gt;,
  all < > outside elements are escaped to &lt; &gt;).
  It doesn't try very hard to deal with incorrect HTML context (it will not
  crash, but results are undefined).
  It's designed to strip HTML from PasDoc-generated HTML, which should always
  be correct. }
function StripHtml(const S: string): string;

{$ifdef VER3_0}
{ Index of AText within AValues, -1 if none.
  Missing from FPC 3.0.4 StrUtils. }
function IndexText(const AText: string; const AValues: array of string): Integer;
{$endif}

{ If S = '' then returns NextPart, else returns S + PartSeparator + NextPart. }
function SAppendPart(const s, PartSeparator, NextPart: String): String;

{ Find first occurrence of any character in Chars in string S.
  This is quite like FirstDelimiter but it takes parameter as TSetOfChars
  and has more sensible name.
  Returns 0 if not found. }
function CharsPos(const Chars: TCharSet; const S: String): Integer;

{ Remove all instances of a character in Chars from a string. }
function SRemoveChars(const S: string; const Chars: TCharSet): string;

implementation

uses StrUtils, PasDoc_StreamUtils;

{---------------------------------------------------------------------------}

function IsStrEmptyA(const AString: string): boolean;
begin
  Result := Length(Trim(AString)) = 0;
end;

function StrCountCharA(const AString: string; const AChar: Char): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := Length(AString) downto 1 do begin
    if AString[i] = AChar then Inc(Result);
  end;
end;

function StrPosIA(const ASub, AString: string): Integer;
begin
  Result := Pos(LowerCase(ASub), LowerCase(AString))
end;

function MakeMethod(const AObject: Pointer; AMethod: Pointer): TMethod;
begin
  Result.Code := AMethod;
  Result.Data := AObject;
end;

{$ifndef DELPHI_6_UP}
{$ifndef KYLIX}
{$ifndef FPC}
function IncludeTrailingPathDelimiter(const S: string): string;
begin
  Result := S;
  if Length(S)>0 then begin
    if S[Length(S)] <> PathDelim then begin
      Result := S + PathDelim;
    end;
  end;
end;

function ExcludeTrailingPathDelimiter(const S: string): string;
begin
  Result := S;
  if (S <> '') and (S[Length(S)] in ['/', '\']) then
    SetLength(Result, Length(Result) - 1);
end;
{$endif}
{$endif}
{$endif}

function StringReplaceChars(const S: string;
  const ReplacementArray: array of TCharReplacement): string;

  function Replacement(const Special: Char): String;
  var
    i: Integer;
  begin
    for i := 0 to High(ReplacementArray) do
      with ReplacementArray[i] do
        if cChar = Special then
        begin
          Result := sSpec;
          Exit;
        end;
    Result := Special;
  end;

var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(S) do
  begin
    Result := Result + Replacement(S[i]);
  end;
end;

function SCharIs(const S: string; Index: integer; C: char): boolean; overload;
begin
  Result := (Index <= Length(S)) and (S[Index] = C);
end;

function SCharIs(const S: string; Index: integer;
  const Chars: TCharSet): boolean; overload;
begin
  Result := (Index <= Length(S)) and IsCharInSet(S[Index], Chars);
end;

function ExtractFirstWord(var S: String): String;

  { Look for "[xxx]" inside S right after CurrentPos.
    Assumes that CurrentPos points to whitespace in S, or CurrentPos is > Length(S).
    If flag is found, this increases CurrentPos to point to flag end
    (to the index right after final ']'),
    otherwise CurrentPos remains unchanged.
    See https://github.com/pasdoc/pasdoc/issues/8 . }
  procedure FindFlag(var CurrentPos: Integer);
  var
    P: Integer;
  begin
    P := CurrentPos;
    while SCharIs(S, P, Whitespace) do // skip whitespace
      Inc(P);
    if SCharIs(S, P, '[') then // check it starts with [
    begin
      while not SCharIs(S, P, ']') do // skip flag contents
        Inc(P);
      if SCharIs(S, P, ']') then // check it ends with ]
      begin
        Inc(P);
        CurrentPos := P; // success, modify CurrentPos
      end;
    end;
  end;

var
  Len: Integer;
  StartPos: Integer;
  EndPos: Integer;
  Depth: Integer;
begin
  StartPos := 1;
  Len := Length(S);

  while (StartPos <= Len) and IsCharInSet(S[StartPos], WhiteSpace) do
    Inc(StartPos);

  Depth := 0;

  if StartPos <= Len then
  begin
    EndPos := StartPos + 1;
    while (EndPos <= Len) do begin
      if S[EndPos] = '(' then
        Inc(Depth)
      else if S[EndPos] = ')' then
        Dec(Depth)
      else if (Depth = 0) and IsCharInSet(S[EndPos], WhiteSpace) then
        Break;

      Inc(EndPos);
    end;
    FindFlag(EndPos);
    Result := Copy(S, StartPos, EndPos - StartPos);
    S := Trim(Copy(S, EndPos, Len));
  end else
  begin
    { S is only whitespaces }
    Result := '';
    S := '';
  end;
end;

procedure ExtractFirstWord(const S: string; out FirstWord, Rest: string);
begin
  Rest := S;
  FirstWord := ExtractFirstWord(Rest);
end;

{$IFNDEF STRING_UNICODE}
procedure SkipBOM(const InputStream: TStream);
var
  A : array [0..3] of Byte;
begin
  { Stream too short to contain BOM.
    This may happen e.g. for (completely empty and valid) .inc files.

    TODO: This is not friendly to streams that don't have determined Size,
    like pipes, although in practice we don't use SkipBOM on such streams now. }

  if InputStream.Size < 4 then
    Exit;
  InputStream.ReadBuffer(A, 4);

  { See also TStreamReader.GetCodePageFromBOM for an implementation
    that actually uses UTF-x BOM. Here, we only detect BOM to make
    nice error (in case of UTF-16/32) or skip it (in case of UTF-8). }

  if (A[0] = $FF) and (A[1] = $FE) and (A[2] = 0) and (A[3] = 0) then
  begin
    raise EPasDoc.Create('Detected UTF-32 (little endian) encoding (right now we cannot read such files)');
  end else
  if (A[0] = 0) and (A[1] = 0) and (A[2] = $FE) and (A[3] = $FF) then
  begin
    raise EPasDoc.Create('Detected UTF-32 (big endian) encoding (right now we cannot read such files)');
  end else
  if (A[0] = $FF) and (A[1] = $FE) then
  begin
    raise EPasDoc.Create('Detected UTF-16 (little endian) encoding (right now we cannot read such files, unless compiled with Delphi Unicode)');
  end else
  if (A[0] = $FE) and (A[1] = $FF) then
  begin
    raise EPasDoc.Create('Detected UTF-16 (big endian) encoding (right now we cannot read such files, unless compiled with Delphi Unicode)');
  end else
  if (A[0] = $EF) and (A[1] = $BB) and (A[2] = $BF) then
  begin
    { Do not log for now, to keep SkipBOM API simple,
      otherwise it would need to get current verbosity and event to print messages. }
    // DoMessage(6, pmtInformation, 'Detected UTF-8 BOM, skipping.', []);
    // Writeln('Detected UTF-8 BOM, skipping.'); // uncomment this to debug

    InputStream.Position := 3;
  end else
    { No BOM: get back to the beginning of the steam }
    InputStream.Position := 0;
end;
{$ENDIF}

function FileToString(const FileName: string): string;
{$IFDEF STRING_UNICODE}
var Reader: TStreamReader;
begin
  Reader := TStreamReader.Create(FileName, TRUE);
  try
    Reader.ReadToEnd(Result);
  finally Reader.Free; end;
{$ELSE}
var F: TStream;
begin
  F := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    SkipBOM(F);
    { F.Position may be non-zero in case SkipBOM did something, account for it. }
    SetLength(Result, F.Size - F.Position);
    F.ReadBuffer(Pointer(Result)^, Length(Result));
  finally F.Free end;
{$ENDIF}
end;

procedure StringToFile(const FileName, S: string);
{$IFDEF STRING_UNICODE}
var Writer: TStreamWriter;
begin
  Writer := TStreamWriter.Create(FileName, FALSE, FALSE);
  try
    Writer.Write(S);
  finally Writer.Free; end;
{$ELSE}
var F: TStream;
begin
  F := TFileStream.Create(FileName, fmCreate);
  try
    F.WriteBuffer(Pointer(S)^, Length(S));
  finally F.Free end;
{$ENDIF}
end;

procedure DataToFile(const FileName: string; const Data: array of Byte);
var F: TFileStream;
begin
  F := TFileStream.Create(FileName, fmCreate);
  try
    F.WriteBuffer(Data, High(Data) + 1);
  finally F.Free end;
end;

function SCharsReplace(const S: string; const Chars: TCharSet;
  const ReplacementChar: Char): string;
var
  I: Integer;
begin
  Result := S;
  for I := 1 to Length(Result) do
    if IsCharInSet(Result[I], Chars) then
      Result[I] := ReplacementChar;
end;

function SCharsReplace(const S: String; const SearchChar: Char;
  const ReplacementChar: Char): string;
var
  I: Integer;
begin
  Result := S;
  for I := 1 to Length(Result) do
    if Result[I] = SearchChar then
      Result[I] := ReplacementChar;
end;

procedure CopyFile(const SourceFileName, DestinationFileName: string);
var Source, Destination: TFileStream;
begin
  Destination := TFileStream.Create(DestinationFileName, fmCreate);
  try
    Source := TFileStream.Create(SourceFileName, fmOpenRead or fmShareDenyWrite);
    try
      Destination.CopyFrom(Source, Source.Size);
    finally Source.Free end;
  finally Destination.Free end;
end;

{$ifdef DELPHI_1_UP}
function ExtractFilePath(const FileName: string): string;
var i: longint;
begin
  i := Length(FileName);
  while (i > 0) and not IsCharInSet(FileName[i], ['/', '\', ':']) do Dec(i);
  if I > 0 then
    Result := Copy(FileName, 1, i)
  else
    Result := '';
end;

function ExtractFileName(const FileName: string): string;
var i: longint;
begin
  I := Length(FileName);
  while (I > 0) and not IsCharInSet(FileName[I], ['/', '\', ':']) do Dec(I);
  Result := Copy(FileName, I + 1, 255);
end;
{$endif}

function IsPrefix(const Prefix, S: string): boolean;
begin
  Result := AnsiSameText(Copy(S, 1, Length(Prefix)), Prefix);
end;

function RemovePrefix(const Prefix, S: string): string;
begin
  if IsPrefix(Prefix, S) then
    Result := SEnding(S, Length(Prefix) + 1)
  else
    Result := S;
end;

{$ifdef DELPHI_5}
function BoolToStr(Value: Boolean): string;
begin
  if Value then
    Result := 'TRUE' else
    Result := 'FALSE';
end;
{$endif}

function SEnding(const S: string; P: integer): string;
begin
 result := Copy(S, P, MaxInt)
end;

function IsPathAbsolute(const Path: string): boolean;
begin
  Result := {$ifdef UNIX} SCharIs(Path, 1, PathDelim) {$endif}
            {$ifdef MSWINDOWS} SCharIs(Path, 2, DriveDelim) {$endif};
end;

function IsPathAbsoluteOnDrive(const Path: string): boolean;
begin
  Result := IsPathAbsolute(Path)
    {$ifdef MSWINDOWS} or SCharIs(Path, 1, PathDelim) {$endif}
end;

function CombinePaths(BasePath, RelPath: string): string;
begin
  {$ifdef UNIX}
  { On Unix accept also relative paths with backslash (Windows). }
  // Commented out, not valid -- on Unix backslash is a valid filename character.
  // RelPath := SCharsReplace(RelPath, '\', '/');
  {$endif}

  if IsPathAbsolute(RelPath) then
    result := RelPath else
  {$ifdef MSWINDOWS}
  if IsPathAbsoluteOnDrive(RelPath) then
    result := BasePath[1] +DriveDelim +RelPath else
  {$endif}
  begin
    repeat
      if (Copy(RelPath, 1, 2) = './')
        {$ifdef MSWINDOWS} or (Copy(RelPath, 1, 2) = '.\') {$endif} then
        RelPath := SEnding(RelPath, 3) else
      if (Copy(RelPath, 1, 3) = '../')
        {$ifdef MSWINDOWS} or (Copy(RelPath, 1, 3) = '..\') {$endif} then
      begin
        BasePath := ExtractFileDir(ExcludeTrailingPathDelimiter(BasePath));
        RelPath := SEnding(RelPath, 4);
      end else
        Break;
    until false;

    result := IncludeTrailingPathDelimiter(BasePath) + RelPath;
  end;
end;

function DeleteFileExt(const FileName: string): string;
var
  I: Integer;
begin
  for I := Length(FileName) downto 1 do
  begin
    if FileName[I] = '.' then
    begin
      Result := Copy(FileName, 1, I - 1);
      Exit;
    end else
    if FileName[I] = PathDelim then
      Break;
  end;

  Result := FileName;
end;

function RemoveIndentation(const Code: string): string;
var
  Source: TStrings;
  IndentationPrefix: string;
  I, J, FirstNonEmptyLine: Integer;
begin
  Source := TStringList.Create;
  try
    Source.Text := Code;

    // calculate FirstNonEmptyLine
    FirstNonEmptyLine := -1;
    for I := 0 to Source.Count - 1 do
      if Trim(Source[I]) <> '' then
      begin
        FirstNonEmptyLine := I;
        break;
      end;

    // nothing to do if all the lines are empty
    if FirstNonEmptyLine <> -1 then
    begin
      // calculate IndentationPrefix as the whitespace in FirstNonEmptyLine
      Assert(Trim(Source[FirstNonEmptyLine]) <> '');
      IndentationPrefix := ''; // should always be changed by loop below
      for I := 1 to Length(Source[FirstNonEmptyLine]) - 1 do
        if not IsCharInSet(Source[FirstNonEmptyLine][I], WhiteSpace) then
        begin
          IndentationPrefix := Copy(Source[FirstNonEmptyLine], 1, I - 1);
          break;
        end;

      // update the IndentationPrefix,
      // to be a common prefix of all the lines since FirstNonEmptyLine
      for I := FirstNonEmptyLine + 1 to Source.Count - 1 do
      begin
        // Don't limit IndentationPrefix on lines that have only whitespace.
        // This allows users to trim whitespace in their source code without
        // affecting the longCode look/
        if Trim(Source[I]) <> '' then
        begin
          for J := 1 to Length(IndentationPrefix) do
          begin
            { We should never reach here the situation when
              "J > Length(Source[I])". Because then Source[I] would be a prefix
              of IndentationPrefix, but then Source[I] would be only whitespace,
              and we have eliminated this case by "Trim(Source[I]) <> ''" check above. }
            Assert(J <= Length(Source[I]));
            // Possibly make IndentationPrefix shorter.
            if Source[I][J] <> IndentationPrefix[J] then
            begin
              IndentationPrefix := Copy(IndentationPrefix, 1, J - 1);
              break;
            end;
          end;
        end;
      end;

      // cut the IndentationPrefix from all the lines since FirstNonEmptyLine
      for I := FirstNonEmptyLine to Source.Count - 1 do
        Source[I] := SEnding(Source[I], Length(IndentationPrefix) + 1);
    end;

    Result := TrimRight(Source.Text);
  finally Source.Free; end;
end;

procedure Swap16Buf(Src, Dst: PWord; WordCount: Integer);
var
  I: Integer;
begin
  for I := 1 to WordCount do
  begin
    Dst^ := Swap(Src^);
    Inc(Src);
    Inc(Dst);
  end;
end;

{---------------------------------------------------------------------------}
function IsUtf8LeadByte(const B: Byte): Boolean;
begin
    Result := (B < $80) or (B in [$C2..$F4]);
end;


{---------------------------------------------------------------------------}
function IsUtf8TrailByte(const B: Byte): Boolean;
begin
    Result := B in [$80..$BF];
end;


{---------------------------------------------------------------------------}
function Utf8Size(const LeadByte: Byte): Integer;
begin
    case LeadByte of
        $00..$7F : Result := 1;
        $C2..$DF : Result := 2;
        $E0..$EF : Result := 3;
        $F0..$F4 : Result := 4;
    else
        Result := 0; // Invalid lead byte
    end;
end;


{---------------------------------------------------------------------------}
{$IFNDEF COMPILER_12_UP}
function IsLeadChar(Ch: WideChar): Boolean;
begin
    Result := (Ch >= #$D800) and (Ch <= #$DFFF);
end;
{$ENDIF}


{---------------------------------------------------------------------------}
function IsCharInSet(C: AnsiChar; const CharSet: TCharSet): Boolean;
begin
  Result := C in CharSet;
end;


{---------------------------------------------------------------------------}
function IsCharInSet(C: WideChar; const CharSet: TCharSet): Boolean;
begin
  Result := (C < #$0100) and (AnsiChar(C) in CharSet);
end;


{---------------------------------------------------------------------------}
{$IFDEF MSWINDOWS}
function AnsiToUnicode(const Str: RawByteString; ACodePage: LongWord): UnicodeString;
var
    Len, Len2 : Integer;
begin
    Len := Length(Str);
    if Len > 0 then begin
        Len := MultiByteToWideChar(ACodePage, 0, Pointer(Str),
                                   Len, nil, 0);
        SetLength(Result, Len);
        if Len > 0 then
        begin
            Len2 := MultiByteToWideChar(ACodePage, 0, Pointer(Str), Length(Str),
                                Pointer(Result), Len);
            if Len2 <> Len then // May happen, very rarely
                SetLength(Result, Len2);
        end;
    end
    else
        Result := '';
end;


{---------------------------------------------------------------------------}
function AnsiToUnicode(const Str: PAnsiChar; ACodePage: LongWord): UnicodeString;
var
    Len, Len2 : Integer;
begin
    if (Str <> nil) then begin
        Len := MultiByteToWideChar(ACodePage, 0, Str, -1, nil, 0);
        if Len > 1 then begin // counts the null-terminator
            SetLength(Result, Len - 1);
            Len2 := MultiByteToWideChar(ACodePage, 0, Str, -1,
                                Pointer(Result), Len);
            if Len2 <> Len then  // May happen, very rarely
            begin
                if Len2 > 0 then
                    SetLength(Result, Len2 - 1)
                else
                    Result := '';
            end;
        end
        else
            Result := '';
    end
    else
        Result := '';
end;


{---------------------------------------------------------------------------}
function AnsiToUnicode(const Str: RawByteString): UnicodeString;
begin
    Result := AnsiToUnicode(Str, CP_ACP);
end;


{---------------------------------------------------------------------------}
function UnicodeToAnsi(const Str: UnicodeString; ACodePage: LongWord; SetCodePage: Boolean = False): RawByteString;
var
    Len, Len2 : Integer;
begin
    Len := Length(Str);
    if Len > 0 then begin
        Len := WideCharToMultiByte(ACodePage, 0, Pointer(Str), Len, nil, 0, nil, nil);
        SetLength(Result, Len);
        if Len > 0 then begin
            Len2 := WideCharToMultiByte(ACodePage, 0, Pointer(Str), Length(Str),
                                Pointer(Result), Len, nil, nil);
            if Len2 <> Len then // May happen, very rarely
                SetLength(Result, Len2);
        {$IFDEF COMPILER_12_UP}
            if SetCodePage and (ACodePage <> CP_ACP) then
                PWord(INT_PTR(Result) - 12)^ := ACodePage;
        {$ENDIF}
        end;
    end
    else
        Result := '';
end;


{---------------------------------------------------------------------------}
function UnicodeToAnsi(const Str: PWideChar; ACodePage: LongWord;
  SetCodePage: Boolean = False): RawByteString;
var
    Len, Len2 : Integer;
begin
    if (Str <> nil) then begin
        Len := WideCharToMultiByte(ACodePage, 0, Str, -1, nil, 0, nil, nil);
        if Len > 1 then begin // counts the null-terminator
            SetLength(Result, Len - 1);
            Len2 := WideCharToMultiByte(ACodePage, 0, Str, -1,
                                Pointer(Result), Len,
                                nil, nil);
            if Len2 <> Len then // May happen, very rarely
            begin
                if Len2 > 0 then
                    SetLength(Result, Len2 - 1)
                else
                    Result := '';
            end;
        {$IFDEF COMPILER_12_UP}
            if SetCodePage and (ACodePage <> CP_ACP) then
                PWord(INT_PTR(Result) - 12)^ := ACodePage;
        {$ENDIF}
        end
        else
            Result := '';
    end
    else
        Result := '';
end;


{---------------------------------------------------------------------------}
function UnicodeToAnsi(const Str: UnicodeString): RawByteString;
begin
    Result := UnicodeToAnsi(Str, CP_ACP);
end;
{$ENDIF}

{$IFDEF COMPILER_10_UP}
function CheckGetFileDate(const AFileName: string): TDateTime;
begin
  if not FileAge(AFileName, Result) then
    raise Exception.Create('Error on getting the file date :"' + AFileName + '"');
end;
{$ENDIF}

function StripHtml(const S: string): string;
var
  Done, NextTagEnd, NextTagStart: Integer;
begin
  Result := '';
  Done := 0;
  while Done < Length(S) do
  begin
    NextTagStart := PosEx('<', S, Done + 1);
    if NextTagStart <> 0 then
      NextTagEnd := PosEx('>', S, NextTagStart + 1)
    else
      NextTagEnd := 0; // just for safety, not really needed
    if (NextTagStart <> 0) and (NextTagEnd <> 0) then
    begin
      Result := Result + Copy(S, Done + 1, NextTagStart - (Done + 1));
      Done := NextTagEnd;
    end else
    begin
      Result := Result + SEnding(S, Done + 1);
      // Done := Length(S);
      Break; // we know that we can break the loop now
    end;
  end;
end;

{$ifdef VER3_0}
function IndexText(const AText: string; const AValues: array of string): Integer;
begin
  for Result := Low(AValues) to High(AValues) do
    if AnsiSameText(AValues[Result], AText) then
      Exit;
  Result := -1;
end;
{$endif}

function SAppendPart(const S, PartSeparator, NextPart: String): String;
begin
  if S = '' then
    Result := NextPart
  else
    Result := S + PartSeparator + NextPart;
end;

function CharsPos(const Chars: TCharSet; const S: String): Integer;
begin
  for Result := 1 to Length(S) do
    if IsCharInSet(S[Result], Chars) then
      Exit;
  Result := 0;
end;

function SRemoveChars(const S: string; const Chars: TCharSet): string;
var I: Integer;
var NextResultChar: Integer;
begin
  SetLength(Result, Length(S));

  NextResultChar := 1;
  for I := 1 to Length(S) do
  begin
    if not CharInSet(S[I], Chars) then
    begin
      Result[NextResultChar] := S[I];
      Inc(NextResultChar);
    end;
  end;

  SetLength(Result, NextResultChar - 1);
end;

end.

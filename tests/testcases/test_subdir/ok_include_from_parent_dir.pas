{ Test using $I to include a file from the parent directory.
  E.g. mORMot uses this, to include mormot.defines.inc, all along sources. }
unit ok_include_from_parent_dir;
interface

{ Include file using Windows backslashes, to make test harder.
  Should work cross-platform, FPC allows this even on Linux too. }
{$I ..\sample_include.inc}
const
  TestSampleInclude = {$ifdef GOT_SAMPLE_INCLUDE} 'OK' {$else} make parsing error {$endif};

{ Include with (Unix forward) slashes.
  This is easier test, since / work also on Windos as path separator
  out-of-the-box. }
{$I ../sample_include_2.inc}
const
  TestSampleInclude2 = {$ifdef GOT_SAMPLE_INCLUDE_2} 'OK' {$else} make parsing error {$endif};

implementation
end.

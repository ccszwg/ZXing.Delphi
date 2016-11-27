{
  * Copyright 2008 ZXing authors
  *
  * Licensed under the Apache License, Version 2.0 (the "License");
  * you may not use this file except in compliance with the License.
  * You may obtain a copy of the License at
  *
  *      http://www.apache.org/licenses/LICENSE-2.0
  *
  * Unless required by applicable law or agreed to in writing, software
  * distributed under the License is distributed on an "AS IS" BASIS,
  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  * See the License for the specific language governing permissions and
  * limitations under the License.

  * Original Authors: dswitkin@google.com (Daniel Switkin), Sean Owen and
  *                   alasdair@google.com (Alasdair Mackintosh)
  *
  * Delphi Implementation by E. Spelt
}

unit ZXing.OneD.EAN8Reader;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.Math,
  ZXing.OneD.OneDReader,
  ZXing.Common.BitArray,
  ZXing.OneD.UPCEANReader,
  ZXing.ReadResult,
  ZXing.DecodeHintType,
  ZXing.ResultPoint,
  ZXing.BarcodeFormat;

type
  /// <summary>
  /// <p>Implements decoding of the EAN-8 format.</p>
  /// </summary>
  TEAN8Reader = class(TUPCEANReader)

  private
    class var decodeMiddleCounters: TArray<Integer>;
  protected
      class function decodeMiddle(const row: IBitArray;
      const startRange: TArray<Integer>; const resultString: TStringBuilder)
      : Integer; override;
  public
    function BarcodeFormat: TBarcodeFormat; override;
    constructor Create; override;
    destructor Destroy; override;
  end;

implementation

function TEAN8Reader.BarcodeFormat: TBarcodeFormat;
begin
  result:=TBarcodeFormat.EAN_8;
end;

constructor TEAN8Reader.Create;
begin
  inherited;
  SetLength(decodeMiddleCounters, 4);
end;

destructor TEAN8Reader.Destroy;
begin
  decodeMiddleCounters := nil;
  inherited;
end;

class function TEAN8Reader.DecodeMiddle(const row: IBitArray;
  const startRange: TArray<Integer>;
  const resultString: TStringBuilder): Integer;
var
  ending, rowOffset, x, bestMatch: Integer;
  counter: Integer;
  counters, middleRange: TArray<Integer>;
begin
  counters := self.decodeMiddleCounters;
  counters[0] := 0;
  counters[1] := 0;
  counters[2] := 0;
  counters[3] := 0;
  ending := row.Size;
  rowOffset := startRange[1];
  x := 0;
  while (((x < 4) and (rowOffset < ending))) do
  begin
    if (not TUPCEANReader.decodeDigit(row, counters, rowOffset,
      TUPCEANReader.L_PATTERNS, bestMatch)) then
    begin
      Result := -1;
      exit
    end;

    resultString.Append(IntToStr(bestMatch));

    for counter in counters do
    begin
      inc(rowOffset, counter)
    end;
    inc(x)
  end;

  middleRange := TUPCEANReader.findGuardPattern(row, rowOffset, true,
    TUPCEANReader.MIDDLE_PATTERN);
  if (middleRange = nil) then
  begin
    Result := -1;
    exit
  end;

  rowOffset := middleRange[1];
  x := 0;
  while (((x < 4) and (rowOffset < ending))) do
  begin
    if (not TUPCEANReader.decodeDigit(row, counters, rowOffset,
      TUPCEANReader.L_PATTERNS, bestMatch)) then
    begin
      Result := -1;
      exit
    end;

    resultString.Append(IntToStr(bestMatch));
    for counter in counters do
    begin
      inc(rowOffset, counter)
    end;

    inc(x)
  end;

  Result := rowOffset;

end;



end.

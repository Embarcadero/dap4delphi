unit BaseProtocol.Json;

interface

uses
  Rest.Json,
  Rest.Json.Types,
  Rest.JsonReflect,
  Rest.Json.Interceptors;

type
  TBaseProtocolJsonAdapter = class
  public
    class procedure RegisterConverters(const AJSONMarshal: TJSONMarshal); static;
    class procedure RegisterReverters(const AJSONUnmarshal: TJSONUnMarshal); static;
  end;

  TEnumInterceptor = class(TJSONInterceptor)
  public
    constructor Create;
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TSetInterceptor = class(TJSONInterceptor)
  public
    constructor Create;
    function StringsConverter(Data: TObject; Field: string): TListOfStrings; override;
    procedure StringsReverter(Data: TObject; Field: string; Args: TListOfStrings); override;
  end;

implementation

uses
  System.Rtti, System.TypInfo, System.SysUtils, System.Classes, System.Character;

{ TBaseProtocolJsonAdapter }

class procedure TBaseProtocolJsonAdapter.RegisterConverters(
  const AJSONMarshal: TJSONMarshal);
begin

end;

class procedure TBaseProtocolJsonAdapter.RegisterReverters(
  const AJSONUnmarshal: TJSONUnMarshal);
begin

end;

{ TEnumInterceptor }

constructor TEnumInterceptor.Create;
begin
  inherited;
  ConverterType := ctString;
  ReverterType := rtString;
end;

function TEnumInterceptor.StringConverter(Data: TObject; Field: string): string;
var
  LRttiCtx: TRttiContext;
begin
  var LValue := LRttiCtx.GetType(Data.ClassInfo).GetField(Field).GetValue(Data);

  if (LValue.Kind <> tkEnumeration) then
    raise Exception.CreateFmt('%s %s is not a valid enum type.', [
      Data.ClassName, Field]);

  Result := GetEnumName(LValue.TypeInfo, TValueData(LValue).FAsSLong);
  if not Result.IsEmpty() then
    Result[Low(Result)] := Result[Low(Result)].ToLower();
end;

procedure TEnumInterceptor.StringReverter(Data: TObject; Field, Arg: string);
var
  LRttiCtx: TRttiContext;
begin
  var LRttiField := LRttiCtx.GetType(Data.ClassInfo).GetField(Field);
  var LValue := GetEnumValue(LRttiField.FieldType.Handle, Arg);
  if LValue = -1 then
    raise Exception.CreateFmt('%s is not a valid enum value for %s %s', [
      Arg, Data.ClassName, Field]);

  var LEnumValue: TValue;
  TValue.Make(LValue, LRttiField.FieldType.Handle, LEnumValue);
  LRttiField.SetValue(Data, LEnumValue);
end;

{ TSetInterceptor }

constructor TSetInterceptor.Create;
begin
  ConverterType := ctStrings;
  ReverterType := rtStrings;
end;

function TSetInterceptor.StringsConverter(Data: TObject;
  Field: string): TListOfStrings;
var
  LRttiCtx: TRttiContext;
begin
  var LValue := LRttiCtx.GetType(Data.ClassInfo).GetField(Field).GetValue(Data);

  if (LValue.Kind <> tkSet) then
    raise Exception.CreateFmt('%s %s is not a valid set type.', [
      Data.ClassName, Field]);

  Result := TListOfStrings(
    SetToString(LValue.TypeInfo, TValueData(LValue).FAsSLong, false)
      .Split([',']));

  for var I := Low(Result) to High(Result) do
    Result[I][Low(Result[I])] := Result[I][Low(Result[I])].ToLower();
end;

procedure TSetInterceptor.StringsReverter(Data: TObject; Field: string;
  Args: TListOfStrings);
var
  LRttiCtx: TRttiContext;
begin
  var LRttiField := LRttiCtx.GetType(Data.ClassInfo).GetField(Field);
  var LValues: TArray<string> := [];
  for var LEnumValue in Args do begin
    var LTypeData := GetTypeData(LRttiField.FieldType.Handle)^;
    var LValue := GetEnumValue(LTypeData.CompType^, LEnumValue);
    if LValue = -1 then
      raise Exception.CreateFmt('%s is not a valid enum value for %s %s', [
        LEnumValue, Data.ClassName, Field])
    else
      LValues := LValues + [LEnumValue];
  end;

  var LEnumValue: TValue;
  TValue.Make(
    StringToSet(LRttiField.FieldType.Handle, String.Join(',', LValues)),
    LRttiField.FieldType.Handle, LEnumValue);
  LRttiField.SetValue(Data, LEnumValue);
end;

end.

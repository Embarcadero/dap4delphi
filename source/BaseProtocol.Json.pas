unit BaseProtocol.Json;

interface

uses
  Rest.Json,
  Rest.Json.Types,
  Rest.JsonReflect,
  Rest.Json.Interceptors;

type
  TBaseProtocolJsonAdapter = class
  private
    class procedure DoRegisterObjectListConverter<T: class>(const AMarshal: TJSONMarshal); static;
    class procedure DoRegisterObjectListReverter<T: class>(const AUnmarshal: TJSONUnMarshal); static;
  public
    class procedure RegisterConverters(const AMarshal: TJSONMarshal); static;
    class procedure RegisterReverters(const AUnmarshal: TJSONUnMarshal); static;
  end;

  {----------|| Interceptors ||----------}

  TEnumInterceptor = class(TJSONInterceptor)
  public
    constructor Create();
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
  System.Rtti, System.TypInfo, System.SysUtils, System.Classes, System.Character,
  System.Generics.Collections, BaseProtocol.Types;

const
  DEFAULT_NULL_ENUM_ITEM_NAME = 'None';
  FIELD_ANY = '*';

{ TBaseProtocolJsonAdapter }

class procedure TBaseProtocolJsonAdapter.DoRegisterObjectListConverter<T>(
  const AMarshal: TJSONMarshal);
begin
  AMarshal.RegisterConverter(TObjectList<T>,
    function(Data: TObject): TListOfObjects
    begin
      var LList := TObjectList<T>(Data);
      SetLength(Result, LList.Count);
      for var I := Low(Result) to High(Result) do
        Result[I] := LList[I];
    end);
end;

class procedure TBaseProtocolJsonAdapter.DoRegisterObjectListReverter<T>(
  const AUnmarshal: TJSONUnMarshal);
var
  LReverterEvent: TReverterEvent;
begin
  LReverterEvent := TReverterEvent.Create(T, FIELD_ANY);
  LReverterEvent.TypeObjectsReverter := function(Data: TListOfObjects): TObject
    begin
      var LList := TObjectList<T>.Create();
      try
        for var LItem in Data do
          if Assigned(LItem) then
            LList.Add(LItem);
      except
        on E: Exception do begin
          LList.Free();
          raise;
        end;
      end;
      Result := LList;
    end;
  AUnmarshal.RegisterReverter(TObjectList<T>, FIELD_ANY, LReverterEvent);
end;

class procedure TBaseProtocolJsonAdapter.RegisterConverters(
  const AMarshal: TJSONMarshal);
begin
  DoRegisterObjectListConverter<TDefaultSource>(AMarshal);
  DoRegisterObjectListConverter<TBreakpoint>(AMarshal);
  DoRegisterObjectListConverter<TModule>(AMarshal);
  DoRegisterObjectListConverter<TBreakpointLocation>(AMarshal);
  DoRegisterObjectListConverter<TSourceBreakpoint>(AMarshal);
  DoRegisterObjectListConverter<TFunctionBreakpoint>(AMarshal);
  DoRegisterObjectListConverter<TExceptionFilterOption>(AMarshal);
  DoRegisterObjectListConverter<TExceptionOption>(AMarshal);
  DoRegisterObjectListConverter<TDataBreakpoint>(AMarshal);
  DoRegisterObjectListConverter<TInstructionBreakpoint>(AMarshal);
  DoRegisterObjectListConverter<TStackFrame>(AMarshal);
  DoRegisterObjectListConverter<TScope>(AMarshal);
  DoRegisterObjectListConverter<TVariable>(AMarshal);
  DoRegisterObjectListConverter<TThread>(AMarshal);
  DoRegisterObjectListConverter<TStepInTarget>(AMarshal);
  DoRegisterObjectListConverter<TTarget>(AMarshal);
  DoRegisterObjectListConverter<TCompletitionItem>(AMarshal);
  DoRegisterObjectListConverter<TExceptionDetail>(AMarshal);
  DoRegisterObjectListConverter<TDisassembleInstruction>(AMarshal);

  AMarshal.RegisterConverter(TEmptyBody,
    function(Data: TObject): TObject
    begin
      Result := nil;
    end);

  AMarshal.RegisterConverter(TEmptyArguments,
    function(Data: TObject): TObject
    begin
      Result := nil;
    end);

  AMarshal.RegisterConverter(TKeyValue,
    function(Data: TObject): TListOfStrings
    begin
      raise ENotImplemented.Create('Not implemented.');
    end);
end;

class procedure TBaseProtocolJsonAdapter.RegisterReverters(
  const AUnmarshal: TJSONUnMarshal);
begin
  DoRegisterObjectListReverter<TDefaultSource>(AUnmarshal);
  DoRegisterObjectListReverter<TBreakpoint>(AUnmarshal);
  DoRegisterObjectListReverter<TModule>(AUnmarshal);
  DoRegisterObjectListReverter<TBreakpointLocation>(AUnmarshal);
  DoRegisterObjectListReverter<TSourceBreakpoint>(AUnmarshal);
  DoRegisterObjectListReverter<TFunctionBreakpoint>(AUnmarshal);
  DoRegisterObjectListReverter<TExceptionFilterOption>(AUnmarshal);
  DoRegisterObjectListReverter<TExceptionOption>(AUnmarshal);
  DoRegisterObjectListReverter<TDataBreakpoint>(AUnmarshal);
  DoRegisterObjectListReverter<TInstructionBreakpoint>(AUnmarshal);
  DoRegisterObjectListReverter<TStackFrame>(AUnmarshal);
  DoRegisterObjectListReverter<TScope>(AUnmarshal);
  DoRegisterObjectListReverter<TVariable>(AUnmarshal);
  DoRegisterObjectListReverter<TThread>(AUnmarshal);
  DoRegisterObjectListReverter<TStepInTarget>(AUnmarshal);
  DoRegisterObjectListReverter<TTarget>(AUnmarshal);
  DoRegisterObjectListReverter<TCompletitionItem>(AUnmarshal);
  DoRegisterObjectListReverter<TExceptionDetail>(AUnmarshal);
  DoRegisterObjectListReverter<TDisassembleInstruction>(AUnmarshal);

  AUnmarshal.RegisterReverter(TEmptyBody,
    function(Data: TObject): TObject
    begin
      Result := nil;
    end);

  AUnmarshal.RegisterReverter(TEmptyArguments,
    function(Data: TObject): TObject
    begin
      Result := nil;
    end);

  AUnmarshal.RegisterReverter(TKeyValue,
    function(Data: TListOfStrings): TObject
    begin
      raise ENotImplemented.Create('Not implemented.');
    end);
end;

{ TEnumInterceptor }

constructor TEnumInterceptor.Create;
begin
  inherited Create();
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

  if (Result = DEFAULT_NULL_ENUM_ITEM_NAME) then
    Exit(String.Empty);

  if not Result.IsEmpty() then
    Result[Low(Result)] := Result[Low(Result)].ToLower();
end;

procedure TEnumInterceptor.StringReverter(Data: TObject; Field, Arg: string);
var
  LRttiCtx: TRttiContext;
  LValue: integer;
begin
  var LRttiField := LRttiCtx.GetType(Data.ClassInfo).GetField(Field);

  if Arg.Trim().IsEmpty() then
    LValue := GetEnumValue(LRttiField.FieldType.Handle, DEFAULT_NULL_ENUM_ITEM_NAME)
  else
    LValue := GetEnumValue(LRttiField.FieldType.Handle, Arg);

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

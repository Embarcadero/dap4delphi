unit BaseProtocol.Parser;

interface

uses
  System.SysUtils,
  System.JSON,
  BaseProtocol,
  BaseProtocol.Types,
  BaseProtocol.Events;

type
  TBaseProtocolParser = class
  private
    class function GetJsonValue<T>(const AJSONObject: TJSONObject; const APath: string): T;
    class function JsonToMessageType(const AJSONObject: TJSONObject): TMessageType;
    class function JsonToEventType(const AJSONObject: TJSONObject): TEventType;
    class function JsonToRequestType(const AJSONObject: TJSONObject): TRequestCommand;

    class function GetProtocolMessageType(const AJSONObject: TJSONObject): TClass;
  public
    class function EncodeMessage(const AProtocolMessage: TProtocolMessage): TBytes;
    class function DecodeMessage(const AProtocolMessage: string): TProtocolMessage;
  end;

implementation

uses
  System.Rtti,
  System.TypInfo,
  Rest.JSON,
  Rest.JsonReflect;

{ TBaseProtocolParser }

class function TBaseProtocolParser.EncodeMessage(
  const AProtocolMessage: TProtocolMessage): TBytes;
begin
  var LBody := TEncoding.UTF8.GetBytes(TJson.ObjectToJsonString(AProtocolMessage));
  var LHeader := CONTENT_LENGTH_HEADER + ': ' + Length(LBody).ToString() + String(TWO_CRLF);
  Result := TEncoding.ANSI.GetBytes(LHeader) + LBody;
end;

class function TBaseProtocolParser.GetJsonValue<T>(
  const AJSONObject: TJSONObject; const APath: string): T;
begin
  if not AJSONObject.TryGetValue<T>(APath, Result) then
    raise Exception.CreateFmt('Json attribute %s not found.', [APath]);
end;

class function TBaseProtocolParser.GetProtocolMessageType(
  const AJSONObject: TJSONObject): TClass;
begin
  case JsonToMessageType(AJSONObject) of
    TMessageType.Request : Exit(TProtocolMessage.Requests[JsonToRequestType(AJSONObject)]);
    TMessageType.Response: Exit(TProtocolMessage.Responses[JsonToRequestType(AJSONObject)]);
    TMessageType.Event   : Exit(TProtocolMessage.Events[JsonToEventType(AJSONObject)]);
  end;
  Result := nil;
end;

class function TBaseProtocolParser.JsonToMessageType(
  const AJSONObject: TJSONObject): TMessageType;
begin
  Result := TRttiEnumerationType.GetValue<TMessageType>(
    GetJsonValue<string>(AJSONObject, 'type'));
end;

class function TBaseProtocolParser.JsonToRequestType(
  const AJSONObject: TJSONObject): TRequestCommand;
begin
  Result := TRttiEnumerationType.GetValue<TRequestCommand>(
    GetJsonValue<string>(AJSONObject, 'command'));
end;

class function TBaseProtocolParser.JsonToEventType(
  const AJSONObject: TJSONObject): TEventType;
begin
  Result := TRttiEnumerationType.GetValue<TEventType>(
    GetJsonValue<string>(AJSONObject, 'event'));
end;

class function TBaseProtocolParser.DecodeMessage(
  const AProtocolMessage: string): TProtocolMessage;
var
  LRttiCtx: TRttiContext;
begin
  var LJSON := TJSONValue.ParseJSONValue(AProtocolMessage);
  try
    if not (LJSON is TJSONObject) then
      raise Exception.Create('Unexpected JSON type.');

    var LUnMarshaler := TJSONConverters.GetJSONUnMarshaler;
    try
      var LClass := GetProtocolMessageType(LJSON as TJSONObject);
      var LInstance := TJSONUnMarshal.ObjectInstance(LRttiCtx, LClass.QualifiedClassName);
      try
        if not Assigned(LInstance) then
          raise Exception.Create('Cannot parse JSON.');

        TProtocolMessage(LInstance).Raw := AProtocolMessage;

        Result := LUnMarshaler.CreateObject(
          LClass, LJSON as TJSONObject, LInstance) as TProtocolMessage;
      except
        on E: Exception do begin
          LInstance.Free();
          raise;
        end;
      end;
    finally
      LUnMarshaler.Free;
    end;
  finally
    LJSON.Free();
  end;
end;

end.

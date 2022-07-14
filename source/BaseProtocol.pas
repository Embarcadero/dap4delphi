unit BaseProtocol;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Rest.Json.Types,
  Rest.JsonReflect,
  BaseProtocol.Types,
  BaseProtocol.Json;

type
  TProtocolMessage = class
  strict private
    class var FMessageSequence: integer;
    class var FRequests: TDictionary<TRequestCommand, TClass>;
    class var FResponses: TDictionary<TRequestCommand, TClass>;
    class var FEvents: TDictionary<TEventType, TClass>;
  private
    [JSONName('seq')]
    FSeq: integer;
    [JSONName('type'), JSONReflect(ctString, rtString, TEnumInterceptor)]
    FMessageType: TMessagetype;
  protected
    function GetMessageTypeFromAttribute(): TMessageType;
  public
    class constructor Create();
    class destructor Destroy();

    procedure AfterConstruction(); override;
    procedure BeforeDestruction(); override;

    property Seq: integer read FSeq;
    property MessageType: TMessagetype read FMessageType;

    class procedure RegisterRequest(const ARequestCommand: TRequestCommand;
      const ARequestClass, AResponseClass: TClass);
    class procedure UnregisterRequest(const ARequestCommand: TRequestCommand);
    class procedure RegisterEvent(const AEventType: TEventType; const AClass: TClass);
    class procedure UnregisterEvent(const AEventType: TEventType);

    //Protocol message handlers
    class property Requests: TDictionary<TRequestCommand, TClass> read FRequests;
    class property Responses: TDictionary<TRequestCommand, TClass> read FResponses;
    class property Events: TDictionary<TEventType, TClass> read FEvents;
  end;

  [MessageType(TMessageType.Request)]
  TRequest<TArguments> = class(TProtocolMessage)
  private
    [JSONName('command'), JSONReflect(ctString, rtString, TEnumInterceptor)]
    FCommand: TRequestCommand;
    [JSONName('arguments')]
    FArguments: TArguments;
  protected
    function GetRequestCommandFromAttribute(): TRequestCommand;
  public
    procedure AfterConstruction(); override;
    procedure BeforeDestruction(); override;

    property Command: TRequestCommand read FCommand;
    property Arguments: TArguments read FArguments write FArguments;
  end;
  TDefaultRequest = TRequest<TEmptyArguments>;

  [MessageType(TMessageType.Event)]
  TEvent<TBody> = class(TProtocolMessage)
  private
    [JSONName('event'), JSONReflect(ctString, rtString, TEnumInterceptor)]
    FEvent: TEventType;
    [JSONName('body')]
    FBody: TBody;
  public
    procedure AfterConstruction(); override;
    procedure BeforeDestruction(); override;

    property Event: TEventType read FEvent;
    property Body: TBody read FBody write FBody;
  end;
  TDefaultEvent = TEvent<TEmptyBody>;

  [MessageType(TMessageType.Response)]
  TResponse<TBody> = class(TProtocolMessage)
  private
    [JSONName('request_seq')]
    FRequestSeq: integer;
    [JSONName('success')]
    FSuccess: boolean;
    [JSONName('command'), JSONReflect(ctString, rtString, TEnumInterceptor)]
    FCommand: TRequestCommand;
    [JSONName('message'), JSONReflect(ctString, rtString, TEnumInterceptor)]
    FMessage: TResponseMessage;
    [JSONName('body')]
    FBody: TBody;
  public
    procedure AfterConstruction(); override;
    procedure BeforeDestruction(); override;

    property RequestSeq: integer read FRequestSeq write FRequestSeq;
    property Success: boolean read FSuccess write FSuccess;
    property Command: TRequestCommand read FCommand write FCommand;
    property Message: TResponseMessage read FMessage write FMessage;
    property Body: TBody read FBody;
  end;
  TDefaultResponse = TResponse<TEmptyBody>;

  TErrorResponseBody = class
  private
    [JSONName('error')]
    FError: TMessage;
  public
    procedure AfterConstruction(); override;
    procedure BeforeDestruction(); override;

    property Error: TMessage read FError;
  end;

  TErrorResponse = class(TResponse<TErrorResponseBody>);

implementation

uses
  System.Classes, System.SyncObjs, System.Rtti, System.TypInfo,
  BaseProtocol.Helpers;

{ TProtocolMessage }

procedure TProtocolMessage.AfterConstruction;
begin
  inherited;
  FMessageType := GetMessageTypeFromAttribute();
  if (FMessageType = TMessageType.Request) then
    FSeq := TInterlocked.Increment(FMessageSequence);
  TGenericHelper.CreateFields(Self);
end;

procedure TProtocolMessage.BeforeDestruction;
begin
  inherited;
  TGenericHelper.FreeFields(Self);
end;

class constructor TProtocolMessage.Create;
begin
  FRequests := TDictionary<TRequestCommand, TClass>.Create();
  FResponses := TDictionary<TRequestCommand, TClass>.Create();
  FEvents := TDictionary<TEventType, TClass>.Create();
end;

class destructor TProtocolMessage.Destroy;
begin
  FEvents.Free();
  FResponses.Free();
  FRequests.Free();
end;

function TProtocolMessage.GetMessageTypeFromAttribute: TMessageType;
begin
  var LRttiCtx := TRttiContext.Create();
  try
    var LType := LRttiCtx.GetType(Self.ClassInfo);
    while Assigned(LType) do begin
      var LAttribute := LType.GetAttribute<MessageTypeAttribute>();
      if Assigned(LAttribute) then
        Exit(LAttribute.MessageType);

      LType := LType.BaseType;
    end;

    raise Exception.Create('Message type attribute not found.');
  finally
    LRttiCtx.Free();
  end;
end;

class procedure TProtocolMessage.RegisterEvent(const AEventType: TEventType;
  const AClass: TClass);
begin
  FEvents.Add(AEventType, AClass);
end;

class procedure TProtocolMessage.RegisterRequest(
  const ARequestCommand: TRequestCommand;
  const ARequestClass, AResponseClass: TClass);
begin
  FRequests.Add(ARequestCommand, ARequestClass);
  FResponses.Add(ARequestCommand, AResponseClass)
end;

class procedure TProtocolMessage.UnregisterEvent(const AEventType: TEventType);
begin
  FEvents.Remove(AEventType);
end;

class procedure TProtocolMessage.UnregisterRequest(
  const ARequestCommand: TRequestCommand);
begin
  FRequests.Remove(ARequestCommand);
  FResponses.Remove(ARequestCommand);
end;

{ TRequest<TArguments> }

procedure TRequest<TArguments>.AfterConstruction;
begin
  inherited;
  FCommand := GetRequestCommandFromAttribute();
  FArguments := TGenericHelper.CreateGenericIfClass<TArguments>();
end;

procedure TRequest<TArguments>.BeforeDestruction;
begin
  inherited;
  TGenericHelper.FreeGenericIfInstance<TArguments>(FArguments);
end;

function TRequest<TArguments>.GetRequestCommandFromAttribute: TRequestCommand;
begin
  var LRttiCtx := TRttiContext.Create();
  try
    var LType := LRttiCtx.GetType(Self.ClassInfo);
    while Assigned(LType) do begin
      var LAttribute := LType.GetAttribute<RequestCommandAttribute>();
      if Assigned(LAttribute) then
        Exit(LAttribute.RequestCommand);

      LType := LType.BaseType;
    end;

    raise Exception.Create('Request command attribute not found.');
  finally
    LRttiCtx.Free();
  end;
end;

{ TEvent<TBody> }

procedure TEvent<TBody>.AfterConstruction;
begin
  inherited;
  FBody := TGenericHelper.CreateGenericIfClass<TBody>();
end;

procedure TEvent<TBody>.BeforeDestruction;
begin
  inherited;
  TGenericHelper.FreeGenericIfInstance<TBody>(FBody);
end;

{ TResponse<TBody> }

procedure TResponse<TBody>.AfterConstruction;
begin
  inherited;
  FBody := TGenericHelper.CreateGenericIfClass<TBody>();
end;

procedure TResponse<TBody>.BeforeDestruction;
begin
  inherited;
  TGenericHelper.FreeGenericIfInstance<TBody>(FBody);
end;

{ TErrorResponseBody }

procedure TErrorResponseBody.AfterConstruction;
begin
  inherited;
  FError := TMessage.Create();
end;

procedure TErrorResponseBody.BeforeDestruction;
begin
  inherited;
  FError.Free();
end;

end.

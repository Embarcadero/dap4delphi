unit BaseProtocol;

interface

uses
  System.SysUtils,
  Rest.Json.Types,
  Rest.JsonReflect,
  BaseProtocol.Types,
  BaseProtocol.Json;

type
  TProtocolMessage = class
  strict private
    class var FMessageSequence: integer;
  private
    [JSONName('seq')]
    FSeq: integer;
    [JSONName('type'), JSONReflect(ctString, rtString, TEnumInterceptor)]
    FMessageType: TMessagetype;
  protected
    function GetMessageTypeFromAttribute(): TMessageType;
  public
    procedure AfterConstruction(); override;

    property Seq: integer read FSeq;
    property MessageType: TMessagetype read FMessageType;
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
  System.Classes, System.SyncObjs, System.Rtti, System.TypInfo;

{ TProtocolMessage }

procedure TProtocolMessage.AfterConstruction;
begin
  inherited;
  FMessageType := GetMessageTypeFromAttribute();
  if (FMessageType = TMessageType.Request) then
    FSeq := TInterlocked.Increment(FMessageSequence);
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

{ TRequest<TArguments> }

procedure TRequest<TArguments>.AfterConstruction;
begin
  inherited;
  FCommand := GetRequestCommandFromAttribute();
end;

procedure TRequest<TArguments>.BeforeDestruction;
begin
  inherited;
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
end;

procedure TEvent<TBody>.BeforeDestruction;
begin
  inherited;
end;

{ TResponse<TBody> }

procedure TResponse<TBody>.AfterConstruction;
begin
  inherited;
end;

procedure TResponse<TBody>.BeforeDestruction;
begin
  inherited;
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

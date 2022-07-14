unit BaseProtocol.Client;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.Threading,
  BaseProtocol,
  BaseProtocol.Types,
  BaseProtocol.Requests,
  BaseProtocol.ReverseRequests,
  BaseProtocol.Events;

type
  {$SCOPEDENUMS ON}
  TConnectionState = (Disconnected, Connecting, Connected);
  {$SCOPEDENUMS OFF}
  TResolve<T> = reference to procedure(const AArg: T);
  TReject = reference to procedure(const AArg: TResponseMessage);
  TEventNotification<T: TEvent> = reference to procedure(const AEvent: T);
  TEventNotification = TEventNotification<TEvent>;

  IUnsubscribable = interface
    ['{6E085AE3-0AE4-4CAF-9921-12902D1633B6}']
    procedure Unsubscribe();
  end;

  TBaseProtocolClient = class
  private
    FActive: boolean;
    FState: TConnectionState;
    FPendingRequests: TDictionary<integer, TProc<TResponse>>;
    FEventSubscribers: TList<TEventNotification>;
    FTask: ITask;
    FBuffer: string;
    FContentLenght: integer;
    procedure DoHandleResponse(const AResponse: TResponse);
    procedure DoHandleEvent(const AEvent: TEvent);
    procedure DoHandleRequest(const ARequest: TProtocolMessage);
    procedure SetActive(const Value: boolean);
  protected
    procedure InternalConnect(); virtual; abstract;
    procedure InternalDisconnect(); virtual; abstract;
    //Message type comparison
    function IsResponse(const AMessage: TProtocolMessage): boolean;
    function IsEvent(const AMessage: TProtocolMessage): boolean;
    function IsRequest(const AMessage: TProtocolMessage): boolean;
    //Response message handler
    procedure HandleMessage(const AMessage: TProtocolMessage);
    //Raw data
    function RequestData(): TBytes; virtual; abstract;
    procedure SendData(const ARaw: TBytes); virtual; abstract;
    procedure HandleData(const AData: TBytes; const ABody: TProc<string>);
  public
    constructor Create();
    destructor Destroy(); override;

    procedure Connect();
    procedure Disconnect();

    function SubscribeToEvent(
      const AEventNotification: TEventNotification): IUnsubscribable; overload;
    function SubscribeToEvent<T>(const AEventType: TEventType;
      const AEventNotification: TEventNotification): IUnsubscribable; overload;
    function SubscribeToEvent<T: TEvent>(
      const AEventNotification: TEventNotification<T>): IUnsubscribable; overload;

    procedure SendRequest<T: TResponse>(const AMessage: TRequest;
      const AResolve: TResolve<T>; const AReject: TReject);

    property Active: boolean read FActive write SetActive;
    property State: TConnectionState read FState;
  end;

implementation

uses
  System.Classes,
  System.Rtti,
  System.RegularExpressions,
  BaseProtocol.Parser;

type
  TUnsubscribable = class(TInterfacedObject, IUnsubscribable)
  private type
    TOnUnsubscribe = reference to procedure();
  private
    FOnUnsubscribe: TOnUnsubscribe;
  public
    constructor Create(const AOnUnsubscribe: TOnUnsubscribe);
    procedure Unsubscribe();
  end;

{ TBaseProtocolClient }

constructor TBaseProtocolClient.Create;
begin
  FState := TConnectionState.Disconnected;
  FPendingRequests := TDictionary<integer, TProc<TResponse>>.Create();
  FEventSubscribers := TList<TEventNotification>.Create();
  FContentLenght := -1;
end;

destructor TBaseProtocolClient.Destroy;
begin
  FActive := false;
  if Assigned(FTask) then
    FTask.Wait();
  FEventSubscribers.Free();
  FPendingRequests.Free();
  inherited;
end;

procedure TBaseProtocolClient.Connect;
begin
  if FState <> TConnectionState.Disconnected then
    raise Exception.Create('Client is currently connected or connecting.');

  FState := TConnectionState.Connecting;
  try
    InternalConnect();
    FState := TConnectionState.Connected;
  finally
    if FState = TConnectionState.Connecting then
      FState := TConnectionState.Disconnected;
  end;
end;

procedure TBaseProtocolClient.Disconnect;
begin
  if FState <> TConnectionState.Connected then
    raise Exception.Create('Client is not connected.');

  InternalDisconnect();
  FState := TConnectionState.Disconnected;
end;

procedure TBaseProtocolClient.DoHandleResponse(
  const AResponse: TResponse);
begin
  var LRequestSeq := AResponse.RequestSeq;
  if FPendingRequests.ContainsKey(LRequestSeq) then begin
    var LCallback := FPendingRequests.ExtractPair(LRequestSeq).Value;
    LCallback(AResponse);
  end;
end;

procedure TBaseProtocolClient.DoHandleEvent(
  const AEvent: TEvent);
begin
  for var LSubscriber in FEventSubscribers do begin
    LSubscriber(AEvent);
  end;
end;

procedure TBaseProtocolClient.DoHandleRequest(
  const ARequest: TProtocolMessage);
begin

end;

function TBaseProtocolClient.IsEvent(const AMessage: TProtocolMessage): boolean;
begin
  Result := (AMessage.MessageType = TMessageType.Event)
    and (AMessage is TEvent);
end;

function TBaseProtocolClient.IsRequest(
  const AMessage: TProtocolMessage): boolean;
begin
  Result := (AMessage.MessageType = TMessageType.Request)
    and (AMessage is TRequest);
end;

function TBaseProtocolClient.IsResponse(
  const AMessage: TProtocolMessage): boolean;
begin
  Result := (AMessage.MessageType = TMessageType.Response)
    and (AMessage is TResponse);
end;

procedure TBaseProtocolClient.SendRequest<T>(const AMessage: TRequest;
  const AResolve: TResolve<T>; const AReject: TReject);
begin
  FPendingRequests.Add(AMessage.Seq,
    procedure(AProtocolMessage: TResponse)
    begin
      if AProtocolMessage.Success then
        AResolve(AProtocolMessage as T)
      else
        AReject(AProtocolMessage.Message);
    end);
  SendData(TBaseProtocolParser.EncodeMessage(AMessage));
end;

procedure TBaseProtocolClient.SetActive(const Value: boolean);
begin
  if (FActive <> Value) then begin
    FActive := Value;
    if FActive then begin
      if (FState = TConnectionState.Disconnected) then
        Connect();

      FTask := TTask.Run(
        procedure()
        begin
          while FActive do begin
            HandleData(RequestData(),
              procedure(ABody: string)
              begin
                var LProtocolMessage := TBaseProtocolParser.DecodeMessage(ABody);
                try
                  HandleMessage(LProtocolMessage);
                finally
                  LProtocolMessage.Free();
                end;
              end);
            Sleep(100);
          end;
        end);
    end else
      Disconnect();
  end;
end;

function TBaseProtocolClient.SubscribeToEvent(
  const AEventNotification: TEventNotification): IUnsubscribable;
begin
  FEventSubscribers.Add(AEventNotification);
  Result := TUnsubscribable.Create(
    procedure
    begin
      FEventSubscribers.Remove(AEventNotification);
    end);
end;

function TBaseProtocolClient.SubscribeToEvent<T>(
  const AEventNotification: TEventNotification<T>): IUnsubscribable;
var
  LRttiCtx: TRttiContext;
begin
  Result := SubscribeToEvent(
    procedure(const AEvent: TEvent)
    begin
      var LRttiType := LRttiCtx.GetType(T);
      if (LRttiType.IsInstance
        and (LRttiType.AsInstance.MetaclassType = AEvent.ClassType)) then
          AEventNotification(AEvent as T);
    end);
end;

function TBaseProtocolClient.SubscribeToEvent<T>(const AEventType: TEventType;
  const AEventNotification: TEventNotification): IUnsubscribable;
begin
  Result := SubscribeToEvent(
    procedure(const AEvent: TEvent)
    begin
      if (AEvent.Event = AEventType) then
        AEventNotification(AEvent);
    end);
end;

procedure TBaseProtocolClient.HandleData(const AData: TBytes;
  const ABody: TProc<string>);
begin
  FBuffer := FBuffer + TEncoding.ANSI.GetString(AData);
  while true do begin
    if (FContentLenght >= 0) then begin
      if (FBuffer.Length >= FContentLenght) then begin
        var LBody := FBuffer.Substring(0, FContentLenght + 1);
        FBuffer := FBuffer.Substring(FContentLenght + 1);
        FContentLenght := -1;
        if (LBody.Length > 0) then
          ABody(String(AnsiToUtf8(LBody)));
      end;
      Continue;
    end else begin
      var LIdx := FBuffer.IndexOf(TWO_CRLF);
      if (LIdx <> -1) then begin
        var LHeader := FBuffer.Substring(0, LIdx);
        var LLines := LHeader.Split([sLineBreak]);
        for var I := Low(LLines) to High(LLines) do begin
          var LPair := TRegEx.Split(LLines[I], ': +');
          if (String.CompareText(LPair[Low(LPair)], LPair[Low(LPair)]) = 0) then
            Inc(FContentLenght, LPair[Low(LPair) + 1].ToInteger());
        end;
        FBuffer :=  FBuffer.Substring(LIdx + String(TWO_CRLF).Length);
        Continue;
      end;
    end;
    Break;
  end;
end;

procedure TBaseProtocolClient.HandleMessage(const AMessage: TProtocolMessage);
begin
  if IsResponse(AMessage) then
    DoHandleResponse(AMessage as TResponse)
  else if IsEvent(AMessage) then
    DoHandleEvent(AMessage as TEvent)
  else if IsRequest(AMessage) then
    DoHandleRequest(AMessage as TRequest)
end;

{ TUnsubscribable }

constructor TUnsubscribable.Create(const AOnUnsubscribe: TOnUnsubscribe);
begin
  inherited Create();
  FOnUnsubscribe := AOnUnsubscribe;
end;

procedure TUnsubscribable.Unsubscribe;
begin
  if Assigned(FOnUnsubscribe) then
    FOnUnsubscribe();
end;

end.

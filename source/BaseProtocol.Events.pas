unit BaseProtocol.Events;

interface

uses
  System.Rtti,
  System.Generics.Collections,
  Rest.Json.Types,
  Rest.JsonReflect,
  BaseProtocol,
  BaseProtocol.Types,
  BaseProtocol.Json;

type
  [EventType(TEventType(-1))]
  [EventType(TEventType.Unknown)]
  TUnknownEvent = class(TEvent<TDynamicBody>)
  private
    FEventDescription: string;
  public
    property EventDescription: string read FEventDescription write FEventDescription;
  end;

  [EventType(TEventType.Initialized)]
  TInitializedEvent = class(TEvent<TEmptyBody>);

  TStoppedEventBody = class(TBaseType)
  private
    [JSONName('reason'), JSONReflect(ctString, rtString, TEnumInterceptor)]
    FReason: TStoppedEventReason;
    [JSONName('description')]
    FDescription: string;
    [JSONName('threadId')]
    FThreadId: integer;
    [JSONName('preserveFocusHint')]
    FPreserveFocusHint: boolean;
    [JSONName('text')]
    FText: string;
    [JSONName('allThreadsStopped')]
    FAllThreadStopped: boolean;
    [JSONName('hitBreakpointIds')]
    FHitBreakpointIds: TArray<integer>;
  public
    property Reason: TStoppedEventReason read FReason write FReason;
    property Description: string read FDescription write FDescription;
    property ThreadId: integer read FThreadId write FThreadId;
    property PreserveFocusHint: boolean read FPreserveFocusHint write FPreserveFocusHint;
    property Text: string read FText write FText;
    property AllThreadStopped: boolean read FAllThreadStopped write FAllThreadStopped;
    property HitBreakpointIds: TArray<integer> read FHitBreakpointIds write FHitBreakpointIds;
  end;

  [EventType(TEventType.Stopped)]
  TStoppedEvent = class(TEvent<TStoppedEventBody>);

  TContinuedEventBody = class(TBaseType)
  private
    [JSONName('threadId')]
    FThreadId: integer;
    [JSONName('allThreadsContinued')]
    FAllThreadsContinued: boolean;
  public
    property ThreadId: integer read FThreadId write FThreadId;
    property AllThreadsContinued: boolean read FAllThreadsContinued write FAllThreadsContinued;
  end;

  [EventType(TEventType.Continued)]
  TContinuedEvent = class(TEvent<TContinuedEventBody>);

  TExitedEventBody = class(TBaseType)
  private
    [JSONName('exitCode')]
    FExitCode: integer;
  public
    property ExitCode: integer read FExitCode write FExitCode;
  end;

  [EventType(TEventType.Exited)]
  TExitedEvent = class(TEvent<TExitedEventBody>);

  TTerminatedEventBody<TRestart> = class(TBaseType)
  private
    [JSONName('restart')]
    FRestart: TRestart;
  public
    property Restart: TRestart read FRestart write FRestart;
  end;

  [EventType(TEventType.Terminated)]
  TTerminatedEvent = class(TEvent<TTerminatedEventBody<TValue>>);

  TThreadEventBody = class(TBaseType)
  private
    [JSONName('reason'), JSONReflect(ctString, rtString, TEnumInterceptor)]
    FReason: TThreadEventReason;
    [JSONName('threadId')]
    FThreadId: integer;
  public
    property Reason: TThreadEventReason read FReason write FReason;
    property ThreadId: integer read FThreadId write FThreadId;
  end;

  [EventType(TEventType.Thread)]
  TThreadEvent = class(TEvent<TThreadEventBody>);

  TOutputEventBody = class(TBaseType)
  private
    [JSONName('category'), JSONReflect(ctString, rtString, TEnumInterceptor)]
    FCategory: TOutputEventCategory;
    [JSONName('output')]
    FOutput: string;
    [JSONName('group'), JSONReflect(ctString, rtString, TEnumInterceptor)]
    FGroup: TOutputEventGroup;
    [JSONName('variablesReference')]
    FVariablesReference: integer;
    [Managed()]
    [JSONName('line')]
    FLine: integer;
    [JSONName('column')]
    FColumn: integer;
  public
    property Category: TOutputEventCategory read FCategory write FCategory;
    property Output: string read FOutput write FOutput;
    property Group: TOutputEventGroup read FGroup write FGroup;
    property VariablesReference: integer read FVariablesReference write FVariablesReference;
    property Line: integer read FLine write FLine;
    property Column: integer read FColumn write FColumn;
  end;

  TOutputEventBody<TData, TAdapterData> = class(TOutputEventBody)
  private
    [JSONName('source'), Managed()]
    FSource: TSource<TAdapterData>;
    [JSONName('data'), Managed()]
    FData: TData;
  public
    property Source: TSource<TAdapterData> read FSource;
    property Data: TData read FData write FData;
  end;

  [EventType(TEventType.Output)]
  TOutputEvent<TData, TAdapterData> = class(TEvent<TOutputEventBody<TData, TAdapterData>>);

  TDynamicOutputEvent = TOutputEvent<TDynamicData, TDynamicData>;

  TBreakpointEventBody = class(TBaseType)
  private
    [JSONName('reason'), JSONReflect(ctString, rtString, TEnumInterceptor)]
    FReason: TBreakpointEventReason;
    [JSONName('breakpoint')]
    FBreakpoint: TBreakpoint;
  public
    property Reason: TBreakpointEventReason read FReason write FReason;
    property Breakpoint: TBreakpoint read FBreakpoint;
  end;

  [EventType(TEventType.Breakpoint)]
  TBreakpointEvent = class(TEvent<TBreakpointEventBody>);

  TModuleEventBody = class(TBaseType)
  private
    [JSONName('reason'), JSONReflect(ctString, rtString, TEnumInterceptor)]
    FReason: TModuleEventReason;
    [Managed()]
    [JSONName('module')]
    FModule: TModule;
  public
    property Reason: TModuleEventReason read FReason write FReason;
    property Module: TModule read FModule;
  end;

  [EventType(TEventType.Module)]
  TModuleEvent = class(TEvent<TModuleEventBody>);

  TLoadedSourceEventBody = class(TBaseType)
  private
    [JSONName('reason'), JSONReflect(ctString, rtString, TEnumInterceptor)]
    FReason: TLoadedSourceEventReason;
  public
    property Reason: TLoadedSourceEventReason read FReason write FReason;
  end;

  TLoadedSourceEventBody<TAdapterData> = class(TLoadedSourceEventBody)
  private
    [JSONName('source'), Managed()]
    FSource: TSource<TAdapterData>;
  public
    property Source: TSource<TAdapterData> read FSource;
  end;

  [EventType(TEventType.LoadedSource)]
  TLoadedSourceEvent<TAdapterData> = class(TEvent<TLoadedSourceEventBody<TAdapterData>>);

  TDynamicLoadedSourceEvent = TLoadedSourceEvent<TDynamicData>;

  TProcessEventBody = class(TBaseType)
  private
    [JSONName('name')]
    FName: string;
    [JSONName('systemProcessId')]
    FSystemprocessId: integer;
    [JSONName('isLocalProcess')]
    FIsLocalProcess: boolean;
    [JSONName('startedMethod'), JSONReflect(ctString, rtString, TEnumInterceptor)]
    FStartedMethod: TProcessStartedMethod;
    [JSONName('pointerSize')]
    FPointerSize: integer;
  public
    property Name: string read FName write FName;
    property SystemProcessId: integer read FSystemprocessId write FSystemprocessid;
    property IsLocalProcess: boolean read FIsLocalProcess write FIsLocalProcess;
    property StartedMethod: TProcessStartedMethod read FStartedMethod write FStartedMethod;
    property PointerSize: integer read FPointerSize write FPointerSize;
  end;

  [EventType(TEventType.Process)]
  TProcessEvent = class(TEvent<TProcessEventBody>);

  TCapabilitiesEventBody = class(TBaseType)
  private
    [JSONName('capabilities'), Managed()]
    FCapabilities: TCapabilities;
  public
    property Capabilities: TCapabilities read FCapabilities write FCapabilities;
  end;

  [EventType(TEventType.Capabilities)]
  TCapabilitiesEvent = class(TEvent<TCapabilitiesEventBody>);

  TProgressStartEventBody = class(TBaseType)
  private
    [JSONName('progressId')]
    FProgressId: string;
    [JSONName('title')]
    FTitle: string;
    [JSONName('requestId')]
    FRequestId: integer;
    [JSONName('cancellable')]
    FCancellable: boolean;
    [JSONName('message')]
    FMessage: string;
    [JSONName('percentage')]
    FPercentage: integer;
  public
    property ProgressId: string read FProgressId write FProgressId;
    property Title: string read FTitle write FTitle;
    property RequestId: integer read FRequestId write FRequestId;
    property Cancellable: boolean read FCancellable write FCancellable;
    property Message: string read FMessage write FMessage;
    property Percentage: integer read FPercentage write FPercentage;
  end;

  [EventType(TEventType.ProgressStart)]
  TProgressStartEvent = class(TEvent<TProgressStartEventBody>);

  TProgressUpdateEventBody = class(TBaseType)
  private
    [JSONName('progressId')]
    FProgressId: string;
    [JSONName('message')]
    FMessage: string;
    [JSONName('percentage')]
    FPercentage: integer;
  public
    property ProgressId: string read FProgressId write FProgressId;
    property Message: string read FMessage write FMessage;
    property Percentage: integer read FPercentage write FPercentage;
  end;

  [EventType(TEventType.ProgressUpdate)]
  TProgressUpdateEvent = class(TEvent<TProgressUpdateEventBody>);

  TProgressEndEventBody = class(TBaseType)
  private
    [JSONName('progressId')]
    FProgressId: string;
    [JSONName('message')]
    FMessage: string;
  public
    property ProgressId: string read FProgressId write FProgressId;
    property Message: string read FMessage write FMessage;
  end;

  [EventType(TEventType.ProgressEnd)]
  TProgressEndEvent = class(TEvent<TProgressEndEventBody>);

  TInvalidatedEventBody = class(TBaseType)
  private
    [JSONName('areas'), JSONReflect(ctStrings, rtStrings, TSetInterceptor)]
    FAreas: TInvalidatedAreas;
    [JSONName('threadId')]
    FThreadId: integer;
    [JSONName('stackFrameId')]
    FStackFrameId: integer;
  public
    property Areas: TInvalidatedAreas read FAreas write FAreas;
    property ThreadId: integer read FThreadId write FThreadId;
    property StackFrameId: integer read FStackFrameId write FStackFrameId;
  end;

  [EventType(TEventType.Invalidated)]
  TInvalidatedEvent = class(TEvent<TInvalidatedEventBody>);

  TMemoryEventBody = class(TBaseType)
  private
    [JSONName('memoryReference')]
    FMemoryReference: string;
    [JSONName('offset')]
    FOffset: integer;
    [JSONName('count')]
    FCount: integer;
  public
    property MemoryReference: string read FMemoryReference write FMemoryReference;
    property Offset: integer read FOffset write FOffset;
    property Count: integer read FCount write FCount;
  end;

  [EventType(TEventType.Memory)]
  TMemoryEvent = class(TEvent<TMemoryEventBody>);

  TEventsRegistration = class
  public
    class procedure RegisterAll();
    class procedure UnregisterAll();
  end;

implementation

{ TEventsRegistration }

class procedure TEventsRegistration.RegisterAll;
begin
  TProtocolMessage.RegisterEvent(TEventType(-1), TUnknownEvent);
  TProtocolMessage.RegisterEvent(TEventType.Breakpoint, TBreakpointEvent);
  TProtocolMessage.RegisterEvent(TEventType.Capabilities, TCapabilitiesEvent);
  TProtocolMessage.RegisterEvent(TEventType.Continued, TContinuedEvent);
  TProtocolMessage.RegisterEvent(TEventType.Exited, TExitedEvent);
  TProtocolMessage.RegisterEvent(TEventType.Initialized, TInitializedEvent);
  TProtocolMessage.RegisterEvent(TEventType.Invalidated, TInvalidatedEvent);
  TProtocolMessage.RegisterEvent(TEventType.LoadedSource, TDynamicLoadedSourceEvent);
  TProtocolMessage.RegisterEvent(TEventType.Memory, TMemoryEvent);
  TProtocolMessage.RegisterEvent(TEventType.Module, TModuleEvent);
  TProtocolMessage.RegisterEvent(TEventType.Output, TDynamicOutputEvent);
  TProtocolMessage.RegisterEvent(TEventType.Process, TProcessEvent);
  TProtocolMessage.RegisterEvent(TEventType.ProgressEnd, TProgressEndEvent);
  TProtocolMessage.RegisterEvent(TEventType.ProgressStart, TProgressStartEvent);
  TProtocolMessage.RegisterEvent(TEventType.ProgressUpdate, TProgressUpdateEvent);
  TProtocolMessage.RegisterEvent(TEventType.Stopped, TStoppedEvent);
  TProtocolMessage.RegisterEvent(TEventType.Terminated, TTerminatedEvent);
  TProtocolMessage.RegisterEvent(TEventType.Thread, TThreadEvent);
end;

class procedure TEventsRegistration.UnregisterAll;
begin
  TProtocolMessage.UnregisterEvent(TEventType(-1));
  TProtocolMessage.UnregisterEvent(TEventType.Breakpoint);
  TProtocolMessage.UnregisterEvent(TEventType.Capabilities);
  TProtocolMessage.UnregisterEvent(TEventType.Continued);
  TProtocolMessage.UnregisterEvent(TEventType.Exited);
  TProtocolMessage.UnregisterEvent(TEventType.Initialized);
  TProtocolMessage.UnregisterEvent(TEventType.Invalidated);
  TProtocolMessage.UnregisterEvent(TEventType.LoadedSource);
  TProtocolMessage.UnregisterEvent(TEventType.Memory);
  TProtocolMessage.UnregisterEvent(TEventType.Module);
  TProtocolMessage.UnregisterEvent(TEventType.Output);
  TProtocolMessage.UnregisterEvent(TEventType.Process);
  TProtocolMessage.UnregisterEvent(TEventType.ProgressEnd);
  TProtocolMessage.UnregisterEvent(TEventType.ProgressStart);
  TProtocolMessage.UnregisterEvent(TEventType.ProgressUpdate);
  TProtocolMessage.UnregisterEvent(TEventType.Stopped);
  TProtocolMessage.UnregisterEvent(TEventType.Terminated);
  TProtocolMessage.UnregisterEvent(TEventType.Thread);
end;

end.

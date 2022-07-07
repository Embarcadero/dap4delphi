unit BaseProtocol.Events;

interface

uses
  System.Rtti,
  Rest.Json.Types,
  BaseProtocol,
  BaseProtocol.Types;

type
  [EventType(TEventType.Initialized)]
  TInitializedEvent<T> = class(TEvent<T>);

  TStoppedEventBody = class(TManaged)
  private
    [JSONName('reason')]
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

  TContinuedEventBody = class(TManaged)
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

  TExitedEventBody = class(TManaged)
  private
    [JSONName('exitCode')]
    FExitCode: integer;
  public
    property ExitCode: integer read FExitCode write FExitCode;
  end;

  [EventType(TEventType.Exited)]
  TExitedEvent = class(TEvent<TExitedEventBody>);

  TTerminatedEventBody<TRestart> = class(TManaged)
  private
    [JSONName('restart')]
    FRestart: TRestart;
  public
    property Restart: TRestart read FRestart write FRestart;
  end;

  [EventType(TEventType.Terminated)]
  TTerminatedEvent = class(TEvent<TTerminatedEventBody<TValue>>);

  TThreadEventBody = class(TManaged)
  private
    [JSONName('reason')]
    FReason: TThreadEventReason;
    [JSONName('threadId')]
    FThreadId: integer;
  public
    property Reason: TThreadEventReason read FReason write FReason;
    property ThreadId: integer read FThreadId write FThreadId;
  end;

  [EventType(TEventType.Thread)]
  TThreadEvent = class(TEvent<TThreadEventBody>)end;

  TOutputEventBody<TData> = class(TManaged)
  private
    [JSONName('category')]
    FCategory: TOutputEventCategory;
    [JSONName('output')]
    FOutput: string;
    [JSONName('group')]
    FGroup: TOutputEventGroup;
    [JSONName('variablesReference')]
    FVariablesReference: integer;
    [Managed()]
    [JSONName('source')]
    FSource: TSource<TValue>;
    [JSONName('line')]
    FLine: integer;
    [JSONName('column')]
    FColumn: integer;
    [JSONName('data')]
    FData: TData;
  public
    property Category: TOutputEventCategory read FCategory write FCategory;
    property Output: string read FOutput write FOutput;
    property Group: TOutputEventGroup read FGroup write FGroup;
    property VariablesReference: integer read FVariablesReference write FVariablesReference;
    property Source: TSource<TValue> read FSource;
    property Line: integer read FLine write FLine;
    property Column: integer read FColumn write FColumn;
    property Data: TData read FData write FData;
  end;

  [EventType(TEventType.Output)]
  TOutputEvent = class(TEvent<TOutputEventBody<TValue>>);

  TBreakpointEventBody = class(TManaged)
  private
    [JSONName('reason')]
    FReason: TBreakpointEventReason;
    [JSONName('breakpoint')]
    FBreakpoint: TBreakpoint;
  public
    property Reason: TBreakpointEventReason read FReason write FReason;
    property Breakpoint: TBreakpoint read FBreakpoint;
  end;

  [EventType(TEventType.Breakpoint)]
  TBreakpointEvent = class(TEvent<TBreakpointEventBody>);

  TModuleEventBody = class(TManaged)
  private
    [JSONName('reason')]
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

  TLoadedSourceEventBody = class(TManaged)
  private
    [JSONName('reason')]
    FReason: TLoadedSourceEventReason;
    [Managed()]
    [JSONName('source')]
    FSource: TSource<TValue>;
  public
    property Reason: TLoadedSourceEventReason read FReason write FReason;
    property Source: TSource<TValue> read FSource;
  end;

  [EventType(TEventType.LoadedSource)]
  TLoadedSourceEvent = class(TEvent<TLoadedSourceEventBody>);

  TProcessEventBody = class(TManaged)
  private
    [JSONName('name')]
    FName: string;
    [JSONName('systemProcessId')]
    FSystemprocessId: integer;
    [JSONName('isLocalProcess')]
    FIsLocalProcess: boolean;
    [JSONName('startedMethod')]
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

  TCapabilitiesEventBody = class(TManaged)
  private
    [JSONName('capabilities'), Managed()]
    FCapabilities: TCapabilities;
  public
    property Capabilities: TCapabilities read FCapabilities write FCapabilities;
  end;

  [EventType(TEventType.Capabilities)]
  TCapabilitiesEvent = class(TEvent<TCapabilitiesEventBody>);

  TProgressStartEventBody = class(TManaged)
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

  TProgressUpdateEventBody = class(TManaged)
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

  TProgressEndEventBody = class(TManaged)
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

  TInvalidatedEventBody = class(TManaged)
  private
    [JSONName('areas')]
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

  TMemoryEventBody = class(TManaged)
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

implementation

end.

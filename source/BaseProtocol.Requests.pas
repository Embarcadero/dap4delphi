unit BaseProtocol.Requests;

interface

uses
  System.Rtti,
  Rest.Json.Types,
  BaseProtocol,
  BaseProtocol.Types;

type
  TCancelArguments = class(TManaged)
  private
    [JSONName('requestId')]
    FRequestId: integer;
    [JSONName('progressId')]
    FProgressId: string;
  public
    property RequestId: integer read FRequestId;
    property ProgressId: string read FProgressId;
  end;

  [RequestCommand(TRequestCommand.Cancel)]
  TCancelRequest = class(TRequest<TCancelArguments>);

  TCancelResponse = class(TResponse<TObject>);
  
  TInitializeRequestArguments = class(TManaged)
  private
    [JSONName('clientId')]
    FClientId: string;
    [JSONName('clientName')]
    FClientName: string;
    [JSONName('adapterId')]
    FAdapterId: string;
    [JSONName('locale')]
    FLocale: string;
    [JSONName('linesStartAt1')]
    FLinesStartAt1: boolean;
    [JSONName('columnsStartAt1')]
    FColumnsStartAt1: boolean;
    [JSONName('pathFormat')]
    FPathFormat: TPathFormat;
    [JSONName('supportsVariableType')]
    FSupportsVariableType: boolean;
    [JSONName('supportsVariablePaging')]
    FSupportsVariablePaging: boolean;
    [JSONName('supportsRunInTerminalRequest')]
    FSupportsRunInTerminalRequest: boolean;
    [JSONName('supportsMemoryReferences')]
    FSupportsMemoryReferences: boolean;
    [JSONName('supportsProgressReporting')]
    FSupportsProgressReporting: boolean;
    [JSONName('supportsInvalidatedEvent')]
    FSupportsInvalidatedEvent: boolean;
    [JSONName('supportsMemoryEvent')]
    FSupportsMemoryEvent: boolean;
  public
    property ClientId: string read FClientId write FClientId;
    property ClientName: string read FClientName write FClientName;
    property AdapterId: string read FAdapterId write FAdapterId;
    property Locale: string read FLocale write FLocale;
    property LinesStartAt1: boolean read FLinesStartAt1 write FLinesStartAt1;
    property ColumnsStartAt1: boolean read FColumnsStartAt1 write FColumnsStartAt1;
    property PathFormat: TPathFormat read FPathFormat write FPathFormat;
    property SupportsVariableType: boolean read FSupportsVariableType write FSupportsVariableType;
    property SupportsVariablePaging: boolean read FSupportsVariablePaging write FSupportsVariablePaging;
    property SupportsRunInTerminalRequest: boolean read FSupportsRunInTerminalRequest write FSupportsRunInTerminalRequest;
    property SupportsMemoryReferences: boolean read FSupportsMemoryReferences write FSupportsMemoryReferences;
    property SupportsProgressReporting: boolean read FSupportsProgressReporting write FSupportsProgressReporting;
    property SupportsInvalidatedEvent: boolean read FSupportsInvalidatedEvent write FSupportsInvalidatedEvent;
    property SupportsMemoryEvent: boolean read FSupportsMemoryEvent write FSupportsMemoryEvent;
  end;
  
  [RequestCommand(TRequestCommand.Initialize)]
  TInitializeRequest = class(TRequest<TInitializeRequestArguments>);

  TInitializeResponse = class(TResponse<TCapabilities>);

  [RequestCommand(TRequestCommand.ConfigurationDone)]
  TConfigurationDoneRequest = class(TRequest<TEmptyArguments>);

  TConfigurationDoneResponse = class(TResponse<TEmptyBody>);

  { TODO : Create a converter/reverter }
  TLaunchOrAttachRequestArguments = class(TManaged);

  TRestart = TValue;

  TLaunchRequestArguments = class(TLaunchOrAttachRequestArguments)
  private
    [JSONName('noDebug')]
    FNoDebug: boolean;
    [JSONName('__restart'), Managed()]
    FRestart: TRestart;
  public
    property NoDebug: boolean read FNoDebug write FNoDebug;
    property __Restart: TRestart read FRestart write FRestart;
  end;
  
  [RequestCommand(TRequestCommand.Launch)]
  TLaunchRequest = class(TRequest<TLaunchRequestArguments>);

  TLaunchResponse = class(TResponse<TEmptyBody>);

  TAttachRequestArguments = class(TLaunchOrAttachRequestArguments)
  private
    [JSONName('__restart'), Managed()]
    FRestart: TRestart;
  public
    property __Restart: TRestart read FRestart write FRestart;
  end;

  [RequestCommand(TRequestCommand.Attach)]
  TAttachRequest = class(TRequest<TAttachRequestArguments>);

  TAttachResponse = class(TResponse<TEmptyBody>);

  { TODO : Attention here }
  TRestartArguments = class(TManaged)
  private
    [JSONName('arguments')]
    FArguments: TLaunchOrAttachRequestArguments;
  public
    procedure BeforeDestruction(); override;

    property Arguments: TLaunchOrAttachRequestArguments read FArguments write FArguments;
  end;

  [RequestCommand(TRequestCommand.Restart)]
  TRestartRequest = class(TRequest<TRestartArguments>);

  TRestartResponse = class(TResponse<TEmptyBody>);

  TDisconnectArguments = class(TManaged)
  private
    [JSONName('restart')]
    FRestart: boolean;
    [JSONName('terminateDebuggee')]
    FTerminateDebuggee: boolean;
    [JSONName('suspendDebuggee')]
    FSuspendDebuggee: boolean;
  public
    property Restart: boolean read FRestart write FRestart;
    property TerminateDebuggee: boolean read FTerminateDebuggee write FTerminateDebuggee;
    property SuspendDebuggee: boolean read FSuspendDebuggee write FSuspendDebuggee;
  end;

  [RequestCommand(TRequestCommand.Disconnect)]
  TDisconnectRequest = class(TRequest<TDisconnectArguments>);

  TDisconnectResponse = class(TResponse<TEmptyBody>);

  TTerminateArguments = class(TManaged)
  private
    [JSONName('restart')]
    FRestart: boolean;
  public
    property Restart: boolean read FRestart write FRestart;
  end;

  [RequestCommand(TRequestCommand.Terminate)]
  TTerminateRequest = class(TRequest<TTerminateArguments>);

  TTerminateResponse = class(TResponse<TEmptyBody>);

  TBreakpointLocationsArguments = class(TManaged)
  private
    [JSONName('source'), Managed()]
    FSource: TSource<TValue>;
    [JSONName('line')]
    FLine: integer;
    [JSONName('column')]
    FColumn: integer;
    [JSONName('endLine')]
    FEndLine: integer;
    [JSONName('endColumn')]
    FEndColumn: integer;
  public
    property Source: TSource<TValue> read FSource write FSource;
    property Line: integer read FLine write FLine;
    property Column: integer read FColumn write FColumn;
    property EndLine: integer read FEndLine write FEndLine;
    property EndColumn: integer read FEndColumn write FEndColumn;
  end;

  [RequestCommand(TRequestCommand.BreakpointLocations)]
  TBreakpointLocationsRequest = class(TRequest<TBreakpointLocationsArguments>);

  TBreakpointLocationsResponseBody = class(TManaged)
  private
    [JSONName('breakpoints'), Managed()]
    FBreakpoints: TBreakpointLocations;
  public
    property Breakpoints: TBreakpointLocations read FBreakpoints;
  end;

  TBreakpointLocationsResponse = class(TResponse<TBreakpointLocationsResponseBody>);

  TSetBreakpointsArguments = class(TManaged)
  private
    [JSONName('source'), Managed()]
    FSource: TSource<TValue>;
    [JSONName('breakpoints'), Managed()]
    FBreakpoints: TSourceBreakpoints;
    [JSONName('lines')]
    FLines: TArray<integer>;
    [JSONName('sourceModified')]
    FSourceModified: boolean;
  public
    property Source: TSource<TValue> read FSource write FSource;
    property Breakpoints: TSourceBreakpoints read FBreakpoints write FBreakpoints;
    property Lines: TArray<integer> read FLines write FLines;
    property SourceModified: boolean read FSourceModified write FSourceModified;
  end;

  [RequestCommand(TRequestCommand.SetBreakpoints)]
  TSetBreakpointsRequest = class(TRequest<TSetBreakpointsArguments>);

  TSetBreakpointsResponseBody = class(TManaged)
  private
    [JSONName('breakpoints'), Managed()]
    FBreakpoints: TBreakpoints;
  public
    property Breakpoints: TBreakpoints read FBreakpoints;
  end;

  TSetBreakpointsResponse = class(TResponse<TSetBreakpointsResponseBody>);

  TSetFunctionBreakpointsArguments = class(TManaged)
  private
    [JSONName('breakpoints'), Managed()]
    FBreakpoints: TFunctionBreakpoints;
  public
    property Breakpoints: TFunctionBreakpoints read FBreakpoints;
  end;

  [RequestCommand(TRequestCommand.SetFunctionBreakpoints)]
  TSetFunctionBreakpointsRequest = class(TRequest<TSetFunctionBreakpointsArguments>);

  TSetFunctionBreakpointsResponseBody = class(TManaged)
  private
    [JSONName('breakpoints'), Managed()]
    FBreakpoints: TBreakpoints;
  public
    property Breakpoints: TBreakpoints read FBreakpoints;
  end;

  TSetFunctionBreakpointsResponse = class(TResponse<TSetFunctionBreakpointsResponseBody>);

  TSetExceptionBreakpointsArguments = class(TManaged)
  private
    [JSONName('filters')]
    FFilters: TArray<string>;
    [JSONName('filterOptions'), Managed()]
    FFilterOptions: TExceptionFilterOptions;
    [JSONName('exceptionOptions'), Managed()]
    FExceptionOptions: TExceptionOptions;
  public
    property Filters: TArray<string> read FFilters write FFilters;
    property FilterOptions: TExceptionFilterOptions read FFilterOptions write FFilterOptions;
    property ExceptionOptions: TExceptionOptions read FExceptionOptions write FExceptionOptions;
  end;

  [RequestCommand(TRequestCommand.SetExceptionBreakpoints)]
  TSetExceptionBreakpointsRequest = class(TRequest<TSetExceptionBreakpointsArguments>);

  TSetExceptionBreakpointsResponseBody = class(TManaged)
  private
    [JSONName('breakpoints'), Managed()]
    FBreakpoints: TBreakpoints;
  public
    property Breakpoints: TBreakpoints read FBreakpoints;
  end;

  TSetExceptionBreakpointsResponse = class(TResponse<TSetExceptionBreakpointsResponseBody>);

  TDatabreakpointInfoArguments = class(TManaged)
  private
    [JSONName('variablesReference')]
    FVariablesReference: integer;
    [JSONName('name')]
    FName: string;
  public
    property VariablesReference: integer read FVariablesReference write FVariablesReference;
    property Name: string read FName write FName;
  end;

  [RequestCommand(TRequestCommand.DataBreakpointInfo)]
  TDatabreakpointInfoRequest = class(TRequest<TDatabreakpointInfoArguments>);

  TDatabreakpointInfoResponseBody = class(TManaged)
  private
    [JSONName('dataId')]
    FDataId: string;
    [JSONName('description')]
    FDescription: string;
    [JSONName('accessTypes')]
    FAccessTypes: TDataBreakpointAccessTypes;
    [JSONName('canPersist')]
    FCanPersist: boolean;
  public
    property DataId: string read FDataId write FDataId;
    property Description: string read FDescription write FDescription;
    property AccessTypes: TDataBreakpointAccessTypes read FAccessTypes write FAccessTypes;
    property CanPersist: boolean read FCanPersist write FCanPersist;
  end;

  TDatabreakpointInfoResponse = class(TResponse<TDatabreakpointInfoResponseBody>);

  TSetDataBreakpointArguments = class(TManaged)
  private
    [JSONName('breakpoints'), Managed()]
    FBreakpoints: TDataBreakpoints;
  public
    property Breakpoints: TDataBreakpoints read FBreakpoints write FBreakpoints;
  end;

  [RequestCommand(TRequestCommand.SetDataBreakpoints)]
  TSetDataBreakpointRequest = class(TRequest<TSetDataBreakpointArguments>);

  TSetDataBreakpointResponseBody = class(TManaged)
  private
    [JSONName('breakpoints'), Managed()]
    FBreakpoints: TBreakpoints;
  public
    property Breakpoints: TBreakpoints read FBreakpoints write FBreakpoints;
  end;

  TSetDataBreakpointResponse = class(TResponse<TSetDataBreakpointResponseBody>);

  TSetInstructionBreakpointArguments = class(TManaged)
  private
    [JSONName('breakpoints'), Managed()]
    FBreakpoints: TInstructionBreakpoints;
  public
    property Breakpoints: TInstructionBreakpoints read FBreakpoints write FBreakpoints;
  end;

  [RequestCommand(TRequestCommand.SetInstructionBreakpoints)]
  TSetInstructionBreakpointRequest = class(TRequest<TSetInstructionBreakpointArguments>);

  TSetInstructionBreakpointResponseBody = class(TManaged)
  private
    [JSONName('breakpoints'), Managed()]
    FBreakpoints: TBreakpoints;
  public
    property Breakpoints: TBreakpoints read FBreakpoints write FBreakpoints;
  end;

  TSetInstructionBreakpointResponse = class(TResponse<TSetInstructionBreakpointResponseBody>);

  TContinueArguments = class(TManaged)
  private
    [JSONName('threadId')]
    FThreadId: integer;
    [JSONName('singleThread')]
    FSingleThread: boolean;
  public
    property ThreadId: integer read FThreadId write FThreadId;
    property SingleThread: boolean read FSingleThread write FSingleThread;
  end;

  [RequestCommand(TRequestCommand.Continue)]
  TContinueRequest = class(TRequest<TContinueArguments>);

  TContinueResponseBody = class(TManaged)
  private
    [JSONName('allThreadsContinued')]
    FAllThreadsContinued: boolean;
  public
    property AllThreadsContinued: boolean read FAllThreadsContinued write FAllThreadsContinued;
  end;

  TContinueResponse = class(TResponse<TContinueResponseBody>);

  TNextArguments = class(TManaged)
  private
    [JSONName('threadId')]
    FThreadId: integer;
    [JSONName('singleThread')]
    FSingleThread: boolean;
    [JSONName('granularity')]
    FGranularity: TSteppingGranularity;
  public
    property ThreadId: integer read FThreadId write FThreadId;
    property SingleThread: boolean read FSingleThread write FSingleThread;
    property Granularity: TSteppingGranularity read FGranularity write FGranularity;
  end;

  [RequestCommand(TRequestCommand.Next)]
  TNextRequest = class(TRequest<TNextArguments>);

  TNextResponse = class(TResponse<TEmptyBody>);

  TStepInArguments = class(TManaged)
  private
    [JSONName('threadId')]
    FThreadId: integer;
    [JSONName('singleThread')]
    FSingleThread: boolean;
    [JSONName('targetId')]
    FTargetId: integer;
    [JSONName('granularity')]
    FGranularity: TSteppingGranularity;
  public
    property ThreadId: integer read FThreadId write FThreadId;
    property SingleThread: boolean read FSingleThread write FSingleThread;
    property TargetId: integer read FTargetId write FTargetId;
    property Granularity: TSteppingGranularity read FGranularity write FGranularity;
  end;

  [RequestCommand(TRequestCommand.StepIn)]
  TStepInRequest = class(TRequest<TStepInArguments>);

  TStepInResponse = class(TResponse<TEmptyBody>);

  TStepOutArguments = class(TManaged)
  private
    [JSONName('threadId')]
    FThreadId: integer;
    [JSONName('singleThread')]
    FSingleThread: boolean;
    [JSONName('granularity')]
    FGranularity: TSteppingGranularity;
  public
    property ThreadId: integer read FThreadId write FThreadId;
    property SingleThread: boolean read FSingleThread write FSingleThread;
    property Granularity: TSteppingGranularity read FGranularity write FGranularity;
  end;

  [RequestCommand(TRequestCommand.StepOut)]
  TStepOutRequest = class(TRequest<TStepOutArguments>);

  TStepOutResponse = class(TResponse<TEmptyBody>);

  TStepBackArguments = class(TManaged)
  private
    [JSONName('threadId')]
    FThreadId: integer;
    [JSONName('singleThread')]
    FSingleThread: boolean;
    [JSONName('granularity')]
    FGranularity: TSteppingGranularity;
  public
    property ThreadId: integer read FThreadId write FThreadId;
    property SingleThread: boolean read FSingleThread write FSingleThread;
    property Granularity: TSteppingGranularity read FGranularity write FGranularity;
  end;

  [RequestCommand(TRequestCommand.Continue)]
  TStepBackRequest = class(TRequest<TStepBackArguments>);

  TStepBackResponse = class(TResponse<TEmptyBody>);

  TReverseContinueArguments = class(TManaged)
  private
    [JSONName('threadId')]
    FThreadId: integer;
    [JSONName('singleThread')]
    FSingleThread: boolean;
  public
    property ThreadId: integer read FThreadId write FThreadId;
    property SingleThread: boolean read FSingleThread write FSingleThread;
  end;

  [RequestCommand(TRequestCommand.ReverseContinue)]
  TReverseContinueRequest = class(TRequest<TReverseContinueArguments>);

  TReverseContinueResponse = class(TResponse<TEmptyBody>);

  TRestartFrameArguments = class(TManaged)
  private
    [JSONName('frameId')]
    FFrameId: integer;
  public
    property FrameId: integer read FFrameId write FFrameId;
  end;

  [RequestCommand(TRequestCommand.RestartFrame)]
  TRestartFrameRequest = class(TRequest<TRestartFrameArguments>);  

  TRestartFrameResponse = class(TResponse<TEmptyBody>);

  TGotoArguments = class(TManaged)
  private
    [JSONName('threadId')]
    FThreadId: integer;
    [JSONName('targetId')]
    FTargetId: integer;
  public
    property ThreadId: integer read FThreadId write FThreadId;
    property TargetId: integer read FTargetId write FTargetId;
  end;

  [RequestCommand(TRequestCommand.Goto)]
  TGotoRequest = class(TRequest<TGotoArguments>);

  TGotoResponse = class(TResponse<TEmptyBody>);

  TPauseRequestArguments = class(TManaged)
  private
    [JSONName('threadId')]
    FThreadId: integer;
  public
    property ThreadId: integer read FThreadId write FThreadId;
  end;

  [RequestCommand(TRequestCommand.Pause)]
  TPauseRequestRequest = class(TRequest<TPauseRequestArguments>);

  TPauseRequestResponse = class(TResponse<TEmptyBody>);

  TStackTraceArguments = class(TManaged)
  private
    [JSONName('threadId')]
    FThreadId: integer;
    [JSONName('startFrame')]
    FStartFrame: integer;
    [JSONName('levels')]
    FLevels: integer;
    [JSONName('stackFrameFormat')]
    FFormat: TStackFrameFormat;
  public
    property ThreadId: integer read FThreadId write FThreadId;
    property StartFrame: integer read FStartFrame write FStartFrame;
    property Levels: integer read FLevels write FLevels;
    property Format: TStackFrameFormat read FFormat write FFormat;
  end;

  [RequestCommand(TRequestCommand.StackTrace)]
  TStackTraceRequest = class(TRequest<TStackTraceArguments>);

  TStackTraceResponseBody = class(TManaged)
  private
    [JSONName('stackFrames'), Managed()]
    FStackFrames: TStackFrames;
    [JSONName('totalFrames')]
    FTotalFrames: integer;
  public
    property StackFrames: TStackFrames read FStackFrames write FStackFrames;
    property TotalFrames: integer read FTotalFrames write FTotalFrames;
  end;

  TStackTraceResponse = class(TResponse<TStackTraceResponseBody>);

  TScopeArguments = class(TManaged)
  private
    [JSONName('frameId')]
    FFrameId: integer;
  public
    property FrameId: integer read FFrameId write FFrameId;
  end;

  [RequestCommand(TRequestCommand.Scopes)]
  TScopeRequest = class(TRequest<TScopeArguments>);

  TScopeResponseBody = class(TManaged)
  private
    [JSONName('scopes'), Managed()]
    FScopes: TScopes;
  public
    property Scopes: TScopes read FScopes write FScopes;
  end;

  TScopeResponse = class(TResponse<TScopeResponseBody>);

  TVariablesArguments = class(TManaged)
  private
    [JSONName('variablesReference')]
    FVariablesReference: integer;
    [JSONName('filter')]
    FFilter: TVariablesFilter;
    [JSONName('start')]
    FStart: integer;
    [JSONName('count')]
    FCount: integer;
    [JSONName('format'), Managed()]
    FFormat: TValueFormat;
  public
    property VariablesReference: integer read FVariablesReference write FVariablesReference;
    property Filter: TVariablesFilter read FFilter write FFilter;
    property Start: integer read FStart write FStart;
    property Count: integer read FCount write FCount;
    property Format: TValueFormat read FFormat write FFormat;
  end;

  [RequestCommand(TRequestCommand.Variables)]
  TVariablesRequest = class(TRequest<TVariablesArguments>);

  TVariablesResponseBody = class(TManaged)
  private
    [JSONName('variables'), Managed()]
    FVariables: TVariables;
  public
    property Variables: TVariables read FVariables write FVariables;
  end;

  TVariablesResponse = class(TResponse<TVariablesResponseBody>);

  TSetVariableArguments = class(TManaged)
  private
    [JSONName('variablesReference')]
    FVariablesReference: integer;
    [JSONName('name')]
    FName: string;
    [JSONName('value')]
    FValue: string;
    [JSONName('format'), Managed()]
    FFormat: TValueFormat;
  public
    property VariablesReference: integer read FVariablesReference write FVariablesReference;
    property Name: string read FName write FName;
    property Value: string read FValue write FValue;
    property Format: TValueFormat read FFormat write FFormat;
  end;

  [RequestCommand(TRequestCommand.SetVariable)]
  TSetVariableRequest = class(TRequest<TSetVariableArguments>);

  TSetVariableResponseBody = class(TManaged)
  private
    [JSONName('value')]
    FValue: string;
    [JSONName('type')]
    FType: string;
    [JSONName('variablesReference')]
    FVariablesReference: integer;
    [JSONName('namedVariables')]
    FNamedVariables: integer;
    [JSONName('indexedVariables')]
    FIndexedVariables: integer;
  public
    property Value: string read FValue write FValue;
    property &Type: string read FType write FType;
    property VariablesReference: integer read FVariablesReference write FVariablesReference;
    property NamedVariables: integer read FNamedVariables write FNamedVariables;
    property IndexedVariables: integer read FIndexedVariables write FIndexedVariables;
  end;

  TSetVariableResponse = class(TResponse<TSetVariableResponseBody>);

  TSourceArguments = class(TManaged)
  private
    [JSONName('source'), Managed()]
    FSource: TSource<TValue>;
    [JSONName('sourceReference')]
    FSourceReference: integer;
  public
    property Source: TSource<TValue> read FSource write FSource;
    property SourceReference: integer read FSourceReference write FSourceReference;
  end;

  [RequestCommand(TRequestCommand.Source)]
  TSourceRequest = class(TRequest<TSourceArguments>);

  TSourceResponseBody = class(TManaged)
  private
    [JSONName('content')]
    FContent: string;
    [JSONName('mimeType')]
    FMimeType: string;
  public
    property Content: string read FContent write FContent;
    property MimeType: string read FMimeType write FMimeType;
  end;

  TSourceResponse = class(TResponse<TSourceResponseBody>);

  [RequestCommand(TRequestCommand.Threads)]
  TThreadsRequest = class(TRequest<TEmptyArguments>);

  TThreadsResponseBody = class(TManaged)
  private
    [JSONName('threads'), Managed()]
    FThreads: TThreads;
  public
    property Threads: TThreads read FThreads write FThreads;
  end;

  TThreadsResponse = class(TResponse<TThreadsResponseBody>);

  TTerminateThreadsArguments = class(TManaged)
  private
    [JSONName('threadIds')]
    FThreadIds: TArray<integer>;
  public
    property ThreadIds: TArray<integer> read FThreadIds write FThreadIds;
  end;

  [RequestCommand(TRequestCommand.TerminateThreads)]
  TTerminateThreadsRequest = class(TRequest<TTerminateThreadsArguments>);

  TTerminateThreadsResponse = class(TResponse<TEmptyBody>);

  TModulesArguments = class(TManaged)
  private
    [JSONName('startModule')]
    FStartModule: integer;
    [JSONName('moduleCount')]
    FModuleCount: integer;
  public
    property StartModule: integer read FStartModule write FStartModule;
    property ModuleCount: integer read FModuleCount write FModuleCount;
  end;

  [RequestCommand(TRequestCommand.Modules)]
  TModulesRequest = class(TRequest<TModulesArguments>);

  TModulesResponseBody = class(TManaged)
  private
    [JSONName('modules'), Managed()]
    FModules: TModules;
    [JSONName('totalModules')]
    FTotalModules: integer;
  public
    property Modules: TModules read FModules write FModules;
    property TotalModules: integer read FTotalModules write FTotalModules;
  end;

  TModulesResponse = class(TResponse<TModulesResponseBody>);

  [RequestCommand(TRequestCommand.LoadedSources)]
  TLoadedSourcesRequest = class(TRequest<TEmptyArguments>);

  TLoadedSourcesResponseBody = class(TManaged)
  private
    [JSONName('sources'), Managed()]
    FSources: TSources;
  public
    property Sources: TSources read FSources write FSources;
  end;

  TLoadedSourcesResponse = class(TResponse<TLoadedSourcesResponseBody>);

  TEvaluteArguments = class(TManaged)
  private
    [JSONName('expression')]
    FExpression: string;
    [JSONName('frameId')]
    FFrameId: string;
    [JSONName('context')]
    FContext: TEvaluteContext;
    [JSONName('format'), Managed()]
    FFormat: TValueFormat;
  public
    property Expression: string read FExpression write FExpression;
    property FrameId: string read FFrameId write FFrameId;
    property Context: TEvaluteContext read FContext write FContext;
    property Format: TValueFormat read FFormat write FFormat;
  end;

  [RequestCommand(TRequestCommand.Evaluate)]
  TEvaluteRequest = class(TRequest<TEvaluteArguments>);

  TEvaluteResponseBody = class(TManaged)
  private
    [JSONName('result')]
    FResult: string;
    [JSONName('type')]
    FType: string;
    [JSONName('presentationHint'), Managed()]
    FPresentationHint: TVariablePresentationHint;
    [JSONName('variablesReference')]
    FVariablesReference: integer;
    [JSONName('namedVariables')]
    FNamedVariables: integer;
    [JSONName('indexedVariables')]
    FIndexedVariables: integer;
    [JSONName('memoryReference')]
    FMemoryReference: integer;
  public
    property Result: string read FResult write FResult;
    property &Type: string read FType write FType;
    property PresentationHint: TVariablePresentationHint read FPresentationHint write FPresentationHint;
    property VariablesReference: integer read FVariablesReference write FVariablesReference;
    property NamedVariables: integer read FNamedVariables write FNamedVariables;
    property IndexedVariables: integer read FIndexedVariables write FIndexedVariables;
    property MemoryReference: integer read FMemoryReference write FMemoryReference;
  end;

  TEvaluteResponse = class(TResponse<TEvaluteResponseBody>);

  TSetExpressionArguments = class(TManaged)
  private
    [JSONName('expression')]
    FExpression: string;
    [JSONName('value')]
    FValue: string;
    [JSONName('frameId')]
    FFrameId: integer;
    [JSONName('format'), Managed()]
    FFormat: TValueFormat;
  public
    property Expression: string read FExpression write FExpression;
    property Value: string read FValue write FValue;
    property FrameId: integer read FFrameId write FFrameId;
    property Format: TValueFormat read FFormat write FFormat;
  end;

  [RequestCommand(TRequestCommand.SetExpression)]
  TSetExpressionRequest = class(TRequest<TSetExpressionArguments>);

  TSetExpressionResponseBody = class(TManaged)
  private
    [JSONName('value')]
    FValue: string;
    [JSONName('presentationHint'), Managed()]
    FPresentationHint: TVariablePresentationHint;
    [JSONName('variablesReference')]
    FVariablesReference: integer;
    [JSONName('namedVariables')]
    FNamedVariables: integer;
    [JSONName('indexedVariables')]
    FIndexedVariables: integer;
  public
    property Value: string read FValue write FValue;
    property PresentationHint: TVariablePresentationHint read FPresentationHint write FPresentationHint;
    property VariablesReference: integer read FVariablesReference write FVariablesReference;
    property NamedVariables: integer read FNamedVariables write FNamedVariables;
    property IndexedVariables: integer read FIndexedVariables write FIndexedVariables;
  end;

  TSetExpressionResponse = class(TResponse<TSetExpressionResponseBody>);

  TStepInTargetsArguments = class(TManaged)
  private
    [JSONName('frameId')]
    FFrameId: integer;
  public
    property FrameId: integer read FFrameId write FFrameId;
  end;

  [RequestCommand(TRequestCommand.StepInTargets)]
  TStepInTargetsRequest = class(TRequest<TStepInTargetsArguments>);

  TStepInTargetsResponseBody = class(TManaged)
  private
    [JSONName('targets'), Managed()]
    FTargets: TStepInTargets;
  public
    property Targets: TStepInTargets read FTargets write FTargets;
  end;

  TStepInTargetsResponse = class(TResponse<TStepInTargetsResponseBody>);

  TGotoTargetsArguments = class(TManaged)
  private
    [JSONName('source'), Managed()]
    FSource: TSource<TValue>;
    [JSONName('line')]
    FLine: integer;
    [JSONName('column')]
    FColumn: integer;
  public
    property Source: TSource<TValue> read FSource write FSource;
    property Line: integer read FLine write FLine;
    property Column: integer read FColumn write FColumn;
  end;

  [RequestCommand(TRequestCommand.GotoTargets)]
  TGotoTargetsRequest = class(TRequest<TGotoTargetsArguments>);

  TGotoTargetsResponseBody = class(TManaged)
  private
    [JSONName('targets'), Managed()]
    FTargets: TTargets;
  public
    property Targets: TTargets read FTargets write FTargets;
  end;

  TGotoTargetsResponse = class(TResponse<TGotoTargetsResponseBody>);

  TCompletitionsArguments = class(TManaged)
  private
    [JSONName('frameId')]
    FFrameId: integer;
    [JSONName('text')]
    FText: string;
    [JSONName('column')]
    FColumn: integer;
    [JSONName('line')]
    FLine: integer;
  public
    property FrameId: integer read FFrameId write FFrameId;
    property Text: string read FText write FText;
    property Column: integer read FColumn write FColumn;
    property Line: integer read FLine write FLine;
  end;

  [RequestCommand(TRequestCommand.Completions)]
  TCompletitionsRequest = class(TRequest<TCompletitionsArguments>);

  TCompletitionsResponseBody = class(TManaged)
  private
    [JSONName('frameId'), Managed()]
    FTargets: TCompletitionItems;
  public
    property Targets: TCompletitionItems read FTargets write FTargets;
  end;

  TCompletitionsResponse = class(TResponse<TCompletitionsResponseBody>);
  
  TExcpetionInfoArguments = class(TManaged)
  private
    [JSONName('threadId')]
    FThreadId: integer;
  public
    property ThreadId: integer read FThreadId write FThreadId;
  end;

  [RequestCommand(TRequestCommand.ExceptionInfo)]
  TExcpetionInfoRequest = class(TRequest<TExcpetionInfoArguments>);

  TExcpetionInfoResponseBody = class(TManaged)
  private
    [JSONName('exceptionId')]
    FExceptionId: string;
    [JSONName('description')]
    FDescription: string;
    [JSONName('breakMode')]
    FBreakMode: TExceptionBreakMode;
    [JSONName('details'), Managed()]
    FDetails: TExceptionDetail;
  public
    property ExceptionId: string read FExceptionId write FExceptionId;
    property Description: string read FDescription write FDescription;
    property BreakMode: TExceptionBreakMode read FBreakMode write FBreakMode;
    property Details: TExceptionDetail read FDetails write FDetails;
  end;

  TExcpetionInfoResponse = class(TResponse<TExcpetionInfoResponseBody>);

  TReadMemoryArguments = class(TManaged)
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

  [RequestCommand(TRequestCommand.ReadMemory)]
  TReadMemoryRequest = class(TRequest<TReadMemoryArguments>);

  TReadMemoryResponseBody = class(TManaged)
  private
    [JSONName('address')]
    FAddress: string;
    [JSONName('unreadableBytes')]
    FUnreadableBytes: integer;
    [JSONName('data')]
    FData: string;
  public
    property Address: string read FAddress write FAddress;
    property UnreadableBytes: integer read FUnreadableBytes write FUnreadableBytes;
    property Data: string read FData write FData;
  end;

  TReadMemoryResponse = class(TResponse<TReadMemoryResponseBody>);

  TWriteMemoryArguments = class(TManaged)
  private
    [JSONName('memoryReference')]
    FMemoryReference: string;
    [JSONName('addoffsetress')]
    FOffset: integer;
    [JSONName('allowPartial')]
    FAllowPartial: boolean;
    [JSONName('data')]
    FData: string;
  public
    property MemoryReference: string read FMemoryReference write FMemoryReference;
    property Offset: integer read FOffset write FOffset;
    property AllowPartial: boolean read FAllowPartial write FAllowPartial;
    property Data: string read FData write FData;
  end;

  [RequestCommand(TRequestCommand.WriteMemory)]
  TWriteMemoryRequest = class(TRequest<TWriteMemoryArguments>);

  TWriteMemoryResponseBody = class(TManaged)
  private
    [JSONName('offset')]
    FOffset: integer;
    [JSONName('bytesWritten')]
    FBytesWritten: integer;
  public
    property Offset: integer read FOffset write FOffset;
    property BytesWritten: integer read FBytesWritten write FBytesWritten;
  end;

  TWriteMemoryResponse = class(TResponse<TWriteMemoryResponseBody>);

  TDisassembleArguments = class(TManaged)
  private
    [JSONName('memoryReference')]
    FMemoryReference: string;
    [JSONName('offset')]
    FOffset: integer;
    [JSONName('instructionOffset')]
    FInstructionOffset: integer;
    [JSONName('instructionCount')]
    FInstructionCount: integer;
    [JSONName('resolveSymbols')]
    FResolveSymbols: boolean;
  public
    property MemoryReference: string read FMemoryReference write FMemoryReference;
    property Offset: integer read FOffset write FOffset;
    property InstructionOffset: integer read FInstructionOffset write FInstructionOffset;
    property InstructionCount: integer read FInstructionCount write FInstructionCount;
    property ResolveSymbols: boolean read FResolveSymbols write FResolveSymbols;
  end;

  [RequestCommand(TRequestCommand.Disassemble)]
  TDisassembleRequest = class(TRequest<TDisassembleArguments>);

  TDisassembleResponseBody = class(TManaged)
  private
    [JSONName('instructions'), Managed()]
    FInstructions: TDisassembleInstructions;
  public
    property Instructions: TDisassembleInstructions read FInstructions write FInstructions;
  end;

  TDisassembleResponse = class(TResponse<TDisassembleResponseBody>);
  
implementation

{ TRestartArguments }

procedure TRestartArguments.BeforeDestruction;
begin
  inherited;
  FArguments.Free();
end;

end.

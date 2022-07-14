unit BaseProtocol.Types;

interface

uses
  System.Generics.Collections, System.Rtti, System.Classes,
  Rest.Json.Types,
  Rest.JsonReflect,
  BaseProtocol.Json;

type
  {$REGION 'ENUNS'}
  {$SCOPEDENUMS ON}
  TMessageType = (
    Request,
    Response,
    Event);

  TRequestCommand = (
    Attach,
    BreakpointLocations,
    Cancel,
    Completions,
    ConfigurationDone,
    Continue,
    DataBreakpointInfo,
    Disassemble,
    Disconnect,
    Evaluate,
    ExceptionInfo,
    &Goto,
    GotoTargets,
    Initialize,
    Launch,
    LoadedSources,
    Modules,
    Next,
    Pause,
    ReadMemory,
    Restart,
    RestartFrame,
    ReverseContinue,
    RunInTerminal,
    Scopes,
    SetBreakpoints,
    SetDataBreakpoints,
    SetExceptionBreakpoints,
    SetExpression,
    SetFunctionBreakpoints,
    SetInstructionBreakpoints,
    SetVariable,
    Source,
    StackTrace,
    StepBack,
    StepIn,
    StepInTargets,
    StepOut,
    Terminate,
    TerminateThreads,
    Threads,
    Variables,
    WriteMemory);

  TEventType = (
    Breakpoint,
    Capabilities,
    Continued,
    Exited,
    Initialized,
    Invalidated,
    LoadedSource,
    Memory,
    Module,
    Output,
    Process,
    ProgressEnd,
    ProgressStart,
    ProgressUpdate,
    Stopped,
    Terminated,
    Thread);

  TResponseMessage = (
    None,
    Cancelled);

  TStoppedEventReason = (
    Step,
    Breakpoint,
    Exception,
    Pause,
    Entry,
    &Goto,
    FunctionBreakpoint,
    DataBreakpoint,
    InstructionBreakpoint);

  TThreadEventReason = (
    Started,
    Exited);

  TOutputEventCategory = (
    None,
    Console,
    Important,
    Stdout,
    Stderr,
    Telemetry);

  TOutputEventGroup = (
    None,
    Start,
    StartCollapsed,
    &End);

  TBreakpointEventReason = (
    Changed,
    New,
    Removed);

  TModuleEventReason = (
    New,
    Changed,
    Removed);

  TLoadedSourceEventReason = (
    New,
    Changed,
    Removed);

  TProcessStartedMethod = (
    None,
    Launch,
    Attach,
    AttatchForSuspendedLaunch);

  TRunInTerminalRequestArgumentsKind = (
    None,
    Integrated,
    &External);

  TPathFormat = (
    None,
    Path,
    Uri);

  TVariablesFilter = (
    None,
    Indexed,
    Named);

  TEvaluteContext = (
    None,
    Variables,
    Watch,
    Repl,
    Hover,
    Clipboard);

  TColumnDescriptorType = (
    None,
    &String,
    Number,
    &Boolean,
    UnixTimestampUTC);

  TSourcePresentationHint = (
    None,
    Normal,
    Emphasize,
    Deemphasize);

  TStackFramePresentationHint = (
    None,
    Normal,
    &Label,
    Subtle);

  TScopePresentationHint = (
    None,
    Arguments,
    Locals,
    Registers);

  TVariableKind = (
    None,
    &Property,
    Method,
    &Class,
    Data,
    Event,
    baseClass,
    innerClass,
    &Interface,
    MostDerivedClass,
    &Virtual,
    DataBreakpoint);

  TVariableAttribute = (
    None,
    &Static,
    Constant,
    ReadOnly,
    RawString,
    HasObjectId,
    CanHaveObjectId,
    HasSideEffects,
    HasDataBreakpoint);
  TVariableAttributes = set of TVariableAttribute;

  TVariableVisibility = (
    None,
    &Public,
    &Private,
    &Protected,
    Internal,
    &Final);

  TDataBreakpointAccessType = (
    Read,
    Write,
    ReadWrite);
  TDataBreakpointAccessTypes = set of TDataBreakpointAccessType;

  TSteppingGranularity = (
    None,
    Statement,
    Line,
    Instruction);

  TCompletitionItemType = (
    None,
    Method,
    &Function,
    &Constructor,
    Field,
    Variable,
    &Class,
    &Interface,
    Module,
    &Property,
    &Unit,
    Value,
    Enum,
    Keyword,
    Snippet,
    Text,
    Color,
    &File,
    Reference,
    CustomColor);

  TChecksumAlgorithm = (
    MD5,
    SHA1,
    SHA256,
    Timestamp);
  TChecksumAlgorithms = set of TChecksumAlgorithm;

  TExceptionBreakMode = (
    Never,
    Always,
    Unhandled,
    UserUnhandled);

  TInvalidatedArea = (
    All,
    Stacks,
    Threads,
    Variables);
  TInvalidatedAreas = set of TInvalidatedArea;
  {$SCOPEDENUMS OFF}
  {$ENDREGION 'ENUNS'}

  {----------|| Attributes ||----------}

  MessageTypeAttribute = class(TCustomAttribute)
  private
    FMessageType: TMessageType;
  public
    constructor Create(const AMessageType: TMessageType);
    property MessageType: TMessageType read FMessageType write FMessageType;
  end;

  RequestCommandAttribute = class(TCustomAttribute)
  private
    FRequestCommand: TRequestCommand;
  public
    constructor Create(const ARequestCommand: TRequestCommand);
    property RequestCommand: TRequestCommand read FRequestCommand write FRequestCommand;
  end;

  EventTypeAttribute = class(TCustomAttribute)
  private
    FEventType: TEventType;
  public
    constructor Create(const AEventType: TEventType);
    property EventType: TEventType read FEventType write FEventType;
  end;

  ManagedAttribute = class(TCustomAttribute);

  {----------|| BaseType ||----------}

  TBaseType = class(TPersistent)
  public
    procedure AfterConstruction(); override;
    procedure BeforeDestruction(); override;
  end;

  {----------|| Empty Data ||----------}

  TEmptyArguments = class
  end;

  TEmptyBody = class
  end;

 {----------|| BaseProtocol Types ||----------}

  TKeyValue = TDictionary<string, string>;

  TMessage = class(TBaseType)
  private type
    TVariables = TKeyValue;
  private
    [JSONName('id')]
    FId: integer;
    [JSONName('format')]
    FFormat: string;
    [JSONName('variables')]
    FVariables: TVariables;
    [JSONName('sendTelemetry')]
    FSendTelemetry: boolean;
    [JSONName('showUser')]
    FShowUser: boolean;
    [JSONName('url')]
    FUrl: string;
    [JSONName('urlLabel')]
    FUrlLabel: string;
  public
    property Id: integer read FId;
    property Format: string read FFormat;
    property Variables: TDictionary<string, string> read FVariables;
    property SendTelemetry: boolean read FSendTelemetry;
    property ShowUser: boolean read FShowUser;
    property Url: string read FUrl;
    property UrlLabel: string read FUrlLabel;
  end;

  TChecksum = class(TBaseType)
  private
    [JSONName('algorithm'), JSONReflect(ctString, rtString, TEnumInterceptor)]
    FAlgorithm: TChecksumAlgorithm;
    [JSONName('checksum')]
    FChecksum: string;
  public
    procedure Assign(Source: TPersistent); override;

    property Algorithm: TChecksumAlgorithm read FAlgorithm write FAlgorithm;
    property Checksum: string read FChecksum write FChecksum;
  end;

  TSource<TAdapterData> = class;
  TDefaultSource = TSource<TValue>;
  TSources = TObjectList<TDefaultSource>;
  TSource<TAdapterData> = class(TBaseType)
  private type
    TCheckSums = TObjectList<TChecksum>;
  private
    [JSONName('name')]
    FName: string;
    [JSONName('path')]
    FPath: string;
    [JSONName('sourceReference')]
    FSourceReference: integer;
    [JSONName('presentationHint'), JSONReflect(ctString, rtString, TEnumInterceptor)]
    FPresentationHint: TSourcePresentationHint;
    [JSONName('origin')]
    FOrigin: string;
    [Managed()]
    [JSONName('sources')]
    FSources: TSources;
    [Managed()]
    [JSONName('adapterData')]
    FAdapterData: TAdapterData;
    [Managed()]
    [JSONName('checksums')]
    FChecksums: TCheckSums;
  public
    procedure Assign(Source: TPersistent); override;

    property Name: string read FName write FName;
    property Path: string read FPath write FPath;
    property SourceReference: integer read FSourceReference write FSourceReference;
    property PresentationHint: TSourcePresentationHint read FPresentationHint write FPresentationHint;
    property Origin: string read FOrigin write FOrigin;
    property Sources: TSources read FSources;
    property AdapterData: TAdapterData read FAdapterData write FAdapterData;
    property Checksums: TCheckSums read FChecksums;
  end;

  TBreakpoint = class(TBaseType)
  private
    [JSONName('id')]
    FId: integer;
    [JSONName('verified')]
    FVerified: boolean;
    [JSONName('message')]
    FMessage: string;
    [Managed()]
    [JSONName('source')]
    FSource: TDefaultSource;
    [JSONName('line')]
    FLine: integer;
    [JSONName('column')]
    FColumn: integer;
    [JSONName('endLine')]
    FEndLine: integer;
    [JSONName('endColumn')]
    FEndColumn: integer;
    [JSONName('instructionReference')]
    FInstructionReference: string;
    [JSONName('offset')]
    FOffset: integer;
  public
    property Id: integer read FId write FId;
    property Verified: boolean read FVerified write FVerified;
    property Message: string read FMessage write FMessage;
    property Source: TDefaultSource read FSource write FSource;
    property Line: integer read FLine write FLine;
    property Column: integer read FColumn write FColumn;
    property EndLine: integer read FEndLine write FEndLine;
    property EndColumn: integer read FEndColumn write FEndColumn;
    property InstructionReference: string read FInstructionReference write FInstructionReference;
    property Offset: integer read FOffset write FOffset;
  end;

  TBreakpoints = TObjectList<TBreakpoint>;

  TModule = class(TBaseType)
  private
    [JSONName('id')]
    FId: integer;
    [JSONName('name')]
    FName: string;
    [JSONName('path')]
    FPath: string;
    [JSONName('isOptimized')]
    FIsOptimized: boolean;
    [JSONName('isUserCode')]
    FIsUserCode: boolean;
    [JSONName('version')]
    FVersion: string;
    [JSONName('symbolStatus')]
    FSymbolStatus: string;
    [JSONName('symbolFilePath')]
    FSymbolFilePath: string;
    [JSONName('dateTimeStamp')]
    FDateTimeStamp: string;
    [JSONName('addressRange')]
    FAddressRange: string;
  public
    property Id: integer read FId write FId;
    property Name: string read FName write FName;
    property Path: string read FPath write FPath;
    property IsOptimized: boolean read FIsOptimized write FIsOptimized;
    property IsUserCode: boolean read FIsUserCode write FIsUserCode;
    property Version: string read FVersion write FVersion;
    property SymbolStatus: string read FSymbolStatus write FSymbolStatus;
    property SymbolFilePath: string read FSymbolFilePath write FSymbolFilePath;
    property DateTimeStamp: string read FDateTimeStamp write FDateTimeStamp;
    property AddressRange: string read FAddressRange write FAddressRange;
  end;

  TModules = TObjectList<TModule>;

  TExceptionBreakpointsFilter = class(TBaseType)
  private
    [JSONName('filter')]
    FFilter: string;
    [JSONName('label')]
    FLabel: string;
    [JSONName('description')]
    FDescription: string;
    [JSONName('default')]
    FDefault: boolean;
    [JSONName('supportsCondition')]
    FSupportsCondition: boolean;
    [JSONName('conditionDescription')]
    FConditionDescription: string;
  public
    property Filter: string read FFilter write FFilter;
    property &Label: string read FLabel write FLabel;
    property Description: string read FDescription write FDescription;
    property &Default: boolean read FDefault write FDefault;
    property SupportsCondition: boolean read FSupportsCondition write FSupportsCondition;
    property ConditionDescription: string read FConditionDescription write FConditionDescription;
  end;
  TExceptionBreakpointsFilters = TObjectList<TExceptionBreakpointsFilter>;

  TColumnDescriptor = class(TBaseType)
  private
    [JSONName('attributeName')]
    FAttributeName: string;
    [JSONName('label')]
    FLabel: string;
    [JSONName('format')]
    FFormat: string;
    [JSONName('type'), JSONReflect(ctString, rtString, TEnumInterceptor)]
    FType: TColumnDescriptorType;
    [JSONName('width')]
    FWidth: integer;
  public
    property AttributeName: string read FAttributeName write FAttributeName;
    property &Label: string read FLabel write FLabel;
    property Format: string read FFormat write FFormat;
    property &Type: TColumnDescriptorType read FType write FType;
    property Width: integer read FWidth write FWidth;
  end;

  TCapabilities = class(TBaseType)
  private type
    TColumnDescriptors = TObjectList<TColumnDescriptor>;
  private
    [JSONName('supportsConfigurationDoneRequest')]
    FSupportsConfigurationDoneRequest: boolean;
    [JSONName('supportsFunctionBreakpoints')]
    FSupportsFunctionBreakpoints: boolean;
    [JSONName('supportsConditionalBreakpoints')]
    FSupportsConditionalBreakpoints: boolean;
    [JSONName('supportsEvaluateForHovers')]
    FSupportsEvaluateForHovers: boolean;
    [JSONName('exceptionBreakpointFilters'), Managed()]
    FExceptionBreakpointFilters: TExceptionBreakpointsFilters;
    [JSONName('supportsStepBack')]
    FSupportsStepBack: boolean;
    [JSONName('supportsSetVariable')]
    FSupportsSetVariable: boolean;
    [JSONName('supportsRestartFrame')]
    FSupportsRestartFrame: boolean;
    [JSONName('supportsGotoTargetsRequest')]
    FSupportsGotoTargetsRequest: boolean;
    [JSONName('supportsCompletitionsRequest')]
    FSupportsCompletitionsRequest: boolean;
    [JSONName('completitionTriggerCharacters')]
    FCompletitionTriggerCharacters: TArray<string>;
    [JSONName('supportsModuleRequests')]
    FSupportsModuleRequests: boolean;
    [JSONName('additionalModuleColumns')]
    FAdditionalModuleColumns: TColumnDescriptors;
    [JSONName('supportedChecksumAlgorithms'), JSONReflect(ctStrings, rtStrings, TSetInterceptor)]
    FSupportedChecksumAlgorithms: TChecksumAlgorithms;
    [JSONName('supportsRestartRequest')]
    FSupportsRestartRequest: boolean;
    [JSONName('supportsExceptionOptions')]
    FSupportsExceptionOptions: boolean;
    [JSONName('supportsValueFormattingOptions')]
    FSupportsValueFormattingOptions: boolean;
    [JSONName('supportsExceptionInfoRequest')]
    FSupportsExceptionInfoRequest: boolean;
    [JSONName('supportTerminateDebuggee')]
    FSupportTerminateDebuggee: boolean;
    [JSONName('supportSuspendDebuggee')]
    FSupportSuspendDebuggee: boolean;
    [JSONName('supportsDelayedStackTraceLoading')]
    FSupportsDelayedStackTraceLoading: boolean;
    [JSONName('supportsLoadedSourcesRequest')]
    FSupportsLoadedSourcesRequest: boolean;
    [JSONName('supportsLogPoints')]
    FSupportsLogPoints: boolean;
    [JSONName('supportsTerminateThreadsRequest')]
    FSupportsTerminateThreadsRequest: boolean;
    [JSONName('supportsSetExpression')]
    FSupportsSetExpression: boolean;
    [JSONName('supportsTerminateRequest')]
    FSupportsTerminateRequest: boolean;
    [JSONName('supportsDataBreakpoints')]
    FSupportsDataBreakpoints: boolean;
    [JSONName('supportsReadMemoryRequest')]
    FSupportsReadMemoryRequest: boolean;
    [JSONName('supportsWriteMemoryRequest')]
    FSupportsWriteMemoryRequest: boolean;
    [JSONName('supportsDisassembleRequest')]
    FSupportsDisassembleRequest: boolean;
    [JSONName('supportsCancelRequest')]
    FSupportsCancelRequest: boolean;
    [JSONName('supportsBreakpointLocationRequest')]
    FSupportsBreakpointLocationRequest: boolean;
    [JSONName('supportsClipboardContext')]
    FSupportsClipboardContext: boolean;
    [JSONName('supportsSteppingGranularity')]
    FSupportsSteppingGranularity: boolean;
    [JSONName('supportsInstructionBreakpoints')]
    FSupportsInstructionBreakpoints: boolean;
    [JSONName('supportsExceptionFilterOptions')]
    FSupportsExceptionFilterOptions: boolean;
    [JSONName('supportsSingleThreadExecutionRequests')]
    FSupportsSingleThreadExecutionRequests: boolean;
  public
    property SupportsConfigurationDoneRequest: boolean read FSupportsConfigurationDoneRequest write FSupportsConfigurationDoneRequest;
    property SupportsFunctionBreakpoints: boolean read FSupportsFunctionBreakpoints write FSupportsFunctionBreakpoints;
    property SupportsConditionalBreakpoints: boolean read FSupportsConditionalBreakpoints write FSupportsConditionalBreakpoints;
    property SupportsEvaluateForHovers: boolean read FSupportsEvaluateForHovers write FSupportsEvaluateForHovers;
    property ExceptionBreakpointFilters: TExceptionBreakpointsFilters read FExceptionBreakpointFilters write FExceptionBreakpointFilters;
    property SupportsStepBack: boolean read FSupportsStepBack write FSupportsStepBack;
    property SupportsSetVariable: boolean read FSupportsSetVariable write FSupportsSetVariable;
    property SupportsRestartFrame: boolean read FSupportsRestartFrame write FSupportsRestartFrame;
    property SupportsGotoTargetsRequest: boolean read FSupportsGotoTargetsRequest write FSupportsGotoTargetsRequest;
    property SupportsCompletitionsRequest: boolean read FSupportsCompletitionsRequest write FSupportsCompletitionsRequest;
    property CompletitionTriggerCharacters: TArray<string> read FCompletitionTriggerCharacters write FCompletitionTriggerCharacters;
    property SupportsModuleRequests: boolean read FSupportsModuleRequests write FSupportsModuleRequests;
    property AdditionalModuleColumns: TColumnDescriptors read FAdditionalModuleColumns write FAdditionalModuleColumns;
    property SupportedChecksumAlgorithms: TChecksumAlgorithms read FSupportedChecksumAlgorithms write FSupportedChecksumAlgorithms;
    property SupportsRestartRequest: boolean read FSupportsRestartRequest write FSupportsRestartRequest;
    property SupportsExceptionOptions: boolean read FSupportsExceptionOptions write FSupportsExceptionOptions;
    property SupportsValueFormattingOptions: boolean read FSupportsValueFormattingOptions write FSupportsValueFormattingOptions;
    property SupportsExceptionInfoRequest: boolean read FSupportsExceptionInfoRequest write FSupportsExceptionInfoRequest;
    property SupportTerminateDebuggee: boolean read FSupportTerminateDebuggee write FSupportTerminateDebuggee;
    property SupportSuspendDebuggee: boolean read FSupportSuspendDebuggee write FSupportSuspendDebuggee;
    property SupportsDelayedStackTraceLoading: boolean read FSupportsDelayedStackTraceLoading write FSupportsDelayedStackTraceLoading;
    property SupportsLoadedSourcesRequest: boolean read FSupportsLoadedSourcesRequest write FSupportsLoadedSourcesRequest;
    property SupportsLogPoints: boolean read FSupportsLogPoints write FSupportsLogPoints;
    property SupportsTerminateThreadsRequest: boolean read FSupportsTerminateThreadsRequest write FSupportsTerminateThreadsRequest;
    property SupportsSetExpression: boolean read FSupportsSetExpression write FSupportsSetExpression;
    property SupportsTerminateRequest: boolean read FSupportsTerminateRequest write FSupportsTerminateRequest;
    property SupportsDataBreakpoints: boolean read FSupportsDataBreakpoints write FSupportsDataBreakpoints;
    property SupportsReadMemoryRequest: boolean read FSupportsReadMemoryRequest write FSupportsReadMemoryRequest;
    property SupportsWriteMemoryRequest: boolean read FSupportsWriteMemoryRequest write FSupportsWriteMemoryRequest;
    property SupportsDisassembleRequest: boolean read FSupportsDisassembleRequest write FSupportsDisassembleRequest;
    property SupportsCancelRequest: boolean read FSupportsCancelRequest write FSupportsCancelRequest;
    property SupportsBreakpointLocationRequest: boolean read FSupportsBreakpointLocationRequest write FSupportsBreakpointLocationRequest;
    property SupportsClipboardContext: boolean read FSupportsClipboardContext write FSupportsClipboardContext;
    property SupportsSteppingGranularity: boolean read FSupportsSteppingGranularity write FSupportsSteppingGranularity;
    property SupportsInstructionBreakpoints: boolean read FSupportsInstructionBreakpoints write FSupportsInstructionBreakpoints;
    property SupportsExceptionFilterOptions: boolean read FSupportsExceptionFilterOptions write FSupportsExceptionFilterOptions;
    property SupportsSingleThreadExecutionRequests: boolean read FSupportsSingleThreadExecutionRequests write FSupportsSingleThreadExecutionRequests;
  end;

  TBreakpointLocation = class(TBaseType)
  private
    [JSONName('line')]
    FLine: integer;
    [JSONName('column')]
    FColumn: integer;
    [JSONName('endLine')]
    FEndLine: integer;
    [JSONName('endColumn')]
    FEndColumn: integer;
  public
    property Line: integer read FLine write FLine;
    property Column: integer read FColumn write FColumn;
    property EndLine: integer read FEndLine write FEndLine;
    property EndColumn: integer read FEndColumn write FEndColumn;
  end;

  TBreakpointLocations = TObjectList<TBreakpointLocation>;

  TSourceBreakpoint = class(TBaseType)
  private
    [JSONName('line')]
    FLine: integer;
    [JSONName('column')]
    FColumn: integer;
    [JSONName('condition')]
    FCondition: string;
    [JSONName('hitCondition')]
    FHitCondition: string;
    [JSONName('logMessage')]
    FLogMessage: string;
  public
    property Line: integer read FLine write FLine;
    property Column: integer read FColumn write FColumn;
    property Condition: string read FCondition write FCondition;
    property HitCondition: string read FHitCondition write FHitCondition;
    property LogMessage: string read FLogMessage write FLogMessage;
  end;

  TSourceBreakpoints = TObjectList<TSourceBreakpoint>;

  TFunctionBreakpoint = class(TBaseType)
  private
    [JSONName('name')]
    FName: string;
    [JSONName('condition')]
    FCondition: string;
    [JSONName('hitCondition')]
    FHitCondigition: string;
  public
    property Name: string read FName write FName;
    property Condition: string read FCondition write FCondition;
    property HitCondigition: string read FHitCondigition write FHitCondigition;
  end;

  TFunctionBreakpoints = TObjectList<TFunctionBreakpoint>;

  TExceptionFilterOption = class(TBaseType)
  private
    [JSONName('filterId')]
    FFilterId: string;
    [JSONName('condition')]
    FCondition: string;
  public
    property FilterId: string read FFilterId write FFilterId;
    property Condition: string read FCondition write FCondition;
  end;

  TExceptionFilterOptions = TObjectList<TExceptionFilterOption>;

  TExceptionPathSegment = class(TBaseType)
  private
    [JSONName('negate')]
    FNegate: boolean;
    [JSONName('names')]
    FNames: TArray<string>;
  public
    property Negate: boolean read FNegate write FNegate;
    property Names: TArray<string> read FNames write FNames;
  end;

  TExceptionOption = class(TBaseType)
  private
    [JSONName('path'), Managed()]
    FPath: TExceptionPathSegment;
    [JSONName('breakMode'), JSONReflect(ctString, rtString, TEnumInterceptor)]
    FBreakMode: TExceptionBreakMode;
  public
    property Path: TExceptionPathSegment read FPath write FPath;
    property BreakMode: TExceptionBreakMode read FBreakMode write FBreakMode;
  end;

  TExceptionOptions = TObjectList<TExceptionOption>;

  TDataBreakpoint = class(TBaseType)
  private
    [JSONName('dataId')]
    FDataId: string;
    [JSONName('accessType'), JSONReflect(ctString, rtString, TEnumInterceptor)]
    FAccessType: TDataBreakpointAccessType;
    [JSONName('condition')]
    FCondition: string;
    [JSONName('hitCondition')]
    FHitCondition: string;
  public
    property DataId: string read FDataId write FDataId;
    property AccessType: TDataBreakpointAccessType read FAccessType write FAccessType;
    property Condition: string read FCondition write FCondition;
    property HitCondition: string read FHitCondition write FHitCondition;
  end;

  TDataBreakpoints = TObjectList<TDataBreakpoint>;

  TInstructionBreakpoint = class(TBaseType)
  private
    [JSONName('instructionReference')]
    FInstructionReference: string;
    [JSONName('offset')]
    FOffset: string;
    [JSONName('condition')]
    FCondition: string;
    [JSONName('hitCondition')]
    FHitCondition: string;
  public
    property InstructionReference: string read FInstructionReference write FInstructionReference;
    property Offset: string read FOffset write FOffset;
    property Condition: string read FCondition write FCondition;
    property HitCondition: string read FHitCondition write FHitCondition;
  end;

  TInstructionBreakpoints = TObjectList<TInstructionBreakpoint>;

  TStackFrameFormat = class(TBaseType)
  private
    [JSONName('parameters')]
    FParameters: boolean;
    [JSONName('parameterTypes')]
    FParameterTypes: boolean;
    [JSONName('parameterNames')]
    FParameterNames: boolean;
    [JSONName('parameterValues')]
    FParameterValues: boolean;
    [JSONName('lines')]
    FLines: boolean;
    [JSONName('module')]
    FModule: boolean;
    [JSONName('includedAll')]
    FIncludeAll: boolean;
  public
    property Parameters: boolean read FParameters write FParameters;
    property ParameterTypes: boolean read FParameterTypes write FParameterTypes;
    property ParameterNames: boolean read FParameterNames write FParameterNames;
    property ParameterValues: boolean read FParameterValues write FParameterValues;
    property Lines: boolean read FLines write FLines;
    property Module: boolean read FModule write FModule;
    property IncludeAll: boolean read FIncludeAll write FIncludeAll;
  end;

  TIntegerOrString = TValue;
  TStackFrame<TModuleId> = class;
  TDefaultStackFrame = TStackFrame<TIntegerOrString>;
  TStackFrame<TModuleId> = class(TBaseType)
  private
    [JSONName('id')]
    FId: integer;
    [JSONName('name')]
    FName: string;
    [JSONName('source'), Managed()]
    FSource: TDefaultSource;
    [JSONName('line')]
    FLine: integer;
    [JSONName('column')]
    FColumn: integer;
    [JSONName('endLine')]
    FEndLine: integer;
    [JSONName('endColumn')]
    FEndColumn: integer;
    [JSONName('canRestart')]
    FCanRestart: boolean;
    [JSONName('instructionPointerReference')]
    FInstructionPointerReference: String;
    [JSONName('moduleId')]
    FModuleId: TModuleId;
    [JSONName('presentationHint'), JSONReflect(ctString, rtString, TEnumInterceptor)]
    FPresentationHint: TStackFramePresentationHint;
  public
    procedure Assign(Source: TPersistent); override;

    property Id: integer read FId write FId;
    property Name: string read FName write FName;
    property Source: TDefaultSource read FSource write FSource;
    property Line: integer read FLine write FLine;
    property Column: integer read FColumn write FColumn;
    property EndLine: integer read FEndLine write FEndLine;
    property EndColumn: integer read FEndColumn write FEndColumn;
    property CanRestart: boolean read FCanRestart write FCanRestart;
    property InstructionPointerReference: String read FInstructionPointerReference write FInstructionPointerReference;
    property ModuleId: TModuleId read FModuleId write FModuleId;
    property PresentationHint: TStackFramePresentationHint read FPresentationHint write FPresentationHint;
  end;

  TStackFrames = TObjectList<TDefaultStackFrame>;

  TScope = class(TBaseType)
  private
    [JSONName('name')]
    FName: string;
    [JSONName('presentationHint'), JSONReflect(ctString, rtString, TEnumInterceptor)]
    FPresentationHint: TScopePresentationHint;
    [JSONName('variablesReference')]
    FVariablesReference: integer;
    [JSONName('namedVariables')]
    FNamedVariables: integer;
    [JSONName('indexedVariables')]
    FIndexedVariables: integer;
    [JSONName('expensive')]
    FExpensive: Boolean;
    [JSONName('source'), Managed()]
    FSource: TDefaultSource;
    [JSONName('line')]
    FLine: integer;
    [JSONName('column')]
    FColumn: integer;
    [JSONName('endLine')]
    FEndLine: integer;
    [JSONName('endColumn')]
    FEndColumn: integer;
  public
    property Name: string read FName write FName;
    property PresentationHint: TScopePresentationHint read FPresentationHint write FPresentationHint;
    property VariablesReference: integer read FVariablesReference write FVariablesReference;
    property NamedVariables: integer read FNamedVariables write FNamedVariables;
    property IndexedVariables: integer read FIndexedVariables write FIndexedVariables;
    property Expensive: boolean read FExpensive write FExpensive;
    property Source: TDefaultSource read FSource write FSource;
    property Line: integer read FLine write FLine;
    property Column: integer read FColumn write FColumn;
    property EndLine: integer read FEndLine write FEndLine;
    property EndColumn: integer read FEndColumn write FEndColumn;
  end;

  TScopes = TObjectList<TScope>;

  TValueFormat = class(TBaseType)
  private
    FHex: boolean;
  public
    property Hex: boolean read FHex write FHex;
  end;

  TVariablePresentationHint = class(TBaseType)
  private
    [JSONName('kind'), JSONReflect(ctString, rtString, TEnumInterceptor)]
    FKind: TVariableKind;
    [JSONName('attributes'), JSONReflect(ctStrings, rtStrings, TSetInterceptor)]
    FAttributes: TVariableAttributes;
    [JSONName('visibility'), JSONReflect(ctString, rtString, TEnumInterceptor)]
    FVisibility: TVariableVisibility;
    [JSONName('lazy')]
    FLazy: boolean;
  public
    property Kind: TVariableKind read FKind write FKind;
    property Attributes: TVariableAttributes read FAttributes write FAttributes;
    property Visibility: TVariableVisibility read FVisibility write FVisibility;
    property Lazy: boolean read FLazy write FLazy;
  end;

  TVariable = class(TBaseType)
  private
    [JSONName('name')]
    FName: string;
    [JSONName('value')]
    FValue: string;
    [JSONName('type')]
    FType: string;
    [JSONName('presentationHint'), Managed()]
    FPresentationHint: TVariablePresentationHint;
    [JSONName('evaluateName')]
    FEvaluateName: string;
    [JSONName('variablesReference')]
    FVariablesReference: integer;
    [JSONName('namedVariables')]
    FNamedVariables: integer;
    [JSONName('indexedVariables')]
    FIndexedVariables: integer;
    [JSONName('memoryReference')]
    FMemoryReference: string;
  public
    property Name: string read FName write FName;
    property Value: string read FValue write FValue;
    property &Type: string read FType write FType;
    property PresentationHint: TVariablePresentationHint read FPresentationHint write FPresentationHint;
    property EvaluateName: string read FEvaluateName write FEvaluateName;
    property VariablesReference: integer read FVariablesReference write FVariablesReference;
    property NamedVariables: integer read FNamedVariables write FNamedVariables;
    property IndexedVariables: integer read FIndexedVariables write FIndexedVariables;
    property MemoryReference: string read FMemoryReference write FMemoryReference;
  end;

  TVariables = TObjectList<TVariable>;

  TThread = class(TBaseType)
  private
    [JSONName('id')]
    FId: integer;
    [JSONName('name')]
    FName: string;
  public
    property Id: integer read FId write FId;
    property Name: string read FName write FName;
  end;

  TThreads = TObjectList<TThread>;

  TStepInTarget = class(TBaseType)
  private
    [JSONName('id')]
    FId: integer;
    [JSONName('label')]
    FLabel: string;
    [JSONName('line')]
    FLine: integer;
    [JSONName('column')]
    FColumn: integer;
    [JSONName('endLine')]
    FEndLine: integer;
    [JSONName('endColumn')]
    FEndColumn: integer;
  public
    property Id: integer read FId write FId;
    property &Label: string read FLabel write FLabel;
    property Line: integer read FLine write FLine;
    property Column: integer read FColumn write FColumn;
    property EndLine: integer read FEndLine write FEndLine;
    property EndColumn: integer read FEndColumn write FEndColumn;
  end;

  TStepInTargets = TObjectList<TStepInTarget>;

  TTarget = class(TBaseType)
  private
    [JSONName('id')]
    FId: integer;
    [JSONName('label')]
    FLabel: string;
    [JSONName('line')]
    FLine: integer;
    [JSONName('column')]
    FColumn: integer;
    [JSONName('endLine')]
    FEndLine: integer;
    [JSONName('endColumn')]
    FEndColumn: integer;
    [JSONName('instructionPointerReference')]
    FInstructionPointerReference: string;
  public
    property Id: integer read FId write FId;
    property &Label: string read FLabel write FLabel;
    property Line: integer read FLine write FLine;
    property Column: integer read FColumn write FColumn;
    property EndLine: integer read FEndLine write FEndLine;
    property EndColumn: integer read FEndColumn write FEndColumn;
    property InstructionPointerReference: string read FInstructionPointerReference write FInstructionPointerReference;
  end;

  TTargets = TObjectList<TTarget>;

  TCompletitionItem = class(TBaseType)
  private
    [JSONName('label')]
    FLabel: string;
    [JSONName('text')]
    FText: string;
    [JSONName('sortText')]
    FSortText: string;
    [JSONName('detail')]
    FDetail: string;
    [JSONName('start')]
    FStart: integer;
    [JSONName('type'), JSONReflect(ctString, rtString, TEnumInterceptor)]
    FType: TCompletitionItemType;
    [JSONName('length')]
    FLength: integer;
    [JSONName('selectionStart')]
    FSelectionStart: integer;
    [JSONName('selectionLength')]
    FSelectionLength: integer;
  public
    property &Label: string read FLabel write FLabel;
    property Text: string read FText write FText;
    property SortText: string read FSortText write FSortText;
    property Detail: string read FDetail write FDetail;
    property &Type: TCompletitionItemType read FType write FType;
    property Start: integer read FStart write FStart;
    property Length: integer read FLength write FLength;
    property SelectionStart: integer read FSelectionStart write FSelectionStart;
    property SelectionLength: integer read FSelectionLength write FSelectionLength;
  end;

  TCompletitionItems = TObjectList<TCompletitionItem>;

  TExceptionDetail = class;
  TExceptionDetails = TObjectList<TExceptionDetail>;
  TExceptionDetail = class(TBaseType)
  private
    [JSONName('message')]
    FMessage: string;
    [JSONName('typeName')]
    FTypeName: string;
    [JSONName('fullTypeName')]
    FFullTypeName: string;
    [JSONName('evaluteName')]
    FEvaluteName: string;
    [JSONName('stackTrace')]
    FStackTrace: string;
    [JSONName('innerException'), Managed()]
    FInnerException: TExceptionDetails;
  public
    property Message: string read FMessage write FMessage;
    property TypeName: string read FTypeName write FTypeName;
    property FullTypeName: string read FFullTypeName write FFullTypeName;
    property EvaluteName: string read FEvaluteName write FEvaluteName;
    property StackTrace: string read FStackTrace write FStackTrace;
    property InnerException: TExceptionDetails read FInnerException write FInnerException;
  end;

  TDisassembleInstruction = class(TBaseType)
  private
    [JSONName('address')]
    FAddress: string;
    [JSONName('instructionBytes')]
    FInstructionBytes: string;
    [JSONName('instruction')]
    FInstruction: string;
    [JSONName('symbol')]
    FSymbol: string;
    [JSONName('location'), Managed()]
    FLocation: TDefaultSource;
    [JSONName('line')]
    FLine: integer;
    [JSONName('column')]
    FColumn: integer;
    [JSONName('endLine')]
    FEndLine: integer;
    [JSONName('endColumn')]
    FEndColumn: integer;
  public
    property Address: string read FAddress write FAddress;
    property InstructionBytes: string read FInstructionBytes write FInstructionBytes;
    property Instruction: string read FInstruction write FInstruction;
    property Symbol: string read FSymbol write FSymbol;
    property Location: TDefaultSource read FLocation write FLocation;
    property Line: integer read FLine write FLine;
    property Column: integer read FColumn write FColumn;
    property EndLine: integer read FEndLine write FEndLine;
    property EndColumn: integer read FEndColumn write FEndColumn;
  end;

  TDisassembleInstructions = TObjectList<TDisassembleInstruction>;

const
  TWO_CRLF = sLineBreak + sLineBreak;
  CONTENT_LENGTH_HEADER = 'Content-Length';

implementation

uses
  System.TypInfo, System.SysUtils,
  BaseProtocol.Helpers;

{ TMessageTypeAttribute }

constructor MessageTypeAttribute.Create(const AMessageType: TMessageType);
begin
  FMessageType := AMessageType;
end;

{ TRequestCommandAttribute }

constructor RequestCommandAttribute.Create(
  const ARequestCommand: TRequestCommand);
begin
  FRequestCommand := ARequestCommand;
end;

{ TEventTypeAttribute }

constructor EventTypeAttribute.Create(const AEventType: TEventType);
begin
  FEventType := AEventType;
end;

{ TBaseType }

procedure TBaseType.AfterConstruction;
begin
  inherited;
  TGenericHelper.CreateFields(Self);
end;

procedure TBaseType.BeforeDestruction;
begin
  inherited;
  TGenericHelper.FreeFields(Self);
end;

{ TChecksum }

procedure TChecksum.Assign(Source: TPersistent);
begin
  inherited;
  Self.Algorithm := TChecksum(Source).Algorithm;
  Self.Checksum := TChecksum(Source).Checksum;
end;

{ TSource<TAdapterData> }

procedure TSource<TAdapterData>.Assign(Source: TPersistent);
var
  LNewItem: TPersistent;
begin
  inherited;
  Self.Name := TDefaultSource(Source).Name;
  Self.Path := TDefaultSource(Source).Path;
  Self.SourceReference := TDefaultSource(Source).SourceReference;
  Self.PresentationHint := TDefaultSource(Source).PresentationHint;
  Self.Origin := TDefaultSource(Source).Origin;
  { TODO : Fix here when we get the AdapterData type possibilities }
  for var LItem in Self.Sources do begin
    //Creates a identical instance type
    LNewItem := LItem.ClassType.InitInstance(LNewItem) as TPersistent;
    LNewItem.Create();
    LNewItem.Assign(LItem);
    TDefaultSource(Self).Sources.Add(TDefaultSource(LNewItem));
  end;

  if (Source is TDefaultSource) then
    TDefaultSource(Self).AdapterData := TDefaultSource(Source).AdapterData
  else if Source is TSource<string> then
    TDefaultSource(Self).AdapterData := TSource<string>(Source).AdapterData
  else
    raise Exception.Create('Invalid "AdapterData" type.');

  for var LItem in Self.Checksums do begin
    LNewItem := TChecksum.Create();
    LNewItem.Assign(LItem);
    Self.Checksums.Add(TChecksum(LNewItem));
  end;
end;

{ TStackFrame<TModuleId> }

procedure TStackFrame<TModuleId>.Assign(Source: TPersistent);
begin
  inherited;
  Self.Id := TDefaultStackFrame(Source).Id;
  Self.Name := TDefaultStackFrame(Source).Name;
  Self.Line := TDefaultStackFrame(Source).Line;
  Self.Column := TDefaultStackFrame(Source).Column;
  Self.EndLine := TDefaultStackFrame(Source).EndLine;
  Self.EndColumn := TDefaultStackFrame(Source).EndColumn;
  Self.CanRestart := TDefaultStackFrame(Source).CanRestart;
  Self.InstructionPointerReference := TDefaultStackFrame(Source).InstructionPointerReference;
  Self.PresentationHint := TDefaultStackFrame(Source).PresentationHint;

  Self.Source.Assign(TDefaultStackFrame(Source).Source);

  var GetModuleId := function(const AStackFrame: TPersistent): TValue
  begin
    if (AStackFrame is TDefaultStackFrame) then
      Result := TDefaultStackFrame(AStackFrame).ModuleId
    else if AStackFrame is TStackFrame<Integer> then
      Result :=  TStackFrame<Integer>(AStackFrame).ModuleId
    else if AStackFrame is TStackFrame<String> then
      Result :=  TStackFrame<String>(AStackFrame).ModuleId
    else
      raise Exception.Create('Invalid "ModuleId" type.');
  end;

  var SetModuleId := procedure(const AStackFrame: TPersistent; const AValue: TValue)
  begin
    if AStackFrame is TDefaultStackFrame then
      TDefaultStackFrame(AStackFrame).ModuleId := AValue
    else if AStackFrame is TStackFrame<Integer> then
      TStackFrame<Integer>(AStackFrame).ModuleId := AValue.AsInteger()
    else if AStackFrame is TStackFrame<String> then
      TStackFrame<String>(AStackFrame).ModuleId := AValue.AsString()
    else
      raise Exception.Create('Invalid "ModuleId" type.');
  end;

  SetModuleId(Self, GetModuleId(Source));
end;

end.

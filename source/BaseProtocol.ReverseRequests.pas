unit BaseProtocol.ReverseRequests;

interface

uses
  System.Rtti,
  Rest.Json.Types,
  Rest.JsonReflect,
  BaseProtocol,
  BaseProtocol.Types,
  BaseProtocol.Json;

type
  TRunInTerminalRequestArguments = class(TBaseType)
  private type
    TEnvs = TKeyValue;
  private
    [JSONName('kind'), JSONReflect(ctString, rtString, TEnumInterceptor)]
    FKind: TRunInTerminalRequestArgumentsKind;
    [JSONName('title')]
    FTitle: string;
    [JSONName('cwd')]
    FCwd: string;
    [JSONName('args')]
    FArgs: TArray<string>;
    [JSONName('env'), Managed()]
    FEnv: TEnvs;
  public
    property Kind: TRunInTerminalRequestArgumentsKind read FKind write FKind;
    property Title: string read FTitle write FTitle;
    property Cwd: string read FCwd write FCwd;
    property Args: TArray<string> read FArgs write FArgs;
    property Env: TEnvs read FEnv write FEnv;
  end;

  [RequestCommand(TRequestCommand.RunInTerminal)]
  TRunInTerminalRequest = class(TRequest<TRunInTerminalRequestArguments>);

  TRunInTerminalResponseBody = class(TBaseType)
  private
    [JSONName('processId')]
    FProcessId: integer;
    [JSONName('shellProcessId')]
    FShellProcessId: integer;
  public
    property ProcessId: integer read FProcessId write FProcessId;
    property ShellProcessId: integer read FShellProcessId write FShellProcessId;
  end;

  TRunInTerminalResponse = class(TResponse<TRunInTerminalResponseBody>);

  TReverseRequestsRegistration = class
  public
    class procedure RegisterAll();
    class procedure unregisterAll();
  end;

implementation

{ TReverseRequestsRegistration }

class procedure TReverseRequestsRegistration.RegisterAll;
begin
  TProtocolMessage.RegisterRequest(TRequestCommand.RunInTerminal, TRunInTerminalRequest, TRunInTerminalResponse);
end;

class procedure TReverseRequestsRegistration.unregisterAll;
begin
  TProtocolMessage.UnregisterRequest(TRequestCommand.RunInTerminal);
end;

end.

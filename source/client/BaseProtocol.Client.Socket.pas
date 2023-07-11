unit BaseProtocol.Client.Socket;

interface

uses
  System.SysUtils,
  System.Net.Socket,
  BaseProtocol,
  BaseProtocol.Client;

type
  TBaseProtocolClientSocket = class(TBaseProtocolClient)
  private
    FHost: string;
    FPort: integer;
    FSocket: TSocket;
  protected
    procedure InternalConnect(); override;
    procedure InternalDisconnect(); override;

    //Raw data
    function RequestData(): TBytes; override;
    procedure SendData(const ARaw: TBytes); override;
  public
    constructor Create(); overload;
    constructor Create(const AAddr: string; const APort: integer); overload;
    destructor Destroy(); override;

    property Host: string read FHost write FHost;
    property Port: integer read FPort write FPort;
  end;

implementation

uses
  System.Classes,
  System.SyncObjs;

{ TBaseProtocolClientSocket }

constructor TBaseProtocolClientSocket.Create(const AAddr: string;
  const APort: integer);
begin
  Create();
  FHost := AAddr;
  FPort := APort;
end;

destructor TBaseProtocolClientSocket.Destroy;
begin
  FSocket.Free();
  inherited;
end;

constructor TBaseProtocolClientSocket.Create;
begin
  inherited;
  FSocket := TSocket.Create(TSocketType.TCP);
end;

procedure TBaseProtocolClientSocket.InternalConnect;
begin
  inherited;
  FSocket.Connect(TNetEndpoint.Create(TIPAddress.LookupAddress(FHost), FPort));
end;

procedure TBaseProtocolClientSocket.InternalDisconnect;
begin
  inherited;
  FSocket.Close();
end;

function TBaseProtocolClientSocket.RequestData: TBytes;
begin
  TMonitor.Enter(FSocket);
  try
    Result := FSocket.Receive();
    TMonitor.Pulse(FSocket);
  finally
    TMonitor.Exit(FSocket);
  end;
end;

procedure TBaseProtocolClientSocket.SendData(const ARaw: TBytes);
begin
  TMonitor.Enter(FSocket);
  try
    FSocket.Send(ARaw);
  finally
    TMonitor.Exit(FSocket);
  end;
end;

end.



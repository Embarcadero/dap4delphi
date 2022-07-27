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

    property Host: string read FHost write FHost;
    property Port: integer read FPort write FPort;
  end;

implementation

uses
  System.Classes;

{ TBaseProtocolClientSocket }

constructor TBaseProtocolClientSocket.Create(const AAddr: string;
  const APort: integer);
begin
  Create();
  FHost := AAddr;
  FPort := APort;
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
  Result := FSocket.Receive();
end;

procedure TBaseProtocolClientSocket.SendData(const ARaw: TBytes);
begin
  FSocket.Send(ARaw);
end;

end.

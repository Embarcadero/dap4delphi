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
    FPort: integer;
    FSocket: TSocket;
    FIPAddress: TIPAddress;
  protected
    procedure InternalConnect(); override;
    procedure InternalDisconnect(); override;

    //Raw data
    function RequestData(): TBytes; override;
    procedure SendData(const ARaw: TBytes); override;
  public
    constructor Create(const AAddr: string; const APort: integer);
  end;

implementation

uses
  System.Classes;

{ TBaseProtocolClientSocket }

constructor TBaseProtocolClientSocket.Create(const AAddr: string;
  const APort: integer);
begin
  inherited Create();
  FSocket := TSocket.Create(TSocketType.TCP);
  FIPAddress := TIPAddress.LookupAddress(AAddr);
  FPort := APort;
end;

procedure TBaseProtocolClientSocket.InternalConnect;
begin
  inherited;
  FSocket.Connect(TNetEndpoint.Create(FIPAddress, FPort));
end;

procedure TBaseProtocolClientSocket.InternalDisconnect;
begin
  inherited;
  FSocket.Close();
end;

function TBaseProtocolClientSocket.RequestData: TBytes;
begin
  Result := FSocket.ReceiveFrom();
end;

procedure TBaseProtocolClientSocket.SendData(const ARaw: TBytes);
begin
  FSocket.Send(ARaw);
end;

end.

unit MainForm;

interface
//Update the project path for mORMot source directory.
{$I Synopse.inc}
//If you want to test libcurl, then also edit Synopse.inc and uncomment the USELIBCURL define under {$ifdef MSWINDOWS}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  System.Diagnostics,
  SynCrtSock;


type
  TfrmMain = class(TForm)
    Label1: TLabel;
    butSimpleHTTP: TButton;
    memHeaders: TMemo;
    edtReturnCode: TEdit;
    Label2: TLabel;
    memBody: TMemo;
    Label3: TLabel;
    Label4: TLabel;
    butWinHTTP: TButton;
    butLibcurl: TButton;
    labElapsedTime: TLabel;
    cboURI: TComboBox;
    procedure butSimpleHTTPClick(Sender: TObject);
    procedure butWinHTTPClick(Sender: TObject);
    procedure butLibcurlClick(Sender: TObject);
  private
    fURI:TURI;
    fStopWatch:TStopwatch;
    procedure PrepareCall;
    procedure EndCall;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}


(* Notes
- Avoid using TSimpleHttpClient

- This request typically creates a new instance via MainHttpClass.Create but the call is s wrapped in a try/except
and all exceptions are **silently eaten**   To repro: simply use in an invalid hostname and the result will be 0 with no exception displayed.

- ConnectionTimeout, SendTimeout, ReceiveTimeout:  all have hard coded 5000 in .Request()

- Minor:
  - Always uses HTTP/1.1 on request
  - Always has Accept: */*
*)
procedure TfrmMain.butSimpleHTTPClick(Sender: TObject);
var
  vSimple:TSimpleHttpClient;
begin
  PrepareCall;

  vSimple := TSimpleHttpClient.Create();
  try
    edtReturnCode.Text := IntToStr(vSimple.Request(fURI.URI));
    memHeaders.Text := utf8tostring(vSimple.Headers);
    memBody.Text := utf8tostring(vSimple.Body);
  finally
    vSimple.Free();
  end;

  EndCall;
end;


(* Notes

- TWinHTTP is the client to use on Windows
*)
procedure TfrmMain.butWinHTTPClick(Sender: TObject);
var
  vWinHTTP:TWinHTTP;
  vInHeader:SockString;
  vInData:SockString;
  vInDataType:SockString;
  vHeaders:SockString;
  vBody:RawByteString;
begin
  PrepareCall;

  vWinHTTP := TWinHTTP.Create(fURI.URI);
  try
    edtReturnCode.Text := IntToStr(vWinHTTP.Request(fURI.Address, 'GET', 0, vInHeader, vInData, vInDataType, SockString(vHeaders), SockString(vBody)));
    memHeaders.Text := utf8tostring(vHeaders);
    memBody.Text := utf8tostring(vBody);
  finally
    vWinHTTP.Free();
  end;

  EndCall;
end;

(* Notes
- No apparent way to set Cert Authority file on Windows unless you are using client certs
- A bit slower on Windows than WinHTTP
- Requires external file dependencies  (libcurl.dll, libssl-1_1.dll, cacert.pem|curl-ca-bundle.crt)
*)
procedure TfrmMain.butLibcurlClick(Sender: TObject);
{$ifdef USELIBCURL}
var
  vCurl:TCurlHTTP;
  vInHeader:SockString;
  vInData:SockString;
  vInDataType:SockString;
  vHeaders:SockString;
  vBody:SockString;
  vHeaderText:String;
begin
  PrepareCall;

  vCurl := TCurlHTTP.Create(fURI.URI);
  try
    (*On Windows, to set the cert authority path, use the .UseClientCertificate method
      to pass in CACert for path and manually change procedure TCurlHTTP.InternalCreateRequest
      by adding an else to the check for this missing CACertFile assignment:
        if fSSL.CertFile<>'' then begin
        ...

        end
        else if fSSL.CACertFile <> '' then begin
          curl.easy_setopt(fHandle,coCAInfo,pointer(fSSL.CACertFile));
    *)
    //vInHeader := 'Accept-Charset: iso-8859-1';  no one uses anymore: https://hsivonen.fi/accept-charset/
    vCurl.UseClientCertificate('', 'curl-ca-bundle.crt', '', '');
    //To simplify, I added a new CACertFile property via pull request #259 which includes the above mentioned fix for setting the CACertFile option
    //vCurl.CACertFile := 'curl-ca-bundle.crt';


    edtReturnCode.Text := IntToStr(vCurl.Request(fURI.Address, 'GET', 0, vInHeader, vInData, vInDataType, SockString(vHeaders), SockString(vBody)));
    memBody.Text := utf8tostring(vBody);
    memHeaders.Text := utf8tostring(vHeaders);
  finally
    vCurl.Free();
  end;

  EndCall;
end;
{$ELSE}
begin
  ShowMessage('libcurl support not included in Synopse.inc');
end;
{$ENDIF}



procedure TfrmMain.PrepareCall;
begin
  if not fURI.From(SockString(cboURI.Text)) then raise Exception.Create('Invalid URI');

  edtReturnCode.Text := '...attempting connection...';
  memHeaders.Text := '';
  memBody.Text := '';
  edtReturnCode.Refresh;
  memHeaders.Refresh;
  memBody.Refresh;
  fStopWatch.Reset;
  fStopWatch.Start;
end;

procedure TfrmMain.EndCall;
begin
  fStopWatch.Stop;
  labElapsedTime.Caption := Format('%d ms',[fStopWatch.ElapsedMilliseconds]);
end;



(* See also:

- https://docs.microsoft.com/en-us/windows/win32/wininet/wininet-vs-winhttp
One main takeaway: "When selecting between the two, you should use WinINet,
unless you plan to run within a service or service-like process that requires
impersonation and session isolation."
+ Chunked upload support in WinHTTP

- https://support.microsoft.com/en-us/help/238425/info-wininet-not-supported-for-use-in-services
Reinforces above conclusion:  Do not use WinINet in a windows service application

- http://blog.synopse.info/post/2011/07/04/WinINet-vs-WinHTTP
*)



end.

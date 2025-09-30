# Zen Browser Todos

- How to add a custom "search engine", ie what is a "search engine" in the browser?

## Extensions

- Tridactyl
- Surfingkeys
- Vimium
- Vimmatic

- foxy proxy
- darkreader
- webarchives
- Le Git Graph
- git notify
- octotree
- github gloc
- github search
- github repo size
- gitlab search
- 1password
- regex search
- rust search
- incognito search
- chatgpt search
- grok search
- C/C++ search
- cppreference search
- Arch linux search
- mdn web docs search
- zlibrary search
- pubmed search
- youtube search
- crates search
- nixos search
- reddit search
- copilot search
- alphaxiv search

## Alt Browsers

- LuaKit
- Qutebrowser

```json
{
  source: ConnectorError {
    kind: Other(None),
    source: ProviderError(ProviderError {
      source: ProviderError(ProviderError {
        source: ServiceError(ServiceError {
          source: Unhandled(Unhandled {
            source: ErrorMetadata {
              code: Some("AccessDenied"),
              message: Some("User: arn:aws-us-gov:iam::153771329827:user/Team-Kit-2586-2 is not authorized to perform: sts:AssumeRole
              on resource: arn:aws-us-gov:iam::153771329827:role/Kit-2586-Role"), extras: Some({"aws_request_id": "e9eb17c0-1727-4e96-be60-96cf5ca44a2f"}) }, meta:
ErrorMetadata { code: Some("AccessDenied"), message: Some("User: arn:aws-us-gov:iam::153771329827:user/Team-Kit-2586-2 is not authorized to perform: s
ts:AssumeRole on resource: arn:aws-us-gov:iam::153771329827:role/Kit-2586-Role"), extras: Some({"aws_request_id": "e9eb17c0-1727-4e96-be60-96cf5ca44a2
f"}) } }), raw: Response { status: StatusCode(403), headers: Headers { headers: {"x-amzn-requestid": HeaderValue { _private: H1("e9eb17c0-1727-4e96-be
60-96cf5ca44a2f") }, "x-amz-sts-extended-request-id": HeaderValue { _private: H1("MTp1cy1nb3Ytd2VzdC0xOjE3NTg3MjUyOTgzNzg6UjoyYUxERFJYYg==") }, "conte
nt-type": HeaderValue { _private: H1("text/xml") }, "content-length": HeaderValue { _private: H1("413") }, "date": HeaderValue { _private: H1("Wed, 24
 Sep 2025 14:48:18 GMT") }} }, body: SdkBody { inner: Once(Some(b"<ErrorResponse xmlns=\"https://sts.amazonaws.com/doc/2011-06-15/\">\n  <Error>\n
<Type>Sender</Type>\n    <Code>AccessDenied</Code>\n    <Message>User: arn:aws-us-gov:iam::153771329827:user/Team-Kit-2586-2 is not authorized to perf
orm: sts:AssumeRole on resource: arn:aws-us-gov:iam::153771329827:role/Kit-2586-Role</Message>\n  </Error>\n  <RequestId>e9eb17c0-1727-4e96-be60-96cf5
ca44a2f</RequestId>\n</ErrorResponse>\n")), retryable: true }, extensions: Extensions { extensions_02x: Extensions, extensions_1x: Extensions } } }) }
) }), connection: Unknown } }
```

DispatchFailure(
DispatchFailure {
source: ConnectorError {
kind: Other(None),
source: ProviderError(ProviderError {
source: ProviderError(ProviderError {
source: ServiceError(ServiceError {
source: Unhandled(Unhandled {
source: ErrorMetadata {
code: Some("AccessDenied"),
message: Some("User: arn:aws-us-gov:iam::153771329827:user/Team-Kit-2586-2 is not authorized to perform: sts:AssumeRole
on resource: arn:aws-us-gov:iam::153771329827:role/Kit-2586-Role"), extras: Some({"aws_request_id": "8055d1bd-c8d2-4191-b1a3-0b36873451d3"}) }, meta:
ErrorMetadata { code: Some("AccessDenied"), message: Some("User: arn:aws-us-gov:iam::153771329827:user/Team-Kit-2586-2 is not authorized to perform: s
ts:AssumeRole on resource: arn:aws-us-gov:iam::153771329827:role/Kit-2586-Role"), extras: Some({"aws_request_id": "8055d1bd-c8d2-4191-b1a3-0b36873451d
3"}) } }), raw: Response { status: StatusCode(403), headers: Headers { headers: {"x-amzn-requestid": HeaderValue { \_private: H1("8055d1bd-c8d2-4191-b1
a3-0b36873451d3") }, "x-amz-sts-extended-request-id": HeaderValue { \_private: H1("MTp1cy1nb3Ytd2VzdC0xOjE3NTg3MjU2MTc1MDE6UjpjOUVNOWluMg==") }, "conte
nt-type": HeaderValue { \_private: H1("text/xml") }, "content-length": HeaderValue { \_private: H1("413") }, "date": HeaderValue { \_private: H1("Wed, 24
Sep 2025 14:53:37 GMT") }} }, body: SdkBody { inner: Once(Some(b"<ErrorResponse xmlns=\"https://sts.amazonaws.com/doc/2011-06-15/\">\n <Error>\n
<Type>Sender</Type>\n <Code>AccessDenied</Code>\n <Message>User: arn:aws-us-gov:iam::153771329827:user/Team-Kit-2586-2 is not authorized to perf
orm: sts:AssumeRole on resource: arn:aws-us-gov:iam::153771329827:role/Kit-2586-Role</Message>\n </Error>\n <RequestId>8055d1bd-c8d2-4191-b1a3-0b368
73451d3</RequestId>\n</ErrorResponse>\n")), retryable: true }, extensions: Extensions { extensions_02x: Extensions, extensions_1x: Extensions } } }) }
) }), connection: Unknown } })

15 │ 2025-09-24 11:00:21.425097 -04:00 Failed to load objects: DispatchFailure(DispatchFailure { source: ConnectorError { kind: Other(None), source: Provid
│ erError(ProviderError { source: ProviderError(ProviderError { source: ServiceError(ServiceError { source: Unhandled(Unhandled { source: ErrorMetadata
│ { code: Some("AccessDenied"), message: Some("User: arn:aws-us-gov:iam::153771329827:user/Team-Kit-2586-2 is not authorized to perform: sts:AssumeRole
│ on resource: arn:aws-us-gov:iam::153771329827:role/Kit-2586-Role"), extras: Some({"aws_request_id": "842464bc-3966-49e9-bc64-f170bd102ee8"}) }, meta:
│ ErrorMetadata { code: Some("AccessDenied"), message: Some("User: arn:aws-us-gov:iam::153771329827:user/Team-Kit-2586-2 is not authorized to perform: s
│ ts:AssumeRole on resource: arn:aws-us-gov:iam::153771329827:role/Kit-2586-Role"), extras: Some({"aws_request_id": "842464bc-3966-49e9-bc64-f170bd102ee
│ 8"}) } }), raw: Response { status: StatusCode(403), headers: Headers { headers: {"x-amzn-requestid": HeaderValue { \_private: H1("842464bc-3966-49e9-bc
│ 64-f170bd102ee8") }, "x-amz-sts-extended-request-id": HeaderValue { \_private: H1("MTp1cy1nb3Ytd2VzdC0xOjE3NTg3MjYwMjEzODE6UjprZTdIZ1BWbg==") }, "conte
│ nt-type": HeaderValue { \_private: H1("text/xml") }, "content-length": HeaderValue { \_private: H1("413") }, "date": HeaderValue { \_private: H1("Wed, 24
│ Sep 2025 15:00:21 GMT") }} }, body: SdkBody { inner: Once(Some(b"<ErrorResponse xmlns=\"https://sts.amazonaws.com/doc/2011-06-15/\">\n <Error>\n
│ <Type>Sender</Type>\n <Code>AccessDenied</Code>\n <Message>User: arn:aws-us-gov:iam::153771329827:user/Team-Kit-2586-2 is not authorized to perf
│ orm: sts:AssumeRole on resource: arn:aws-us-gov:iam::153771329827:role/Kit-2586-Role</Message>\n </Error>\n <RequestId>842464bc-3966-49e9-bc64-f170b
│ d102ee8</RequestId>\n</ErrorResponse>\n")), retryable: true }, extensions: Extensions { extensions_02x: Extensions, extensions_1x: Extensions } } }) }
│ ) }), connection: Unknown } })

choco install -y pyenv-win

$env:PYENV=$env:USERPROFILE + "\.pyenv\pyenv-win\"
$env:PYENV_ROOT=$env:USERPROFILE + "\.pyenv\pyenv-win\"
$env:PYENV_HOME=$env:USERPROFILE + "\.pyenv\pyenv-win\"
$env:path = $env:PYENV_ROOT + "\bin;" + $env:PYENV_ROOT + "\shims;" + $env:path

pyenv update

pyenv install 3.12

pyenv global 3.12

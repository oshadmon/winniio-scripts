on error ignore

:set-params:
grpc_client_ip = 127.0.0.1
grpc_client_port = 50051
grpc_name = winniio-grpc1
grpc_dir = /app/winniio-scripts/
grpc_proto = edgemain
grpc_value = (message = all)
grpc_limit = 0
set grpc_ingest = true
set grpc_debug = false


grpc_service = Greeter
grpc_request = RequestMessage
grpc_function = StreamingMessage
grpc_response = message

:grpc-client:
on error goto grpc-client-error
<run grpc client where
    ip = !grpc_client_ip and port = !grpc_client_port and
    name = !grpc_name and
    grpc_dir = !grpc_dir and
    proto = !grpc_proto and
    function = !grpc_function and
    request = !grpc_request and
    response = !grpc_response and
    service = !grpc_service and
    value = !grpc_value and
    policy = !policy_id and
    dbms = !default_dbms and
    table = !table_name and
    debug = !grpc_debug and
    ingest = !grpc_ingest and
    limit = !grpc_limit
>

:end-script;
end script

:grpc-client-error:
echo Failed to set gRPC client
goto end-script




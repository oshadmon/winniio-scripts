#-----------------------------------------------------------------------------------------------------------------------
# Deploy process to accept data from KubeArmor
# Steps:
#   1. Compile proto file
#   2. Set params
#   3. gRPC client
#-----------------------------------------------------------------------------------------------------------------------
# process !anylog_path/deployment-scripts/grpc/kubearmor/deploy_kubearmor_healthcheck.al
on error ignore

# Compile proto file
#:compile-proto:
# on error goto compile-error
# compile proto where protocol_file=!anylog_path/deployment-scripts/grpc/kubearmor/kubearmor/kubearmor.proto

# Set Params
:set-params:
grpc_name = healthcheck1
grpc_client_ip = 10.0.0.228
grpc_client_port = 50051
grpc_dir = !anylog_path/winniio-scripts/grpc-test
grpc_proto = kubearmor
grpc_function = HealthCheck
grpc_request = NonceMessage
grpc_response = ReplyMessage
grpc_service = LogService
grpc_value = (nonce = 11.int)
set grpc_debug = true

:run-grpc-client:
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
    debug = true and
    limit = 1
>



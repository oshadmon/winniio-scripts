:set-params:
grpc_client_ip = kubearmor.kubearmor.svc.cluster.local
grpc_client_port = 32767
grpc_dir = !anylog_path/deployment-scripts/grpc/kubearmor/
grpc_proto = winniio
grpc_value = (Filter = all)
grpc_limit = 0
set grpc_ingest = true
set grpc_debug = false

grpc_service = LogService
grpc_request = RequestMessage

set alert_flag_1 = false
set alert_level = 0
ingestion_alerts = ''
table_name = bring [Operation]

# set default_dbms = kubearmor
# set company_name = kubearmor



:run-grpc-client:
grpc_name = kubearmor-message
grpc_function = WatchMessages
grpc_response = Message

process !anylog_path/deployment-scripts/grpc/kubearmor/kubearmor_message.al
process !anylog_path/deployment-scripts/grpc/kubearmor/grpc_client.al

grpc_name = kubearmor-alert
grpc_function = WatchAlerts
grpc_response = Alert

process !anylog_path/deployment-scripts/grpc/kubearmor/kubearmor_alert.al
process !anylog_path/deployment-scripts/grpc/kubearmor/grpc_client.al

grpc_name = kubearmor-logs
grpc_function = WatchLogs
grpc_response = Logs
process !anylog_path/deployment-scripts/grpc/kubearmor/kubearmor_log.al
process !anylog_path/deployment-scripts/grpc/kubearmor/grpc_client.al

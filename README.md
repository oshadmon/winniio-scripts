# winniio-scripts

## files 
```tree
winnio-scripts 
├── README.md
├── compile.py <-- code to compile proto file
├── grpc_client.al <-- gRPC client 
├── policy.al  <-- EdgeLake / AnyLog policy for mapping data, the same policy is used for both Kafaka and gRPC 
├── winniio.proto <-- protocol file
└── kafka_client.al <-- kafka client
```

## Preparing Docker Container
Since WinniIO scripts are **not** part of the deployment process we need to  


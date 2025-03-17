# GRPC

## General Steps 
1. Access the Docker or Kubernetes volume & compile the relevant _proto_ file(s)
2. Set params associated with protocol based (_gRPC_) process
3. Declare policy (not needed for _HealthCheck_)
4. run _gRPC_ client

## Example 
The following example is using the Kubearmor protocol file, which provides both standard data coming and an _HealthCheck_.

1. Access the Docker or Kubernetes volume & compile the relevant _proto_ file(s)
This step will soon be deprecated and replaced by a command within AnyLog 
```shell
python3 /app/deployment-scripts/grpc/compile.py /app/deployment-scripts/grpc/kubearmor/kubearmor.proto
```

2. Access the Docker or Kubernetes volume &  update params for kubernetes
* [HealthCheck](kubearmor/deploy_kubearmor_healthcheck.al) - /app/deployment-scripts/grpc/kubearmor/deploy_kubearmor_healthcheck.al
* [System](kubearmor/deploy_kubearmor_system.al) - /app/deployment-scripts/grpc/kubearmor/deploy_kubearmor_system.al

3. Attach into the AnyLog instance & run
* HealthCheck
```anylog 
process $ANYLOG_PATH/deployment-scripts/grpc/kubearmor/deploy_kubearmor_healthcheck.al 
```
* System
```anylog
process $ANYLOG_PATH/deployment-scripts/grpc/kubearmor/deploy_kubearmor_system.al
```

## Dummy Server
In the case where a user does not want to deploy a Kubearmor, they can simply deploy our [dummy_kube_server.py](dummy_kube_server.py), 
which imitates an active Kuberamor instance. Please make sure to [compile kubearmor.proto](#L12) before starting the server. 


```shell
python3 dummy_kube_server.py [--port 50051] 
```


# WinniIO Scripts

The following provides directions for deploying either a _Kafka_ or _gRPC_ consumer for WinniIO. 
This document will cover: 
1. adding repository as a docker volume 
2. deploying _Kafka_ consumer 
3. deploying _gRPC_ client 

### File Structure 
```tree
winnio-scripts 
├── README.md
├── grpc-orig/ <-- origianl code from Grpc.zip  
├── grpc-test/ <-- health check to validate gRPC is working
├── compile.py <-- code to compile proto file
├── grpc_client.al <-- gRPC client 
├── policy.al  <-- EdgeLake / AnyLog policy for mapping data, the same policy is used for both Kafaka and gRPC 
├── winniio.proto <-- protocol file
└── kafka_consumer.al <-- kafka client
```

## Preparing Docker Container
Since WinniIO scripts are **not** part of the deployment process we need to add them to be accessible through the 
docker-compose. This should be done only on the node(s) accepting the data - operator or publisher. 

1. clone this repository
```shell
cd $HOME/ 
git clone https://github.com/oshadmon/winniio-scripts 
```

2. Clone docker-compose 
```shell
cd $HOME/
git clone -b makefile-patch https://github.com/EdgeLake/docker-compose/
```

3. Update [Operator configs](https://github.com/EdgeLake/docker-compose/blob/makefile-patch/docker-makefiles/edgelake_operator.env)

4. Update docker-compose-template-base.yaml to have winniio-scripts as a volume
```yaml
services:
  ${NODE_NAME}:
    image: ${IMAGE}:${TAG}
    restart: always
    env_file:
      - ../docker-makefiles/${ANYLOG_TYPE}-configs/base_configs.env
      - ../docker-makefiles/${ANYLOG_TYPE}-configs/advance_configs.env
      - .env
    container_name: ${NODE_NAME}
    stdin_open: true
    tty: true
    network_mode: host
    volumes:
      - ${NODE_NAME}-anylog:/app/AnyLog-Network/anylog
      - ${NODE_NAME}-blockchain:/app/AnyLog-Network/blockchain
      - ${NODE_NAME}-data:/app/AnyLog-Network/data
      - ${NODE_NAME}-local-scripts:/app/deployment-scripts
      - ${HOME}/winniio-scripts:/app/winniio-scripts  # Mount local directory - make sure to have a full path for ${HOME} value

volumes:
  ${NODE_NAME}-anylog:
  ${NODE_NAME}-blockchain:
  ${NODE_NAME}-data:
  ${NODE_NAME}-local-scripts:
```

5. Start operator node 
```shell
cd $HOME/docker-compose
make up EDGELAKE_TYPE=operator
```

## Deploy Kafka Consumer 
1. Attach to EdgeLake container 
```shell
cd $HOME/docker-compose 
make attach EDGELAKE_TYPE=operator
```

2. Execute Kafka consumer
   * Create [policy](pillback_policy.al) if doesn't exist
   * Connect to [Kafka consumer](kafka_consumer.al)
```shell
process /app/winnio-scripts/kafka_consumer.al
``` 

3. Validate data coming in 
```anylog
# view active message client 
get msg client 

# see amount of data coming in 
get streaming 

# see data stored into Operator
get operator
```

## Default gRPC Server-Client setup
The directory [grpc-orig](grpc-orig) contains the commands for a server-client gRPC used by Hossein by default.
1. Install python3 and requirements for compiling proto file
```shell
sudo apt-get -y install python3-pip 
python3 -m pip install --upgrade pip 
python3 -m pip install --upgrade -r ./requirements.txt 
```

2. Update [.env](grpc-orig/.env) with correct values

3. compile [edgemain.proto](grpc-orig/edgemain.proto) protocol file 
```shell
python3 compile.py grpc-orig/edgemain.proto
```

4. Run [test_server.py](grpc-orig/test_server.py) - changes made: 
* call [.env](grpc-orig/.env) directly 
* clean try / catch behavior 
```shell
python3 grpc-orig/test_server.py)
```

5. Run [test_client.py](grpc-orig/test_client.py) - changes made: 
* call [.env](grpc-orig/.env) directly 
```shell
python3 grpc-orig/test_client.py
```
**Expect**: Data coming from server would be seen on client 
**Actual**: Nothing comes from server / nothing sent to client


## Deploy gRPC Health Check
Validate the gRPC is working properly against the correct IP and port. 

1. Install python3 and requirements for compiling proto file
```shell
sudo apt-get -y install python3-pip 
python3 -m pip install --upgrade pip 
python3 -m pip install --upgrade -r ./requirements.txt 
```

2. Compile [protocol file](grpc-test/kubearmor.proto)
```shell
python3 $HOME/winniio-scripts/compile.py $HOME/winniio-scripts/grpc-test/kubearmor.proto
```

3. Run gRPC  [dummy_kubearmor_server.py](grpc-test/dummy_kubearmor_server.py) - I recommend using the IP and ports 
that would be used with your gRPC server setup.  
credentials to be the same as 
```shell
python3 $HOME/winniio-scripts/grpc-test/deploy_kubearmor_healthcheck.al --host [IP Info] --port  [Port Info]
```

4. Update `grpc_client_ip` and `grpc_client_port` in [deploy_kubearmor_healthcheck.al](grpc-test/deploy_kubearmor_healthcheck.al) to match step 3

5. In AnyLog / EdgeLake, run [deploy_kubearmor_healthcheck.al](grpc-test/deploy_kubearmor_healthcheck.al)
```anylog
process /app/winniio-scripts/grpc-test/deploy_kubearmor_healthcheck.al
```

**Expect Behavior**:
```anylog
AL anylog-operator1 +> process winniio-scripts/grpc-test/deploy_kubearmor_healthcheck.al
[gRPC] [set] [attr name: 'nonce'] [attr value: '11']
```

## Deploy gRPC Consumer
1. Install python3 and requirements for compiling proto file
```shell
sudo apt-get -y install python3-pip 
python3 -m pip install --upgrade pip 
python3 -m pip install --upgrade -r ./requirements.txt 
```

2. Compile [protocol file](winniio.proto)
```shell
python3 $HOME/winniio-scripts/compile.py $HOME/winniio-scripts/winniio.proto

<<COMMENT
# Output
winnio-scripts 
├── compile.py <-- code to compile proto file
├── winniio.proto <-- protocol file
├── winniio_pb2.py <-- compiled protocol file 
└── winniio_pb2_grpc.py <-- compiled protocol file 
<<
```

3. In [grpc_client.py](grpc_client.al) validate the following params: 
   * grpc_client_ip
   * grpc_client_port

3. Attach to EdgeLake container 
```shell
cd $HOME/docker-compose 
make attach EDGELAKE_TYPE=operator
```

4. Run gRPC client
   * Create [policy](pillback_policy.al) if doesn't exist
   * Connect to [gRPC client](grpc_client.al)
```anylog
process /app/winnio-scripts/grpc_client.al
```

5. Validate 
```anylog
# view active message client 
get grpc clients  

# see amount of data coming in 
get streaming 

# see data stored into Operator
get operator
```

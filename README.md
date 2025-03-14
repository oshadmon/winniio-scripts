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
├── compile.py <-- code to compile proto file
├── grpc_client.al <-- gRPC client 
├── policy.al  <-- EdgeLake / AnyLog policy for mapping data, the same policy is used for both Kafaka and gRPC 
├── winniio.proto <-- protocol file
└── kafka_client.al <-- kafka client
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
      - ${HOME}/winnio-scripts:/app/winnio-scripts  # Mount local directory - make sure to have a full path for ${HOME} value

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
   * Create [policy](policy.al) if doesn't exist
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
   * Create [policy](policy.al) if doesn't exist
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
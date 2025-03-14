# WinniIO Scripts

The following provides directions to deploying either a [Kafka]() or [gRPC]() consumer for WinniIO. 
This document will cover: 
1. adding repository as a docker volume 
2. deploying Kafka consumer 
3. deploying gRPC consumer 

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
      - ${HOME}/winnio-scripts:/app/winnio-scripts  # Mount local directory

volumes:
  ${NODE_NAME}-anylog:
  ${NODE_NAME}-blockchain:
  ${NODE_NAME}-data:
  ${NODE_NAME}-local-scripts:
```

5. Start operator node 
```shell
make up EDGELAKE_TYPE=operator
```


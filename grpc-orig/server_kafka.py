import os
import zlib
# import json
import grpc
import time
import threading
from google.protobuf.json_format import MessageToJson
from google.protobuf.message import DecodeError
from kafka import KafkaConsumer
from concurrent import futures
import edgemain_pb2  # Generated Python file from the .proto
import edgemain_pb2_grpc
from dotenv import load_dotenv

# Load environment variables
DOTENV = os.path.join(os.path.dirname(__file__), '.env')
if not os.path.isfile(DOTENV):
    raise FileNotFoundError(DOTENV)
load_dotenv(DOTENV)

# Kafka parameters
KAFKA_BOOTSTRAP_SERVERS = os.getenv('KAFKA_BOOTSTRAP_SERVERS')
KAFKA_GROUP_ID = os.getenv('KAFKA_GROUP_ID')
KAFKA_TOPIC = os.getenv('KAFKA_TOPIC')

# gRPC connection parameters
TCP_IP_gRPC = os.getenv('GRPC_SERVER_IP')
TCP_PORT_gRPC = int(os.getenv('GRPC_SERVER_PORT'))

json_message = []  # Global variable to store the latest JSON messages


def read_from_kafka():
    """Reads data from a Kafka topic."""
    global json_message
    consumer = KafkaConsumer(
        KAFKA_TOPIC,
        bootstrap_servers=[KAFKA_BOOTSTRAP_SERVERS],
        group_id=KAFKA_GROUP_ID,
        auto_offset_reset='latest',
        enable_auto_commit=True,
        value_deserializer=lambda x: x  # Raw bytes
    )

    for msg in consumer:
        decompressed_data = decompress_data(msg.value)
        if decompressed_data:
            message = process_message(decompressed_data)
            if message:
                json_message.append(message)
                print(f"Updated JSON Message: {message}")


def decompress_data(data):
    """Decompresses the incoming data."""
    try:
        return zlib.decompress(data)
    except OSError as e:
        print(f"Decompression error: {e}")
        return None


def process_message(data):
    """Processes the protobuf message and returns a JSON representation."""
    try:
        message = edgemain_pb2.NetPacket()
        message.ParseFromString(data)
        return MessageToJson(message)
    except DecodeError as e:
        print(f"Decode error: {e}")
        return None


def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    edgemain_pb2_grpc.add_GreeterServicer_to_server(GreeterServicer(), server)
    server.add_insecure_port(f"{TCP_IP_gRPC}:{TCP_PORT_gRPC}")
    server.start()
    server.wait_for_termination()


class GreeterServicer(edgemain_pb2_grpc.GreeterServicer):
    def StreamingMessage(self, request, context):
        global json_message
        while True:
            if json_message:
                for message in json_message:
                    message_reply = edgemain_pb2.ReplyMessage()
                    message_reply.message = message
                    yield message_reply
                json_message = []
            time.sleep(1)


if __name__ == '__main__':
    grpc_thread = threading.Thread(target=serve)
    grpc_thread.start()

    kafka_thread = threading.Thread(target=read_from_kafka)
    kafka_thread.start()

    grpc_thread.join()
    kafka_thread.join()

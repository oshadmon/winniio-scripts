import os
import socket
import zlib
import edgemain_pb2  # Generated Python file from the .proto
from google.protobuf.json_format import MessageToJson
from google.protobuf.message import DecodeError
import time
import json
import grpc
import edgemain_pb2
import edgemain_pb2_grpc    
from dotenv import load_dotenv

from concurrent import futures
import threading

load_dotenv()
# TCP connection parameters
TCP_IP = os.getenv('TCP_IP')
TCP_PORT = int(os.getenv('TCP_PORT'))
# gRPC connection parameters
TCP_IP_gRPC = os.getenv('GRPC_SERVER_IP')
TCP_PORT_gRPC = int(os.getenv('GRPC_SERVER_PORT'))
TCP_BUFFER_SIZE = int(os.getenv('TCP_BUFFER_SIZE'))

json_message = []  # Global variable to store the latest JSON messages


def read_from_tcp():
    """Reads data from the remote TCP port."""
    global json_message
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((TCP_IP, TCP_PORT))
    try:
        while True:
            data = s.recv(TCP_BUFFER_SIZE)  # Adjust the buffer size as needed
            if not data:
                break
            decompressed_data = decompress_data(data)
            if decompressed_data:
                message = process_message(decompressed_data)
                if message:
                    json_message.append(message)
                    print(f"Updated JSON Message: {message}")
    except socket.error as e:
        print(f"Socket error: {e}")
    finally:
        s.close()


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
        # Convert protobuf message to JSON and return it as a string
        return MessageToJson(message)  # Convert the protobuf message to JSON string
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
        print("Client send the request:")
        global json_message
        
        while True:
            if json_message:
                for message in json_message:
                    message_reply = edgemain_pb2.ReplyMessage()
                    message_reply.message = message  # Send the JSON string directly
                    yield message_reply
                json_message = []  # Reset json_message after sending all messages
            time.sleep(1)  # Check for new message every second


# Function to generate client stream requests
def get_client_stream_requests():
    while True:
        name = input("Please enter a name (or nothing to stop chatting): ")

        if name == "":
            break

        hello_request = edgemain_pb2.HelloRequest(greeting="Hello", name=name)
        yield hello_request
        time.sleep(1)

# Function to run the gRPC client
def run():
    with grpc.insecure_channel('localhost:50051') as channel:
        stub = edgemain_pb2_grpc.GreeterStub(channel)
        
        # Sending a message request and receiving streaming responses
        message_request = edgemain_pb2.ReplyMessage(message="Streaming")
        message_replies = stub.StreamingMessage(message_request)
        
        for message_reply in message_replies:
            message_reply_json = message_reply.message  # JSON string received from server
            print(json.dumps(json.loads(message_reply_json), indent=2))

if __name__ == '__main__':
    # Start the gRPC server in a separate thread
    grpc_thread = threading.Thread(target=serve)
    grpc_thread.start()
    
    # Start reading from TCP in a separate thread
    tcp_thread = threading.Thread(target=read_from_tcp)
    tcp_thread.start()
    
    # Wait for threads to finish
    grpc_thread.join()
    tcp_thread.join()

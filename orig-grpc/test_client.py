import edgemain_pb2
import edgemain_pb2_grpc
import grpc
import time
import json
import os


# Function to run the gRPC client
def run():
    TCP_IP_gRPC = os.getenv('GRPC_SERVER_IP')
    TCP_PORT_gRPC = int(os.getenv('GRPC_SERVER_PORT'))
    with grpc.insecure_channel(f"{TCP_IP_gRPC}:{TCP_PORT_gRPC}") as channel:
        stub = edgemain_pb2_grpc.GreeterStub(channel)
        
        # Sending a message request and receiving streaming responses
        message_request = edgemain_pb2.ReplyMessage(message="Streaming")
        message_replies = stub.StreamingMessage(message_request)
        
        for message_reply in message_replies:
            # The message_reply.message is a JSON string received from the server
            message_reply_json = message_reply.message  # Already a JSON string
            # Parse the JSON string and pretty-print it
            parsed_json = json.loads(message_reply_json)
            print(f"Received Data :  {json.dumps(parsed_json, indent=2)}")  # Pretty print the JSON

# Main execution block
if __name__ == "__main__":

    run()

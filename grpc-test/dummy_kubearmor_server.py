from concurrent import futures
import grpc
import kubearmor_pb2
import kubearmor_pb2_grpc

class DummyKubeServer(kubearmor_pb2_grpc.LogServiceServicer, kubearmor_pb2_grpc.PushLogServiceServicer):
    def HealthCheck(self, request, context):
        return kubearmor_pb2.ReplyMessage(Retval=0)


def serve(conn_info: str = "[::]:50051"):
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    kubearmor_pb2_grpc.add_LogServiceServicer_to_server(DummyKubeServer(), server)
    kubearmor_pb2_grpc.add_PushLogServiceServicer_to_server(DummyKubeServer(), server)

    server.add_insecure_port(conn_info)
    server.start()
    print(f"Dummy Kube Server is running on {conn_info}...")
    server.wait_for_termination()


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", type=str, default="[::]", help="Host to bind the server")
    parser.add_argument("--port", type=int, default=50051, help="Port to bind the server")
    args = parser.parse_args()
    serve(f"{args.host}:{args.port}")

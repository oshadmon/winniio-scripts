from concurrent import futures
import grpc
import kubearmor_pb2
import kubearmor_pb2_grpc

class DummyKubeServer(kubearmor_pb2_grpc.LogServiceServicer, kubearmor_pb2_grpc.PushLogServiceServicer):
    def HealthCheck(self, request, context):
        return kubearmor_pb2.ReplyMessage(Retval=0)

def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    kubearmor_pb2_grpc.add_LogServiceServicer_to_server(DummyKubeServer(), server)
    kubearmor_pb2_grpc.add_PushLogServiceServicer_to_server(DummyKubeServer(), server)
    server.add_insecure_port('[::]:50051')
    server.start()
    print("Dummy Kube Server is running on port 50051...")
    server.wait_for_termination()

if __name__ == "__main__":
    serve()

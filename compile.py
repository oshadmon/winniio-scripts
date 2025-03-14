"""
The following  script, compiles a protocol file to be used by AnyLog

requirements:
- grpcio-tools

command: may need to run with sudo when running in a docker volume
python3 compile.py dummy/dummy.proto
"""
import argparse
import os.path

from grpc_tools import protoc

parse = argparse.ArgumentParser()
parse.add_argument('proto_file', type=str, default=os.path.join(os.path.dirname(__file__), 'dummy', 'dummy.proto'))
args = parse.parse_args()

proto_file_path = os.path.expanduser(os.path.expandvars(args.proto_file))
proto_dir_path = os.path.dirname(proto_file_path)
if not os.path.isfile(proto_file_path):
    print(f"Failed to locate protocol file {proto_file_path}")
    exit(1)


# Use protoc to generate Python files
protoc.main(
    (
        "",
        f"-I{proto_dir_path}",
        f"--python_out={proto_dir_path}",
        f"--grpc_python_out={proto_dir_path}",
        f"{proto_file_path}",
    )
)

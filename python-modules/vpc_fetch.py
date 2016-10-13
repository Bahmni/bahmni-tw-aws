import json
import sys
from boto.vpc import VPCConnection
from boto.vpc import VPC

cidr_name_map = json.loads(sys.argv[1])
vpc_account_id = json.loads(sys.argv[2])
vpc_connection = VPCConnection()

def get_vpc_facts():
   vpc_list = vpc_connection.get_all_vpcs()
   vpcs = dict()

   for vpc in vpc_list:
       if cidr_name_map.get(vpc.cidr_block):
           vpc_tag = cidr_name_map[vpc.cidr_block]
           vpc_details = dict()
           vpc_details["id"] = vpc.id
           vpc_details["tag"] = vpc_tag
           vpc_details["cidr"] = vpc.cidr_block
           vpc_details["state"] = vpc.state
           vpc_details["is_default"] = vpc.is_default
           vpc_details["account_id"] = vpc_account_id
           vpcs =  vpc_details
   return json.dumps(vpcs)

print get_vpc_facts()
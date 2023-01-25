import boto3

ec2 = boto3.client('ec2')

response = ec2.describe_network_interfaces(Filters=[{'Name': 'status', 'Values': ['available']}])

for interface in response['NetworkInterfaces']:
    ec2.delete_network_interface(NetworkInterfaceId=interface['NetworkInterfaceId'])

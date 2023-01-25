import boto3, json
from botocore.vendored import requests
import json

asg_client = boto3.client('autoscaling')
ec2_client = boto3.client('ec2')

def lambda_handler(event, context):
    AutoScalingGroupName = event['AsgName']
    asg_response = asg_client.describe_auto_scaling_groups(AutoScalingGroupNames=[AutoScalingGroupName])
    instance_ids = []

    for i in asg_response['AutoScalingGroups']:
        for k in i['Instances']:
            instance_ids.append(k['InstanceId'])

    print("Terminating instance_ids:")
    print (instance_ids)
    
    if instance_ids != []:
        ec2_client.terminate_instances(InstanceIds = instance_ids)

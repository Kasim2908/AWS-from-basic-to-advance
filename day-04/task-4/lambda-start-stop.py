import boto3
import os

ec2 = boto3.client('ec2')
region = os.environ.get('AWS_REGION', 'us-east-1')

def lambda_handler(event, context):
    action = event.get('action', 'stop')  # 'start' or 'stop'
    tag_key = event.get('tag_key', 'AutoStartStop')
    tag_value = event.get('tag_value', 'true')
    
    # Find instances with specific tag
    filters = [
        {'Name': f'tag:{tag_key}', 'Values': [tag_value]},
        {'Name': 'instance-state-name', 'Values': ['running' if action == 'stop' else 'stopped']}
    ]
    
    instances = ec2.describe_instances(Filters=filters)
    instance_ids = []
    
    for reservation in instances['Reservations']:
        for instance in reservation['Instances']:
            instance_ids.append(instance['InstanceId'])
    
    if not instance_ids:
        return {
            'statusCode': 200,
            'body': f'No instances to {action}'
        }
    
    # Perform action
    if action == 'stop':
        ec2.stop_instances(InstanceIds=instance_ids)
        message = f'Stopped instances: {instance_ids}'
    elif action == 'start':
        ec2.start_instances(InstanceIds=instance_ids)
        message = f'Started instances: {instance_ids}'
    else:
        return {
            'statusCode': 400,
            'body': 'Invalid action. Use "start" or "stop"'
        }
    
    print(message)
    return {
        'statusCode': 200,
        'body': message
    }

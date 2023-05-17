import boto3

session = boto3.Session(
        aws_access_key_id='',
        aws_secret_access_key='',
        region_name='ap-south-1'
    )

def create_cpu_alarm(instance_id, session):
    
    cloudwatch = session.client('cloudwatch')

    response = cloudwatch.put_metric_alarm(
        AlarmName='CPU_Utilization_' + instance_id,
        ComparisonOperator='GreaterThanThreshold',
        EvaluationPeriods=5,
        MetricName='CPUUtilization',
        Namespace='AWS/EC2',
        Period=60,
        Statistic='Average',
        Threshold=80.0,
        ActionsEnabled=True,
        AlarmDescription='Alarm when server CPU exceeds 80%',
        Dimensions=[
            {
              'Name': 'InstanceId',
              'Value': instance_id
            },
        ],
        Unit='Percent'
    )

    print(response)

# Replace 'your_instance_id' with your actual EC2 instance ID
create_cpu_alarm('instance_id', session) 

import boto3
import json
import os

def lambda_handler(event, context):

    ses_client = boto3.client('ses', region_name='us-east-1')

    bucket_name = event['Records'][0]['s3']['bucket']['name']
    object_name = event['Records'][0]['s3']['object']['key']

    email_body =   ses_client.send_email(
        Source=os.environ['SENDER_EMAIL'],
        Destination={
            'ToAddresses': [os.environ['RECEIVER_EMAIL']]
        },
        Message={
            'Subject': {
                'Data': 'Terraform State Update Notification'
            },
            'Body': {
                'Text': {
                    'Data': email_body
                }
            }
        }
    )

    print("Email sent successfully")

    return {
        'statusCode': 200,
        'body': json.dumps('Notification sent')
    }
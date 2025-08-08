import json
import boto3
import datetime
from decimal import Decimal
# import requests

dynamodb = boto3.resource('dynamodb', region_name='ap-south-1')
table = dynamodb.Table("github-repo-data")

def lambda_handler(event, context):

    valid_request = True if "username" in event else False

    if not valid_request:
        return {
            'statusCode': 500,
            'body': json.dumps({"message": "Invalid request. Missing username"})
        }

    try:
        username = event['username']
        
        response = table.query(
            KeyConditionExpression=boto3.dynamodb.conditions.Key('username').eq(username)
        )
        print("DDB response ----",response)
    
        body = {}
        body['Items'] = response['Items']
        
        response = {
            'statusCode': 200,
            'body': json.dumps(body, default=decimal_to_float)
        }
    except Exception as err:
        print(f'Error occured during dynamodb get data username: {username}, error: {err}')
        response = {
            "statusCode": 500,
            "body": json.dumps({
                "message": f"Error {err}"
            })
        }
    return response

def decimal_to_float(obj):
    """Convert Decimal objects to float for JSON serialization."""
    if isinstance(obj, Decimal):
        return float(obj)
    raise TypeError

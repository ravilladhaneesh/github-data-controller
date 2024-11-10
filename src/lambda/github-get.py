import json
import boto3
import datetime
from decimal import Decimal
# import requests


def lambda_handler(event, context):

    if event["username"]:
        username = event["username"]

    else:
        username = "ravilladhaneesh"

    try:
        

        dynamodb = boto3.resource('dynamodb', region_name='ap-south-1')
        #print("----",dynamodb)
        table = dynamodb.Table("github-repo-data")
        #print("----",table)
        
        response = table.query(
            KeyConditionExpression=boto3.dynamodb.conditions.Key('username').eq(username)
        )
        print("----",response)
        item = response['Items']
        #print(item)
    
        body = {}
        body['Items'] = item
        #print(body)
        #print(json.dump(body, default=decimal_to_float))
        return {
            'statusCode': 200,
            'body': json.dumps(body, default=decimal_to_float)
        }
    except Exception as err:
        print(f'github-viewer Cloudfront invalidation exception {err}')
        return {
            "statusCode": 500,
            "body": json.dumps({
                "message": f"Error {err}"
            })
        }


def decimal_to_float(obj):
    """Convert Decimal objects to float for JSON serialization."""
    if isinstance(obj, Decimal):
        return float(obj)
    raise TypeError
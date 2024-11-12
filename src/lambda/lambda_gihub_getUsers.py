import json
import boto3
# import requests


def lambda_handler(event, context):


    try:
        # Initialize DynamoDB client
        dynamodb = boto3.resource('dynamodb', region_name='ap-south-1')
        table = dynamodb.Table("github-repo-data")

        users = set()

        # Scan the table
        response = table.scan()

        # Loop through items and collect unique partition keys
        for item in response.get('Items', []):
            users.add(item['username'])

        # Handle pagination in case the table has more items
        while 'LastEvaluatedKey' in response:
            response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
            for item in response.get('Items', []):
                users.add(item['username'])

        # Print all unique partition keys
        #print(users)

        return {
        "statusCode": 200,
        "body": json.dumps({
            "users": list(users),
        })
    }


    except Exception as e:
        print("Exception: ", e)
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': str(e)
            })
        }
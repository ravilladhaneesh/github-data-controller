import json
import boto3
from decimal import Decimal
import os

dynamodb = boto3.resource('dynamodb', region_name='ap-south-1')
table = dynamodb.Table('github-repo-data')
PUT_LIMIT = int(os.environ.get('PUT_LIMIT', 5))

def present_items_of_user(username):
    response = table.query(
        KeyConditionExpression=boto3.dynamodb.conditions.Key('username').eq(username))
    
    return response.get("Items", {})


def put_data_to_dynamodb(event):
    decimal_languages = languages_to_decimal_type(event["body"]["languages"])
    username = event["body"]['username']
    reponame = event["body"]['reponame']
    
    print(table)
    response = table.put_item(
        Item={
            'username': username,
            'repo_name': reponame,
            "languages": decimal_languages,
            "repo_url": event["body"]["url"],
            "branch": event["body"]["branch"],
            "is_private_repo": event["body"]["is_private"]
        }
    )
    return response

    
def lambda_handler(event, context):
    
    is_valid = validate_event(event)

    if not is_valid:
        return {
            'statusCode': 400,
            'message': "Invalid request"
        }
    
    try:
        new_repo = True
        present_items = present_items_of_user(event["body"]["username"])
        for item in present_items:
            if item['repo_name'] == event["body"]["reponame"]:
                new_repo = False
        if new_repo and len(present_items) >= PUT_LIMIT:
            return {
                'statusCode': 429,
                'message': "Max limit reached"
            }
        
        response = put_data_to_dynamodb(event)
        if response['ResponseMetadata']['HTTPStatusCode'] == 200:

            return {
                "statusCode": 200,
                "body": f"Successfully put Data for username: {event['body']['username']}, repo: {event['body']['reponame']}."
            }
        else:
            raise Exception(f"Unable to put data for username: {event['body']['username']}, repo: {event['body']['reponame']}.")

        
    except Exception as e:
        print("Exception: ", e)
        message = f"Exception {e}"
        
        return {
                "statusCode": 500,
                "message": message
            }
    

def validate_event(event):
    
    if "body" not in event:
        return False
    
    required_fields = ["username", "reponame", "url", "languages", "branch", "is_private"]
    for field in required_fields:
        if field not in event["body"]:
            return False
    return True


def languages_to_decimal_type(languages):
    dec_languages = {}
    for lang in languages:
        dec_languages[lang] = Decimal(str(languages[lang]))
    return dec_languages
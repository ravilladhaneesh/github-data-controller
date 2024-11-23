import json
import boto3
# import requests
from decimal import Decimal

def lambda_handler(event, context):
    
    is_valid = validate_event(event)

    if not is_valid:
        return {
            'statusCode': 400,
            'message': "Invalid request"
        }
    
    try:
        decimal_languages = languages_to_decimal_type(event["body"]["languages"])
        username = event["body"]['username']
        reponame = event["body"]['reponame']

        dynamodb = boto3.resource('dynamodb', region_name='ap-south-1')
        table = dynamodb.Table('github-repo-data')

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
        
        if response['ResponseMetadata']['HTTPStatusCode'] == 200:

            return {
                "statusCode": 200,
                "body": f"Successfully put Data for username: {username}, repo: {reponame}."
            }
        else:
            raise Exception(f"Unable to put data for username: {username}, repo: {reponame}.")


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
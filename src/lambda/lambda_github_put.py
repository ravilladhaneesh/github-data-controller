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
    decimal_languages = languages_to_decimal_type(event["languages"])
    username = event['username']
    reponame = event['reponame']
    try:
        dynamodb = boto3.resource('dynamodb', region_name='ap-south-1')
        table = dynamodb.Table('github-repo-data')

        response = table.put_item(
            Item={
                'username': username,
                'repo_name': reponame,
                "languages": decimal_languages,
                "repo_url": event["url"],
                "branch": event["branch"],
                "is_private_repo": event["is_private"]
            }
        )
        # print("dec languages:", decimal_languages)
        # print(response)
        if response['ResponseMetadata']['HTTPStatusCode'] == 200:

            return {
                "statusCode": 200,
                "body": f"Successfully put Data for username: {username}, repo: {reponame}"
            }
        else:
            raise Exception(f"Unable to put data for username: {username}, repo: {reponame}")


    except Exception as e:
        print("Exception: ", e)
        return {
            "statusCode": 500,
            "body": json.dumps({
                "message": f"Error {str(e)}"
            })
        }
    

def validate_event(event):
    
    if "username" not in event:
        return False
    if "reponame" not in event:
        return False
    
    return True

def languages_to_decimal_type(languages):
    dec_languages = {}
    for lang in languages:
        dec_languages[lang] = Decimal(languages[lang])
    return dec_languages
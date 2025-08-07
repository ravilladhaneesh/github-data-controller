data "archive_file" "getUsers-lambda-source" {
  type        = "zip"
  source_file = "../src/lambda/lambda_github_getUsers.py"
  output_path = "../files/lambda/lambda_github_getUsers.zip"

}


resource "aws_lambda_function" "lambda-getUsers" {
  filename      = data.archive_file.getUsers-lambda-source.output_path
  function_name = "github-repo-getUsers-func"
  role          = aws_iam_role.lambda-get-role.arn
  handler       = "lambda_github_getUsers.lambda_handler"
  runtime       = "python3.12"
  timeout       = 10

  environment {
    variables = {
      DDB_TABLE_NAME = ""
    }
  }

  source_code_hash = filebase64sha256(data.archive_file.getUsers-lambda-source.output_path)

}
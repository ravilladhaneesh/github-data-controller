data "archive_file" "get-lambda-source" {
  type        = "zip"
  source_file = "../src/lambda/lambda_github_get.py"
  output_path = "../files/lambda/lambda_github_get.zip"

}


resource "aws_lambda_function" "lambda-get" {
  filename      = data.archive_file.get-lambda-source.output_path
  function_name = "github-repo-get-func"
  role          = aws_iam_role.lambda-get-role.arn
  handler       = "lambda_github_get.lambda_handler"
  runtime       = "python3.12"
  timeout       = 10

  environment {
    variables = {
      DDB_TABLE_NAME = ""
    }
  }
    source_code_hash = filebase64sha256(data.archive_file.get-lambda-source.output_path)

}
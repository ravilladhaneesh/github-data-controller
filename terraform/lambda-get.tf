data "archive_file" "get-lambda-source" {
  type        = "zip"
  source_file = "../src/lambda/github-get.py"
  output_path = "../files/lambda/github-get.zip"

}


resource "aws_lambda_function" "lambda-get" {
  filename = data.archive_file.get-lambda-source.output_path
  function_name     = "github-repo-get-func"
  role = aws_iam_role.lambda-get-role.arn
  handler  = "github-get.lambda_handler"
  runtime  = "python3.12"
  timeout  = 10

  environment {
    variables = {
      DDB_TABLE_NAME = ""
    }
  }

}
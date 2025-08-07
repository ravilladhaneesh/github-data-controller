data "archive_file" "lambda-put-source-zip" {
  type        = "zip"
  source_file = "../src/lambda/lambda_github_put.py"
  output_path = "../files/lambda/lambda_github_put.zip"
}


resource "aws_lambda_function" "lambda_github_put" {
  function_name = "github-put"
  role          = aws_iam_role.lambda-get-role.arn
  filename      = data.archive_file.lambda-put-source-zip.output_path
  timeout       = 20
  handler       = "lambda_github_put.lambda_handler"
  runtime       = "python3.12"

  environment {
    variables = {
      "DDB_TABLE_NAME" = "",
      "PUT_LIMIT"      = "5"
    }
  }

}
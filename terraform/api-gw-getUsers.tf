
resource "aws_api_gateway_resource" "test-api-res-getUsers" {
  parent_id   = aws_api_gateway_rest_api.test-api-tf.root_resource_id
  path_part   = "getUsers"
  rest_api_id = aws_api_gateway_rest_api.test-api-tf.id
}

resource "aws_api_gateway_method" "getUsers-api-method" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.test-api-res-getUsers.id
  rest_api_id   = aws_api_gateway_rest_api.test-api-tf.id
}

resource "aws_api_gateway_integration" "getUsers-intergration" {
  rest_api_id             = aws_api_gateway_rest_api.test-api-tf.id
  resource_id             = aws_api_gateway_resource.test-api-res-getUsers.id
  http_method             = aws_api_gateway_method.getUsers-api-method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.lambda-getUsers.invoke_arn

}

resource "aws_api_gateway_method_response" "getUsers-response_200" {
  rest_api_id = aws_api_gateway_rest_api.test-api-tf.id
  resource_id = aws_api_gateway_resource.test-api-res-getUsers.id
  http_method = aws_api_gateway_method.getUsers-api-method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "getUsers-response-integration" {
  rest_api_id = aws_api_gateway_rest_api.test-api-tf.id
  resource_id = aws_api_gateway_resource.test-api-res-getUsers.id
  http_method = aws_api_gateway_method.getUsers-api-method.http_method
  status_code = aws_api_gateway_method_response.getUsers-response_200.status_code

  # Transforms the backend JSON response to XML
  response_templates = {
    "application/json" = <<EOF
    
    EOF
  }

  depends_on = [aws_api_gateway_integration.getUsers-intergration]
}
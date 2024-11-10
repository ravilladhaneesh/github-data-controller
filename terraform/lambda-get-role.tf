resource "aws_iam_role" "lambda-get-role" {
    name = "lambda-role-for-get-function"
    assume_role_policy = <<EOF
    {
        "version": "2012-10-17",
        "Statement" : [
            {
                "Effect": "Allow",
                "Principal" : {
                    "Service" : "lambda.amazonaws.com"
                },
                "Action": "sts:AllowRole"
            }
        ]
    }
    EOF
}


resource "aws_iam_role_policy_attachment" "lambda-get-role-attachment" {
    role = aws_iam_role.lambda-get-role.name
    policy_arn = "arn:aws:iam::aws:policy/DynamoDBFullAccess"
}


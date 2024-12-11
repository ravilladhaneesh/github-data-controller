# github-data-controller

github-data-controller is one of the 3 github-repo-viewer project that stores the github user's repository data to Amazon AWS through API Gateway.

1. [github-data-processor](https://github.com/ravilladhaneesh/github-data-processor)
2. github-data-controller
3. [github-data-viewer](https://github.com/ravilladhaneesh/github-data-viewer)

## Table of Contents

- [project flow diagram](#project-diagram)
- [Steps to put data to AWS](#steps-to-put-data-to-aws)
- [Technologies used](#Technologies-Used)
- [To-do](#To-do)


## project-diagram

![project flow diagram](https://github.com/ravilladhaneesh/github-data-viewer/blob/Add-readme-file/src/static/images/project-final-diagram.png)


## Technologies-Used

    1. Terraform
    2. Python
    3. Github CI/CD

## Steps to Put Data to AWS

1. Create an environment in the repository and Add secrets to the environment.

        Steps to create an environment and add secrets:
            1. Go to `settings` in the repository.
            2. In the `General` section Click on `Environments` option.
            3. Click on `New Environment` and provide a name of the `environment` and click on `Configure environment`.This will create a new environment and opens your newly created environment.
            4. In the `environment secrets` section click on 'Add environment secrets' and add the below variables.
                1. Name  : AWS_PUT_DATA_ROLE
                   value : arn:aws:iam::011528266310:role/github-put-data-role
                2. Name  : AWS_REGION
                   value : ap-south-1 
  

    The AWS role provided in the above secrets has a single permission to put data to an AWS API Gateway.So the role doesn't cause any security threat. To put data to AWS your github userId/username has to be added in the role policy document to allow your github userID to assume the above provided role. Please contact me @ ravilladhaneesh@gmail.com to add your github userId to the role.

2. Create a .github/workflows directory in your root repository to trigger a workflow on Github Actions.
3. Add the file in this [link](https://github.com/ravilladhaneesh/workflow-test/blob/main/.github/workflows/python-test.yml) to the .github/workflow folder created in the above step to run a job that puts data to AWS

### Detailed Description of the job

1. The below code snippet describes the name of the workflow as 'Python Test' and the workflow runs on each push to 'main' branch.You can update/Add branch as your requirement to run the worklow for your specific branch.

        name: Python Test

        on:
        push:
            branches:
            - main  # Run the workflow when code is pushed to the main branch

2. The below code snippet has the list of jobs that runs in the workflow.In this script we have a single job 'run-python-script' that executes the [github-data-processor](https://github.com/ravilladhaneesh/github-data-processor) project to put data to AWS.The job is deployed in the 'staging' environment(Update the environment that you have created in the above [Steps to put data to AWS](#steps-to-put-data-to-aws) section).The permissions section in the code snippet are required to request the JWT token to autenticate AWS and read content of the repository.

        jobs:
            run-python-script:
                runs-on: ubuntu-latest
                environment: staging
                permissions:
                    id-token: write
                    contents: read

3. The below code snippet describes the executions of the job.In the step 1. the job checkouts the current repository and in step 2. github-data-processor is cloned into the current job execution.


        steps:
        # Step 1: Checkout the repository
        - name: Checkout code
            uses: actions/checkout@v3

        # Step 2: Clone github-data-processor repo
        - name: Clone github-data-processor repository
            run: git clone https://github.com/ravilladhaneesh/github-data-processor.git

4. This is the step where the autentication for AWS is requested using the 'AWS_PUT_DATA_ROLE'. The AWS_PUT_DATA_ROLE, AWS_REGION variable has to be added to the environment as a secret variable.

        # Step 3: Configure aws credentials
        - name: Configure aws credentials
            uses: aws-actions/configure-aws-credentials@v2
            with:
                role-to-assume: ${{ secrets.AWS_PUT_DATA_ROLE}}
                aws-region: ${{ secrets.AWS_REGION }}

5. In the below Step 4 and Step 5 the job is installing python and setting up the environment variables that are later used by github-data-processor to process the data and put the data in AWS.The last step (Step 6) is where the required dependencies are installed and github-data-processor is ran to put the data to AWS. 

        # Step 4: Set up Python environment
        - name: Set up Python
            uses: actions/setup-python@v4
            with:
                python-version: '3.x'

        # Step 5: Set repository details as environment variable
        - name: Set ENV variable with repository name
            run: |
                echo "REPO_NAME=${{ github.repository }}" >> $GITHUB_ENV
                echo "REPO_PATH=${{ github.workspace }}" >> $GITHUB_ENV
                echo "REPO_URL=https://github.com/${{ github.repository }}" >> $GITHUB_ENV
                echo "BRANCH=${{ github.ref_name}}" >> $GITHUB_ENV
                echo "REPO_VISIBILITY=${{ github.event.repository.private }}" >> $GITHUB_ENV

        # Step 6: Run the github-data-processor project
        - name: Run scraper
            env:
                ROLE_ARN: ${{ secrets.AWS_PUT_DATA_ROLE }}
            run: |
                pip install -r github-data-processor/requirements.txt
                python github-data-processor/src/main.py  # This will run the github-data-processor project

## To-do
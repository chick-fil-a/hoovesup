HoovesUp
-------------------------------------------

The purpose of HoovesUp is to create self-provisioning and self-healing SSM Agents on bare-metal devices.

This is a simple script that does three things;
1. The provided Ansible script provisions your bare metal servers, installing the SSM Agent as well as the ssm.sh script
2. Installs a crontab that runs every 5 minutes on the server, executing the ssm.sh bash script
3. When the ssm.sh script gets invoked, it checks to see if SSM has been configured and is working... if not, it will enroll itself to your AWS SSM account

#### PREREQUISITES FOR YOUR BARE METAL TARGET:

1. Have your AWS credentials setup in ~/.aws/credentials and ~/.aws/config of the target machine
Follow these instructions; https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/setup-credentials.html

2. Your AWS Credentials will require (at a minimum) the following IAM policies;

```{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ssm:DeleteActivation",
                "iam:PassRole",
                "ssm:CreateActivation",
                "ssm:DescribeActivations",
                "ssm:DeleteAssociation",
                "iam:AddRoleToInstanceProfile"
            ],
            "Resource": "*"
        }
    ]
}```

3. The NUC's require the SSM agent, and jq to be installed. You can use the provision.yml to get the box ready.
Sample command;

```ssh
ansible-playbook -i hosts/dev_example provision.yml
```

4. This Ansible repo only works for Ubuntu at this time. Minor modifications should allow it to work on other Linux OS's

#### EXAMPLE USAGE:

Once the devices have enrolled themselves in to SSM, you can use this SSM wrapper to easily interact with the devices;
https://github.com/coffeesn0b/ssm-run
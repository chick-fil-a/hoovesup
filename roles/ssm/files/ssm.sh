#!/bin/bash
LOGFILE=/var/log/ssm_activation.log
echo "`date +%H:%M:%S` : Starting the SSM script" >> $LOGFILE 2>&1

# here is what this thing does:
# 1) It figures out if the SSM Agent has an associated ami ID (ie; is it working or not and has it been provisioned)
# 2) If it has not been setup yet, it creates and uses an SSM activation. Each activation will register only 1 device
# 3) It uses that SSM activation to register itself, and then deletes the activation

sudo service amazon-ssm-agent start

SSM_STATUS="$(service amazon-ssm-agent status | grep -o Failed | head -n 1)"

if [ "$SSM_STATUS" == "Failed" ]; then   # if any value is returned then SSM is not yet setup, and needs to be initialized

    echo "`date +%H:%M:%S` : the SSM Status failed so lets create an activation" >> $LOGFILE 2>&1
    SSM_ACTIVATION="$(aws ssm create-activation --default-instance-name edge-${LOCATION} --iam-role ssm --registration-limit 5)"
    echo "`date +%H:%M:%S` : SSM activation ID is: ${SSM_ACTIVATION_ID} and activation code is: ${SSM_ACTIVATION_CODE}" >> $LOGFILE 2>&1

    SSM_ACTIVATION_ID="$(echo $SSM_ACTIVATION | jq -r '[.ActivationId] ' | tr -d '"' | tr -d '[' | tr -d ']' | tr -d ' ' | tr -d '\n')"
    SSM_ACTIVATION_CODE="$(echo $SSM_ACTIVATION | jq -r '[.ActivationCode] ' | tr -d '"' | tr -d '[' | tr -d ']' | tr -d ' ' | tr -d '\n')"

    sudo service amazon-ssm-agent stop
    amazon-ssm-agent -register -code "${SSM_ACTIVATION_CODE}" -id "${SSM_ACTIVATION_ID}" -region "us-east-1"
    sudo service amazon-ssm-agent start

    echo "`date +%H:%M:%S` : SSM activation ID is: ${SSM_ACTIVATION_ID} and activation code is: ${SSM_ACTIVATION_CODE}" >> $LOGFILE 2>&1

    aws ssm delete-activation --activation-id "${SSM_ACTIVATION_ID}"
fi
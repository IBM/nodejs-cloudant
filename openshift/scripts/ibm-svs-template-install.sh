#!/bin/bash

function usage {
    echo "Usage: ./oc-template-install.sh <api_key> <resource_group_id> <cluster_name> [template_file]"
    echo "Defaults to the template file located in /openshift/templates."
}

function check_input {
    if [[ -z "$1" ]]; then
        echo "$2"
        usage
        exit 1
    fi
}

function check_exit {
    check_exit_custom $? $2
}

function check_exit_custom {
    if [[ $1 -ne 0 ]]; then
        echo -e "\n$2"
        exit 1
    fi
}

API_KEY=$1
RESOURCE_GROUP=$2
CLUSTER_NAME=$3
if [[ -z "$4" ]]; then
    TEMPLATE_FILE=./../templates/clone.json
else
    TEMPLATE_FILE=$4
fi
echo "Using template file $TEMPLATE_FILE"

check_input "$API_KEY" "No API key was supplied. A valid IBM Cloud API key is required to login to the IBM Cloud."
check_input "$RESOURCE_GROUP" "No resource group ID was supplied. Execute 'ibmcloud resource groups' to list resource groups."
check_input "$CLUSTER_NAME" "No cluster name was supplied. Execute 'ibmcloud ks clusters' to list available clusters."
check_input "$TEMPLATE_FILE" "No template file was supplied."

echo -e "\nLogging in"
ibmcloud login --apikey $API_KEY
ibmcloud target --cf -g $RESOURCE_GROUP
oc login -u apikey -p $API_KEY

echo -e "\nApplying cluster configuration for cluster $CLUSTER_NAME"
$( ibmcloud ks cluster config $CLUSTER_NAME --admin | grep export)

echo -e "\nInstalling Operator Lifecycle Manager"
#Q: which of those 2 methods is preferred? Ask Paolo.
# Install OLM with:
# oc apply -f https://github.com/operator-framework/operator-lifecycle-manager/releases/download/0.10.0/crds.yaml
# oc apply -f https://github.com/operator-framework/operator-lifecycle-manager/releases/download/0.10.0/olm.yaml 
# OR:
curl -sL -o olm_install.sh https://github.com/operator-framework/operator-lifecycle-manager/releases/download/0.11.0/install.sh
chmod +x ./olm_install.sh
./olm_install.sh 0.10.0
rm ./olm_install.sh
check_exit "Failed to install the Operator Lifecycle Manager. Check the command output and try again."

# Q: is Marketplace a requirement for IBM Cloud Operator? May not be necessary is that is the only operator we're installing as a prereq for our template
echo -e "\nInstalling Operator Marketplace"
OM_TEMP_DIR=om_temp
mkdir $OM_TEMP_DIR
cd $OM_TEMP_DIR
git clone https://github.com/operator-framework/operator-marketplace.git
GIT_CLONE_EXIT=$?
oc apply -f operator-marketplace/deploy/upstream/
OC_APPLY_EXIT=$?
cd ..
rm -rf ./$OM_TEMP_DIR
check_exit_custom $GIT_CLONE_EXIT "Failed to download Operator Marketplace resource definitions. Ensure that you are connected to the Internet and can access GitHub."
check_exit_custom $OC_APPLY_EXIT "Failed to install Operator Marketplace. Check the command output and try again."

echo -e "\nInstalling IBM Cloud Operator"
kubectl apply -f https://operatorhub.io/install/ibmcloud-operator.yaml
check_exit "Failed to deploy IBM Cloud Operator. Ensure the $CLUSTER_NAME cluster is available."
source <(curl -sL https://raw.githubusercontent.com/IBM/cloud-operators/master/hack/config-operator.sh)
check_exit "Failed to configure IBM Cloud Operator. Check the command output and try again."

# Create and manually install a new template to the catalog -- this will also be scoped for that cluster only.
echo -e "\nInstalling template $TEMPLATE_FILE"
oc -n openshift apply -f "$TEMPLATE_FILE"
check_exit "Failed to install template $TEMPLATE_FILE. Ensure the template definition is valid and try again."
echo -e "\nTemplate installation succeeded!"

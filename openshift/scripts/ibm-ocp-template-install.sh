#!/bin/bash

function usage {
    echo "Usage: ./ibm-ocp-template-install.sh --apikey=<api_key> --resource-group-id=<resource_group_id> --cluster-name=<cluster_name> [--template-file=template_file]"
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

for arg in "$@"
do
    if [ "$arg" == "--help" ] || [ "$arg" == "-h" ]; then
        usage
        exit 0
    fi

    if [[ $arg == --apikey=* ]]; then
        API_KEY=$( echo $arg | cut -d'=' -f 2 )
    fi

    if [[ $arg == --resource-group-id=* ]]; then
        RESOURCE_GROUP=$( echo $arg | cut -d'=' -f 2 )
    fi

    if [[ $arg == --cluster-name=* ]]; then
        CLUSTER_NAME=$( echo $arg | cut -d'=' -f 2 )
    fi

    if [[ $arg == --template-file=* ]]; then
        TEMPLATE_FILE=$( echo $arg | cut -d'=' -f 2 )
    fi
done

if [[ -z "$TEMPLATE_FILE" ]]; then
    TEMPLATE_FILE=$PWD/openshift/templates/clone.json
fi
echo "Using template file $TEMPLATE_FILE"

check_input "$API_KEY" "No API key was supplied. A valid IBM Cloud API key is required to login to the IBM Cloud. Use 'ibmcloud iam api-key-create' to create an API key."
check_input "$RESOURCE_GROUP" "No resource group ID was supplied. Execute 'ibmcloud resource groups' to list resource groups."
check_input "$CLUSTER_NAME" "No cluster name was supplied. Execute 'ibmcloud ks clusters' to list available clusters."
check_input "$TEMPLATE_FILE" "No template file was supplied."

echo -e "\nLogging in"
ibmcloud login --apikey $API_KEY
ibmcloud target --cf -g $RESOURCE_GROUP
oc login -u apikey -p $API_KEY

echo -e "\nApplying cluster configuration for cluster $CLUSTER_NAME"
$( ibmcloud ks cluster config $CLUSTER_NAME --admin | grep export)
check_exit "Failed to apply cluster configuration for cluster $CLUSTER_NAME. Check the cluster name and try again."

echo -e "\nInstalling Operator Lifecycle Manager"
kubectl apply -f https://github.com/operator-framework/operator-lifecycle-manager/releases/download/0.12.0/crds.yaml && kubectl apply -f https://github.com/operator-framework/operator-lifecycle-manager/releases/download/0.12.0/olm.yaml
check_exit "Failed to install the Operator Lifecycle Manager. Check the command output and try again."

echo -e "\nInstalling Marketplace Operator"
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
curl -sL https://raw.githubusercontent.com/IBM/cloud-operators/master/hack/config-operator.sh | bash
check_exit "Failed to configure IBM Cloud Operator. Check the command output and try again."

# Create and manually install a new template to the catalog -- this will also be scoped for that cluster only.
echo -e "\nInstalling template $TEMPLATE_FILE"
oc -n openshift apply -f "$TEMPLATE_FILE"
check_exit "Failed to install template $TEMPLATE_FILE. Ensure the template definition is valid and try again."
echo -e "\nTemplate installation succeeded!"

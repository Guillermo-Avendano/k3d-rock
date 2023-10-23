#!/bin/bash
source ../env.sh   

################################################################################
# ORCHESTRATOR CONFIGUTATION
################################################################################
export NAMESPACE=${IFW_NAMESPACE:-ifw}

################################################################################
# IMAGES
################################################################################
IFW_HELM_DEPLOY_NAME=${IFW_HELM_DEPLOY_NAME:-inputframework}
IFW_IMAGE_NAME=${IFW_IMAGE_NAME:-asgthorstenk/inputframework_tef}
IFW_IMAGE_VERSION=${IFW_IMAGE_VERSION:-4.8}

IFW_ADMIN_USR=${IFW_ADMIN_USR:-SYSADMIN}
IFW_ADMIN_PWD=${IFW_ADMIN_PWD:-ASG}

IFW_MOBIUS_REMOTE_CLI_URL=${IFW_MOBIUS_REMOTE_CLI_URL:-https://myshare.rocketsoftware.com/myshare/d/PqgkLvj51}
IFW_MOBIUS_REMOTE_CLI_SETUP_URL=${IFW_MOBIUS_REMOTE_CLI_SETUP_URL:-https://myshare.rocketsoftware.com/myshare/d/y3gz27g56}

export KUBE_NS_LIST=( "$NAMESPACE" )

# MobiusRemoteCLI configuration
export IFW_MOBIUS_REMOTE_HOST_PORT=mobiusview.mobius:80

#########################################
export IFW_URL=${IFW_URL:-ifw.local.net}

export IFW_PV_LOCAL_ENABLED=true

export IFW_PVC_VOLUME="ifw-volume-claim"
export IFW_PVC_INBOX="ifw-inbox-claim"

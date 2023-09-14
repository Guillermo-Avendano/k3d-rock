#!/bin/bash

source ../env.sh   # main env.sh

################################################################################
# ORCHESTRATOR CONFIGUTATION
################################################################################
export NAMESPACE="ifw"

################################################################################
# IMAGES
################################################################################
IFW_HELM_DEPLOY_NAME="inputframework"
IFW_IMAGE_NAME=asgthorstenk/inputframework_tef
IFW_IMAGE_VERSION=4.8

IFW_MOBIUS_REMOTE_CLI_URL=https://myshare.rocketsoftware.com/myshare/d/PqgkLvj51
IFW_MOBIUS_REMOTE_CLI_SETUP_URL=https://myshare.rocketsoftware.com/myshare/d/y3gz27g56

export KUBE_NS_LIST=( "$NAMESPACE" )

# MobiusRemoteCLI configuration
export IFW_MOBIUS_REMOTE_HOST_PORT=mobiusview.mobius:80

#########################################
export IFW_URL="ifw.local.net"

# Define persistent storage in /cluster/cluster.sh  --> cluster_volumnes()
# Copy this definitions, and adds to pv_folder array

# RULE NAME
# PV_<name with "_">
# PV_PATH_<name with "_">
# Where <name with "_"> is the same for PV_ and PV_PATH_
# PV_PATH_<name with "_"> is defined into /cluster/cluster.sh  --> cluster_volumnes()

export IFW_PV_LOCAL_ENABLED=true

export PV_ifw_volume_claim="ifw-volume-claim"
export PV_PATH_ifw_volume_claim=$kube_dir/pv_cluster/ifw-volume  # The name doesn't allow '_', but the variable is with '-'

export PV_ifw_inbox_claim="ifw-inbox-claim"
export PV_PATH_ifw_inbox_claim=$kube_dir/pv_cluster/ifw-inbox    # The name doesn't allow '_', but the variable is with '-'




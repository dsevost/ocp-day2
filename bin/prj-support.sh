#!/bin/bash

function checkLogged() {
    oc whoami || die "Please login first"
}

function oc_adm() {
    checkLogged
    local oc_cmd="oc --as=system:admin"
    local cmd="$oc_cmd $*"
    case $FORCE in
	n*|N*)
	    die "Operation aborted"
	    ;;
	a*|A*)
	    $cmd
	    return
	    ;;
    esac
    echo $cmd
    while (true) ; do
	read -p 'Proceed the command (always/no/yes): ' FORCE
	case $FORCE in
	    n|N)
		die "Operation aborted"
		break;
		;;
	    a|A|y|Y)
		export FORCE
		$cmd
		break;
		;;
	esac
    done
}

function die() {
    echo $*
    exit 1
}

function create_projects() {(
    [ -z "$*" ] && die "Projects not defined"
    [ -z "$PRJ_PREFIX" ] && die "Project (PRJ_PREFIX) prefix not defined"

    [ -z "$NODE_SELECTOR" ] || NODE_SELECTOR="--node-selector='$NODE_SELECTOR'"

    for prj in $* ; do
	p=${PRJ_PREFIX}-$prj
	oc_adm adm new-project $p $NODE_SELECTOR
	if [ -z "$LABELS" ] ; then
	    echo "LABEL not defined, labeling skipped"
	else
	    oc_adm label ns $p $LABELS
	fi
    done
)}


function set_group_role_for_projects() {(
    [ -z "$*" ] && die "Projects not defined"
    [ -z "$PRJ_PREFIX" ] && die "Project (PRJ_PREFIX) prefix not defined"
    [ -z "$GROUP" ] && die "Group not defined"
    [ -z "$ROLE" ] && die "Role not defined"

    for prj in $* ; do
	p=${PRJ_PREFIX}-$prj
	oc_adm adm policy add-role-to-group $ROLE ${PRJ_PREFIX}-$GROUP -n $p
    done
)}

function set_labels_for_projects() {(
    [ -z "$*" ] && die "Projects not defined"
    [ -z "$PRJ_PREFIX" ] && die "Project (PRJ_PREFIX) prefix not defined"
    for prj in $* ; do
	p=${PRJ_PREFIX}-$prj
	oc_adm label ns $p PROJECT_KIND=$prj $LABELS --overwrite
    done
)}

function set_quotes_and_limits_for_projects() {(
    checkLogged

    [ -z "$*" ] && die "Projects not defined"
    [ -z "$PRJ_PREFIX" ] && die "Project (PRJ_PREFIX) prefix not defined"

    [ -z "$QC" ] && die "CPU quote (QC) not defined"
    [ -z "$QM" ] && die "Memory quote (QM) not defined"
    [ -z "$LC" ] && die "CPU limit (LC) not defined"
    [ -z "$LM" ] && die "Memory limit (LM) not defined"

    TMP_FILE=$(mktemp)
    trap "/bin/rm -f $TMP_FILE" EXIT TERM
    cat >> $TMP_FILE << EOF
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: computing
spec:
  hard:
    cpu: "$QC"
    memory: "$QM"
    limits.ephemeral-storage: "0"
    persistentvolumeclaims: "3"
    requests.storage: "5Gi"
#    gold.storageclass.storage.k8s.io/requests.storage: "0"
#    silver.storageclass.storage.k8s.io/requests.storage: "1Gi"
#    silver.storageclass.storage.k8s.io/persistentvolumeclaims: "3"
#    bronze.storageclass.storage.k8s.io/requests.storage: "2Gi"
#    bronze.storageclass.storage.k8s.io/persistentvolumeclaims: "3"
#    bronze.storageclass.storage.k8s.io/requests.storage: "5Gi"
#    bronze.storageclass.storage.k8s.io/persistentvolumeclaims: "3"
    pods: "20"
    services: "5"
    secrets: "30"
    configmaps: "10"
#    replicationcontrollers: "20"
  scopes:
  - NotTerminating
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: terminating
spec:
  hard:
    cpu: "2"
    memory: 8Gi
  scopes:
  - Terminating
---
apiVersion: v1
kind: LimitRange
metadata:
  name: limits
spec:
  limits:
  - max:
      cpu: "$LC"
      memory: "$LM"
    min:
      cpu: 10m
      memory: 128Mi
    type: Pod
  - default:
      cpu: 300m
      memory: 256Mi
    max:
      cpu: 300m
      memory: 2Gi
    min:
      cpu: 20m
      memory: 256Mi
    type: Container
EOF
    read -p 'Would you like to review Quotas and Limits (y/n)? [y]: ' REVIEW
    if [ "$REVIEW" = "y" -o "$REVIEW" = "Y" -o "$REVIEW" = "" ] ; then
	vi $TMP_FILE
    fi
    for prj in $* ; do
	p=${PRJ_PREFIX}-$prj
	oc_adm -n $p create -f $TMP_FILE
    done
)}

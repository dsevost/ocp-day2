# Managing projects
You must be logged with "cluster" admin privileges, to create a cluster-admin like privileges see rbac directory

## Setup variables 
```
$ export PRJ_PREFIX= # название автоматизированной системы
$ export OWNER="login владельца автоматизированной системы"
$ export REQ=000001278 # Projects creation request ID
$ PRJ_PROD="preview prod" # Projects run on production nodes, or some kind of... 
$ PRJ="dev test" # Projects run at developer environment
```
## Load scrips to automate projects creation (https://github.com/dsevost/ocp-day2)
```
$ source bin/prj-support.sh
```
## Create projects group
### Test and dev env
```
$ LABELS="router=dev" \
  create_projects $PRJ
```
### Prod env
Creates projects on specific environments and set specific labels to use specific routers (routing sharding)
```
$ LABELS="router=prod" \
  NODE_SELECTOR=node-compute-type=prod \
  create_projects $PRJ_PROD
```

### Set privilegs for managers and users
```
$ GROUP=managers ROLE=admin \
  set_group_role_for_projects $PRJ $PRJ_PROD

$ GROUP=users ROLE=edit \
  set_group_role_for_projects $PRJ $PRJ_PROD
```
### Set quotes and limits for specific projects
```
$ QC="4" QM="16Gi" LC="500m" LM="512Mi" \
  set_quotes_and_limits_for_projects dev preview
$ QC="8" QM="32Gi" LC="500m" LM="512Mi" \
  set_quotes_and_limits_for_projects test
$ QC="16" QM="64Gi" LC="500m" LM="512Mi" \
  set_quotes_and_limits_for_projects prod
```
### Set useful labels
```
$ LABELS="APP_GROUP=$PRJ_PREFIX OWNER=$OWNER REQ_ID=$REQ" \
  set_labels_for_projects $PRJ $PRJ_PROD
```

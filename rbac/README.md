# Customer's Roles
Customer wants to have roles:
1. Restricted cluster administrator, who manages project's specific settings over cluster
2. Security officer, who manages security permissions over cluster and network
3. Restricted project's administrator, who manages user's permissions and quotas for specific project

## Restricted cluster administrator (cust-cluster-adm)
Permissions: create projects, quotas, manage user's and group's permissions, load images and run images, scaling and accessing to logs over any project

### Subsets of permissions
1. Create project with specific node-selector
2. Managing Quotas
3. Managing Limits
4. Managing ImageStreams
5. Run and scale Applications
6. Having access to application's Logs
7. Managing user's permissions
8. Managing group's permissions

### Restrict for permissions
1. Secrets

## Security officer (cust-security-officer)
Permissions: manages user's and group's permissions over any projects and over all cluster, load and run images, manages networks, accessing to all logs

### Subsets of permissions
1. Managing Secrets over all projects
2. Managing Networks (pod's connectivity)
3. Managing ImageStreams
4. Run any Application
6. Having access to application's Logs
7. Having access to cluster's Logs

### Restrict for permissions
1. Scaling Applications

## Restricted project administrator (cust-prj-adm)
Permissions: manages user's and group's permissions over any projects and over all cluster, load and run images, manages networks, accessing to all logs

### Subsets of permissions
1. Managing Quotas
2. Managing Limits
3. Managing ImageStreams
4. Run and scale Applications
5. Having access to application's Logs
6. Managing user's permissions
7. Managing group's permissions

### Restrict for permissions
1. Secrets


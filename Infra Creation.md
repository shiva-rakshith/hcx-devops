# Create new Infrastructure
Pre-requisites:
To create AWS Infra instance (handles required vpc creation for the cluster)
1. Execute terraform script following infrastructure/terraform/README.md

Steps to create the Kubernetes cluster:
1. Create kubernetes cluster
    1. Kube cluster creation is handled by `eksctl` tool. For more info, check [README.md](infrastructure/eks/README.md) in eks folder.
2. Create Jenkins
    1. We’re using server-less Jenkins architecture, means whenever there is a need for a worker, we’ll create one in AWS Fargate.
    2. Prior creating the Jenkins, you’ll have to create the dependencies like docker registry secret, private GH repo secret etc. All these files are stored in private repo `hcx/kubernetes/manifests/cicd/jenkins` folder. Edit the files with updated secrets, and `kubectl apply -f hcx/kubernetes/manifests/cicd/jenkins`
    3. You’ve to use variable override file from private repo `application/helm/cicd/jenkins/values.yaml`
    4. To install jenkins `helm upgrade --install jenkins --namespace cicd ./jenkins -f ./jenkins/values-custom.yaml --create-namespace` For more information, please refer to `application/helm/cicd/README.md`
3. Create monitoring stack
    1. Since monitoring stack use CRDs and our Jenkins doesn’t have a Cluster Admin role, we’ve to initialize the Jenkins while installing the cluster
    2. We’ve to update the passwords and storage configs in monitoring private repo. `hcx/kubernetes/helm/monitoring/monitoring/values.yaml`
    3. Installing monitoring stack is simple `helm upgrade --install monitoring -n monitoring --create-namespace application/helm/monitoring/moniotring -f private-repo/hcx/kubernetes/helm/monitoring/monitoring/values.yaml` 
4. Build/Depoy apps
    1. All jobs are configured as Jenkins pipeline files
    2. Every job configuration is centralized JCasC code.
        1. Means to recreate all jobs, 
            1. You simply have to create a pipeline job
            2. and run the job, which will inturn create all other jobs.

* Module 1

### Designing Architecture:
Designing a pipeline for an infrastructure with a mixture of cloud and on-premise Kubernetes clusters, varying application instances, and different auxiliary service configurations is a complex task. Below are key points and a high-level design architecture for such a pipeline:

Considering the GitOps best practices of separating your Application Source Code from the Application’s K8s Configuration in two Git(Hub) repositories, Here are the process to implement the CI/CD (Continuous Deployment/Delivery) with GitHub Actions (CI) and pull based deployment via Argo CD.

The workflow I am using which can be easily converted to Continuous Delivery by modifying the GitHub Actions. 

Continuous Deployment is ideal for lower environments (i.e. Development) and can be triggered by a PR merge, push or even a simple commit to the application source code repository wheres Continous Delivery would require the manual approval to proceed with production cluster or env. 

## Pseudocode of Pipeline and ArgoCD

 ![Screenshot](Ruby_App_Deploy/img/GitOps_argoCd.svg) 


### Steps
1. Here User will check-in the code or create PR which will trigger the GITHUB ACTION WORKFLOW 1 (CI Pipeline) by  the modification of event on repo. **Assumption** 1
2. The GITHUB ACTION WORKFLOW 1 will run steps mentioned in pipeline i.e. build, compile, and test your application and then package it in a Docker container and publish it to a container repository.
3. The GITHUB ACTION WORKFLOW 1 passes the Docker image name and tag as input and triggers the  GITHUB ACTION WORKFLOW 2, which will update the helm chart's dev or prod wrapper manifest file and commit and push the changes to the Application/K8s Configuration repository. 
4. Argo CD will be pulling this change and update the application on the K8s cluster.
5. We will be using "sync app" as manual for production and automatic for development.
**Assumption** 2
6. For Dev Env, ArgoCD will pick up the values from helm's dev-value.yaml manifest and apply the changes to Dev Cluster. (ArgoCD runs Helm in backend to generate the helm templates and then apply it on cluster). 
7. Once we have verified the application is working as expected in Dev, UAT, Staging env then we will go to ArgoCD UI and manually sync the application for Production environment. 
8. For Prod Env, ArgoCD will pick up the values from helm prod-value.yaml manifest and apply for changes to prod cluster. . This time ArgoCD will deploy the changes to On-Prem and Cloud K8 cluster simulatenously.
9. The default rolling update will take place, and which we can see in the Argo CD UI that the new version being deployed first and then the containers running the old version being terminated after.
*Rollback*
10. We will navigate to the ArgoCD web UI and select the application you want to rollback. Check the "REVISION HISTORY" section. Find the revision you want to rollback to and click on the "ROLLBACK" button next to it. In the confirmation dialog box, click "ROLLBACK" to confirm the rollback.

**Assumption**
1. The ECR creds to store container image is already in the CI pipeline (GITHUB ACTION WORKFLOW 1)
2. Configured Active and Passive Environments 
3. Passive will be ready with minimal resource
4. Both environment will have autoscalling feature enabled for Pod Level and Cluster level.


**CI/CD In Motion**
- GITHUB ACTION WORKFLOW 1 acts as the CI flow, resides on the Application git repository, and is designed to trigger on code updates initiated by user; it will build the Docker container and push it to the ECR in this scenario. In addition, this flow will trigger Pipleine2 and pass the newly built image tag.

- GITHUB ACTION WORKFLOW 2 (CD Pipeline) is the CD flow, resides on the Helm Chart Configuration git repository, and is initiated at the end of GITHUB ACTION WORKFLOW 1 completion; it will take the latest built image tag form GITHUB ACTION WORKFLOW 1 and update the Helm's dev or prod wrapper manifest file with it, which in turn will wake up ArgoCD and redeploy the latest application.


* How the tag version will get update in k8 configuration repository. 
- The logic behind is very simple. The GITHUB ACTION WORKFLOW 1 will run all steps and last step will send tag version as payload and trigger the GITHUB ACTION WORKFLOW 2 to start. Then next moment the GITHUB ACTION WORKFLOW 2 will initate and take the payload tag version and update in helm chart's dev or prod wrapper manifest file. 


#### Sample dev-values.yaml and prod-values.yaml
======================================
```
Dev-Value.yaml

image:image:$tagversion (Value will be replaced/updated from workflow 1 job)
cluster:
  dev
    Cloud
Auto-deploy - ON
ingress:
  path: /stage

  

Prod-Value.yaml
image:image:$tagversion (Value will be replaced/updated from workflow 1 job)
cluster:
  Prod
    Onprem
    Cloud
Auto-deploy - Off (Manual Approval required)
ingress:
  path: /
```
  

### Best Practice Implementation 

**Rollback Mechanism** - Argo CD Rollbacks can be easily triggered from the UI or CLI, but the idea of GitOps is to rely on Git and revert your changes and let the CI/Argo CD do its magic. Argo CD deployment strategies aka Rollouts include blue-green and canary among others.

**Logging and Monitoring** - Set up logging and monitoring for all clusters and applications. Tools like Prometheus and Grafana can be used for this purpose.

**Security Consideration**
We also can limit in GutHub who can commit to the repo (application and K8s config repos), who can review and merge pull requests, etc. 

**Secret Management**: Implement a secure method for managing secrets and sensitive configurations. Tools like HashiCorp Vault or Kubernetes Secrets can be integrated into your pipeline.

**Documentation and Runbooks**: Maintain comprehensive documentation and runbooks for the pipeline, covering deployment procedures, environment-specific configurations, and troubleshooting steps.

**Audit and Compliance**: Ensure compliance with security and audit requirements in your pipeline. Implement measures for auditing and tracking changes to the infrastructure.



### Problem - 

1. Error

INPUT_PUSH_OPTIONS: 
remote: Permission to manukoli1986/gitops-2.git denied to github-actions[bot].
fatal: unable to access 'https://github.com/manukoli1986/gitops-2/': The requested URL returned error: 403

Solution:
Check if "Read and write permissions" are enabled in Settings -> Actions -> General -> Workflow permissions:
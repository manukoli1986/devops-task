* Module 1 - Pipeline design
We have a homogenous mixture of environments based on cloud as well as
on-premise Kubernetes clusters. Some of our applications run on multiple
instances while others are standalone. The configuration of the auxiliary
services (databases, caches etc) might be different depending on the
environment.
Design a pipeline that fits the needs of such an infrastructure for our app.
(Github actions, helm ,argocd are preferred).



* [Module 2](https://github.com/manukoli1986/devops-task/tree/main/Ruby_App_Deploy#module-2)  - Deploy
Run the app on local k8s cluster.
Part 1 - Containerise
Build a secure, scalable and robust container image.
Part 2 - Manifests
Write helm manifests to deploy the application to local kubernetes cluster.
Should satisfy following:
● Highly available and load balanced
● Ensuring the application is started before served with traffic
● Safeguards for ensuring healthy life cycle of applications
● Ensure zero downtime
● Endpoints of the web application are accessible outside the cluster

* [Module 3](https://github.com/manukoli1986/devops-task/tree/main/Ruby_App_Deploy#module-3) - Improvements
This is an open-ended assignment, you are free to introduce changes, in the
assigned time frame, to the application or in the instrumentation to meet your
standards in terms of security, availability, reliability and observability.
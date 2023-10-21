* Ruby App On Local K8


Steps:

1. Clone the Ruby Code from GitHub

```
git clone https://github.com/sawasy/http_server.git
```

2. Build a Docker Container Image. I am using below format to dockerize the ruby code. 

```
# Use an official base image with minimal OS (Alpine is commonly used for its small size)
FROM ruby:2.7-alpine

# Set the working directory in the container
WORKDIR /app

# Copy the application code into the container
COPY . .

# Expose the port your Ruby application will run on
EXPOSE 80

# Define environment variables (customize as needed)
ENV RAILS_ENV=development

# Run the Ruby application as a non-root user (for security)
RUN adduser -D -u 1000 appuser
USER appuser

# Start the Ruby application
CMD ["ruby", "http_server.rb"]

```

Build the Docker image with the following command:

```
docker build -t rubyapp:latest . 

docker run 
curl --http0.9  http://localhost:8080/healthcheck
curl --http0.9  http://localhost:8080/

```

3. Create/Generate Helm chart for the app. I am using Helm 3 (Latest version)

```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm dependency update
helm create rubyapp
```

4. Adjust the setting in values.yaml, and manifest files under template directory.

|                               **Requirement**                           |                **Solution**             |
|:----------------------------------------------------------------------:	|:--------------------------------------:	|
| Highly available and load balancer                                     	| Using Replicas                         	|
| Ensuring the application is started before served with traffic         	| Using Livenessprobe and Readinessprobe 	|
| Safeguards for ensuring healthy lifecycle of applications              	| Using HealthCheck                      	|
| Ensure zero downtime                                                   	| Deployment Strategy                    	|
| Endpoints of the web application are accessible outside the cluster    	| Using Ingress                          	|

e.g. https://www.tablesgenerator.com/markdown_tables#


5. Deploy App on local K8

```
helm upgrade --install ./runapp -f 
```
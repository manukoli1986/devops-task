* Ruby App On Local K8




Steps:

1. Clone the Ruby Code from GitHub

```
git clone https://github.com/manukoli1986/devops-task.git
```

2. Build a Docker Container Image. I am using below format to dockerize the ruby code. 

```
$ cd devops-task/Ruby_App_Deploy/Docker

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
helm create myfirstapp
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
helm upgrade --install myfirstapp ./helm  
```



6. Verify the application is running as expected on local k8 cluster. I am using Port-forward method from Rancher Desktop UI to verify it. 

Enabling Port-Forward 
![Screenshot](./img/port-forward.png.png)

```
devops-task/Ruby_App_Deploy/helm on  main [!?] is 📦 v0.1.0 via ⎈ v3.12.3 on ☁️ 
❯ curl localhost:49693 
Well, hello there%                                                                                                                                                                         
devops-task/Ruby_App_Deploy/helm on  main [!?] is 📦 v0.1.0 via ⎈ v3.12.3 on ☁️
❯ curl localhost:49693/healthcheck
OK%   
```



# Problem:

1. Getting below error when running the old ruby code on local k8. and dockerize it. When running on K8 cluster and using livenessprobe it is failing we tried to use httpget and tcpsocket but problem was same as it is using old http protocol.  


  ```
  http_server.rb:7:in `readpartial': end of file reached (EOFError)
    from http_server.rb:7:in `block in <main>'
    from http_server.rb:5:in `loop'
    from http_server.rb:5:in `<main>'

  ###   The error message "end of file reached (EOFError)" occurs because your code is trying to read from a socket that has reached the end of the file (EOF). In the context of a web server, this error typically means that the client has closed the connection, and your server is attempting to read from a closed socket.
  ```

  Even I tried to run first on docker and it was running but when hitting from chrome browser, it was throwing the above error. However, the Curl was running but by passing --http0.9 version. Like this..

  curl --http0.9  http://localhost:8080/healthcheck
  curl --http0.9  http://localhost:8080/

  But this is not the agenda of task. Hence I checked the code and with the help of google the issue could be resolved by adding error handling to check if the client socket is still open before attempting to read from it. Here's a modified version of your code that includes error handling for reading from the client socket:


```
require 'socket'

server = TCPServer.new(80)

loop do
  client = server.accept

  begin
    request = client.readpartial(2048)
  rescue EOFError
    # Client closed the connection, so we can't read more data.
    client.close
    next
  end

  method, path, version = request.lines[0].split

  if path == "/healthcheck"
    response = "HTTP/1.1 200 OK\r\nContent-Length: 2\r\n\r\nOK"
  else
    response = "HTTP/1.1 200 OK\r\nContent-Length: 17\r\n\r\nWell, hello there!"
  end

  client.write(response)
  client.close
end

```




# Module 3

This is an open-ended assignment, you are free to introduce changes, in the assigned time frame, to the application or in the instrumentation to meet your standards in terms of security, availability, reliability and observability.
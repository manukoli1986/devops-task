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

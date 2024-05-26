# Use an official Python runtime as the base image
FROM python:3.10-slim AS build

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Create the final image
FROM python:3.10-slim

# Set the working directory in the container
WORKDIR /app

# Copy the dependencies from the build stage
COPY --from=build /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages

# Copy the application source code into the container
COPY . .

# Expose the port the app runs on
EXPOSE 8080

# Specify the command to run the application
CMD ["python", "app.py"]
# Use an official Python runtime as a parent image
FROM python:3.11.13-alpine@sha256:8d8c6d3808243160605925c2a7ab2dc5c72d0e75651699b0639143613e0855b8 AS builder

# Set working directory
WORKDIR /app

# Copy the requirements file
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Use a smaller base image for the final image
FROM python:3.11.13-alpine@sha256:8d8c6d3808243160605925c2a7ab2dc5c72d0e75651699b0639143613e0855b8

# Set working directory
WORKDIR /app

# Copy the dependencies from the builder stage
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy the application files
COPY app /app

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Accept build arguments for versioning
ARG VERSION=unknown
ARG COMMIT_SHA=unknown
ARG BUILD_TIMESTAMP=unknown

ENV VERSION=${VERSION}
ENV COMMIT_SHA=${COMMIT_SHA}
ENV BUILD_TIMESTAMP=${BUILD_TIMESTAMP}

# Create a non-root user and switch to it
RUN adduser -D appuser
USER appuser

# Make port 8000 available to the world outside this container
EXPOSE 8000

# Use ENTRYPOINT to ensure the container runs as expected
ENTRYPOINT ["python", "-u", "main.py"]
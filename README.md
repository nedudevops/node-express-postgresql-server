# Node.js Express PostgreSQL API – DevOps Assessment

[![Build and Deploy Application](https://github.com/nedudevops/node-express-postgresql-server/actions/workflows/deploy.yml/badge.svg?branch=master)](https://github.com/nedudevops/node-express-postgresql-server/actions/workflows/deploy.yml)

## 1. Project Overview

This project demonstrates the containerization and deployment of an existing Node.js REST API application using Docker and Kubernetes.

The application uses Express.js to provide REST API endpoints and PostgreSQL as its database.

The DevOps implementation includes:

- Docker containerization of the existing Node.js application.
- PostgreSQL deployment on Kubernetes.
- Persistent storage using Kubernetes PersistentVolumeClaims.
- Kubernetes Secrets for database credentials and application environment variables.
- Automated Docker image building and publishing to GitHub Container Registry (GHCR).
- Continuous Integration and Continuous Deployment (CI/CD) using GitHub Actions.
- Automated application deployment to a local Minikube Kubernetes cluster.
- A self-hosted GitHub Actions runner configured as a background systemd service.

**An important project constraint was to deploy the existing application without modifying its original application source code.** All deployment-related changes were implemented through Docker, Kubernetes, and CI/CD configuration.

## 2. Technology Stack and Why I Chose These Tools

| Tool / Technology | Purpose | Why I Chose It |
|---|---|---|
| Node.js | Application runtime | The existing application is built with Node.js. |
| Express.js | REST API framework | It powers the existing API endpoints. |
| PostgreSQL | Relational database | It is the database technology already used by the application. |
| Docker | Containerization | Packages the application and its dependencies into a portable image. |
| Kubernetes | Container orchestration | Manages application and database containers, deployments, services, and storage. |
| Minikube | Local Kubernetes environment | Provides a practical way to run and test Kubernetes locally without a cloud cluster. |
| GitHub Actions | CI/CD automation | Integrates the build and deployment process directly with GitHub pushes. |
| GitHub Container Registry | Container image registry | Stores versioned Docker images associated with the GitHub repository. |
| Kubernetes Secrets | Configuration and credential management | Keeps database credentials outside the application manifests. |
| PersistentVolumeClaim | Persistent database storage | Provides storage for PostgreSQL beyond the lifecycle of an individual Pod. |
| socat | Database connection proxy | Bridges the application's localhost database connection to the PostgreSQL Kubernetes Service without changing application code. |
| systemd | Linux service management | Keeps the self-hosted GitHub Actions runner running in the background and starts it automatically when Ubuntu boots. |

## 3. Project Architecture

The application runs inside a Kubernetes cluster with two main workloads:

1. **Node.js application:** Runs the Express REST API and exposes port 3000.
2. **PostgreSQL database:** Stores application data and uses persistent storage.

A lightweight `socat` sidecar container runs alongside the Node.js application. It listens on localhost port 5432 and forwards database connections to the PostgreSQL Kubernetes Service.

This approach preserves the original application's database connection configuration.

The Node.js application is exposed externally through a Kubernetes NodePort Service on port 30080.

### Application architecture

```text
                   GitHub Repository
                          |
                          v
                   GitHub Actions
                          |
                   Build Docker Image
                          |
                          v
               GitHub Container Registry
                          |
                          v
                  Minikube Cluster
                          |
                  Kubernetes Deployment
                          |
               +----------------------+
               |   Node.js Pod        |
               |                      |
               |  Node.js Application |
               |          |           |
               |    Database Proxy    |
               +----------|-----------+
                          |
                          v
                  PostgreSQL Service
                          |
                          v
                  PostgreSQL Pod
                          |
                          v
                  Persistent Storage
```

## 4. Repository Structure

```text
node-express-postgresql-server/
│
├── .github/
│   └── workflows/
│       └── deploy.yml
│
├── k8s/
│   ├── node-app.yaml
│   ├── node-app-service.yaml
│   ├── postgres.yaml
│   └── postgres-pvc.yaml
│
├── src/
│   ├── index.js
│   ├── models/
│   └── routes/
│
├── Dockerfile
├── .dockerignore
├── docker-compose.yml
├── package.json
├── package-lock.json
└── README.md
```

## 5. Running the Project Locally

### Prerequisites

Install the following tools:

- Git
- Node.js and npm
- Docker
- Docker Compose

### Step 1: Clone the repository

```bash
git clone https://github.com/nedudevops/node-express-postgresql-server.git
cd node-express-postgresql-server
```

### Step 2: Install dependencies

```bash
npm install
```

### Step 3: Configure environment variables

Create a local `.env` file in the project root.

The application requires:

```env
PORT=3000
DATABASE=mydatabase
DATABASE_USER=your_database_user
DATABASE_PASSWORD=your_database_password
```

Use credentials that match the PostgreSQL configuration in your local Docker Compose setup.

Do not commit `.env` to GitHub.

### Step 4: Start PostgreSQL

```bash
docker-compose up -d
```

This starts the PostgreSQL and pgAdmin services defined in the existing Docker Compose configuration.

### Step 5: Start the Node.js application

```bash
npm start
```

The application listens on port 3000.

### Step 6: Test the API

Open the following endpoints in a browser:

```text
http://localhost:3000/users
http://localhost:3000/users/1
http://localhost:3000/messages
http://localhost:3000/messages/1
```

Alternatively, use curl:

```bash
curl http://localhost:3000/users
```

```bash
curl http://localhost:3000/messages
```

## 6. Docker Containerization

A Dockerfile was created to package the existing Node.js application into a Docker image.

The Dockerfile uses Node.js 20 Alpine as its base image, installs dependencies using `npm ci`, copies the application files, and starts the application using `npm start`.

### Build the Docker image

```bash
docker build -t node-postgres-api:1.0 .
```

### Verify the image

```bash
docker images
```

### Docker build exclusions

The `.dockerignore` file excludes unnecessary files from the build context, including:

- `node_modules`
- `.git`
- `.env`
- npm debug logs
- Coverage files

This reduces unnecessary build context data and helps prevent environment credentials from being copied into the image.

## 7. Kubernetes Deployment

The application and PostgreSQL database are deployed to a local Kubernetes cluster using Minikube.

### Step 1: Start Minikube

```bash
minikube start --driver=docker
```

Verify the cluster:

```bash
minikube kubectl -- get nodes
```

### Step 2: Create the namespace

```bash
minikube kubectl -- create namespace devops-assessment
```

### Step 3: Configure Kubernetes Secrets

Two Kubernetes Secrets are used:

- `postgres-secret`: Stores the PostgreSQL username, password, and database name.
- `app-secrets`: Stores the application's environment variables.

The Secrets are created from the local `.env` configuration and are not committed as plain-text credentials in the repository.

### Step 4: Create persistent storage

Apply the PersistentVolumeClaim:

```bash
minikube kubectl -- apply -f k8s/postgres-pvc.yaml
```

Verify storage:

```bash
minikube kubectl -- get pvc -n devops-assessment
```

### Step 5: Deploy PostgreSQL

```bash
minikube kubectl -- apply -f k8s/postgres.yaml
```

### Step 6: Deploy the Node.js application

```bash
minikube kubectl -- apply -f k8s/node-app.yaml
```

### Step 7: Expose the application

```bash
minikube kubectl -- apply -f k8s/node-app-service.yaml
```

### Step 8: Verify Kubernetes resources

```bash
minikube kubectl -- get pods -n devops-assessment
```

```bash
minikube kubectl -- get services -n devops-assessment
```

```bash
minikube kubectl -- get deployments -n devops-assessment
```

## 8. Accessing the Deployed Application

The Node.js application is exposed using a Kubernetes NodePort Service on port 30080.

Get the Minikube IP:

```bash
minikube ip
```

Access the API using:

```text
http://MINIKUBE_IP:30080
```

Replace `MINIKUBE_IP` with the IP returned by the command.

### Available GET routes

| Endpoint | Description |
|---|---|
| `/users` | Retrieve all users |
| `/users/1` | Retrieve a user by ID |
| `/messages` | Retrieve all messages |
| `/messages/1` | Retrieve a message by ID |

### Test with curl

```bash
curl http://MINIKUBE_IP:30080/users
```

```bash
curl http://MINIKUBE_IP:30080/messages
```

```bash
curl http://MINIKUBE_IP:30080/users/1
```

## 9. CI/CD Pipeline with GitHub Actions

A GitHub Actions workflow was configured in:

```text
.github/workflows/deploy.yml
```

The pipeline automatically runs whenever changes are pushed to the `master` branch. It can also be triggered manually through GitHub Actions.

### Pipeline stages

**Stage 1 – Checkout**

GitHub Actions checks out the latest repository code.

**Stage 2 – Authentication**

The workflow authenticates with GitHub Container Registry using the automatically provided GitHub Actions token.

**Stage 3 – Build**

Docker builds a new image of the Node.js application.

**Stage 4 – Publish**

The image is published to GitHub Container Registry using two tags:

- The Git commit SHA.
- `latest`.

**Stage 5 – Deploy**

The workflow updates the Kubernetes Node.js Deployment with the newly published image.

**Stage 6 – Verify**

Kubernetes rollout status is checked to confirm that the new application deployment becomes available.

### CI/CD execution environment

The pipeline uses a self-hosted GitHub Actions runner installed on an Ubuntu virtual machine.

The runner has access to Docker and the local Minikube Kubernetes cluster.

### Container registry

Docker images are published to:

```text
ghcr.io/nedudevops/node-express-postgresql-server
```

### Self-Hosted GitHub Actions Runner

This project uses a self-hosted GitHub Actions runner installed on an Ubuntu virtual machine running VirtualBox.

The runner is configured as a systemd service so it operates in the background without requiring an interactive terminal.

**Benefits:**

- Runs GitHub Actions jobs directly on the Ubuntu VM.
- Starts automatically when Ubuntu boots.
- Allows the deployment workflow to access the local Docker environment and Minikube cluster.
- Eliminates the need to manually run `./run.sh` in an open terminal.

#### Runner installation and configuration

The runner was downloaded, configured, and registered with the GitHub repository using the GitHub Actions runner setup instructions.

After registration, the service was installed from the runner directory:

```bash
cd ~/actions-runner
sudo ./svc.sh install
```

The service was then started:

```bash
sudo ./svc.sh start
```

The service installation enables it to start automatically when Ubuntu boots.

#### Runner management commands

Run these commands from `~/actions-runner`:

```bash
# Check runner status
sudo ./svc.sh status

# Start the runner
sudo ./svc.sh start

# Stop the runner
sudo ./svc.sh stop

# Restart the runner
sudo ./svc.sh restart
```

#### Important operational notes

- The Ubuntu VM must be powered on and connected to the internet.
- The runner service must be active for GitHub Actions jobs to execute.
- Docker must be available to the runner.
- Minikube must be running for Kubernetes deployment jobs to succeed.
- After restarting the VM, verify that the runner service is active and start Minikube if it is not already running.

The runner can now operate in the background without keeping a terminal open.

## 10. Assumptions and Engineering Trade-offs

Several decisions were made to meet the assessment requirements while keeping the implementation manageable and preserving the original application.

### 10.1 Local Kubernetes instead of a cloud cluster

**Assumption:** A local Kubernetes environment would be sufficient to demonstrate the deployment requirements.

**Decision:** Minikube was selected to provide a local Kubernetes cluster.

**Trade-off:** This avoids cloud infrastructure costs and makes testing accessible, but it does not demonstrate deployment to a production-grade managed Kubernetes service.

### 10.2 Existing application source code was preserved

**Assumption:** The application was to be deployed as provided, without changes to its original source code.

**Decision:** All infrastructure and deployment changes were implemented outside the application source.

**Trade-off:** Some application configuration limitations had to be handled at the infrastructure level.

### 10.3 Database proxy sidecar

The original application uses a localhost PostgreSQL connection rather than an explicitly configured Kubernetes database hostname.

**Decision:** A `socat` sidecar container was introduced to forward localhost port 5432 to the PostgreSQL Kubernetes Service.

**Trade-off:** This avoids modifying the application code but introduces an additional container and a proxy dependency within the application Pod.

### 10.4 Single application and database replicas

**Decision:** One replica was configured for the Node.js application and one for PostgreSQL.

**Trade-off:** This is sufficient for a local assessment environment but does not provide high availability or database failover.

### 10.5 Self-hosted GitHub Actions runner

**Decision:** A self-hosted runner was installed on the Ubuntu virtual machine and configured as a systemd service.

**Reason:** It provides access to the local Docker environment and Minikube cluster, allowing the workflow to deploy directly to the local Kubernetes environment.

**Trade-off:** The virtual machine must remain powered on and connected to the internet. The runner service must be active, and Minikube must be running for automated Kubernetes deployments to succeed.

Configuring the runner as a systemd service removes the need to keep an interactive terminal open and allows the runner to start automatically when Ubuntu boots.

### 10.6 Kubernetes Secrets

**Decision:** Database credentials and application environment variables were supplied through Kubernetes Secrets.

**Trade-off:** Kubernetes Secrets help separate sensitive configuration from application manifests, but they are not automatically equivalent to an external secrets manager or encrypted secret-management solution. Production deployments should use appropriate encryption-at-rest and access-control policies.

### 10.7 Database initialization behavior

The original application includes database synchronization behavior that recreates tables on startup.

**Trade-off:** This is convenient for a demonstration application, but it is not appropriate for production data management because application restarts can result in data loss. A production implementation should use controlled database migrations.

## 11. Testing and Validation

The implementation was tested at several stages.

### Docker validation

- Successfully built the Node.js Docker image.
- Successfully ran the container and verified API responses.

### Kubernetes validation

- Confirmed that the Minikube cluster was running.
- Confirmed that the PostgreSQL Pod was running.
- Confirmed that the Node.js application Pod was running with both containers ready.
- Confirmed that the PostgreSQL PersistentVolumeClaim was bound.
- Confirmed that the Node.js Deployment was available.

### CI/CD validation

- Successfully executed the GitHub Actions workflow.
- Successfully built and published the Docker image to GHCR.
- Successfully updated the Kubernetes Deployment using the commit-specific image tag.
- Confirmed that the Kubernetes rollout completed successfully.
- Confirmed that the self-hosted runner successfully connected to GitHub and operated as a background systemd service.

### API validation

The following endpoints were successfully tested against the deployed application:

| Endpoint | Result |
|---|---|
| `GET /users` | Passed |
| `GET /users/1` | Passed |
| `GET /messages` | Passed |
| `GET /messages/1` | Passed |

## 12. What I Would Improve With More Time

Although the assessment implementation is functional, several improvements would make it more suitable for a production environment.

### 12.1 Use a managed Kubernetes environment

Deploy the application to a managed Kubernetes platform such as Amazon EKS, Azure AKS, or Google GKE.

This would provide a more realistic production deployment environment.

### 12.2 Improve database connection configuration

Where application changes are permitted, configure the database hostname through environment variables rather than relying on localhost.

This would remove the need for the `socat` sidecar proxy.

### 12.3 Introduce database migrations

Replace destructive database synchronization with a controlled database migration strategy.

This would help preserve application data across deployments and restarts.

### 12.4 Improve application availability

Introduce multiple application replicas, readiness and liveness probes, and appropriate resource requests and limits.

For PostgreSQL, use a more robust database architecture with appropriate backup and recovery procedures rather than simply increasing replicas.

### 12.5 Strengthen security

- Use a dedicated secret-management solution.
- Enable encryption at rest for Kubernetes Secrets.
- Apply stricter Kubernetes RBAC permissions.
- Use non-root containers where supported.
- Scan Docker images for known vulnerabilities.
- Add TLS and appropriate network security controls.

### 12.6 Add automated testing

Introduce automated tests into the GitHub Actions pipeline.

For example:

- Dependency and build checks.
- Unit tests.
- API integration tests.
- Docker image vulnerability scanning.
- Deployment smoke tests.

### 12.7 Improve monitoring and observability

Introduce monitoring and centralized logging using tools such as Prometheus, Grafana, and an appropriate log aggregation platform.

This would make it easier to identify application failures, resource bottlenecks, and database issues.

### 12.8 Improve deployment strategy

Introduce deployment strategies such as rolling updates with more comprehensive health checks, or blue-green deployment for environments requiring reduced downtime.

### 12.9 Improve infrastructure management

Manage Kubernetes resources through Helm charts or another infrastructure-as-code approach to make deployments easier to configure, reproduce, and maintain.

## 13. Project Outcome

This assessment demonstrates the ability to:

- Containerize an existing Node.js application using Docker.
- Deploy Node.js and PostgreSQL to Kubernetes.
- Configure persistent database storage.
- Manage application configuration and credentials using Kubernetes Secrets.
- Build and publish Docker images automatically.
- Implement CI/CD using GitHub Actions.
- Automate Kubernetes application deployments.
- Configure a self-hosted GitHub Actions runner as a systemd service.
- Test and validate deployed REST API endpoints.
- Identify infrastructure trade-offs and potential production improvements.

**The application was successfully containerized, deployed, and tested on a local Minikube Kubernetes cluster, with an operational GitHub Actions pipeline automating image publication and deployment.**

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
| Ubuntu 26.04 LTS | Operating system | Provides the Linux environment for development and deployment. |
| VirtualBox | Virtualization | Provides an isolated Ubuntu virtual machine. |
| Git | Version control | Tracks changes and manages the project repository. |
| Node.js | Application runtime | The existing application is built with Node.js. |
| Express.js | REST API framework | Powers the existing API endpoints. |
| PostgreSQL | Relational database | The database technology already used by the application. |
| Docker | Containerization | Packages the application and its dependencies into a portable image. |
| Docker Compose | Local container management | Runs the local PostgreSQL and pgAdmin services. |
| Kubernetes | Container orchestration | Manages application and database containers, deployments, services, and storage. |
| Minikube | Local Kubernetes environment | Provides a practical way to run and test Kubernetes locally. |
| GitHub Actions | CI/CD automation | Automates the build and deployment process whenever changes are pushed to GitHub. |
| GitHub Container Registry | Container image registry | Stores versioned Docker images associated with the GitHub repository. |
| Kubernetes Secrets | Configuration and credential management | Keeps database credentials outside application manifests. |
| PersistentVolumeClaim | Persistent database storage | Provides storage for PostgreSQL beyond the lifecycle of an individual Pod. |
| socat | Database connection proxy | Bridges the application's localhost database connection to the PostgreSQL Kubernetes Service without changing application code. |
| systemd | Linux service management | Keeps the self-hosted GitHub Actions runner running in the background and starts it automatically when Ubuntu boots. |

## 3. Environment and Prerequisites

### 3.1 Development environment

The project was implemented and tested using:

| Component | Environment |
|---|---|
| Operating System | Ubuntu 26.04 LTS |
| Virtualization | Oracle VirtualBox |
| CPU | 4 CPUs |
| Memory | Approximately 7.1 GiB |
| Disk | 25 GB |
| Docker Engine | 29.9.2 |
| Docker Compose | 5.7.0 |
| Minikube | 1.39.0 |
| Kubernetes | 1.37.0 |
| GitHub Actions Runner | 2.338.2 |
| Container Registry | GitHub Container Registry |

These are the versions used during implementation. Other compatible versions may work.

### 3.2 Required tools

Before deploying the application, install the following:

- Git
- Node.js and npm
- Docker Engine
- Docker Compose plugin
- Minikube
- curl and wget
- A GitHub account

The Kubernetes command-line client can be accessed through `minikube kubectl`, so a separate kubectl installation is not required for this implementation.

## 4. Installing the Required Tools on Ubuntu

The following instructions describe the Ubuntu environment used for this assessment.

### 4.1 Update Ubuntu

```bash
sudo apt update
sudo apt upgrade -y
```

Install common utilities:

```bash
sudo apt install -y git curl wget ca-certificates gnupg
```

Verify Git:

```bash
git --version
```

### 4.2 Install Node.js and npm

Install Node.js 20 using Node Version Manager (nvm):

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
```

Reload the shell configuration:

```bash
source ~/.bashrc
```

Install Node.js 20:

```bash
nvm install 20
nvm use 20
```

Verify the installations:

```bash
node --version
npm --version
```

### 4.3 Install Docker Engine and Docker Compose

Install the required packages:

```bash
sudo apt update
sudo apt install -y ca-certificates curl
```

Create the Docker keyring directory:

```bash
sudo install -m 0755 -d /etc/apt/keyrings
```

Download the official Docker signing key:

```bash
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc
```

Set the correct permissions:

```bash
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

Add the Docker repository:

```bash
sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
```

Update package lists:

```bash
sudo apt update
```

Install Docker Engine, Docker CLI, containerd, Buildx, and Docker Compose:

```bash
sudo apt install -y docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin
```

Start Docker:

```bash
sudo systemctl enable --now docker
```

Verify Docker:

```bash
sudo docker version
```

Verify Docker Compose:

```bash
docker compose version
```

#### Configure Docker to run without sudo

Add your Ubuntu user to the Docker group:

```bash
sudo usermod -aG docker $USER
```

Apply the group membership in the current terminal:

```bash
newgrp docker
```

Alternatively, log out and log back in.

Verify Docker access:

```bash
docker ps
```

If the command works without `sudo`, Docker permissions are configured.

**Security note:** Membership in the Docker group grants highly privileged access to the host. Only trusted users should be added.

### 4.4 Install Minikube

Download Minikube version 1.39.0:

```bash
curl -LO https://storage.googleapis.com/minikube/releases/v1.39.0/minikube-linux-amd64
```

Install the binary:

```bash
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

Verify the installation:

```bash
minikube version
```

Start Minikube using Docker as the driver:

```bash
minikube start --driver=docker
```

Verify the cluster:

```bash
minikube kubectl -- get nodes
```

The expected result is a Kubernetes node with a `Ready` status.

### 4.5 Verify Kubernetes access

This project uses Minikube's bundled kubectl command:

```bash
minikube kubectl -- get nodes
```

Check all Kubernetes system Pods:

```bash
minikube kubectl -- get pods -A
```

Check the Kubernetes StorageClasses:

```bash
minikube kubectl -- get storageclass
```

The default Minikube StorageClass is used for PostgreSQL persistent storage.

## 5. Repository Structure

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

## 6. Running the Project Locally

### Step 1: Clone the repository

```bash
git clone https://github.com/nedudevops/node-express-postgresql-server.git
cd node-express-postgresql-server
```

### Step 2: Install application dependencies

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

Use credentials that match the PostgreSQL configuration in the local Docker Compose setup.

Do not commit `.env` to GitHub.

### Step 4: Start PostgreSQL

```bash
docker compose up -d
```

This starts the PostgreSQL and pgAdmin services defined in the existing Docker Compose configuration.

### Step 5: Start the Node.js application

```bash
npm start
```

The application listens on port 3000.

### Step 6: Test the API

```text
http://localhost:3000/users
http://localhost:3000/users/1
http://localhost:3000/messages
http://localhost:3000/messages/1
```

Alternatively:

```bash
curl http://localhost:3000/users
curl http://localhost:3000/messages
```

## 7. Docker Containerization

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

## 8. Kubernetes Deployment

The application and PostgreSQL database are deployed to a local Kubernetes cluster using Minikube.

### Step 1: Start Minikube

```bash
minikube start --driver=docker
```

### Step 2: Create the namespace

```bash
minikube kubectl -- create namespace devops-assessment
```

### Step 3: Configure Kubernetes Secrets

Two Kubernetes Secrets are used:

- `postgres-secret`: Stores the PostgreSQL username, password, and database name.
- `app-secrets`: Stores the application's environment variables.

The Secrets are created from the local `.env` file.

From the project root, load the environment variables without printing them:

```bash
set -a
source .env
set +a
```

Create or update the PostgreSQL Secret:

```bash
minikube kubectl -- create secret generic postgres-secret \
  -n devops-assessment \
  --from-literal=POSTGRES_USER="$DATABASE_USER" \
  --from-literal=POSTGRES_PASSWORD="$DATABASE_PASSWORD" \
  --from-literal=POSTGRES_DB="$DATABASE" \
  --dry-run=client -o yaml | minikube kubectl -- apply -f -
```

Create or update the application Secret:

```bash
minikube kubectl -- create secret generic app-secrets \
  -n devops-assessment \
  --from-env-file=.env \
  --dry-run=client -o yaml | minikube kubectl -- apply -f -
```

Clean up the exported shell variables:

```bash
unset DATABASE_USER DATABASE_PASSWORD DATABASE
```

**Important:** Never commit `.env` or real credentials to GitHub. Kubernetes Secrets are base64-encoded by default, not automatically encrypted. Production environments should use encryption at rest and appropriate access controls.

### Step 4: Create persistent storage

Apply the PersistentVolumeClaim:

```bash
minikube kubectl -- apply -f k8s/postgres-pvc.yaml
```

Verify storage:

```bash
minikube kubectl -- get pvc -n devops-assessment
```

The PVC should eventually show `Bound`.

### Step 5: Deploy PostgreSQL

```bash
minikube kubectl -- apply -f k8s/postgres.yaml
```

Wait for PostgreSQL:

```bash
minikube kubectl -- rollout status deployment/postgres \
  -n devops-assessment
```

### Step 6: Load the application image into Minikube

For the initial local deployment, load the locally built image:

```bash
minikube image load node-postgres-api:1.0
```

The CI/CD pipeline subsequently publishes and deploys images from GHCR.

### Step 7: Deploy the Node.js application

```bash
minikube kubectl -- apply -f k8s/node-app.yaml
```

### Step 8: Expose the application

```bash
minikube kubectl -- apply -f k8s/node-app-service.yaml
```

### Step 9: Verify Kubernetes resources

```bash
minikube kubectl -- get pods -n devops-assessment
minikube kubectl -- get services -n devops-assessment
minikube kubectl -- get deployments -n devops-assessment
minikube kubectl -- get pvc -n devops-assessment
```

## 9. Accessing the Deployed Application

The Node.js application is exposed using a Kubernetes NodePort Service on port 30080.

Get the Minikube IP:

```bash
minikube ip
```

Access the API using:

```text
http://MINIKUBE_IP:30080
```

Replace `MINIKUBE_IP` with the address returned by the command.

### Available GET routes

| Endpoint | Description |
|---|---|
| `/users` | Retrieve all users |
| `/users/1` | Retrieve a user by ID |
| `/messages` | Retrieve all messages |
| `/messages/1` | Retrieve a message by ID |

### Test with curl

```bash
curl http://$(minikube ip):30080/users
```

```bash
curl http://$(minikube ip):30080/messages
```

```bash
curl http://$(minikube ip):30080/users/1
```

## 10. CI/CD Pipeline with GitHub Actions

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

### Container registry

Docker images are published to:

```text
ghcr.io/nedudevops/node-express-postgresql-server
```

### Workflow trigger

The workflow runs on pushes to `master`.

It also supports manual execution using `workflow_dispatch`.

### GitHub repository permissions

The GitHub Actions workflow uses repository permissions to read the source code and publish packages.

The `GITHUB_TOKEN` is used for authentication with GHCR, avoiding the need to store a separate registry password in the repository.

## 11. Self-Hosted GitHub Actions Runner

This project uses a self-hosted GitHub Actions runner installed on an Ubuntu virtual machine running VirtualBox.

The runner has access to the local Docker environment and Minikube cluster, allowing the CI/CD workflow to deploy directly to Kubernetes.

### 11.1 Runner installation

The runner was downloaded and configured using the Linux x64 instructions provided by GitHub:

1. Open the GitHub repository.
2. Navigate to Settings.
3. Select Actions.
4. Select Runners.
5. Choose New self-hosted runner.
6. Select Linux and x64.
7. Follow the displayed download and configuration instructions.

The runner was installed in:

```text
~/actions-runner
```

**Security note:** Runner registration tokens are temporary and should never be committed to the repository or included in documentation.

### 11.2 Configure the runner as a systemd service

After registering the runner, install the service:

```bash
cd ~/actions-runner
sudo ./svc.sh install
```

Start the service:

```bash
sudo ./svc.sh start
```

Verify its status:

```bash
sudo ./svc.sh status
```

The expected status is:

```text
Active: active (running)
```

The service is enabled to start automatically when Ubuntu boots.

### 11.3 Runner management commands

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

### 11.4 Operational requirements

- The Ubuntu VM must be powered on and connected to the internet.
- The runner service must be active for GitHub Actions jobs to execute.
- Docker must be available to the runner.
- Minikube must be running for Kubernetes deployment jobs to succeed.
- After restarting the VM, verify that the runner service is active and start Minikube if it is not already running.

Configuring the runner as a systemd service removes the need to keep an interactive terminal open.

## 12. Assumptions and Engineering Trade-offs

Several decisions were made to meet the assessment requirements while keeping the implementation manageable and preserving the original application.

### 12.1 Local Kubernetes instead of a cloud cluster

**Assumption:** A local Kubernetes environment would be sufficient to demonstrate the deployment requirements.

**Decision:** Minikube was selected to provide a local Kubernetes cluster.

**Trade-off:** This avoids cloud infrastructure costs and makes testing accessible, but it does not demonstrate deployment to a production-grade managed Kubernetes service.

### 12.2 Existing application source code was preserved

**Assumption:** The application was to be deployed as provided, without changes to its original source code.

**Decision:** All infrastructure and deployment changes were implemented outside the application source.

**Trade-off:** Some application configuration limitations had to be handled at the infrastructure level.

### 12.3 Database proxy sidecar

The original application uses a localhost PostgreSQL connection rather than an explicitly configured Kubernetes database hostname.

**Decision:** A `socat` sidecar container was introduced to forward localhost port 5432 to the PostgreSQL Kubernetes Service.

**Trade-off:** This avoids modifying application code but introduces an additional container and a proxy dependency within the application Pod.

### 12.4 Single application and database replicas

**Decision:** One replica was configured for the Node.js application and one for PostgreSQL.

**Trade-off:** This is sufficient for a local assessment environment but does not provide high availability or database failover.

### 12.5 Self-hosted GitHub Actions runner

**Decision:** A self-hosted runner was installed on the Ubuntu virtual machine and configured as a systemd service.

**Reason:** It provides access to the local Docker environment and Minikube cluster, allowing the workflow to deploy directly to the local Kubernetes environment.

**Trade-off:** The virtual machine must remain powered on and connected to the internet. Minikube must also be running for Kubernetes deployment jobs to succeed.

### 12.6 Kubernetes Secrets

**Decision:** Database credentials and application environment variables were supplied through Kubernetes Secrets.

**Trade-off:** Kubernetes Secrets help separate sensitive configuration from application manifests, but production deployments should use appropriate encryption-at-rest and access-control policies.

### 12.7 Database initialization behavior

The original application includes database synchronization behavior that recreates tables on startup.

**Trade-off:** This is convenient for a demonstration application, but it is not appropriate for production data management because application restarts can result in data loss. A production implementation should use controlled database migrations.

## 13. Testing and Validation

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
- Verified multiple successful GitHub Actions workflow runs.

### API validation

The following endpoints were successfully tested against the deployed application:

| Endpoint | Result |
|---|---|
| `GET /users` | Passed |
| `GET /users/1` | Passed |
| `GET /messages` | Passed |
| `GET /messages/1` | Passed |

## 14. What I Would Improve With More Time

Although the assessment implementation is functional, several improvements would make it more suitable for a production environment.

### 14.1 Use a managed Kubernetes environment

Deploy the application to a managed Kubernetes platform such as Amazon EKS, Azure AKS, or Google GKE.

This would provide a more realistic production deployment environment.

### 14.2 Improve database connection configuration

Where application changes are permitted, configure the database hostname through environment variables rather than relying on localhost.

This would remove the need for the `socat` sidecar proxy.

### 14.3 Introduce database migrations

Replace destructive database synchronization with a controlled database migration strategy.

This would help preserve application data across deployments and restarts.

### 14.4 Improve application availability

Introduce multiple application replicas, readiness and liveness probes, and appropriate resource requests and limits.

For PostgreSQL, use a more robust database architecture with appropriate backup and recovery procedures rather than simply increasing replicas.

### 14.5 Strengthen security

- Use a dedicated secret-management solution.
- Enable encryption at rest for Kubernetes Secrets.
- Apply stricter Kubernetes RBAC permissions.
- Use non-root containers where supported.
- Scan Docker images for known vulnerabilities.
- Add TLS and appropriate network security controls.

### 14.6 Add automated testing

Introduce automated tests into the GitHub Actions pipeline.

For example:

- Dependency and build checks.
- Unit tests.
- API integration tests.
- Docker image vulnerability scanning.
- Deployment smoke tests.

### 14.7 Improve monitoring and observability

Introduce monitoring and centralized logging using tools such as Prometheus, Grafana, and an appropriate log aggregation platform.

This would make it easier to identify application failures, resource bottlenecks, and database issues.

### 14.8 Improve deployment strategy

Introduce deployment strategies such as rolling updates with more comprehensive health checks, or blue-green deployment for environments requiring reduced downtime.

### 14.9 Improve infrastructure management

Manage Kubernetes resources through Helm charts or another infrastructure-as-code approach to make deployments easier to configure, reproduce, and maintain.

## 15. Project Outcome

This assessment demonstrates the ability to:

- Prepare a Linux environment for DevOps activities.
- Install and configure the required development and deployment tools.
- Use Git and GitHub for version control.
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

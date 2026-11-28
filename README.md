# Node.js Express PostgreSQL API – DevOps Assessment

## 1. Project Overview

This project demonstrates the containerization and deployment of an existing Node.js REST API application using Docker and Kubernetes.

The original application was created by [Rwieruch](https://github.com/rwieruch/node-express-postgresql-server). It is a Node.js and Express REST API that uses PostgreSQL as its database.

The objective of this assessment is to take the original application, containerize it, deploy it to a local Kubernetes cluster, and implement an automated CI/CD pipeline.

The implementation includes:

- Docker containerization of the existing Node.js application.
- PostgreSQL deployment on Kubernetes.
- Persistent database storage using Kubernetes PersistentVolumeClaims.
- Kubernetes Secrets for application configuration and database credentials.
- Automated Docker image building and publishing to GitHub Container Registry (GHCR).
- Continuous Integration and Continuous Deployment using GitHub Actions.
- Automated deployment to a local Minikube Kubernetes cluster.
- A self-hosted GitHub Actions runner configured as a background systemd service.

**Important:** The original application source code is preserved without modification. All DevOps-related additions are implemented through Docker, Kubernetes, and GitHub Actions configuration files.

## 2. Original Repository and Final Repository

This project starts from the original repository:

**Original repository:**
https://github.com/rwieruch/node-express-postgresql-server

The completed implementation is published in my fork:

**My repository:**
https://github.com/nedudevops/node-express-postgresql-server

The original repository contains the application source code. It does not contain the Dockerfile, Kubernetes manifests, or GitHub Actions workflow created for this assessment.

Those files are added during the implementation.

The relationship between the repositories is:

| Repository | Purpose |
|---|---|
| `rwieruch/node-express-postgresql-server` | Original application used as the starting point |
| `nedudevops/node-express-postgresql-server` | My fork containing the completed DevOps implementation |

## 3. Technology Stack

| Tool / Technology | Purpose |
|---|---|
| Ubuntu 26.04 LTS | Operating system |
| VirtualBox | Virtualization |
| Git | Version control |
| Node.js | Application runtime |
| Express.js | REST API framework |
| PostgreSQL | Relational database |
| Docker | Application containerization |
| Docker Compose | Local container management |
| Kubernetes | Container orchestration |
| Minikube | Local Kubernetes environment |
| GitHub Actions | CI/CD automation |
| GitHub Container Registry | Docker image storage |
| Kubernetes Secrets | Application configuration and credentials |
| PersistentVolumeClaim | Persistent PostgreSQL storage |
| socat | Database connection proxy |
| systemd | Self-hosted runner service management |

## 4. Environment and Prerequisites

The project was implemented and tested using:

| Component | Version / Configuration |
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

Required tools:

- Git
- Node.js and npm
- Docker Engine
- Docker Compose plugin
- Minikube
- curl and wget
- GitHub account

The instructions below describe the environment used for this assessment. Compatible versions may also work.

## 5. Installing the Required Tools on Ubuntu

### 5.1 Update Ubuntu

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

### 5.2 Install Node.js and npm

Install Node Version Manager:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
```

Reload the shell:

```bash
source ~/.bashrc
```

Install Node.js 20:

```bash
nvm install 20
nvm use 20
```

Verify:

```bash
node --version
npm --version
```

### 5.3 Install Docker Engine and Docker Compose

Install the required packages:

```bash
sudo apt update
sudo apt install -y ca-certificates curl
```

Create the Docker keyring directory:

```bash
sudo install -m 0755 -d /etc/apt/keyrings
```

Download the Docker signing key:

```bash
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc
```

Set permissions:

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

Install Docker:

```bash
sudo apt install -y docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin
```

Start Docker:

```bash
sudo systemctl enable --now docker
```

Verify:

```bash
sudo docker version
docker compose version
```

#### Configure Docker to run without sudo

```bash
sudo usermod -aG docker $USER
newgrp docker
```

Verify:

```bash
docker ps
```

If the command works without `sudo`, Docker permissions are configured.

**Security note:** Membership in the Docker group grants highly privileged access to the host. Only trusted users should be added.

### 5.4 Install Minikube

Download Minikube version 1.39.0:

```bash
curl -LO https://storage.googleapis.com/minikube/releases/v1.39.0/minikube-linux-amd64
```

Install:

```bash
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

Verify:

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

Check Kubernetes system Pods:

```bash
minikube kubectl -- get pods -A
```

Check StorageClasses:

```bash
minikube kubectl -- get storageclass
```

This project uses `minikube kubectl --` to run Kubernetes commands.

## 6. Forking and Cloning the Original Repository

This is the starting point of the actual project implementation.

### Step 1: Fork the original repository

Open:

https://github.com/rwieruch/node-express-postgresql-server

On GitHub:

1. Click **Fork**.
2. Select your GitHub account.
3. Create the fork.

The fork should be available at:

```text
https://github.com/nedudevops/node-express-postgresql-server
```

At this stage, your fork contains the original application. It does not yet contain the DevOps implementation.

### Step 2: Clone the original repository

Clone Rwieruch's original repository, not your fork:

```bash
git clone https://github.com/rwieruch/node-express-postgresql-server.git
```

Enter the project directory:

```bash
cd node-express-postgresql-server
```

### Step 3: Configure Git remotes

The original repository is initially configured as the remote named `origin`.

Rename it to `upstream`:

```bash
git remote rename origin upstream
```

Add your own fork as the new `origin`:

```bash
git remote add origin https://github.com/nedudevops/node-express-postgresql-server.git
```

Verify:

```bash
git remote -v
```

The result should show:

```text
origin    https://github.com/nedudevops/node-express-postgresql-server.git
upstream  https://github.com/rwieruch/node-express-postgresql-server.git
```

This arrangement means:

- `upstream` points to the original project.
- `origin` points to your own GitHub fork.

### Step 4: Push the original project to your fork

Check the current branch:

```bash
git branch --show-current
```

The original project uses the `master` branch.

Push it to your fork:

```bash
git push -u origin master
```

Your own GitHub repository now contains the original application, ready for the DevOps implementation.

**From this point onward, all new project files and changes will be committed and pushed to your own fork. The original Rwieruch repository remains the upstream source.**

## 7. Understanding the Original Application

Before containerization, inspect the original project.

The application is a Node.js and Express REST API that connects to PostgreSQL.

Its environment variables include:

| Variable | Purpose |
|---|---|
| `PORT` | Application listening port |
| `DATABASE` | PostgreSQL database name |
| `DATABASE_USER` | PostgreSQL username |
| `DATABASE_PASSWORD` | PostgreSQL password |

The application exposes endpoints for users and messages.

### Install dependencies

From the project root:

```bash
npm install
```

### Configure environment variables

Create a local `.env` file:

```env
PORT=3000
DATABASE=mydatabase
DATABASE_USER=your_database_user
DATABASE_PASSWORD=your_database_password
```

Use credentials matching the PostgreSQL configuration in the original Docker Compose setup.

Do not commit `.env` to GitHub.

### Start the local database

The original repository already contains a Docker Compose configuration for PostgreSQL and pgAdmin.

Start the services:

```bash
docker compose up -d
```

### Start the application

```bash
npm start
```

### Test the original application

```bash
curl http://localhost:3000/users
curl http://localhost:3000/messages
```

Other available routes include:

```text
/users/1
/messages/1
```

This confirms that the original application works before introducing the DevOps configuration.

## 8. Adding Docker Configuration

The original repository does not contain the Dockerfile or `.dockerignore` created for this assessment.

These files must be added.

### Step 1: Create the Dockerfile

From the project root:

```bash
nano Dockerfile
```

Add:

```dockerfile
# Use Node.js 20
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```

Save the file.

### Step 2: Create the .dockerignore file

```bash
nano .dockerignore
```

Add:

```text
node_modules
npm-debug.log
.git
.github
.env
.env.*
!.env.example
coverage
.DS_Store
```

This prevents unnecessary files and local environment credentials from being included in the Docker build context.

### Step 3: Build the Docker image

```bash
docker build -t node-postgres-api:1.0 .
```

Verify:

```bash
docker images
```

### Step 4: Test the Docker image

The existing application defaults to a localhost database connection. For this local test, use the host network so that the container can access the PostgreSQL service running on the Ubuntu host.

Make sure PostgreSQL is running through Docker Compose.

Run:

```bash
docker run -d \
  --name node-api \
  --network host \
  --env-file .env \
  node-postgres-api:1.0
```

Test:

```bash
curl http://localhost:3000/users
curl http://localhost:3000/messages
```

If the endpoints return the expected data, the Docker image is working.

## 9. Adding Kubernetes Configuration

The original repository does not contain a `k8s/` directory.

We must create it and add the Kubernetes manifests ourselves.

### Step 1: Create the Kubernetes directory

From the project root:

```bash
mkdir -p k8s
```

The directory will contain:

```text
k8s/
├── postgres-pvc.yaml
├── postgres.yaml
├── node-app.yaml
└── node-app-service.yaml
```

### Step 2: Create the namespace

```bash
minikube kubectl -- create namespace devops-assessment
```

### Step 3: Create Kubernetes Secrets

Two Secrets are required:

- `postgres-secret`: Contains the PostgreSQL username, password, and database name.
- `app-secrets`: Contains the application's environment variables.

Load the local `.env` variables:

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

Clean up the exported variables:

```bash
unset DATABASE_USER DATABASE_PASSWORD DATABASE
```

### Step 4: Create the PostgreSQL PersistentVolumeClaim

Create the file:

```bash
nano k8s/postgres-pvc.yaml
```

Add:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
  namespace: devops-assessment
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```

Save the file.

Apply it:

```bash
minikube kubectl -- apply -f k8s/postgres-pvc.yaml
```

Verify:

```bash
minikube kubectl -- get pvc -n devops-assessment
```

The PVC should eventually show `Bound`.

### Step 5: Create the PostgreSQL Deployment and Service

Create:

```bash
nano k8s/postgres.yaml
```

Add:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
  namespace: devops-assessment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
        - name: postgres
          image: postgres:14.2-alpine
          ports:
            - containerPort: 5432
          env:
            - name: POSTGRES_USER
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: POSTGRES_USER
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: POSTGRES_PASSWORD
            - name: POSTGRES_DB
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: POSTGRES_DB
            - name: PGDATA
              value: /data/mydatabase
          volumeMounts:
            - name: postgres-storage
              mountPath: /data
      volumes:
        - name: postgres-storage
          persistentVolumeClaim:
            claimName: postgres-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: postgres
  namespace: devops-assessment
spec:
  selector:
    app: postgres
  ports:
    - port: 5432
      targetPort: 5432
  type: ClusterIP
```

Save the file.

Apply:

```bash
minikube kubectl -- apply -f k8s/postgres.yaml
```

Wait for PostgreSQL:

```bash
minikube kubectl -- rollout status deployment/postgres \
  -n devops-assessment
```

### Step 6: Create the Node.js application Deployment

Create:

```bash
nano k8s/node-app.yaml
```

Add:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: node-app
  namespace: devops-assessment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: node-app
  template:
    metadata:
      labels:
        app: node-app
    spec:
      containers:
        - name: node-app
          image: node-postgres-api:1.0
          imagePullPolicy: IfNotPresent
          command:
            - sh
            - -c
            - |
              until nc -z -w 2 127.0.0.1 5432; do
                echo "Waiting for database proxy..."
                sleep 2
              done
              echo "Database proxy is ready. Starting Node.js..."
              npm start
          ports:
            - containerPort: 3000
          envFrom:
            - secretRef:
                name: app-secrets
        - name: database-proxy
          image: alpine/socat
          command:
            - socat
            - TCP-LISTEN:5432,fork,reuseaddr
            - TCP:postgres:5432
          ports:
            - containerPort: 5432
```

Save the file.

**Why is the database proxy necessary?**

The original application uses localhost for its PostgreSQL connection. In Kubernetes, PostgreSQL runs in a separate Pod.

Instead of modifying the original application source code, a `socat` sidecar container listens on localhost port 5432 and forwards connections to the PostgreSQL Kubernetes Service.

Both containers share the same Pod network namespace, allowing the original application to connect through localhost.

The startup command also waits for the proxy to become available before starting Node.js.

### Step 7: Load the Docker image into Minikube

```bash
minikube image load node-postgres-api:1.0
```

### Step 8: Deploy the Node.js application

```bash
minikube kubectl -- apply -f k8s/node-app.yaml
```

### Step 9: Create the Node.js Service

Create:

```bash
nano k8s/node-app-service.yaml
```

Add:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: node-app
  namespace: devops-assessment
spec:
  type: NodePort
  selector:
    app: node-app
  ports:
    - port: 3000
      targetPort: 3000
      nodePort: 30080
      protocol: TCP
```

Save the file.

Apply:

```bash
minikube kubectl -- apply -f k8s/node-app-service.yaml
```

### Step 10: Verify the Kubernetes resources

```bash
minikube kubectl -- get pods -n devops-assessment
```

```bash
minikube kubectl -- get deployments -n devops-assessment
```

```bash
minikube kubectl -- get services -n devops-assessment
```

```bash
minikube kubectl -- get pvc -n devops-assessment
```

The Node.js Pod should show two ready containers, and the PostgreSQL Pod should show one ready container.

## 10. Accessing the Kubernetes Application

Get the Minikube IP:

```bash
minikube ip
```

The application is exposed through NodePort 30080.

Access it using:

```text
http://MINIKUBE_IP:30080
```

Replace `MINIKUBE_IP` with the address returned by Minikube.

### Test the API

```bash
curl http://$(minikube ip):30080/users
```

```bash
curl http://$(minikube ip):30080/messages
```

```bash
curl http://$(minikube ip):30080/users/1
```

```bash
curl http://$(minikube ip):30080/messages/1
```

## 11. Adding the GitHub Actions CI/CD Pipeline

The original repository does not contain the GitHub Actions workflow created for this assessment.

We must create it.

### Step 1: Create the workflow directory

From the project root:

```bash
mkdir -p .github/workflows
```

### Step 2: Create the deployment workflow

```bash
nano .github/workflows/deploy.yml
```

Add:

```yaml
name: Build and Deploy Application

on:
  push:
    branches:
      - master
  workflow_dispatch:

permissions:
  contents: read
  packages: write

jobs:
  build-and-deploy:
    runs-on: self-hosted

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Log in to GitHub Container Registry
        env:
          GHCR_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          printf '%s' "$GHCR_TOKEN" | docker login ghcr.io \
            --username "$GITHUB_ACTOR" \
            --password-stdin

      - name: Build Docker image
        run: |
          IMAGE_NAME=ghcr.io/nedudevops/node-express-postgresql-server
          docker build \
            -t "$IMAGE_NAME:$GITHUB_SHA" \
            -t "$IMAGE_NAME:latest" .

      - name: Push Docker image
        run: |
          IMAGE_NAME=ghcr.io/nedudevops/node-express-postgresql-server
          docker push "$IMAGE_NAME:$GITHUB_SHA"
          docker push "$IMAGE_NAME:latest"

      - name: Deploy to Kubernetes
        run: |
          IMAGE_NAME=ghcr.io/nedudevops/node-express-postgresql-server

          minikube kubectl -- set image \
            deployment/node-app \
            node-app="$IMAGE_NAME:$GITHUB_SHA" \
            -n devops-assessment

          minikube kubectl -- rollout status \
            deployment/node-app \
            -n devops-assessment \
            --timeout=180s
```

Save the file.

### Step 3: Configure GitHub Container Registry

The workflow publishes Docker images to:

```text
ghcr.io/nedudevops/node-express-postgresql-server
```

The workflow uses GitHub's automatically provided `GITHUB_TOKEN` to authenticate with GHCR.

The workflow requires permission to publish packages.

After the first successful workflow run, check the package settings on GitHub and make the package public if you want Minikube to pull the image without registry authentication.

### Step 4: Understand the pipeline

The workflow performs these operations:

1. **Checkout:** Downloads the latest repository source code.
2. **Authentication:** Logs in to GitHub Container Registry.
3. **Build:** Builds the Docker image.
4. **Publish:** Pushes the image using both the commit SHA and `latest` tags.
5. **Deploy:** Updates the Kubernetes Node.js Deployment with the newly published image.
6. **Verify:** Waits for the Kubernetes rollout to complete.

The workflow runs automatically whenever a change is pushed to `master`. It can also be triggered manually through GitHub Actions.

## 12. Setting Up the Self-Hosted GitHub Actions Runner

The CI/CD workflow uses a self-hosted runner installed on the Ubuntu virtual machine.

This allows GitHub Actions to access the local Docker environment and Minikube cluster.

### Step 1: Add a self-hosted runner on GitHub

1. Open your GitHub repository.
2. Navigate to **Settings**.
3. Select **Actions**.
4. Select **Runners**.
5. Click **New self-hosted runner**.
6. Select Linux and x64.
7. Follow the commands GitHub displays.

The runner is installed in:

```text
~/actions-runner
```

Registration tokens are temporary. Never commit them to the repository or include them in documentation.

### Step 2: Configure the runner as a systemd service

From the runner directory:

```bash
cd ~/actions-runner
```

Install the service:

```bash
sudo ./svc.sh install
```

Start it:

```bash
sudo ./svc.sh start
```

Verify:

```bash
sudo ./svc.sh status
```

The expected status is:

```text
Active: active (running)
```

### Step 3: Runner management commands

Run these from `~/actions-runner`:

```bash
# Check status
sudo ./svc.sh status

# Start
sudo ./svc.sh start

# Stop
sudo ./svc.sh stop

# Restart
sudo ./svc.sh restart
```

The service is configured to start automatically when Ubuntu boots.

### Step 4: Runner requirements

For deployment jobs to work:

- The Ubuntu VM must be powered on.
- The runner service must be active.
- The VM must have internet access.
- Docker must be available to the runner.
- Minikube must be running.

The runner is configured to start automatically when Ubuntu boots. The Minikube startup service and runner dependency are configured in the next section so that the runner does not begin accepting deployment jobs before Minikube has started.

## 13. Automatic Startup and Recovery After VM Reboot

The Ubuntu VM runs Docker, Minikube, and the self-hosted GitHub Actions runner. These services are configured to start automatically after Ubuntu boots.

The startup order is:

1. Docker starts.
2. Minikube starts using Docker as its driver.
3. The GitHub Actions runner starts after the Minikube startup service has completed.
4. Kubernetes brings the application and PostgreSQL Pods back to their desired state.

**Important:** These settings automate startup inside Ubuntu. The VirtualBox VM itself must still be powered on by the host machine.

### Step 1: Make sure Docker starts automatically

Enable Docker and start it immediately:

```bash
sudo systemctl enable --now docker
```

Verify that Docker is enabled and active:

```bash
systemctl is-enabled docker
systemctl is-active docker
```

Both commands should report `enabled` and `active`, respectively.

### Step 2: Create a systemd service for Minikube

Minikube is installed under `/usr/local/bin/minikube` and runs under the normal Ubuntu user account, not as root.

Create the service file:

```bash
sudo nano /etc/systemd/system/minikube.service
```

Add:

```ini
[Unit]
Description=Minikube Kubernetes Cluster
After=docker.service network-online.target
Wants=network-online.target
Requires=docker.service

[Service]
Type=oneshot
User=chinadizi
Group=chinadizi
WorkingDirectory=/home/chinadizi
ExecStart=/usr/local/bin/minikube start --driver=docker
ExecStop=/usr/local/bin/minikube stop
RemainAfterExit=yes
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
```

Save the file.

Tell systemd to reload its service definitions:

```bash
sudo systemctl daemon-reload
```

Enable Minikube to start automatically at boot:

```bash
sudo systemctl enable minikube.service
```

Start the service now:

```bash
sudo systemctl start minikube.service
```

Check its status:

```bash
sudo systemctl status minikube.service
```

The expected state after startup is:

```text
Loaded: loaded (...; enabled; ...)
Active: active (exited)
```

`active (exited)` is expected here because the service uses `Type=oneshot` and `RemainAfterExit=yes`. The Minikube cluster continues running after the startup command finishes.

Verify the cluster:

```bash
minikube status
minikube kubectl -- get nodes
```

The Minikube host, kubelet, and API server should be running, and the Kubernetes node should show `Ready`.

### Step 3: Make the GitHub Actions runner wait for Minikube

The runner must not start before the Minikube startup service has completed. Add a systemd dependency to the runner service.

Open the runner service override:

```bash
sudo systemctl edit actions.runner.nedudevops-node-express-postgresql-server.ubuntu-minikube-runner.service
```

Add:

```ini
[Unit]
Requires=minikube.service
After=minikube.service
```

Save and exit the editor.

Reload systemd and restart the runner:

```bash
sudo systemctl daemon-reload
sudo systemctl restart actions.runner.nedudevops-node-express-postgresql-server.ubuntu-minikube-runner.service
```

Check the runner:

```bash
sudo systemctl status actions.runner.nedudevops-node-express-postgresql-server.ubuntu-minikube-runner.service
```

The service should show `active (running)`.

Verify that the dependency is configured:

```bash
systemctl show actions.runner.nedudevops-node-express-postgresql-server.ubuntu-minikube-runner.service -p Requires -p After
```

The output should include `minikube.service` in both properties.

### Step 4: Verify automatic recovery after reboot

Restart Ubuntu:

```bash
sudo reboot
```

After logging back in, check Docker:

```bash
systemctl is-active docker
```

Check Minikube:

```bash
sudo systemctl status minikube.service
minikube status
minikube kubectl -- get nodes
```

Check the application workloads:

```bash
minikube kubectl -- get pods -n devops-assessment
minikube kubectl -- get deployments -n devops-assessment
```

Check the GitHub Actions runner:

```bash
sudo systemctl status actions.runner.nedudevops-node-express-postgresql-server.ubuntu-minikube-runner.service
```

The Kubernetes node should become `Ready`, the application and PostgreSQL Pods should return to `Running`, and the runner should become active and reconnect to GitHub.

Pods may briefly show transitional states while the cluster is recovering. Wait a short time and check again if they are not immediately ready.

**Startup dependency note:** The runner waits for the Minikube systemd startup command to complete. This does not mean every application Pod is guaranteed to be ready at that exact moment. Kubernetes independently works to restore the configured workloads, and the GitHub Actions deployment workflow includes a rollout-status check for application deployments.


## 14. Pushing the Completed Implementation to GitHub

At this point, the original application has been supplemented with the Docker, Kubernetes, and GitHub Actions configuration files.

Verify the project structure:

```bash
tree -a -L 3 -I '.git|node_modules'
```

The important additions should include:

```text
Dockerfile
.dockerignore
k8s/
.github/workflows/deploy.yml
```

Check the Git status:

```bash
git status
```

Stage the changes:

```bash
git add Dockerfile .dockerignore k8s .github/workflows/deploy.yml
```

If you have also updated the README and `.gitignore`, stage those too:

```bash
git add README.md .gitignore
```

Commit:

```bash
git commit -m "Add Docker and Kubernetes deployment with GitHub Actions"
```

Push to your fork:

```bash
git push origin master
```

Because `origin` points to your fork, the changes are pushed to:

https://github.com/nedudevops/node-express-postgresql-server

They are not pushed to Rwieruch's original repository.

### Verify the Git remotes

```bash
git remote -v
```

Remember:

- `origin` = your repository.
- `upstream` = Rwieruch's original repository.

## 15. Testing and Validation

The implementation should be validated at each stage.

### Docker validation

- Docker image builds successfully.
- Container starts successfully.
- API endpoints return the expected responses.

### Kubernetes validation

- Minikube cluster is running.
- PostgreSQL Pod is running.
- Node.js application Pod is running with both containers ready.
- PersistentVolumeClaim shows `Bound`.
- Kubernetes Services are available.
- Node.js Deployment is available.

Useful commands:

```bash
minikube kubectl -- get all -n devops-assessment
```

```bash
minikube kubectl -- get pvc -n devops-assessment
```

```bash
minikube kubectl -- logs deployment/node-app \
  -n devops-assessment -c node-app
```

### CI/CD validation

- GitHub Actions workflow starts after a push to `master`.
- Docker image builds successfully.
- Image is published to GHCR.
- Kubernetes Deployment is updated.
- Rollout completes successfully.

### API validation

| Endpoint | Expected result |
|---|---|
| `GET /users` | Returns users |
| `GET /users/1` | Returns a user |
| `GET /messages` | Returns messages |
| `GET /messages/1` | Returns a message |

## 16. Assumptions and Engineering Trade-offs

### 16.1 Local Kubernetes instead of a cloud cluster

**Decision:** Minikube was selected to provide a local Kubernetes environment.

**Trade-off:** This avoids cloud infrastructure costs and makes testing accessible, but does not demonstrate deployment to a production-grade managed Kubernetes service.

### 16.2 Preserving the original application source code

**Decision:** The original application source code was not modified.

**Trade-off:** Some application configuration limitations had to be addressed through infrastructure configuration instead.

### 16.3 Database proxy sidecar

The original application uses localhost for its PostgreSQL connection.

**Decision:** A `socat` sidecar forwards localhost port 5432 to the PostgreSQL Kubernetes Service.

**Trade-off:** This avoids changing the application code but introduces an additional container and proxy dependency.

### 16.4 Single application and database replicas

**Decision:** One replica was configured for the Node.js application and one for PostgreSQL.

**Trade-off:** This is sufficient for a local assessment environment but does not provide high availability or database failover.

### 16.5 Self-hosted GitHub Actions runner

**Decision:** A self-hosted runner was installed on the Ubuntu VM and configured as a systemd service.

**Reason:** It provides access to the local Docker environment and Minikube cluster.

**Trade-off:** The VM must remain powered on and connected to the internet. Docker and Minikube are configured to start automatically, and the runner is configured to wait for Minikube's startup service before accepting jobs. The application Pods may still need additional time to recover after a reboot.

### 16.6 Kubernetes Secrets

**Decision:** Application configuration and database credentials were supplied through Kubernetes Secrets.

**Trade-off:** Kubernetes Secrets separate configuration from application manifests, but production deployments should use encryption at rest and appropriate access controls.

### 16.7 Database initialization behavior

The original application includes database synchronization behavior that recreates tables on startup.

**Trade-off:** This is convenient for a demonstration application, but is not appropriate for production data management because application restarts can result in data loss. A production implementation should use controlled database migrations.

## 17. What I Would Improve With More Time

- Deploy to a managed Kubernetes platform such as Amazon EKS, Azure AKS, or Google GKE.
- Configure the database hostname through environment variables if application changes are permitted, removing the need for the `socat` sidecar.
- Replace destructive database synchronization with controlled migrations.
- Introduce readiness and liveness probes.
- Add resource requests and limits.
- Implement database backup and recovery procedures.
- Use a dedicated secret-management solution.
- Apply stricter Kubernetes RBAC permissions.
- Scan Docker images for vulnerabilities.
- Introduce automated unit and integration tests.
- Add monitoring and centralized logging using Prometheus and Grafana.
- Explore Helm charts or another infrastructure-as-code approach.

## 18. Project Outcome

This assessment demonstrates the ability to:

- Start from an existing GitHub application repository.
- Fork and manage the original repository using Git.
- Prepare a Linux environment for DevOps activities.
- Install and configure the required development and deployment tools.
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

**The original Node.js and PostgreSQL application was successfully containerized, deployed, and tested on a local Minikube Kubernetes cluster. A GitHub Actions pipeline was implemented to automate Docker image publication and Kubernetes deployment to my own GitHub repository.**

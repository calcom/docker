# Instructions for Fler's hosted Cal.com stack

## Deploying first time

1. Create a new instance of reasonable size. Currently using Hetzner ccx23 with 4 VCPUs, 16GB RAM and 160GB SSD. 

1. Record the IP and assign it to the designated domain names in your DNS. We use `flercal.com` hosted on AWS Route53.

1. Update the `REMOTE_HOST` secret in [GitHub](https://github.com/getfler/cal.com-docker/settings/secrets/actions)

1. Login to the instance as root and set up user `calcom`:

```
useradd  -s /bin/bash -m -c "Used by GitHub for deploys"  calcom
sudo usermod -aG sudo calcom
mkdir /home/calcom/.ssh
nano /home/calcom/.ssh/authorized_keys
# Add public keys for your local machine and for the GitHub deploy key (found in 1Password)
```

5. Next, run `visudo` and make sure to not require password for `sudo`:
```
%sudo   ALL=(ALL:ALL) NOPASSWD:ALL
```

1. [Deploy the nginx stack](https://github.com/getfler/cal.com-docker/actions/workflows/nginx-proxy.yaml) to the new instance

1. [Deploy the Cal.com stack](https://github.com/getfler/cal.com-docker/actions/workflows/deploy-to-dev.yaml) to the new instance

1. Make sure the Cal.com stack is working by going to `https://www.flercal.com`


## Documentation from @zaheerahmad33

### Nginx Proxy Stack

The `nginx-proxy` folder contains the Docker Compose file for setting up a robust and scalable Nginx reverse proxy stack. This Docker Compose stack automatically registers new containers behind an Nginx reverse proxy with SSL certificates. It exposes environment variables that can be used in other Docker Compose files to generate SSL certificates and Nginx configuration.

Example Environment Variables used in other docker-compose stacks to generate SSL Certificates and Nginx configurations.

```
      - VIRTUAL_HOST=example.com
      - LETSENCRYPT_HOST=example.com
      - VIRTUAL_PORT=5555
```

### Calcom Stack

The `docker-compose-prod.yaml` is responsible for setting up the production-ready cal.com docker containers We used the above-mentioned environment variables along with cal.com variables to spin up cal.com docker containers.

Environment Variables used in cal.com  `docker-compose-prod yaml` to generate SSL Certificates and Nginx configurations.

```
      - VIRTUAL_HOST=example.com
      - LETSENCRYPT_HOST=example.com
      - VIRTUAL_PORT=5555
```

## Github Action Workflows

### Deploy Nginx Proxy Stack 

To deploy the `nginx proxy stack` to a remote server, you must run this workflow manually. As this is a one-time setup, so we do not need to trigger it on every push. Keep in mind, that you have to set repository secret variables for your remote server, like

```
REMOTE_HOST
REMOTE_USER
SSH_PRIVATE_KEY

```


### Build and Push Image To DockerHub

This workflow will automatically build and push the `Calcom` docker image to the  Dockerhub Private Reposotry on every new commit or push.To make this workflow work, you have to provide all the repository `Environment` variables. 

#### Note: Respostry variables and Reposotry Environment variables are two different things in GitHub Actions

```
Environment Variables

DATABASE_HOST
DOCKER_HUB_TOKEN
DOCKER_HUB_USERNAME	
NEXT_PUBLIC_API_V2_URL
NEXT_PUBLIC_LICENSE_CONSENT	
NEXT_PUBLIC_WEBAPP_URL
POSTGRES_DB
POSTGRES_PASSWORD	
POSTGRES_USER	
REMOTE_HOST	
REMOTE_USER	
SSH_PRIVATE_KEY

```

### Deploy Calcom Stack To Dev 

This workflow will automatically trigger once the `Build and Push Image To DockerHub` workflow completes. To make this workflow work, you have to provide all the repository `Environment` variables. 

#### Note: Respostry variables and Reposotry Environment variables are two different things in GitHub Actions

```
Environment Variables

DATABASE_HOST
DOCKER_HUB_TOKEN
DOCKER_HUB_USERNAME	
NEXT_PUBLIC_API_V2_URL
NEXT_PUBLIC_LICENSE_CONSENT	
NEXT_PUBLIC_WEBAPP_URL
POSTGRES_DB
POSTGRES_PASSWORD	
POSTGRES_USER	
REMOTE_HOST	
REMOTE_USER	
SSH_PRIVATE_KEY

```

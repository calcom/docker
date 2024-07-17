# Instructions for Fler's hosted Cal.com stack

## Deploying first time

1. Create a new instance of reasonable size. Currently using Hetzner ccx23 with 4 VCPUs, 16GB RAM and 160GB SSD. 

1. Record the IP and assign it to the designated domain names in your DNS. We use `flercal.com` hosted on AWS Route53.

1. Update the `REMOTE_HOST` secret in [GitHub](https://github.com/getfler/cal.com-docker/settings/secrets/actions)

1. Login to the instance as root and set up user `calcom`:

```
useradd calcom
sudo usermod -aG sudo calcom
mkdir /home/calcom/.ssh
nano /home/calcom/.ssh/authorized_keys
# Add public keys for your local machine and for the GitHub deploy key (found in 1Password)
```

5. [Deploy the nginx stack](https://github.com/getfler/cal.com-docker/actions/workflows/nginx-proxy.yaml) to the new instance

1. [Deploy the Cal.com stack](https://github.com/getfler/cal.com-docker/actions/workflows/deploy-to-dev.yaml) to the new instance

1. Make sure the Cal.com stack is working by going to `https://www.flercal.com`

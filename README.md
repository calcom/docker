<!-- PROJECT LOGO -->
<div align="right">
  <a href="https://github.com/calendso/calendso">
    <img src="https://cal.com/logo.svg" alt="Logo" width="160" height="65">
  </a><br/>
  <a href="https://cal.com">Website</a>
  ·
  <a href="https://github.com/calendso/calendso-docker/issues">Community Support</a>
</div>

# Docker

This image can be found on DockerHub at [https://hub.docker.com/repository/docker/calendso/calendso](https://hub.docker.com/repository/docker/calendso/calendso)

The Docker configuration for Calendso is an effort powered by people within the community. Cal.com, Inc. does not provide official support for Docker, but we will accept fixes and documentation. Use at your own risk.

## Important Notes

This Docker Image is managed by the Calendso Community. Support for this image can be found via the repository, located at [https://github.com/calendso/docker](https://github.com/calcom/docker)

Currently, this image is intended for local development/evaluation use only, as there are specific requirements for providing environmental variables at build-time in order to specify a non-localhost BASE_URL. (this is due to the nature of the static site compilation, which embeds the variable values). The ability to update these variables at runtime is in-progress and will be available in the future.

For Production, for the time being, please checkout the repository and build/push your own image privately.

## Requirements

Make sure you have `docker` & `docker compose` installed on the server / system.

Note: `docker compose` without the hyphen is now the primary method of using docker-compose, per the Docker documentation.

## Getting Started

1. Clone calendso-docker

    ```bash
    git clone --recursive https://github.com/calendso/docker.git calendso-docker
    ```

2. Change into the directory

    ```bash
    cd calendso-docker
    ```

3. Update the calcom submodule

    ```bash
    git submodule update --remote --init
    ```

4. Rename `.env.example` to `.env` and then update `.env`

5. Build and start calendso

    ```bash
    docker compose up --build
    ```

6. (First Run) Open a browser to [http://localhost:5555](http://localhost:5555) to look at or modify the database content.

    a. Click on the `User` model to add a new user record.

    b. Fill out the fields (remembering to encrypt your password with [BCrypt](https://bcrypt-generator.com/)) and click `Save 1 Record` to create your first user.

7. Open a browser to [http://localhost:3000](http://localhost:3000) and login with your just created, first user.

## Configuration

### Build-time variables

These variables must be provided at the time of the docker build, and can be provided by updating the .env file. Changing these is not required for evaluation, but may be required for running in production. Currently, if you require changes to these variables, you must follow the instructions to build and publish your own image.

* NEXT_PUBLIC_WEBAPP_URL
* NEXT_PUBLIC_LICENSE_CONSENT
* NEXT_PUBLIC_TELEMETRY_KEY

### Important Run-time variables

* NEXTAUTH_SECRET

## Git Submodules

This repository uses a git submodule.

To update the calcom submodule, use the following command:

```bash
git submodule update --remote --init
```

For more advanced usage, please refer to the git documentation: [https://git-scm.com/book/en/v2/Git-Tools-Submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)

## Troubleshooting

* SSL edge termination: If running behind a load balancer which handles SSL certificates, you will need to add the environmental variable `NODE_TLS_REJECT_UNAUTHORIZED=0` to prevent requests from being rejected. Only do this if you know what you are doing and trust the services/load-balancers directing traffic to your service.
* Failed to commit changes: Invalid 'prisma.user.create()': Certain versions may have trouble creating a user if the field `metadata` is empty. Using an empty json object `{}` as the field value should resolve this issue. Also, the `id` field will autoincrement, so you may also try leaving the value of `id` as empty.

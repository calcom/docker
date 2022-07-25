<!-- PROJECT LOGO -->
<div align="right">
  <a href="https://github.com/calcom/cal.com">
    <img src="https://cal.com/logo.svg" alt="Logo" width="160" height="65">
  </a><br/>
  <a href="https://cal.com">Website</a>
  ·
  <a href="https://github.com/calcom/docker/issues">Community Support</a>
</div>

# Docker

NOTE: DockerHub organization has not yet been renamed.

This image can be found on DockerHub at [https://hub.docker.com/r/calendso/calendso](https://hub.docker.com/r/calendso/calendso)

The Docker configuration for Cal.com is an effort powered by people within the community. Cal.com, Inc. does not yet provide official support for Docker, but we will accept fixes and documentation at this time. Use at your own risk.

## Important Notes

This Docker Image is managed by the Cal.com Community. Support for this image can be found via the repository, located at [https://github.com/calcom/docker](https://github.com/calcom/docker)

Currently, this image is intended for local development/evaluation use only, as there are specific requirements for providing environmental variables at build-time in order to specify a non-localhost BASE_URL. (this is due to the nature of the static site compilation, which embeds the variable values). The ability to update these variables at runtime is in-progress and will be available in the future.

For Production, for the time being, please checkout the repository and build/push your own image privately.

## Requirements

Make sure you have `docker` & `docker compose` installed on the server / system. Both are installed by most docker utilities, including Docker Desktop and Rancher Desktop.

Note: `docker compose` without the hyphen is now the primary method of using docker-compose, per the Docker documentation.

## Getting Started

1. Clone calcom-docker

    ```bash
    git clone https://github.com/calcom/docker.git calcom-docker
    ```

2. Change into the directory

    ```bash
    cd calcom-docker
    ```

3. Update the calcom submodule. 

    ```bash
    git submodule update --remote --init
    ```

    Note: DO NOT use recursive submodule update, otherwise you will receive a git authentication error.

4. Rename `.env.example` to `.env` and then update `.env`

5. Build the Cal.com docker image: 

    Note: Due to application configuration requirements, an available database is currently required during the build process.

    a) If hosting elsewhere, configure the `DATABASE_URL` in the .env file, and skip the next step

    b) If a local or temporary database is required, start a local database via docker compose.

    ```bash
    docker compose up -d database
    ```

6. Build Cal.com via docker compose (DOCKER_BUILDKIT=0 must be provided to allow a network bridge to be used at build time. This requirement will be removed in the future)

    ```bash
    DOCKER_BUILDKIT=0 docker compose build calcom
    ```

7. Start Cal.com via docker compose

    (Most basic users, and for First Run) To run the complete stack, which includes a local Postgres database, Cal.com web app, and Prisma Studio:

    ```bash
    docker compose up -d
    ```

    To run Cal.com web app and Prisma Studio against a remote database, ensure that DATABASE_URL is configured for an available database and run:

    ```bash
    docker compose up -d calcom studio
    ```

    To run only the Cal.com web app, ensure that DATABASE_URL is configured for an available database and run:

    ```bash
    docker compose up -d calcom
    ```

    **Note: to run in attached mode for debugging, remove `-d` from your desired run command.**

8. (First Run) Open a browser to [http://localhost:5555](http://localhost:5555) to look at or modify the database content.

    a. Click on the `User` model to add a new user record.

    b. Fill out the fields (remembering to encrypt your password with [BCrypt](https://bcrypt-generator.com/)) and click `Save 1 Record` to create your first user.

9. Open a browser to [http://localhost:3000](http://localhost:3000) (or your appropriately configured NEXT_PUBLIC_WEBAPP_URL) and login with your just created, first user.

## Configuration

### Build-time variables

These variables must be provided at the time of the docker build, and can be provided by updating the .env file. Currently, if you require changes to these variables, you must follow the instructions to build and publish your own image. 

Updating these variables is not required for evaluation, but is required for running in production. Instructions for generating variables can be found in the [cal.com instructions](https://github.com/calcom/cal.com) 

| Variable | Description | Required | Default |
| --- | --- | --- | --- |
| NEXT_PUBLIC_WEBAPP_URL | Base URL injected into static files | required | `http://localhost:3000` |
| NEXT_PUBLIC_LICENSE_CONSENT | license consent - true/false |  |  |
| CALCOM_TELEMETRY_DISABLED | Allow cal.com to collect anonymous usage data (set to `1` to disable) | | |
| DATABASE_URL | database url with credentials | required | `postgresql://unicorn_user:magical_password@database:5432/calendso` |
| NEXTAUTH_SECRET | Cookie encryption key | required | `secret` |
| CALENDSO_ENCRYPTION_KEY | Authentication encryption key | required | `secret` |

### Important Run-time variables

These variables must also be provided at runtime

| Variable | Description | Required | Default |
| --- | --- | --- | --- |
| CALCOM_LICENSE_KEY | Enterprise License Key |  |  |
| NEXTAUTH_SECRET | must match build variable | required | `secret` |
| CALENDSO_ENCRYPTION_KEY | must match build variable | required | `secret` |
| DATABASE_URL | database url with credentials | required | `postgresql://unicorn_user:magical_password@database:5432/calendso` |

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

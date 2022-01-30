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

The Docker configuration for Calendso is an effort powered by people within the community. Calendso does not provide official support for Docker, but we will accept fixes and documentation. Use at your own risk.

## Important Notes

This Docker Image is managed by the Calendso Community. Support for this image can be found via the repository, located at [https://github.com/calendso/docker](https://github.com/calendso/docker)

Currently, this image is intended for local development/evaluation use only, as there are specific requirements for providing environmental variables at build-time in order to specify a non-localhost BASE_URL. (this is due to the nature of the static site compilation, which embeds the variable values). The ability to update these variables at runtime is in-progress and will be available in the future.

For Production, for the time being, please checkout the repository and build/push your own image privately.

## Requirements

Make sure you have `docker` & `docker-compose` installed on the server / system.

## Getting Started

1. Clone calendso-docker

    ```bash
    git clone --recursive https://github.com/calendso/docker.git calendso-docker
    ```

2. Change into the directory

    ```bash
    cd calendso-docker
    ```

3. Rename `.env.example` to `.env` and update `.env` if needed.

4. Build and start calendso

    ```bash
    docker-compose up --build
    ```

5. Start prisma studio

    ```bash
    docker-compose exec calendso npx prisma studio
    ```

6. Open a browser to [http://localhost:5555](http://localhost:5555) to look at or modify the database content.

7. Click on the `User` model to add a new user record.

8. Fill out the fields (remembering to encrypt your password with [BCrypt](https://bcrypt-generator.com/)) and click `Save 1 Record` to create your first user.

9. Open a browser to [http://localhost:3000](http://localhost:3000) and login with your just created, first user.

## Git Submodules

This repository uses a git submodule.

If you cloned the repository without using `--recursive`, then you can initialize and clone the submodule with the following steps.

1. Init the submodule

    ```bash
    git submodule init
    ```

2. Update the submodule

    ```bash
    git submodule update --remote
    ```

For more advanced usage, please refer to the git documentation: [https://git-scm.com/book/en/v2/Git-Tools-Submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)

## Troubleshooting

* SSL edge termination: If running behind a load balancer which handles SSL certificates, you will need to add the environmental variable `NODE_TLS_REJECT_UNAUTHORIZED=0` to prevent requests from being rejected. Only do this if you know what you are doing and trust the services/load-balancers directing traffic to your service.
* Failed to commit changes: Invalid 'prisma.user.create()': Certain versions may have trouble creating a user if the field `metadata` is empty. Using an empty json object `{}` as the field value should resolve this issue. Also, the `id` field will autoincrement, so you may also try leaving the value of `id` as empty.

## Docker secrets

As an alternative to passing sensitive information via environment variables, _FILE may be appended to the environment variables listed below, causing the initialization script to load the values for those variables from files present in the container. In particular, this can be used to load passwords from Docker secrets stored in /run/secrets/<secret_name> files. 


* CALENDSO_ENCRYPTION_KEY
* EMAIL_SERVER_PASSWORD
* GOOGLE_API_CREDENTIALS
* JWT_SECRET
* MS_GRAPH_CLIENT_SECRET
* POSTGRES_PASSWORD
* ZOOM_CLIENT_SECRET

The `DATABASE_URL` environment variable can be omitted; it will be computed automatically based on the values of the following environment variables (or their `_FILE` replacements):

* POSTGRES_USER
* POSTGRES_PASSWORD
* DATABASE_HOST
* POSTGRES_DB

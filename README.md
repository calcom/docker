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

Make sure you have `docker` & `docker-compose` installed on the server / system. Both are installed by most docker utilities, including Docker Desktop and Rancher Desktop.

Note: `docker-compose` without the hyphen is now the primary method of using docker-compose, per the Docker documentation.

## Getting Started

1. wget docker-compose.yml to wherever you plan on running this.

    ```bash
    wget https://raw.githubusercontent.com/calcom/docker/main/docker-compose.yml
    ```

2. Modify the environment section at the top of the `docker-compose.yml` file.


    ```yaml
    x-environment: &environment
    environment:
      # Set this value to 'agree' to accept our license:
      # LICENSE: https://github.com/calendso/calendso/blob/main/LICENSE
      #
      # Summary of terms:
      # - The codebase has to stay open source, whether it was modified or not
      # - You can not repackage or sell the codebase
      # - Acquire a commercial license to remove these terms by emailing: license@cal.com
      ## You must agree to these terms manually we can't agree to them for you.
      # NEXT_PUBLIC_LICENSE_CONSENT:
      # LICENSE:

      ## Deployment configuration section you may need to change this if you're using a reverse proxy such as nginx, haproxy or træfik.
      NEXT_PUBLIC_WEBAPP_URL: http://localhost:3000

      # E-mail settings
      # Configures the global From: header whilst sending emails.
      EMAIL_FROM: notifications@example.com

      # Configure SMTP settings (@see https://nodemailer.com/smtp/).
      EMAIL_SERVER_HOST: smtp.example.com
      EMAIL_SERVER_PORT: 587
      EMAIL_SERVER_USER: email_user
      EMAIL_SERVER_PASSWORD: email_password

      ## Only change these if you know what you're doing.  Changes are unlikely to be needed.  
      ## However, you could change the password if you like before you start the first time. Also feel free to read about and implement Docker Secrets.
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: postgres
      DATABASE_HOST: postgres:5432
      DATABASE_URL: ${DATABASE_URL:='postgresql://postgres:postgres@postgres:5432/postgres'}
      # GOOGLE_API_CREDENTIALS: {}

      # Set this to '1' if you don't want Cal to collect anonymous usage.  This is not necessary, however, its kind to give back metrics to the app developers if you trust them.
      CALCOM_TELEMETRY_DISABLED: 0

      # Used for the Office 365 / Outlook.com Calendar integration.
      # MS_GRAPH_CLIENT_ID:
      # MS_GRAPH_CLIENT_SECRET:

      # Used for the Zoom integration.
      # ZOOM_CLIENT_ID:
      # ZOOM_CLIENT_SECRET:

      ## Probably only change this if you know what you're doing.
      NODE_ENV: production
      ```

3. Start Cal.com via docker-compose

    (Most basic users, and for First Run) To run the complete stack, which includes a local Postgres database, Cal.com web app, and Prisma Studio:

    ```bash
    docker-compose up -d
    ```
    ...and if you wish to follow the logs you may run...
    ```bash
    docker-compose logs -f
    ```
    and press `ctrl+c` to end following the console logging output.

8. (First Run) Open a browser to [http://localhost:5555](http://localhost:5555) to look at or modify the database content.

    a. Click on the `User` model to add a new user record.

    b. Fill out the fields (remembering to encrypt your password with [BCrypt](https://bcrypt-generator.com/)) and click `Save 1 Record` to create your first user.

9. Open a browser to [http://localhost:3000](http://localhost:3000) (or your appropriately configured NEXT_PUBLIC_WEBAPP_URL) and login with your just created, first user.

### Bonus tips
    To run Cal.com web app and Prisma Studio against a remote database, ensure that DATABASE_URL is configured for an available database, uncomment the studio segment of the included `docker-compose.yml` and run:

    ```bash
    docker-compose up -d calcom studio
    ```

    To run only the Cal.com web app, ensure that DATABASE_URL is configured for an available database and run:

    ```bash
    docker-compose up -d calcom
    ```

    **Note: to run in attached mode for debugging, remove `-d` from your desired run command.**


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
| NEXTAUTH_SECRET | Cookie encryption key | required | `randomly defined on first boot` |
| CALENDSO_ENCRYPTION_KEY | Authentication encryption key | required | `randomly defined on first boot` |

### Important Run-time variables

These variables must also be provided at runtime

| Variable | Description | Required | Default |
| --- | --- | --- | --- |
| CALCOM_LICENSE_KEY | Enterprise License Key |  |  |
| NEXTAUTH_SECRET | must match build variable | required | `randomly defined on first boot` |
| CALENDSO_ENCRYPTION_KEY | must match build variable | required | `randomly defined on first boot` |
| DATABASE_URL | database url with credentials | required | `postgresql://unicorn_user:magical_password@database:5432/calendso` |

## Troubleshooting

* SSL edge termination: If running behind a load balancer which handles SSL certificates, you will need to add the environmental variable `NODE_TLS_REJECT_UNAUTHORIZED=0` to prevent requests from being rejected. Only do this if you know what you are doing and trust the services/load-balancers directing traffic to your service.
* Failed to commit changes: Invalid 'prisma.user.create()': Certain versions may have trouble creating a user if the field `metadata` is empty. Using an empty json object `{}` as the field value should resolve this issue. Also, the `id` field will autoincrement, so you may also try leaving the value of `id` as empty.

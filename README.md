<!-- PROJECT LOGO -->
<div align="right">
  <a href="https://github.com/calendso/calendso">
    <img src="https://cal.com/logo.svg" alt="Logo" width="160" height="65">
  </a><br/>
  <a href="https://cal.com">Website</a>
  ·
  <a href="https://github.com/calendso/calendso-docker/issues">Community Support</a>
</div>

# calendso-docker

The Docker configuration for Calendso is an effort powered by people within the community. Calendso does not provide official support for Docker, but we will accept fixes and documentation. Use at your own risk.

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

3. Rename `.env.example` to `.env` and update if needed.
   For local development and production use-cases, jump to the [Secrets Management](#secrets-management) section.
   **We strongly encourage using a secrets manager to securely store secrets. ENV files lead to accidental leaks and breaches.**

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

## Secrets Management

We strongly recommend using [Doppler](https://doppler.com) to securely store and manage secrets across devices, environments, and team members.

1. Import our project to get setup.

   <a href="https://dashboard.doppler.com/workplace/template/import?template=https://github.com/calendso/docker/blob/main/doppler.yaml"/>
      <img src="https://raw.githubusercontent.com/DopplerUniversity/app-config-templates/main/doppler-button.svg" alt="Import to Doppler" />
   </a>

2. Create a service token.

   ![create-service-token](https://user-images.githubusercontent.com/1920007/141717862-a524c1ad-9384-4f40-909f-4d293e4889e2.gif)

3. Build and start calendso with Doppler

   ```bash
   DOPPLER_TOKEN=dp.st.XXXXXXX docker-compose up --build
   ```

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

<!-- PROJECT LOGO -->
<div align="right">
  <a href="https://github.com/calendso/calendso">
    <img src="https://calendso.com/calendso-logo.svg" alt="Logo" width="160" height="65">
  </a><br/>
  <a href="https://calendso.com">Website</a>
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
3. Update `.env` if needed 

4. Build and start calendso

    ```
    docker-compose up --build
    ```

5. Start prisma studio 
    ```
    docker-compose exec calendso npx prisma studio
    ```
6. Open a browser to [http://localhost:5555](http://localhost:5555) to look at or modify the database content.

7. Click on the `User` model to add a new user record.
8.  Fill out the fields (remembering to encrypt your password with [BCrypt](https://bcrypt-generator.com/)) and click `Save 1 Record` to create your first user.
9. Open a browser to [http://localhost:3000](http://localhost:3000) and login with your just created, first user.

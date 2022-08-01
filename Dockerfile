FROM node:16

COPY scripts /opt/scripts
RUN apt-get update && \
    apt-get -y install netcat && \
    rm -rf /var/lib/apt/lists/* && \
    npm install --location=global prisma && \
    ln -s /opt/scripts/start.sh /opt/scripts/wait-for-it.sh /usr/bin/

EXPOSE 3000
CMD ["start.sh"]

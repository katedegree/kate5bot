FROM node:24
WORKDIR /bot
RUN apt-get update && \
    apt-get install -y rsync && \
    rm -rf /var/lib/apt/lists/*
COPY package.json package-lock.json ./
RUN npm install
RUN mv node_modules /opt/node_modules
COPY . .
RUN printf '#!/bin/bash\n\
set -e\n\
[ ! -d /bot/node_modules ] || [ -z "$(ls -A /bot/node_modules 2>/dev/null)" ] && \
cp -r /opt/node_modules /bot/node_modules || \
rsync -au --quiet /opt/node_modules/ /bot/node_modules/\n\
exec "$@"\n' > /docker-entrypoint.sh && \
    chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

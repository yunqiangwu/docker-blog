# https://docs.ghost.org/supported-node-versions/
# https://github.com/nodejs/LTS
FROM ubuntu

RUN apt-get update
RUN apt-get install -y unzip wget python gcc make g++

ENV NODE_VERSION 6.5.0
# https://npm.taobao.org/mirrors/node/latest/node-v6.5.0.tar.gz

RUN  cd /tmp; \
	wget https://npm.taobao.org/mirrors/node/latest/node-v${NODE_VERSION}.tar.gz; \
	tar zxf node-v${NODE_VERSION}.tar.gz; \
	cd node-v${NODE_VERSION}; \
	 ./configure; \
	 make ; \
	cd .. && mv node-v${NODE_VERSION} /opt/ ; \
	ln -s /opt/node-v${NODE_VERSION}/node /usr/local/bin/node; \
	ln -s /opt/node-v${NODE_VERSION}/deps/npm/bin/npm-cli.js /usr/local/bin/npm

ENV PATH ${PATH}:/opt/node-v${NODE_VERSION}out/bin

RUN npm install -g cnpm --registry=https://registry.npm.taobao.org


ENV NPM_CONFIG_LOGLEVEL warn
ENV NODE_ENV production
#ENV GHOST_CLI_VERSION 1.1.0
ENV GHOST_CLI_VERSION latest
# ENV GHOST_VERSION 1.6.0
ENV GHOST_VERSION 0.7.4-zh-full


RUN npm install -g "ghost-cli@$GHOST_CLI_VERSION" knex-migrator@latest

ENV GHOST_INSTALL /var/lib/ghost
ENV GHOST_CONTENT /var/lib/ghost/content

RUN set -ex; \
	mkdir -p "$GHOST_INSTALL"; \
#	chown node:node "$GHOST_INSTALL"; \
	wget -O /tmp/ghost.zip http://dl.ghostchina.com/Ghost-${GHOST_VERSION}.zip 

RUN unzip /tmp/ghost.zip -d $GHOST_INSTALL

# RUN ln -s /opt/node-v4.2.0/out/bin/ghost /usr/local/bin/ghost

#	ghost install "$GHOST_VERSION" --db sqlite3 --no-prompt --no-stack --no-setup --dir "$GHOST_INSTALL"; \
# Tell Ghost to listen on all ips and not prompt for additional configuration


RUN	cd "$GHOST_INSTALL"; \
	ghost config --ip 0.0.0.0 --port 2368 --no-prompt --db sqlite3 --url http://localhost:2368 --dbpath "$GHOST_CONTENT/data/ghost.db"; \
	ghost config paths.contentPath "$GHOST_CONTENT"; \
	mv "$GHOST_CONTENT" "$GHOST_INSTALL/content.orig"; \
	mkdir -p "$GHOST_CONTENT";
#	chown node:node "$GHOST_CONTENT"

WORKDIR $GHOST_INSTALL
VOLUME $GHOST_CONTENT

COPY docker-entrypoint.sh /usr/local/bin
# ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 2368
CMD ["node", "index.js"]

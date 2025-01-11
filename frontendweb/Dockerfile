FROM nginx
ADD file:90b9dd8f12120e8b2cd3ece45fcbe8af67e40565e2032a40f64bd921c43e2ce7 in /
CMD ["bash"]
RUN LABEL maintainer=NGINX Docker Maintainers <docker-maint@nginx.com>
RUN ENV NGINX_VERSION=1.27.2
RUN ENV NJS_VERSION=0.8.6
RUN ENV NJS_RELEASE=1~bookworm
RUN ENV PKG_RELEASE=1~bookworm
RUN ENV DYNPKG_RELEASE=1~bookworm
RUN RUN /bin/sh -c set -x     \
    && groupadd --system --gid 101 nginx     \
    && useradd --system --gid nginx --no-create-home --home /nonexistent --comment "nginx user" --shell /bin/false --uid 101 nginx     \
    && apt-get update     \
    && apt-get install --no-install-recommends --no-install-suggests -y gnupg1 ca-certificates     \
    &&     NGINX_GPGKEYS="573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 8540A6F18833A80E9C1653A42FD21310B49F6B46 9E9BE90EACBCDE69FE9B204CBCDCD8A38D88A2B3";     NGINX_GPGKEY_PATH=/etc/apt/keyrings/nginx-archive-keyring.gpg;     export GNUPGHOME="$(mktemp -d)";     found='';     for NGINX_GPGKEY in $NGINX_GPGKEYS; do     for server in         hkp://keyserver.ubuntu.com:80         pgp.mit.edu     ; do         echo "Fetching GPG key $NGINX_GPGKEY from $server";         gpg1 --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$NGINX_GPGKEY" \
    && found=yes \
    && break;     done;     test -z "$found" \
    && echo >&2 "error: failed to fetch GPG key $NGINX_GPGKEY" \
    && exit 1;     done;     gpg1 --export "$NGINX_GPGKEYS" > "$NGINX_GPGKEY_PATH" ;     rm -rf "$GNUPGHOME";     apt-get remove --purge --auto-remove -y gnupg1 \
    && rm -rf /var/lib/apt/lists/*     \
    && dpkgArch="$(dpkg --print-architecture)"     \
    && nginxPackages="         nginx=${NGINX_VERSION}-${PKG_RELEASE}         nginx-module-xslt=${NGINX_VERSION}-${DYNPKG_RELEASE}         nginx-module-geoip=${NGINX_VERSION}-${DYNPKG_RELEASE}         nginx-module-image-filter=${NGINX_VERSION}-${DYNPKG_RELEASE}         nginx-module-njs=${NGINX_VERSION}+${NJS_VERSION}-${NJS_RELEASE}     "     \
    && case "$dpkgArch" in         amd64|arm64)             echo "deb [signed-by=$NGINX_GPGKEY_PATH] https://nginx.org/packages/mainline/debian/ bookworm nginx" >> /etc/apt/sources.list.d/nginx.list             \
    && apt-get update             ;;         *)             tempDir="$(mktemp -d)"             \
    && chmod 777 "$tempDir"                         \
    && savedAptMark="$(apt-mark showmanual)"                         \
    && apt-get update             \
    && apt-get install --no-install-recommends --no-install-suggests -y                 curl                 devscripts                 equivs                 git                 libxml2-utils                 lsb-release                 xsltproc             \
    && (                 cd "$tempDir"                 \
    && REVISION="${NGINX_VERSION}-${PKG_RELEASE}"                 \
    && REVISION=${REVISION%~*}                 \
    && curl -f -L -O https://github.com/nginx/pkg-oss/archive/${REVISION}.tar.gz                 \
    && PKGOSSCHECKSUM="6982e2df739645fc72db5bdf994032f799718230e7016e811d9d482e5cf41814c888660ca9a68814d5e99ab571e892ada3bd43166e720cbf04c7f85b6934772c *${REVISION}.tar.gz"                 \
    && if [ "$(openssl sha512 -r ${REVISION}.tar.gz)" = "$PKGOSSCHECKSUM" ]; then                     echo "pkg-oss tarball checksum verification succeeded!";                 else                     echo "pkg-oss tarball checksum verification failed!";                     exit 1;                 fi                 \
    && tar xzvf ${REVISION}.tar.gz                 \
    && cd pkg-oss-${REVISION}                 \
    && cd debian                 \
    && for target in base module-geoip module-image-filter module-njs module-xslt; do                     make rules-$target;                     mk-build-deps --install --tool="apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends --yes"                         debuild-$target/nginx-$NGINX_VERSION/debian/control;                 done                 \
    && make base module-geoip module-image-filter module-njs module-xslt             )                         \
    && apt-mark showmanual | xargs apt-mark auto > /dev/null             \
    && { [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; }                         \
    && ls -lAFh "$tempDir"             \
    && ( cd "$tempDir" \
    && dpkg-scanpackages . > Packages )             \
    && grep '^Package: ' "$tempDir/Packages"             \
    && echo "deb [ trusted=yes ] file://$tempDir ./" > /etc/apt/sources.list.d/temp.list             \
    && apt-get -o Acquire::GzipIndexes=false update             ;;     esac         \
    && apt-get install --no-install-recommends --no-install-suggests -y                         $nginxPackages                         gettext-base                         curl     \
    && apt-get remove --purge --auto-remove -y \
    && rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/nginx.list         \
    && if [ -n "$tempDir" ]; then         apt-get purge -y --auto-remove         \
    && rm -rf "$tempDir" /etc/apt/sources.list.d/temp.list;     fi     \
    && ln -sf /dev/stdout /var/log/nginx/access.log     \
    && ln -sf /dev/stderr /var/log/nginx/error.log     \
    && mkdir /docker-entrypoint.d # buildkit
RUN COPY docker-entrypoint.sh / # buildkit
RUN COPY 10-listen-on-ipv6-by-default.sh /docker-entrypoint.d # buildkit
RUN COPY 15-local-resolvers.envsh /docker-entrypoint.d # buildkit
RUN COPY 20-envsubst-on-templates.sh /docker-entrypoint.d # buildkit
RUN COPY 30-tune-worker-processes.sh /docker-entrypoint.d # buildkit
RUN ENTRYPOINT ["/docker-entrypoint.sh"]
RUN EXPOSE map[80/tcp:{}]
RUN STOPSIGNAL SIGQUIT
RUN CMD ["nginx" "-g" "daemon off;"]
RUN COPY code /usr/share/nginx/html # buildkit
RUN RUN /bin/sh -c rm -rf /etc/nginx/nginx.conf # buildkit
RUN RUN /bin/sh -c rm -rf /etc/nginx/conf.d/default.conf # buildkit
RUN COPY nginx.conf /etc/nginx/nginx.conf # buildkit
















# FROM nginx:mainline-alpine3.20-slim
# RUN rm -rf /etc/nginx/nginx.conf && \
#     rm -rf /etc/nginx/conf.d/default.conf && \
#     mkdir -p /var/cache/nginx/client_temp && \
#     mkdir -p /var/cache/nginx/proxy_temp && \
#     mkdir -p /var/cache/nginx/fastcgi_temp && \
#     mkdir -p /var/cache/nginx/uwsgi_temp && \
#     mkdir -p /var/cache/nginx/scgi_temp && \
#     chown -R nginx:nginx /var/cache/nginx && \
#     chown -R nginx:nginx /etc/nginx/ && \
#     chmod -R 755 /etc/nginx/ && \
#     chown -R nginx:nginx /var/log/nginx && \
#     touch /var/run/nginx.pid && \
#     chown -R nginx:nginx /var/run/nginx.pid /run/nginx.pid
# COPY nginx.conf /etc/nginx/nginx.conf
# COPY code /usr/share/nginx/html
# USER nginx





# before best practices implemented
# FROM nginx
# COPY code /usr/share/nginx/html
# RUN rm -rf /etc/nginx/nginx.conf
# RUN rm -rf /etc/nginx/conf.d/default.conf   
# COPY nginx.conf /etc/nginx/nginx.conf

#COPY expense.conf /etc/nginx/conf.d/expense.conf

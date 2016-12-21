FROM xtaci/kcptun
#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/' /etc/apk/repositories
RUN set -ex && \
    apk update && \
    apk add --no-cache  curl jq bash && \
    rm -rf /var/cache/apk/* ~/.cache /tmp/libsodium
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && crontab -l | { cat; echo "*/1 * * * * bash /entrypoint.sh"; } | crontab -
#ENTRYPOINT crond -f
ENTRYPOINT  bash /entrypoint.sh ; crond -f
EXPOSE 4440

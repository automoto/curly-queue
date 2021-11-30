FROM alpine:3.14 AS RESTORE
RUN apk -U upgrade \
    && apk --update add --no-cache \
        python3 \
        py3-pip \
        curl \
        bash \
        jq \
    && pip3 install --upgrade pip awscli \
    && touch /var/log/restore
COPY start.sh /start.sh
RUN chmod 755 /start.sh
WORKDIR /
ENTRYPOINT ["./start.sh"]
CMD ["https://google.com"]

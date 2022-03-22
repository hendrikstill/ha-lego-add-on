FROM homeassistant/aarch64-base:latest


RUN mkdir /app

WORKDIR /app
RUN apk update \
    && apk add --no-cache ca-certificates tzdata \
    && update-ca-certificates
RUN wget https://github.com/go-acme/lego/releases/download/v4.6.0/lego_v4.6.0_linux_arm64.tar.gz \
    && tar -xzvf lego_v4.6.0_linux_arm64.tar.gz \
    && rm lego_v4.6.0_linux_arm64.tar.gz 
RUN cp ./lego /usr/bin/lego

COPY data/*.sh /

CMD [ "/run.sh" ]
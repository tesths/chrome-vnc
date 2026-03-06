FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    VNC_PASSWORD=secret \
    SCREEN_WIDTH=1920 \
    SCREEN_HEIGHT=1080 \
    SCREEN_DEPTH=24 \
    DISPLAY=:99

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget gnupg ca-certificates procps xvfb x11vnc fluxbox \
    fonts-noto-cjk fonts-noto-color-emoji supervisor \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/googlechrome-linux-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/googlechrome-linux-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt-get update && apt-get install -y --no-install-recommends google-chrome-stable \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN useradd -m -s /bin/bash chromeuser

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN mkdir -p /home/chromeuser/chrome-data && \
    chown -R chromeuser:chromeuser /home/chromeuser

USER chromeuser
WORKDIR /home/chromeuser

EXPOSE 5900 9222

ENTRYPOINT ["/entrypoint.sh"]

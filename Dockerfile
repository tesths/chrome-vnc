FROM debian:bookworm-slim

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    VNC_PASSWORD=zeabur123 \
    SCREEN_WIDTH=1920 \
    SCREEN_HEIGHT=1080 \
    SCREEN_DEPTH=24 \
    DISPLAY=:99 \
    DBUS_SESSION_BUS_ADDRESS=/dev/null

# 1. 安装依赖，新增 dbus-x11 和 libgbm1 (Chrome 渲染需要)
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget gnupg ca-certificates procps \
    xvfb x11vnc fluxbox \
    dbus-x11 libgbm1 libasound2 \
    fonts-noto-cjk fonts-noto-color-emoji supervisor \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/googlechrome-linux-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/googlechrome-linux-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt-get update && apt-get install -y --no-install-recommends google-chrome-stable \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 2. 创建用户
RUN useradd -m -s /bin/bash chromeuser

# 3. 关键修复：生成 machine-id，解决 Chrome/DBus 启动报错
RUN dbus-uuidgen > /var/lib/dbus/machine-id

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 4. 创建数据目录
RUN mkdir -p /home/chromeuser/chrome-data && \
    chown -R chromeuser:chromeuser /home/chromeuser

USER chromeuser
WORKDIR /home/chromeuser

# 暴露 VNC (5900) 和 Chrome CDP (9111)
EXPOSE 5900 9111

ENTRYPOINT ["/entrypoint.sh"]

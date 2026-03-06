#!/bin/bash
set -e

# 如果没有设置密码，设置一个默认密码
: ${VNC_PASSWORD:=zeabur123}

echo "Starting Xvfb..."
Xvfb $DISPLAY -screen 0 ${SCREEN_WIDTH}x${SCREEN_HEIGHT}x${SCREEN_DEPTH} &
sleep 2

echo "Starting Fluxbox..."
fluxbox &
sleep 1

echo "Starting x11vnc..."
# 启动 VNC，端口默认 5900
x11vnc -display $DISPLAY -forever -shared -passwd "$VNC_PASSWORD" -bg -quiet

echo "Starting Google Chrome..."
# 新增 --disable-dev-shm-usage 解决云环境 crash 问题
exec google-chrome-stable \
  --no-sandbox \
  --disable-gpu \
  --remote-debugging-address=0.0.0.0 \
  --remote-debugging-port=9222 \
  --user-data-dir=/home/chromeuser/chrome-data \
  --window-size=${SCREEN_WIDTH},${SCREEN_HEIGHT} \
  --window-position=0,0 \
  --start-maximized \
  --disable-blink-features=AutomationControlled \
  --disable-infobars \
  --no-first-run \
  --no-default-browser-check \
  --disable-dev-shm-usage \
  --password-store=basic \
  "$@"

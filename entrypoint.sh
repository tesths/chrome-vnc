#!/bin/bash
set -e

# 设置默认密码
: ${VNC_PASSWORD:=zeabur123}

# 清理可能存在的 X11 锁文件 (防止容器重启后报错)
rm -f /tmp/.X99-lock
rm -f /tmp/.X11-unix/X99

echo "[-] Initializing D-Bus..."
# 启动 D-Bus 会话总线，这能解决很多 Chrome 图形界面崩溃或通信失败的问题
eval $(dbus-launch --sh-syntax)
export DBUS_SESSION_BUS_ADDRESS

echo "[-] Starting Xvfb (Virtual Display)..."
Xvfb $DISPLAY -screen 0 ${SCREEN_WIDTH}x${SCREEN_HEIGHT}x${SCREEN_DEPTH} -nolisten tcp &
PID_XVFB=$!

# 循环等待 Xvfb 就绪，比死板的 sleep 更稳定
echo "[-] Waiting for Xvfb..."
for i in {1..10}; do
  if xdpyinfo -display $DISPLAY >/dev/null 2>&1; then
    echo "Xvfb is ready."
    break
  fi
  sleep 1
done

echo "[-] Starting Fluxbox..."
fluxbox &

echo "[-] Starting x11vnc..."
x11vnc -display $DISPLAY -forever -shared -passwd "$VNC_PASSWORD" -bg -quiet

echo "[-] Starting Google Chrome on port 9111..."

exec google-chrome-stable \
  --no-sandbox \
  --test-type \
  --disable-gpu \
  --remote-debugging-address=0.0.0.0 \
  --remote-debugging-port=9111 \   <-- 这里修改为 9111
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
  --disable-features=Translate \
  "$@"

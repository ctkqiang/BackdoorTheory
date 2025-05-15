import webview
import socket


class 假Deepseek:
    def __init__(self):
        self.appname = "DeepSeek"
        self.version = "1.0"
        self.url = "https://chat.deepseek.com/"

    def check_network(self, host="8.8.8.8", port=53, timeout=3):
        try:
            socket.setdefaulttimeout(timeout)
            socket.socket(socket.AF_INET, socket.SOCK_STREAM).connect((host, port))
            print("✅ 网络连接正常")
            return True
        except Exception as ex:
            print(f"❌ 网络连接失败: {ex}")
            return False

    def start(self):
        if self.check_network():
            webview.create_window(self.appname, self.url, width=900, height=600)
            webview.start()  # 显式启动事件循环
        else:
            print("请检查网络连接，无法启动WebView。")


if __name__ == "__main__":
    app = 假Deepseek()
    app.start()

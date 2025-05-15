import sys
import os
import subprocess


def build():
    script_name = "./木马/deepseek.py"
    icon_win = "./assets/logo.ico"
    icon_mac = "./assets/logo.icns"

    if sys.platform == "win32":
        cmd = ["pyinstaller", "-F", "-w", f"--icon={icon_win}", script_name]
        print("🔧 Windows 平台，开始打包exe...")
    elif sys.platform == "darwin":
        cmd = ["pyinstaller", "-F", "-w", f"--icon={icon_mac}", script_name]
        print("🍎 macOS 平台，开始打包app...")
    else:
        print(f"❌ 当前平台 {sys.platform} 暂不支持自动打包脚本")
        return

    # 调用子进程执行命令
    result = subprocess.run(
        cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
    )
    if result.returncode == 0:
        print("✅ 打包完成！查看 dist 文件夹")
    else:
        print("❌ 打包失败，错误信息：")
        print(result.stderr)


if __name__ == "__main__":
    build()

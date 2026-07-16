# -*- coding: utf-8 -*-
"""
Logging and Cross-Platform Notification support for CekRAM.
Supports Windows Toast, Linux notify-send, and macOS Notification Center.
"""

import os
import time
import datetime
import platform
import subprocess
from typing import Optional, Dict, Any


def log_event(log_path: Optional[str], level: str, message: str, metrics: Optional[Dict[str, Any]] = None):
    """
    Appends formatted log entry with timestamp and optional metrics to log file.
    """
    if not log_path:
        return
    try:
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        entry = f"[{timestamp}] [{level.upper()}] {message}"
        if metrics:
            entry += f" | RAM: {metrics.get('used_mb')}/{metrics.get('total_mb')} MB ({metrics.get('percent')}%)"
        entry += "\n"
        with open(log_path, "a", encoding="utf-8") as f:
            f.write(entry)
    except Exception as e:
        # Avoid crashing app if log file is unwriteable
        pass


def send_notification(title: str, message: str):
    """
    Triggers desktop notification on Windows, Linux, and macOS.
    """
    os_name = platform.system()
    try:
        if os_name == "Linux":
            if subprocess.run(["which", "notify-send"], stdout=subprocess.PIPE, stderr=subprocess.PIPE).returncode == 0:
                subprocess.run(["notify-send", "-u", "critical", title, message], check=False)
        elif os_name == "Darwin":
            cmd = f'display notification "{message}" with title "{title}"'
            subprocess.run(["osascript", "-e", cmd], check=False)
        elif os_name == "Windows":
            # Try PowerShell BurntToast or balloon tip
            ps_cmd = (
                f'$ErrorActionPreference = "Stop"; '
                f'try {{ New-BurntToastNotification -Text "{title}", "{message}" }} '
                f'catch {{ '
                f'Add-Type -AssemblyName System.Windows.Forms; '
                f'$n = New-Object System.Windows.Forms.NotifyIcon; '
                f'$n.Icon = [System.Drawing.SystemIcons]::Information; '
                f'$n.Visible = $true; '
                f'$n.ShowBalloonTip(5000, "{title}", "{message}", [System.Windows.Forms.ToolTipIcon]::Warning); '
                f'Start-Sleep -Seconds 5; $n.Dispose() }}'
            )
            subprocess.Popen(["powershell", "-NoProfile", "-Command", ps_cmd], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except Exception:
        pass

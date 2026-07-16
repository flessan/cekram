# -*- coding: utf-8 -*-
"""
Configuration management and automatic language detection for CekRAM.
Supports ~/.cekram.yaml (%USERPROFILE%\\.cekram.yaml) and locale detection.
"""

import os
import sys
import locale
import platform
from typing import Dict, Any, Optional

DEFAULT_CONFIG: Dict[str, Any] = {
    "language": None,  # None means auto-detect
    "threshold": 80,
    "interval": 5,
    "auto_purge": False,
    "server": False,
    "port": 8080,
    "theme": "classic",
    "log": None,
    "watch": False,
    "notify": False,
    "dry_run": False,
    "json": False,
}


def detect_system_language() -> str:
    """
    Detects system locale automatically (LANG, LC_ALL, LC_MESSAGES, Windows locale).
    Returns 'id' if locale starts with 'id', otherwise 'en'.
    """
    for env_var in ("LC_ALL", "LC_MESSAGES", "LANG"):
        val = os.environ.get(env_var, "").strip().lower()
        if val:
            if val.startswith("id"):
                return "id"
            if val.startswith("en") or len(val) >= 2:
                break

    try:
        if hasattr(locale, "getlocale"):
            loc = locale.getlocale()[0] if locale.getlocale() else None
            if not loc and hasattr(locale, "getdefaultlocale"):
                loc = locale.getdefaultlocale()[0]
        else:
            loc = locale.getdefaultlocale()[0]
        if loc and loc.lower().startswith("id"):
            return "id"
    except Exception:
        pass

    if platform.system() == "Windows":
        try:
            import ctypes
            # GetUserDefaultUILanguage returns LANGID
            lang_id = ctypes.windll.kernel32.GetUserDefaultUILanguage()
            primary_lang_id = lang_id & 0x3FF
            # 0x21 is Indonesian (33 in decimal)
            if primary_lang_id == 0x21:
                return "id"
        except Exception:
            pass

    return "en"


def _parse_simple_yaml(content: str) -> Dict[str, Any]:
    """
    Lightweight zero-dependency YAML/JSON key-value parser for simple config files.
    """
    result: Dict[str, Any] = {}
    for line in content.splitlines():
        line = line.strip()
        if not line or line.startswith("#") or line.startswith("//"):
            continue
        if ":" in line:
            parts = line.split(":", 1)
            key = parts[0].strip().strip('"\'').lower()
            val_str = parts[1].strip().split("#")[0].strip().strip('"\'')
            if not key:
                continue
            if val_str.lower() in ("true", "yes", "on"):
                result[key] = True
            elif val_str.lower() in ("false", "no", "off"):
                result[key] = False
            elif val_str.isdigit():
                result[key] = int(val_str)
            else:
                try:
                    result[key] = float(val_str)
                except ValueError:
                    result[key] = val_str
    return result


def get_config_path() -> Optional[str]:
    """
    Returns path to configuration file if exists.
    Checks ~/.cekram.yaml, ~/.cekram.yml, and local .cekram.yaml.
    """
    home = os.path.expanduser("~")
    candidates = [
        os.path.join(home, ".cekram.yaml"),
        os.path.join(home, ".cekram.yml"),
        os.path.join(home, ".cekram.json"),
        ".cekram.yaml",
        ".cekram.yml",
        ".cekram.json",
    ]
    for path in candidates:
        if os.path.exists(path) and os.path.isfile(path):
            return path
    return None


def load_config() -> Dict[str, Any]:
    """
    Loads configuration from file and applies default values + auto language detection.
    """
    cfg = DEFAULT_CONFIG.copy()
    path = get_config_path()
    if path:
        try:
            with open(path, "r", encoding="utf-8") as f:
                parsed = _parse_simple_yaml(f.read())
                for k, v in parsed.items():
                    if k in cfg:
                        cfg[k] = v
        except Exception:
            pass

    if not cfg["language"]:
        cfg["language"] = detect_system_language()

    return cfg

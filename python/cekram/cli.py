# -*- coding: utf-8 -*-
"""
Command line interface for CekRAM.
"""

import os
import sys
import time
import argparse
from .monitor import get_ram_metrics, purge_memory
from .i18n import get_string


def main():
    parser = argparse.ArgumentParser(description="CekRAM - Universal Super RAM Monitor & Auto-Purge")
    parser.add_argument("--lang", "-l", choices=["id", "en"], default="id", help="Language selection (id/en)")
    parser.add_argument("--threshold", "-t", type=int, default=80, help="RAM percentage threshold for auto-purge (default: 80)")
    parser.add_argument("--interval", "-i", type=int, default=5, help="Refresh interval in seconds (default: 5)")
    parser.add_argument("--oneshot", "--once", "-o", action="store_true", help="Run once and exit without looping")
    parser.add_argument("--purge-now", action="store_true", help="Trigger memory purge immediately and exit")
    parser.add_argument("--server", "-s", action="store_true", help="Launch built-in web dashboard server")
    parser.add_argument("--port", "-p", type=int, default=8080, help="Port for web dashboard server when using --server")

    args = parser.parse_args()

    if args.server:
        from .server import run_server
        run_server(port=args.port, lang=args.lang)
        return

    if args.purge_now:
        alert_msg = get_string("alert", args.lang)
        print(alert_msg)
        res = purge_memory()
        print(f"  [+] {res['detail']}")
        return

    title = get_string("title", args.lang)
    str_total = get_string("total", args.lang)
    str_used = get_string("used", args.lang)
    str_free = get_string("free", args.lang)
    str_percent = get_string("percent", args.lang)
    str_status = get_string("status", args.lang)
    str_safe = get_string("safe", args.lang)
    str_alert = get_string("alert", args.lang)
    str_done = get_string("done", args.lang)
    str_stop = get_string("stop", args.lang)

    try:
        while True:
            # Clear screen across systems
            os.system("cls" if os.name == "nt" else "clear")
            print("=" * 50)
            print(f"        {title}")
            print("=" * 50)

            metrics = get_ram_metrics()
            print(f"  {str_total} : {metrics['total_mb']} MB")
            print(f"  {str_used} : {metrics['used_mb']} MB")
            print(f"  {str_free} : {metrics['free_mb']} MB")
            print(f"  {str_percent} : [{metrics['percent']} %]")
            print("-" * 50)

            if metrics["percent"] > args.threshold:
                print(f"  {str_alert}")
                res = purge_memory()
                print(f"  {str_done}")
            else:
                print(f"  {str_status} : {str_safe}")

            print("-" * 50)

            if args.oneshot:
                break

            print(f"  {str_stop}")
            time.sleep(args.interval)
    except KeyboardInterrupt:
        print("\n[+] Exiting CekRAM. Goodbye!")
        sys.exit(0)


if __name__ == "__main__":
    main()

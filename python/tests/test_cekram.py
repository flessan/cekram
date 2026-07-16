# -*- coding: utf-8 -*-
import os
import unittest
from cekram.monitor import get_ram_metrics, purge_memory
from cekram.i18n import get_string
from cekram.config import load_config, _parse_simple_yaml, detect_system_language
from cekram.notify import log_event


class TestCekRAM(unittest.TestCase):
    def test_metrics(self):
        metrics = get_ram_metrics()
        self.assertIn("total_mb", metrics)
        self.assertIn("used_mb", metrics)
        self.assertIn("free_mb", metrics)
        self.assertIn("percent", metrics)
        self.assertGreaterEqual(metrics["total_mb"], 0)

    def test_i18n(self):
        title_id = get_string("title", "id")
        title_en = get_string("title", "en")
        self.assertIn("ID", title_id)
        self.assertIn("EN", title_en)

    def test_purge(self):
        res = purge_memory(dry_run=False)
        self.assertIn("success", res)
        self.assertIn("detail", res)

    def test_dry_run_purge(self):
        res = purge_memory(dry_run=True)
        self.assertTrue(res.get("dry_run"))
        self.assertIn("DRY-RUN", res["detail"])
        self.assertTrue(res["success"])

    def test_yaml_parser(self):
        yaml_content = """
        threshold: 85
        interval: 10
        auto_purge: true
        theme: nerd
        language: en
        """
        parsed = _parse_simple_yaml(yaml_content)
        self.assertEqual(parsed["threshold"], 85)
        self.assertEqual(parsed["interval"], 10)
        self.assertTrue(parsed["auto_purge"])
        self.assertEqual(parsed["theme"], "nerd")
        self.assertEqual(parsed["language"], "en")

    def test_language_detection(self):
        lang = detect_system_language()
        self.assertIn(lang, ["id", "en"])

    def test_load_config(self):
        cfg = load_config()
        self.assertIn("threshold", cfg)
        self.assertIn("theme", cfg)

    def test_log_event(self):
        test_log = "test_memory.log"
        if os.path.exists(test_log):
            os.remove(test_log)
        log_event(test_log, "info", "Testing log", {"used_mb": 100, "total_mb": 1000, "percent": 10.0})
        self.assertTrue(os.path.exists(test_log))
        with open(test_log, "r") as f:
            content = f.read()
        self.assertIn("Testing log", content)
        if os.path.exists(test_log):
            os.remove(test_log)


if __name__ == "__main__":
    unittest.main()

# -*- coding: utf-8 -*-
import unittest
from cekram.monitor import get_ram_metrics, purge_memory
from cekram.i18n import get_string


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
        res = purge_memory()
        self.assertIn("success", res)
        self.assertIn("detail", res)


if __name__ == "__main__":
    unittest.main()

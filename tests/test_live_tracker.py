import unittest

from live_tracker import _parse_sample


class TestLiveTracker(unittest.TestCase):
    def test_parse_sample(self):
        distance, elapsed = _parse_sample("4.2,20:30")
        self.assertEqual(distance, 4.2)
        self.assertEqual(elapsed, 1230)

    def test_parse_sample_invalid(self):
        with self.assertRaises(ValueError):
            _parse_sample("4.2")


if __name__ == "__main__":
    unittest.main()

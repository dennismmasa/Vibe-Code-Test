import unittest

from pace_tracker import _parse_hhmmss, evaluate_pace


class TestParseTime(unittest.TestCase):
    def test_hhmmss(self):
        self.assertEqual(_parse_hhmmss("1:02:03"), 3723)

    def test_mmss(self):
        self.assertEqual(_parse_hhmmss("45:30"), 2730)


class TestEvaluatePace(unittest.TestCase):
    def test_ahead(self):
        # Goal: 10k in 50 min => 5:00/km, current 4:30/km
        status = evaluate_pace(10, 3000, 4, 1080)
        self.assertEqual(status.status, "ahead")

    def test_on_pace(self):
        status = evaluate_pace(10, 3000, 5, 1505)
        self.assertEqual(status.status, "on pace")

    def test_behind(self):
        # Goal: 10k in 50 min => 5:00/km, current 5:30/km
        status = evaluate_pace(10, 3000, 4, 1320)
        self.assertEqual(status.status, "behind")

    def test_projected_vs_goal_sec(self):
        status = evaluate_pace(10, 3000, 5, 1350)  # 4:30/km => 45:00 finish
        self.assertEqual(status.projected_vs_goal_sec, -300)


if __name__ == "__main__":
    unittest.main()

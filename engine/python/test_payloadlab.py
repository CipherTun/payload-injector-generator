import unittest
from payloadlab import Spec, generate

class PayloadLabTests(unittest.TestCase):
    def test_normal(self):
        result = generate(Spec("example.com", 443, "CONNECT", "HTTP/1.1"))
        self.assertFalse(result["errors"])
        self.assertIn("Host: example.com", result["payload"])

    def test_invalid_port(self):
        result = generate(Spec("example.com", 0, "GET", "HTTP/1.1"))
        self.assertTrue(result["errors"])

if __name__ == "__main__":
    unittest.main()

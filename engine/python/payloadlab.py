#!/usr/bin/env python3
"""
PayloadLab Python compatibility/reference CLI.

This module intentionally stays offline. It constructs and validates text; it
does not perform network requests.
"""

from __future__ import annotations
import argparse
import base64
import json
import sys
import urllib.parse
from dataclasses import dataclass, field

TYPES = {
    "normal", "front_inject", "back_inject",
    "front_query", "back_query", "websocket", "sni",
}

@dataclass
class Spec:
    host: str
    port: int
    method: str
    protocol: str
    type: str = "normal"
    user_agent: str = ""
    headers: dict[str, str] = field(default_factory=dict)
    split: bool = False

def generate(s: Spec) -> dict:
    errors: list[str] = []
    warnings: list[str] = []
    if not s.host.strip():
        errors.append("host is required")
    if "\r" in s.host or "\n" in s.host:
        errors.append("host must not contain CR or LF")
    if not 1 <= s.port <= 65535:
        errors.append("port must be between 1 and 65535")
    if not s.method.strip():
        errors.append("method is required")
    if s.type not in TYPES:
        errors.append(f"unknown payload type: {s.type}")
    for name, value in s.headers.items():
        if not name.strip() or any(c in name for c in "\r\n:"):
            errors.append("invalid header name")
        if "\r" in value or "\n" in value:
            errors.append("header values must not contain CR or LF")
    if errors:
        return {"payload": "", "warnings": warnings, "errors": errors}

    crlf = "\r\n"
    host = s.host.strip()
    authority = f"{host}:{s.port}"
    method = s.method.strip().upper()
    protocol = s.protocol.strip()

    if s.type in {"normal", "sni"}:
        payload = f"{method} {authority} {protocol}{crlf}Host: {host}{crlf}"
    elif s.type == "front_inject":
        payload = f"GET http://{host}/ {protocol}{crlf}Host: {host}{crlf}{crlf}"
        payload += f"{method} {authority} {protocol}{crlf}"
    elif s.type == "back_inject":
        payload = f"{method} {authority} {protocol}{crlf}{crlf}"
        payload += f"GET http://{host}/ {protocol}{crlf}Host: {host}{crlf}"
    elif s.type == "front_query":
        payload = f"{method} {host}@{authority} {protocol}{crlf}"
    elif s.type == "back_query":
        payload = f"{method} {authority}@{host} {protocol}{crlf}"
    else:
        payload = (
            f"{method} {authority} {protocol}{crlf}"
            f"Upgrade: websocket{crlf}Connection: Upgrade{crlf}Host: {host}{crlf}"
        )

    if s.user_agent:
        payload += f"User-Agent: {s.user_agent}{crlf}"
    for name, value in s.headers.items():
        if name.lower() != "host":
            payload += f"{name.strip()}: {value}{crlf}"
    payload += crlf

    if s.split:
        payload = payload.replace(crlf + f"Host: {host}", "[split]" + crlf + f"Host: {host}", 1)
        warnings.append("split is an inspection marker, not a transmitted protocol primitive")
    if s.type == "sni":
        warnings.append("SNI belongs to the TLS layer and is not an HTTP request-line field")

    return {"payload": payload, "warnings": warnings, "errors": errors}

def main() -> int:
    parser = argparse.ArgumentParser(description="Offline PayloadLab compatibility tool")
    parser.add_argument("--input", help="JSON spec file")
    parser.add_argument("--base64", help="Base64 encode input text")
    parser.add_argument("--decode-base64", help="Base64 decode input text")
    args = parser.parse_args()

    if args.base64 is not None:
        print(base64.b64encode(args.base64.encode()).decode())
        return 0
    if args.decode_base64 is not None:
        try:
            print(base64.b64decode(args.decode_base64).decode())
            return 0
        except Exception as exc:
            print(f"error: {exc}", file=sys.stderr)
            return 1

    if not args.input:
        parser.error("--input or an encoding option is required")

    with open(args.input, encoding="utf-8") as fh:
        raw = json.load(fh)
    result = generate(Spec(
        host=raw.get("host", ""),
        port=int(raw.get("port", 0)),
        method=raw.get("method", ""),
        protocol=raw.get("protocol", ""),
        type=raw.get("type", "normal"),
        user_agent=raw.get("user_agent", ""),
        headers=raw.get("headers", {}),
        split=bool(raw.get("split", False)),
    ))
    print(json.dumps(result, indent=2))
    return 1 if result["errors"] else 0

if __name__ == "__main__":
    raise SystemExit(main())

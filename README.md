# PayloadLab

PayloadLab is an offline-first Flutter laboratory for constructing, inspecting,
formatting, encoding, validating, saving, and comparing HTTP-style request
templates.

## Scope

PayloadLab is a construction and analysis tool. It does not implement a VPN,
carrier bypass, credential theft, stealth, persistence, or automated attacks.
Generated text is not proof that a remote service will accept it.

## Architecture

- `lib/` — Flutter application, UI, ViewModels, repositories and domain logic.
- `engine/go/` — standalone Go engine with JSON CLI and tests.
- `engine/python/` — compatibility/reference tooling and tests.
- `assets/templates/` — built-in safe templates.
- `.github/workflows/` — reproducible analysis and Android build workflow.

The Flutter app contains the Dart engine because Android cannot execute an
arbitrary Go CLI process as an in-process backend. The Go engine mirrors the
same domain model and is useful for server-side tooling, CI, regression tests,
and future native integration.

## Run

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Go engine

```bash
cd engine/go
go test ./...
go run ./cmd/payloadlab --input examples/request.json
```

## Python compatibility tool

```bash
python3 engine/python/payloadlab.py --help
```

## Safety

Use generated material only on systems and services you are authorized to test.

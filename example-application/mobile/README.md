# car2go

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 🔐 Android CI Keystore Handling

This demo Flutter application is designed to be built and tested inside a containerized CI environment.

In CI, the APK is signed and aligned during the **builder stage** using a release keystore (`release.keystore`) and a pair of ADB keys (`adbkey`, `adbkey.pub`) injected via Docker secrets.

**Keystore usage:**
- The keystore is required to produce signed and aligned `APK` and `AAB` artifacts during build.
- These secrets are passed only to the `builder` stage and **not** embedded in the final image (`runner`).
- The keystore used in CI corresponds to the Play Store release key or a temporary one for test builds.

**ADB keypair usage:**
- ADB keys are used to establish trust between the `Appium` test runner and the Android emulator.
- The emulator runs inside a Docker container and loads the matching `adbkey.pub` at boot.
- The test runner must use the corresponding `adbkey` to be authorized.

⚠️ In local development, fallback default keys are generated if no existing ones are found in `~/.android`.

**Secure practice:**
- CI secrets (keystore + ADB keys) are passed securely via `--mount=type=secret` and not retained in the final container layer.
- The images are compatible with both `arm64` and `amd64` architectures.

For more details, see the CI build setup in the parent project or the Dockerfiles under `local/android/`.


## 🛠️ Makefile Integration for Example Application

This example application includes a dedicated `Makefile` that enables seamless integration with the Vegito CI/CD system.

### Available Targets

- `make build-release`: Builds the release APK and AAB artifacts.
- `make extract-artifacts`: Extracts the APK, AAB, and keystore SHA1 from a tagged container image.
- `make push-release`: Pushes the tagged image and artifacts to the registry.
- `make clean`: Cleans up build outputs.

### CI/CD Reusability

The project leverages a reusable GitHub Actions workflow defined in:

```
./example-application/.github/workflows/application-release.yml
```

This workflow:
- Uses the same versioning logic as the main Vegito repo.
- Builds tagged release images.
- Extracts Android artifacts (APK, AAB, SHA1).
- Publishes the consolidated release.

This modular structure ensures that the example app behaves as a fully standalone subtree, while remaining fully interoperable with Vegito’s central pipeline logic.

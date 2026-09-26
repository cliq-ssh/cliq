# Release workflow

## Workflows

1. **Bump Version** – bumps the version in all packages and in [`VERSION.json`](../VERSION.json)
   root file.
2. **Release** – publishes one release for the selected channel: `edge`, `beta`, or `prod`.

# Usage

Each release iteration follows this order:

1. Run **Bump Version** from the Actions tab and provide the new semantic version. This updates the shared version in
   the frontend, backend, docs, and [`VERSION.json`](../VERSION.json). The JSON file stores the semantic version and the
   shared frontend build number.
2. Run **Release** from the Actions tab and select the release channel:
    - **edge** creates or overrides the `edge` release, marked as a pre-release. It builds all installers and the
      backend JAR, publishes the backend `backend-dev` Docker image, and publishes the frontend to the App Store for
      internal testers.
    - **beta** creates a versioned pre-release tagged `v<version>-beta+<buildnumber>`. It builds all installers and the
      backend JAR, publishes the iOS app to TestFlight for external testers, and publishes the backend beta image.
    - **prod** creates a draft versioned release tagged `v<version>`. It builds all installers and the backend JAR,
      publishes `backend:v<version>`, and publishes iOS and macOS to the App Store.

# Descriptions

## Bump Version

The main goal of this workflow is to keep a unified version across all the components:

- backend
- frontend
- docs

Our single source of truth is [`VERSION.json`](../VERSION.json), which contains the semantic version in `version` and
the shared frontend build number in `buildNumber`. Both values are kept in sync with `frontend/pubspec.yaml`.

### Frontend build metadata

The frontend embeds release metadata at compile time using Flutter's `--dart-define-from-file` option. The values are
available at runtime through `BuildMetadata` in `frontend/lib/shared/utils/build_metadata.dart`:

| Define                 | Runtime value                                        |
|------------------------|------------------------------------------------------|
| `CLIQ_VERSION`         | Semantic application version                         |
| `CLIQ_BUILD_NUMBER`    | Numeric frontend build number                        |
| `CLIQ_GIT_SHA`         | Full Git commit SHA, or `dev` for local development  |
| `CLIQ_GIT_SHA_SHORT`   | Short Git commit SHA, or `dev` for local development |
| `CLIQ_RELEASE_CHANNEL` | `dev`, `edge`, `beta`, or `prod`                     |

Local builds default to `dev` metadata. Release workflows generate the define file from `VERSION.json`, the checked-out
commit, and the selected release channel.

## Release

The release workflow builds all installers and the backend JAR for every release channel. The selected channel controls
the release visibility, Docker image, and App Store distribution:

| Channel | GitHub release                                      | Backend                                         | Frontend                                   |
|---------|-----------------------------------------------------|-------------------------------------------------|--------------------------------------------|
| `edge`  | Create or override `edge`; pre-release              | Publish `backend-dev` Docker image              | App Store internal testers                 |
| `beta`  | Create `v<version>-beta+<buildnumber>`; pre-release | Publish `backend:v<version>-beta-<buildnumber>` | TestFlight external testers                |
| `prod`  | Create `v<version>` as a draft release              | Publish `backend:v<version>`                    | Normal App Store release for iOS and macOS |

Docker tags cannot contain `+`, so the beta Docker tag normalizes the release tag's `+<buildnumber>` suffix to
`-<buildnumber>`. The GitHub release tag retains the exact semantic version format. Production uses the same
`v<version>` tag for both the GitHub release and the backend image. Production releases remain drafts so release notes
can be edited before the announcement.

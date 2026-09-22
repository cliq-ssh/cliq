# Release workflow

## Workflows

1. **Bump Version** – bumps the version in all packages and in the [`VERSION`](../VERSION)
   root file.
2. **Release** – publishes one release for the selected channel: `edge`, `beta`, or `prod`.

# Usage

Each release iteration follows this order:

1. Run **Bump Version** from the Actions tab and provide the new semantic version. This updates the shared version in
   the frontend, backend, docs, and [`VERSION`](../VERSION).
2. Run **Release** from the Actions tab and select the release channel:
    - **edge** creates or overrides the `edge` release, marked as a pre-release. It builds all installers and the
      backend JAR, publishes the backend `backend-dev` Docker image, and publishes the frontend to the App Store for
      internal testers.
    - **beta** creates a normal versioned release marked as a pre-release. It builds all installers and the backend JAR
      and publishes the iOS app to the App Store for external testers. For the backend, we should publish a Docker image
      to `backend:<version>-beta`.
    - **prod** creates a normal versioned release. It builds all installers and the backend JAR, publishes the backend
      `backend` Docker image, and publishes the frontend to the normal App Store release.

# Descriptions

## Bump Version

The main goal of this workflow is to keep a unified version across all the components:

- backend
- frontend
- docs

Our single source of truth is the [`VERSION`](../VERSION) file that only contains a semver compatible version string.
The build number is only bumped and used in the frontend component and therefore is not part of the
[`VERSION`](../VERSION) file.

## Release

The release workflow builds all installers and the backend JAR for every release channel. The selected channel controls
the release visibility, Docker image, and App Store distribution:

| Channel | GitHub release                          | Backend                                                           | Frontend                   |
|---------|-----------------------------------------|-------------------------------------------------------------------|----------------------------|
| `edge`  | Create or override `edge`; pre-release  | Publish `backend-dev` Docker image                                | App Store internal testers |
| `beta`  | Create a versioned release; pre-release | **TODO:** decide how the backend beta release should be published | App Store external testers |
| `prod`  | Create a versioned normal release       | Publish `backend` Docker image                                    | Normal App Store release   |

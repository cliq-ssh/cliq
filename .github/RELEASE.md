# Release workflow

## Workflows

1. bump version – this workflow bumps the version in all the packages and in the `VERSION` root-file
2. release edge – publishes an edge release for internal testers
3. release – publishes a (beta) release that only promotes the edge release

# Usage

Each release iteration follows this order:

1. Run **Bump Version** from the Actions tab and provide the new semantic version. This updates the shared version in
   the frontend, backend, docs, and [`VERSION`](../VERSION).
2. Run **Release Edge** from the Actions tab. This builds all artifacts, publishes the backend edge images, optionally
   publishes the configured app-store builds and creates or updates the `edge` prerelease. Repeat this step whenever a
   new edge build is needed for internal testing.
3. Run **Release** from the Actions tab after the edge build is ready. It downloads the artifacts from the `edge`
   release, promotes the backend images, and creates the versioned release. Enable the beta option when publishing a
   beta release; leave it disabled for a full release.

# Descriptions

## Bump version

The main goal of this workflow is to keep a unified version across all the components:

- backend
- frontend
- docs

Our single source of truth is the [`VERSION`](../VERSION) file that only contains a semver compatible version string.  
The build number is only bumped and used in the frontend component and therefore not part of the [`VERSION`](../VERSION)
file.

## Release Edge

The main goal of this workflow is to build an edge build of the software and publish it to a single `edge` prerelease
and to internal testers through the configured app stores.
This is the only workflow that will actually build the software.
It creates or updates the `edge` release with the new build artifacts.

## Release

The main goal of this workflow is to take the `edge` release and promote the build to beta or stable users.
It creates a new versioned release with the same artifacts as the `edge` release and promotes the backend image.

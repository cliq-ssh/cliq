# Release workflow

## Workflows

1. bump version – this workflow bumps the version in all the packages and in the `VERSION` root-file
2. release edge – publishes an edge release for internal testers
3. release – publishes a (beta) release that only promotes the edge release

# Descriptions

## Bump version

The main goal of this workflow is to keep a unified version across all the components:

- backend
- frontend
- docs

Our single source of truth is the [`VERSION`](../VERSION) file that only contains a semver compatible version string.  
The build number is only bumped and used in the frontend component and therefore not part of the [`VERSION`](../VERSION)
file.

## Release edge

The main goal of this workflow is to build an edge build of the software and publish it to a single draft Release and to
internal testers to the app stores.  
This is the only workflow that will actually build the software.
It should create or update a draft release with the new build artifacts and publish the build to internal testers in the
app stores.

## Release

The main goal if this workflow is to take an edge release and promote the build to beta or stable version.  
It should create a new release with the same build artifacts as the edge release and publish it to the app stores for
beta or stable users.

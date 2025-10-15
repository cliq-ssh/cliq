group "default" {
  targets = ["debian", "alpine"]
}

target "debian" {
  context    = "."
  dockerfile = "docker/prod/debian.Dockerfile"
  tags       = ["ghcr.io/cliq-ssh/backend:dev-debian"]
  output     = ["type=docker"]
}

target "alpine" {
  context    = "."
  dockerfile = "docker/prod/alpine.Dockerfile"
  tags       = ["ghcr.io/cliq-ssh/backend:dev-alpine"]
  output     = ["type=docker"]
}

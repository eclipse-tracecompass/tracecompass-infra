# Trace Compass Infrastructure

This repository contains all the infrastructure code needed to build **Trace Compass** and **Trace Compass Incubator**, e.g. Jenkinsfiles, Dockerfiles etc.

# How to build the docker image (tag 16.04)
```bash
docker build --no-cache --build-arg version=16.04 --build-arg strip=true  -t eclipse/tracecompass-build-env:16.04 .
```

# How to push the docker image to dockerHub under the eclipse organisation
```bash
docker push eclipse/tracecompass-build-env:16.04
```bash

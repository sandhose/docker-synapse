# Alternative [Synapse](https://github.com/matrix-org/synapse/) Docker image

https://hub.docker.com/r/sandhose/synapse

## Features

 1. Multiple config files with Jinja templating are merged
 2. Config files are re-generated every time
 3. Runs on amd64, i386, armv6, arm64v8
 4. Multi-arch manifest. Use the same image for different architectures
 5. ~~Takes a lot of time to (cross-)compile all the images~~

## Why?

I have two Kubernetes clusters, one made of Raspberry PI and the other made of amd64 servers.
I wanted to be able to use the same image on both.

Also, I needed a way to add my own config files via Kubernetes' ConfigMaps, and modify some values at runtime using environment variables.
The official don't allow for multiple config files, and when you provide your own config file, the template engine isn't run.

---

Here are the Kubernetes manifests I'm using for my homeserver: https://gist.github.com/sandhose/4a8e568c1f159134cebe6da20a2f18c1

I might do a Helm chart for Synapse based on this image.

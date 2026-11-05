# Local example

Applies circuit-cosign to a throwaway Rocky Linux 10 container with systemd. You need Conn3x and Podman.

```sh
./up.sh
conn3x init
conn3x apply
conn3x plan
```

The second plan says `No changes.`

Want to see it work? `check.sh` makes a key pair on the host, signs a file, verifies it, then changes the file and checks the old signature is refused. It uses an empty signing config, so nothing goes to Sigstore's public services:

```sh
podman exec -i circuit-cosign sh -s 3.1.4 < check.sh
```

The argument is the version it expects `cosign version` to report. Leave it out to skip that part.

`up.sh` listens on `127.0.0.1:2222`. Set `PORT` to use another port, and pass the same port to Conn3x with `-var port=PORT`. Set `CONTAINER_NAME` to name the container something else. Set `CONTAINERFILE` to test another distro, such as one of the images in Conn3x's `test/images`, which CI uses. On a Mac, rootful Podman is simplest: `export CONTAINER_CONNECTION=podman-machine-default-root`.

`./down.sh` removes the container, its volumes, the key and the state.

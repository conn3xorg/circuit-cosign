#!/usr/bin/env sh
# Runs on the host: makes a key pair, signs a file with it, verifies the
# signature, then checks that a changed copy of the file fails to verify.
# Nothing goes to Sigstore's public services: the key is a local one, and an
# empty signing config means no transparency log or timestamp authority.
# CI pipes it in with podman exec, passing the version it expects.
set -eu
want=${1:-}
cosign version
if [ -n "$want" ]; then
  cosign version 2>&1 | grep -q "GitVersion: *v$want\$"
fi

dir=$(mktemp -d)
trap 'rm -rf "$dir"' EXIT
cd "$dir"
export HOME="$dir" COSIGN_PASSWORD=conn3x-check

cosign generate-key-pair
cosign signing-config create --out offline.json
echo "release 1.0.0" > artifact.txt
cosign sign-blob --yes --key cosign.key --signing-config offline.json \
  --bundle artifact.sigstore.json artifact.txt
cosign verify-blob --key cosign.pub --bundle artifact.sigstore.json --insecure-ignore-tlog artifact.txt

echo "release 1.0.1" > artifact.txt
if cosign verify-blob --key cosign.pub --bundle artifact.sigstore.json --insecure-ignore-tlog artifact.txt; then
  echo "A changed file verified against the old signature." >&2
  exit 1
fi

# Sigstore's trust root is cached under HOME when cosign fetches it, so its
# absence shows nothing here reached the network.
if [ -e "$dir/.sigstore" ]; then
  echo "cosign fetched Sigstore's trust root during the check." >&2
  exit 1
fi
echo "Signed, verified, and the changed file was refused."

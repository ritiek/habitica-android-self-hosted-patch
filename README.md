# habitica-android-self-hosted-patch

Patches Android builds of Habitica to point towards a custom domain instead of the defaults which
is https://habitica.com/. Useful if you're self-hosting your own instance of Habitica and are
interested in using the Android app to point to your own instance as well.

**NOTE:** This supports only habitica-android versions <= 4.4. Later builds of habitica-android
are zipped as an .XAPK file which so far I have been unsuccessful in putting back the patched
version together.

Currently the script hardcodes the link to the habitica-android v4.4 APK in the source.

## Docker

You can patch the APK using Docker image on GHCR built using GitHub Actions CI with:
```bash
$ docker run --rm -v $(pwd)/target:/target patch-habitica my-habitica-server.com
$ ls ./target/7971.apk
```

## Nix

```bash
$ nix run github:ritiek/habitica-android-self-hosted-patch
```

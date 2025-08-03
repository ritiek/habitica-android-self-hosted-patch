# habitica-android-self-hosted-patch

Patches Android builds of Habitica to point towards a custom domain instead of the defaults which
is https://habitica.com/. Useful if you're self-hosting your own instance of Habitica and are
interested in using the Android app to point to your own instance as well.

**NOTE:** This supports only habitica-android versions <= 4.4. Later builds of habitica-android
are zipped as an .XAPK file which so far I have been unsuccessful in putting back the patched
version together.

Currently the script hardcodes the link to the habitica-android v4.4 APK in the source.


## Usage

All of the following methods seem to currently work only on x86_64 machines at the time of writing.
In each of them, replace `my-habitica-server.com` with the domain where your personal Habitica
instance is hosted on.

### Nix

If you have the Nix package manager:
```bash
$ nix run github:ritiek/habitica-android-self-hosted-patch my-habitica-server.com
```

### Docker

You can patch the APK using Docker image on GHCR built using GitHub Actions CI with:
```bash
$ docker run --rm -v $(pwd)/target:/target ghcr.io/ritiek/habitica-android-self-hosted-patch:latest my-habitica-server.com
```

You can also clone this repo and build the Docker image locally if needed:
```bash
$ docker build -t patch-habitica .
$ docker run --rm -v $(pwd)/target:/target patch-habitica my-habitica-server.com
```

### Shell

If you have the required dependencies - openjdk17, apktool installed and setupped, you can
clone the repo and directly invoke the shell script with:
```bash
$ ./patch-habitica.sh my-habitica-server.com
```

----------------------

Patched APK can be found in:
```bash
$ ls ./target/7971.apk
```

Any build intermediates and artifacts can be cleaned using:
```bash
$ rm -rf ./build/ ./target/
```

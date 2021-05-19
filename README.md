# dnsmasq in Docker

This is a Docker image containing a statically built copy of dnsmasq.

## About dnsmasq

dnsmasq is a small and lightweight program for DNS, DHCP, router advertisement, and network booting.

More information can be found here: <http://www.thekelleys.org.uk/dnsmasq/doc.html>

## Running this Docker image

There are many uses for dnsmasq and can be ran in various configurations using different arguments.  Please refer to the documentation regarding dnsmasq on the page mentioned in the previous section to run dnsmasq.  All arguments passed to the docker image will be passed directly to the dnsmasq executable.

Here is a basic example of running dnsmasq in Docker:

```bash
dnsmasq_arguments="--log-queries"

docker run \
 --detach \
 --restart unless-stopped \
 --name dnsmasq \
 macgyverbass/dnsmasq:latest \
 ${dnsmasq_arguments}
```

In the above example, Docker will run the image detached and set to restart (unless stopped) if the system restarts, with the container name "dnsmasq".  The "${dnsmasq_arguments}" are whatever arguments you decide to pass to the dnsmasq binary, in this example "--log-queries" is used.

To see a list of options, you may use the `--help` argument to view the dnsmasq help text.  Here is an example of viewing that information:

```bash
docker run --rm macgyverbass/dnsmasq:latest --help
```

This will execute the Docker image, passing `--help` to the dnsmasq binary and upon exit will remove the container.

Note that running the Docker image without any arguments will result in the version information being displayed.

## Additional Notes for this Docker Image

This Docker image uses a volume for the `dnsmasq.leases` file in the `/var/lib/misc/` folder.  You may choose to run this Docker image with a named volume or having the folder bind mounted to a local path.  Examples are below:

```bash
dnsmasq_arguments="--log-queries"

docker run \
 --detach \
 --restart unless-stopped \
 --name dnsmasq \
 -v dnsmasq-leases:/var/lib/misc/ \
 macgyverbass/dnsmasq:latest \
 ${dnsmasq_arguments}
```

```bash
dnsmasq_arguments="--log-queries"

docker run \
 --detach \
 --restart unless-stopped \
 --name dnsmasq \
 -v /my-docker-data/dnsmasq-leases/:/var/lib/misc/ \
 macgyverbass/dnsmasq:latest \
 ${dnsmasq_arguments}
```

Mounting this volume isn't required, but the data within the volume (the `dnsmasq.leases` file) may not persist when the container is recreated/updated.  To keep the data persistent, consider using a named/bind mount for this folder.  Note that this folder/volume is not required if the `--leasefile-ro` argument is used.

Note that if you are running the `dnsmasq` executable in your own Docker image as a daemon service (without the `--no-daemon` argument), the `/var/run/` folder is required.  This folder can be created in the image (if it does not already exist) or at image runtime using the same method as above using a volume for the `/var/run/` folder.

Currently, this Docker image applies the `--no-daemon` argument by default in the entrypoint, so this folder/volume is not required when running this image.

More information regarding Docker Volumes can be found here: [Docker Docs: Use Volumes](https://docs.docker.com/storage/volumes/)

## Network accessiblity

For network devices to be able to find and communicate with dnsmasq, it is best to run this image using `--network host` or using a macvlan you've previously created that co-exists on your network with your devices.  This is to allow the container to advertise the DHCP and/or DNS to devices and for those devices to be able to thus connect to the container.  Using the default network bridge will not work as your devices will not able to find and communicate with this container.

If your devices do not need to detect/find the container running on the network, you may forward the necessary ports from the host to the container.  Note that you may have problems doing this with DHCP, but it should work fine with DNS requests.

## Fix for error "dnsmasq: process is missing required capability NET_ADMIN"

In some cases, the `NET_ADMIN` capability will need to be added to the docker run command using the docker run `--cap-add NET_ADMIN` argument.  For example:

```bash
dnsmasq_arguments="--log-queries"

docker run \
 --detach \
 --restart unless-stopped \
 --cap-add NET_ADMIN \
 --name dnsmasq \
 macgyverbass/dnsmasq:latest \
 ${dnsmasq_arguments}
```

## Details on the Docker build

This is a multi-stage Docker image, done so to compile dnsmasq statically and put the compiled binary in the final stage.

To make the final build as small as possible, it then builds the image from scratch, adding only the required binary file to the final build.  The files /etc/group and /etc/passwd are also added to allow dnsmasq to run under the "nobody" user.

The end result is a Docker image with only the files necessary to run dnsmasq.  Thus this image is very small (about 181kB at the time of writing).

## Building/Advanced Usage

By default, this Docker image uses the latest dnsmasq branch (master) to build the dnsmasq binary file.  However, you may build this image with a different branch/tag by specifying an alternate build-argument.

Build arguments that are available:

* `BRANCH` - This specifies the branch/tag to pull/checkout from the dnsmasq repository, which uses the main branch "master" by default.

As noted above, you can specify a different dnsmasq branch/tag to pull/checkout to build a specific version of dnsmasq in the image.

This may be useful for debugging or if your image requires a specific version of the dnsmasq binary file.

More information on using Docker build-arguments can be found here:  [Docker Docs: docker build -- Set build-time variables (--build-arg)](https://docs.docker.com/engine/reference/commandline/build/#set-build-time-variables---build-arg)

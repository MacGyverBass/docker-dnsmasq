# Use Alpine image to build the static binary
FROM	macgyverbass/base-label:alpine AS compile

# Install all necessary packages for compiling dnsmasq
RUN	apk --no-cache add	\
		git	\
		make	\
		gcc	\
		musl-dev	\
		linux-headers	\
		upx

# Define branch to clone/checkout
ARG	BRANCH="master"

# Clone the dnsmasq repo
RUN	git clone --branch "${BRANCH}" "http://thekelleys.org.uk/git/dnsmasq.git" /dnsmasq.git/

# Compile dnsmasq statically
RUN	make -j$(nproc) -C /dnsmasq.git/ CFLAGS="-Os -nostdlib" LDFLAGS="-Os -static -no-pie"

# Strip binary
RUN	strip -s /dnsmasq.git/src/dnsmasq

# Compress the binary
RUN	upx -9 /dnsmasq.git/src/dnsmasq

# Copy overlay folder.
# This contains pre-made /etc/group and /etc/passwd for user/group "nobody"/"nogroup".
COPY	overlay/ /dnsmasq-root/


# Build from scratch for smallest possible secure build
FROM	macgyverbass/base-label:scratch

# Copy the previously compiled dnsmasq file and previously copied overlay folder
COPY	--from=compile /dnsmasq.git/src/dnsmasq /dnsmasq-root/ /

# The folder "/var/lib/misc/" is needed for the dnsmasq.leases file.  (Note that this isn't required if --leasefile-ro is used.)
VOLUME	["/var/lib/misc/"]

# Define dnsmasq as our entrypoint, with --no-daemon as a default argument
ENTRYPOINT	["/dnsmasq", "--no-daemon"]

# If no arguments are provided, display the dnsmasq version information
CMD	["--version"]


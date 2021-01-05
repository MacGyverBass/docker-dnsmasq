# Compile dnsmasq as a static binary (Tested working on Alpine v3.12)
FROM	alpine:3.12 AS compile

# Install all necessary packages for compiling dnsmasq
RUN	apk --no-cache add	\
		git	\
		build-base	\
		linux-headers	\
		gettext	\
		pkgconf	\
		python3	\
		upx

# Define build argument for dnsmasq branch to clone/checkout
ARG	DNSMASQ_BRANCH="master"

# Clone the dnsmasq repo
RUN	git clone --branch "${DNSMASQ_BRANCH}" --single-branch "http://thekelleys.org.uk/git/dnsmasq.git" /dnsmasq.git/

# Compile dnsmasq statically
RUN	make -C /dnsmasq.git/ CFLAGS="-Os -nostdlib" LDFLAGS="-Os -static -no-pie"

# Strip binary
RUN	strip -s /dnsmasq.git/src/dnsmasq

# Compress the binary
RUN	upx -9 /dnsmasq.git/src/dnsmasq

# Copy overlay folder.
# This contains pre-made /etc/group and /etc/passwd for user/group "nobody"/"nogroup".
COPY	overlay/ /dnsmasq-root/


# Build from scratch for smallest possible secure build
FROM	scratch

# Copy the previously compiled dnsmasq file and previously copied overlay folder
COPY	--from=compile /dnsmasq.git/src/dnsmasq /dnsmasq-root/ /

# The folder "/var/lib/misc/" is needed for the dnsmasq.leases file.  (Note that this isn't required if --leasefile-ro is used.)
# The folder "/var/run/" is needed for the dnsmasq.pid file.  (Note that this isn't require if --no-daemon is used.)
VOLUME	["/var/lib/misc/", "/var/run/"]

# Define dnsmasq as our entrypoint
ENTRYPOINT	["/dnsmasq"]

# If no arguments are provided, display the dnsmasq version information
CMD	["--version"]


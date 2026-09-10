FROM alpine:latest

# These are the same packages that upstream's `build -s` would install on alpine, plus bash for our script
RUN apk --update --no-cache add bash binutils cmake gcc g++ git make musl-dev perl-utils wget file; \
   mkdir /build; \
   mkdir /output

COPY . /build

# This builds the program and copies it to /output
CMD /build/build_static_gitstatus.sh

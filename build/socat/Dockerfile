FROM alpine:latest

RUN apk --update --no-cache add build-base bash automake git curl linux-headers; \
   mkdir /build; \
   mkdir /output

COPY . /build

# This builds the program and copies it to /output
CMD /build/build_static_socat.sh

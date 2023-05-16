#!/bin/bash

project_name="v2ray-custom-geo"
release_version="0.0.1"

release_dir=./release
rm -rf $release_dir/*
mkdir -p $release_dir

go mod tidy

for goos in "linux" "darwin" "freebsd" "windows"; do
    filenameextension=""
    if [ "$goos" == "windows" ]; then
        filenameextension=".exe"
    fi
    for goarch in "amd64" "arm64" "i386" "armhf"; do
        if [ "$goos" == "linux" ] && [ "$goarch" == "arm64" ]; then
            for goarm in "5" "6" "7"; do
                GOOS=$goos GOARCH=$goarch GOARM=$goarm go build -o v2ipdat geoip.go
                GOOS=$goos GOARCH=$goarch GOARM=$goarm go build -o v2sitedat geosite.go
                zip $release_dir/$project_name-$goos-${goarch}v${goarm}.zip v2ipdat v2sitedat
            done
        else
            GOOS=$goos GOARCH=$goarch go build -o v2ipdat${filenameextension} geoip.go
            GOOS=$goos GOARCH=$goarch go build -o v2sitedat${filenameextension} geosite.go
            zip $release_dir/$project_name-$goos-${goarch}.zip v2ipdat${filenameextension} v2sitedat${filenameextension}
        fi
    done
    rm -f v2ipdat${filenameextension} v2sitedat${filenameextension}
done

cd $release_dir
for file in ./*; do
    md5sum $file >>sha1sum.txt
done


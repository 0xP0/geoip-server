FROM ubuntu:latest  as builder

RUN apt-get update
RUN apt-get install cargo -y

# 设置国内镜像源,这部分海外不需要 --------Start-------
RUN mkdir -p ~/.cargo
RUN echo '[source.crates-io]' > ~/.cargo/config \
 && echo 'registry = "https://github.com/rust-lang/crates.io-index"'  >> ~/.cargo/config \
 && echo '# 替换镜像源'  >> ~/.cargo/config \
 && echo "replace-with = 'sjtu'"  >> ~/.cargo/config \
 && echo '# 上海交通大学'   >> ~/.cargo/config \
 && echo '[source.sjtu]'   >> ~/.cargo/config \
 && echo 'registry = "sparse+https://mirrors.sjtug.sjtu.edu.cn/crates.io-index/"'  >> ~/.cargo/config \
 && echo '' >> ~/.cargo/config
# 设置国内镜像源,这部分海外不需要 --------END-------

WORKDIR /build
COPY . /build
RUN cargo build --bins --release

FROM ubuntu:latest

WORKDIR /app
COPY --from=builder /build/target/release/geoip-server /app
COPY --from=builder /build/*.mmdb /app
CMD ["./geoip-server","0.0.0.0:3000","/app/GeoLite2-City.mmdb"]


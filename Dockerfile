FROM tarantool/tarantool:2.2

RUN set -x \
    && apk add --no-cache --virtual .build-deps \
    cmake \
    make \
    coreutils \
    gcc \
    g++ \
    lua-dev \
    curl \
    git
RUN tarantoolctl rocks install document
RUN apk del .build-deps

COPY src/*.lua /opt/tarantool/
EXPOSE 3301 8080 443
WORKDIR /opt/tarantool

CMD ["tarantool", "dict.lua"]
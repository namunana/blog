#!/bin/bash
set -e
function pull() {
    if [ ! -d "/opt/blog" ]; then
      echo "pull: 初始化blog"
      cd /opt
      git clone https://github.com/namunana/blog.git
    fi
    cd /opt/blog
    echo "pull: 切换到source分支"
    git checkout source
    git pull
}
function build() {
  echo "build: 删除blog镜像"
  docker rmi blog
  echo "build: 重建blog镜像"
  docker build -t blog .
}
function run() {
  echo "build: 删除blog镜像"
  docker run -p 80:4000 -d blog
}
case "$1" in
   pull) pull "$2";;
   build) build;;
   run) run;;
   *) echo "Error: unexpected option $1...";;
esac
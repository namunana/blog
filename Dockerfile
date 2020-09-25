FROM node:10

WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install

EXPOSE 4000
RUN apt-get update && apt-get install -y git && \
    npm install -g hexo-cli && \
    npm install hexo-renderer-kramed && \
    npm install hexo-asset-image && \
    npm install hexo-generator-searchdb && \
    npm install hexo-generator-feed && \
#    npm install hexo-related-popular-posts && \
    npm install hexo-symbols-count-time && \
    npm install hexo-generator-sitemap && \
    npm install hexo-generator-baidu-sitemap && \
    npm install hexo-deployer-git && \
#    npm install hexo-leancloud-counter-security && \
    npm install hexo-helper-live2d && \
    npm install theme-next/next-util && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/theme-next/hexo-theme-next themes/next && \
    cd themes/next && git checkout v7.8.0 && cd - && \
    # next主题依赖下载
    git clone https://github.com/theme-next/theme-next-pdf themes/next/source/lib/pdf && \
    git clone https://github.com/theme-next/theme-next-pace themes/next/source/lib/pace

RUN hexo clean --config source/_data/next.yml && \
    hexo g --config source/_data/next.yml

COPY . .
ENTRYPOINT hexo s
CMD ["-p", "80", "--config", "source/_data/next.yml"]
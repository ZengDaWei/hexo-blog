---
title: Install chrome&chrome driver on ubuntu
date: 2021-5-31 11:48:26
categories: ubuntu
top_img: https://image.zdw1.cn/img20210602175152.png
cover: https://image.zdw1.cn/img20210602175152.png
tags:
  - ubuntu
---

# Install chrome&chrome driver on ubuntu

## Install dependencies

```bash
sudo apt-get install libxss1 libappindicator1 libindicator7
```

## Download chrome installat package

```bash
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome*.deb
sudo apt-get install -f
google-chrome --version
```

## Install chrome driver

open https://chromedriver.chromium.org/downloads

choose your chrome version driver and download it

next

```bash
unzip chromedriver_linux64.zip
sudo mv chromedriver /usr/local/chromedriver
sudo ln -s /usr/local/chromedriver /usr/bin/chromedriver
```

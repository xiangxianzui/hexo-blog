---
title: Build blogs with Hexo!
date: 2017-01-05 10:29:32
tags: [Hexo]
categories: [Guides]
---
Welcome to my blog! In this my very first post, I will record my experience of building this blog with the help of [Github Pages](https://pages.github.com/) and the amazing [Hexo](https://hexo.io/)! This not only keeps a record of what I did, but also may help those who want to build a personal blog site. Ok, let's get down to the business. 


## Prerequisite

 - Node.js
 - Git

Node.js and Git should be installed properly on your machine.
If not, download [Node.js](https://nodejs.org/en/download/) and [Git](https://git-scm.com/downloads), then choose the version you want.

## Install Hexo

``` bash
$ npm install -g hexo-cli
```

## Set up Hexo

``` bash
$ hexo init [your-site-directory]
$ cd [your-site-directory]
$ npm install
```
If [your-site-directory] is not specified, hexo will create the project in the current working directory.


## Create a post

``` bash
$ hexo new post [your-post-title]
```

Will find a new post is created in /source/_posts

All posts created by hexo is written in Markdown. You can edit in favorite editor or I recommend to use this online editor -- [StackEdit](https://stackedit.io/).


## Generate static files

``` bash
$ hexo generate
```

This will create a /public folder in the root of your project, and it contains all static html, css, js, fonts, images, etc. 

## Run hexo server locally

``` bash
$ hexo server
```

The server will be running in http://localhost:4000/ And this offers a convenient way for you to view what you have changed with the look of your website.

## From offline to online

Hexo provides many ways to deploy the website to your real server. I choose to deploy to Github Pages.

#### Create a github repository

Go to github and create a repository named: `[your-github-username]-github.io`, mine is `xiangxianzui.github.io`.

Go to *settings* of created repository, pull down the page and you find:

![GitHub Page Setting](hexo-1.png) 

Next, deploy a SSH key to this repository. This [article](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/) is helpful.

#### Git deploy strategy for Hexo

Install the official git deploy strategy for hexo.

``` bash
$ npm install hexo-deployer-git --save
```

After that, edit deploy config in your *_config.yml* (located in project root).

``` bash
deploy:
  type: git
  repo: [your-ssh-repo]
  branch: master
  message: "Site updated: {{ now('YYYY-MM-DD HH:mm:ss') }}"
```

Then, deploy website to git repository

``` bash
$ hexo deploy
```

**Note**: If you are using Windows, it is recommended to run deploy command in Git Bash.

#### Take off!

Browse https://[your-github-username].github.io/ and enjoy your flight with Hexo!

----------

> Written with [StackEdit](https://stackedit.io/).
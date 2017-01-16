---
title: Upload image to a Node.JS server
date: 2017-01-16 19:10:26
tags: [Node.JS]
categories: [Guides]
---

Recently, I came up with a problem that I need to upload images to a Node server and display the image instantly. 

Generally, firstly I wrap the uploading image as a [FormData](https://developer.mozilla.org/en-US/docs/Web/API/FormData). Then I use jquery `.ajax()` method to send `POST` request to the server. At server, [formidable](https://github.com/felixge/node-formidable) middleware is used to handle the uploading file. 

I write this post to keep a record of what I have done.

**Note: A working demo is available in [github](https://github.com/xiangxianzui/node-image-previewer-uploader).**

The demo could be used like this:

``` bash
# clone the repo to local machine
$ git clone https://github.com/xiangxianzui/node-image-previewer-uploader
# open code directory
$ cd node-image-previewer-uploader
# install node dependencies
$ npm install
# run the server
$ node server.js
```

#### File Structure

 - **server.js** is Node server, which contains routes and main logic of back end
 - **.env** stores environmenal variable while developing. A node module called `dotenv` can be used to load variables in `.env` file to global variable `process`
 - **package.json** contains information of this project and dependencies
 - **/public** contains javascript, css, fonts and images, which will be used in front end
 - **/views** contains HTML templates
 - **/uploads** stores uploaded images



> Written with [StackEdit](https://stackedit.io/).
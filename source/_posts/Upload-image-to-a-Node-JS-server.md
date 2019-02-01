---
title: Upload image to a Node.JS server
date: 2017-01-16 19:10:26
tags: [Node.JS]
categories: [Learning]
---

Recently, I came up with a problem that I need to upload images to a Node server and display the image instantly. I write this post to keep a record of what I have done.

Generally, firstly I wrap the uploading image as a [FormData](https://developer.mozilla.org/en-US/docs/Web/API/FormData). 

``` bash
#'upload[]' is the name attr of #upload-input
#append the selected file to formData obj
formData.append('upload[]', file, file.name);
```

Then I use jquery `.ajax()` method to send `POST` request to the server. 

``` bash
#processData:false means to stop jquery from converting the formData object to string
#contentType:false means to tell jquery not to add a Content-Type header
$.ajax({
	url: '/upload',
	type: 'POST',
	data: formData,
	processData: false,
    contentType: false,
	success: function(data){
		#do something when success
		}
	}
});
```

At server, [formidable](https://github.com/felixge/node-formidable) middleware is used to handle the uploading file. 

``` bash
app.post('/upload', function(req, res){
  #create an incoming form object
  var form = new formidable.IncomingForm();
  #specify that we don't want user to upload multiple files at the same time; set true to allow.
  form.multiples = false;
  #store uploads in /uploads directory
  form.uploadDir = path.join(process.cwd(), '/uploads');
  #log any occured error
  form.on('error', function(err){
     console.log('File Uploading Error: '+err);
  });
  #parse the incoming request containing form data
  form.parse(req, function(err, fields, files){
	  var file = files['upload[]'];
      #rename the uploaded file as its origin name
      fs.rename(file.path, path.join(form.uploadDir, file.name));
      res.send('success');
  });
});
```

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
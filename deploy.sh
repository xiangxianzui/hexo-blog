#!/bin/sh
echo "What do you want?"
echo "a:update algolia index  d:deploy the blog"
read v
if [ $v = "a" ]
then
    export HEXO_ALGOLIA_INDEXING_KEY=304502cbd81590137ae69166c42f1ffd
    hexo algolia
elif [ $v = "d" ]
then
    hexo clean
    hexo g
    sudo hexo deploy
else
    echo "exit, bye"
fi

Objective-C And Swift Dependencies Visualizer
==========================  
[![Build Status](https://travis-ci.org/PaulTaykalo/objc-dependency-visualizer.svg)](https://travis-ci.org/PaulTaykalo/objc-dependency-visualizer)  

This is the tool, that can use .o(object) files to generate dependency graph.  
All visualisations was done by [d3js](http://d3js.org/) library, which is just awesome!  
This tool was made just for fun, but images can show how big your project is, how many classes it have, and how they linked to each other    

![Image example](https://pbs.twimg.com/media/CFDYofdUsAAzjSK.png:large)  

### Easiest way - For those who don't like to read docs
This will clone project, and run it on the latest modified project
```
git clone https://github.com/PaulTaykalo/objc-dependency-visualizer.git ;
cd objc-dependency-visualizer ;
./generate-objc-dependencies-to-json.rb -d -s "" > origin.js ;
open index.html
```

### Easiest way for Swift projects
```
git clone https://github.com/PaulTaykalo/objc-dependency-visualizer.git ;
cd objc-dependency-visualizer ;
./generate-objc-dependencies-to-json.rb -w -s "" > origin.js ;
open index.html
```

### More specific examples
Examples are [here](https://github.com/PaulTaykalo/objc-dependency-visualizer/wiki/Usage-examples)

### Tell the world about the awesomeness of your project structure
Share image to the Twitter with [#objcdependencyvisualizer](https://twitter.com/search?q=%23objcdependencyvisualizer) hashtag


### Hard way - or "I want to read what I'm doing!"

Here's [detailed description](https://github.com/PaulTaykalo/objc-dependency-visualizer/wiki) of what's going on under the hood

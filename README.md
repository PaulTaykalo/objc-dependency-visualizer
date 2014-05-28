Objective-C Class Dependencies Visualizer
==========================  

This is the tool, that can use .o(object) files to generate dependency graph.  
All visualisations was done by [d3js](http://d3js.org/) library, which is just awesome!  
This tool was made just for fun, but images can show how big your project is, how many classes it have, and how they linked to each other    

![Image example](https://pbs.twimg.com/media/BecW8fRCcAAPdP4.png:large)  

### Easiest way - For those who don't like to read docs
This will clone project, and run it on the latest modified project
```
git clone https://github.com/PaulTaykalo/objc-dependency-visualizer.git ;
cd objc-dependency-visualizer ;
./generate-objc-dependencies-to-json.rb -s "" > origin.js ;
open index.html
```

### Tell the world about the awesomeness of your project structure
Share image to the Twitter with [#objc-dv](https://twitter.com/search/realtime?q=%23objc-dv) hashtag


### Hard way - or "I want to read what I'm doing!"

Here's [detailed description](https://github.com/PaulTaykalo/objc-dependency-visualizer/wiki) of what's going on under the hood

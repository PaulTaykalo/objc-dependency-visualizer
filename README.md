Objective-C Dependency Visualizer
==========================  

This is the tool, that is used generated .obj (.o) files from your Objective-C files, to generate dependency graph.  
All visualisations was done by [d3js](http://d3js.org/) library, which is just awesome!  

## Requirements
Any Xcode project will be enough 

## Results
Something like this (http://image) or this (http://image) or, may be this

## What should I do?  

### Step 1 - Open index.html  
You should see cute dependency graph of some Pod target of my project  
If you want to have it for your project, proceed to next Step

### Step 2 - Build your Xcode project  
### Step 3 - Run ./generate-objc-dependencies-to-json.rb script  
`./generate-objc-dependencies-to-json.rb <path_to_folder_with_object_files>`  
`./generate-objc-dependencies-to-json.rb ~/Library/Developer/Xcode/DerivedData/YOURPROJECTNAME-efsbjtrozyranpekmckkebzycitp/Build/Intermediates/YOURPROJECTNAME.build/Debug-iphonesimulator/YOURPROJECTNAME.build/Objects-normal/i386`  

~/Library/Developer/Xcode/ _DerivedData_ /  
 YOURPROJECTNAME-efsbjtrozyranpekmckkebzycitp/Build/ _Intermediates_ /   
   YOURPROJECTNAME.build/Debug-iphonesimulator/YOURPROJECTNAME.build/ _Objects-normal_ /i386  

If you make it right, you'll see something like that  
```
var dependencies = {
     links:
   	  [
            { "source" : "main", "dest" : "UTAppDelegate" },
            { "source" : "UTAppDelegate", "dest" : "UIResponder" },
            { "source" : "UTViewController", "dest" : "UIColor" },
            { "source" : "UTViewController", "dest" : "UIView" },
            { "source" : "UTViewController", "dest" : "UIViewController" },
         ]
    }
  ;  
```

### Step 4 - Grab output from Step #3 and save it to origin.js  
`./generate-objc-dependencies-to-json.rb <path_to_folder_with_object_files>  > origin.js`  

### Step 5 - Open/Refresh index.html
Now you should see dependency graph of your project  

### Step 6 - Tuning  
You can play with some parameters in index.html  
You can change graph generation in ruby script  
You can go to [d3js site](http://d3js.org/) and see what else you can do with this library  
You can share your images to twitter with #objc-dv hashtag

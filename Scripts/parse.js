//  ===================================================
//  =============== PARSING ===========================
//  ===================================================
var correctGraph = {};
var correctNodes = [];
var correctLinks = [];
var nodesSet = {};
var prefixes = {};

for (var i = 0; i < dependencies.links.length; i++) {
  var object = dependencies.links[i];

  var source = nodesSet[object.source];
  if (source == null) {
     source = {
        name : object.source, 
        source : 1,
        dest   : 0
     }
     nodesSet[object.source] = source;
  }
  source.source++;

  var dest = nodesSet[object.dest];
  if (dest == null) {
     dest = {
        name : object.dest, 
        source : 0,
        dest   : 1
     }
     nodesSet[object.dest] = dest;
  }
  dest.dest++;

  // Grouping by prefixes
  var sourcePrefix = object.source.substring(0,2);
  var destPrefix = object.dest.substring(0,2);


  if (!(sourcePrefix in prefixes)) {
    prefixes[sourcePrefix] = 1
  } else {
    prefixes[sourcePrefix]++;
  }

  if (!(destPrefix in prefixes)) {
    prefixes[destPrefix] = 1
  } else {
    prefixes[destPrefix]++;
  }

};

// Sort prefixes
var prefixes_groups = {};
var prefixes_arr = [];
for (var key in prefixes) {
    prefixes_arr.push( {key : key, value:prefixes[key] });
}

var sorted_prefixes = prefixes_arr.slice(0).sort(function(a, b) {
   return b.value - a.value;
});


var idx = 0;
for (var p in nodesSet) {
  var groupId = 0;


  if (use_regexp_color_grouping_matchers)  {
    for (var i = 0; i < regexp_color_matchers.length; i++) {
      var re = new RegExp(regexp_color_matchers[i],"");
      if (p.match(re)) {
        groupId = i + 1;
      }
    };
  } else {
     for (var i in sorted_prefixes) {
     var str = sorted_prefixes[i].key;
     // console.log("Checking " + p + " for " + str)
       if (p.slice(0, str.length) == str) {
         groupId = i;
         break;
       }
     }
  }


  // It's time to create node :)
  correctNodes.push({
    idx : idx,
    name : p,
    group : groupId,
    source : nodesSet[p].source,
    dest : nodesSet[p].dest,
    weight : nodesSet[p].source
  });
  console.log( " Pushing node : IDX="+idx+", name="+p+", groupId="+groupId+", source="+nodesSet[p].source+", dest="+nodesSet[p].dest+", weight="+nodesSet[p].source );
  nodesSet[p].idx = idx;
  idx++;
}

for (var i = 0; i < dependencies.links.length; i++) {
  var link = dependencies.links[i];
  var sourceIdx = nodesSet[link.source].idx;
  var destIdx = nodesSet[link.dest].idx;
  correctLinks.push({
    source : sourceIdx,
    target : destIdx,
    value : nodesSet[link.source].source,
    sourceNode : nodesSet[link.source],
    targetNode : nodesSet[link.dest]
  });
    console.log( "Pushing link : source="+sourceIdx+", target="+destIdx);

}


correctGraph["nodes"] = correctNodes;
correctGraph["links"] = correctLinks;


//  ===================================================
//  =============== PARSING ENDS  =====================
//  ===================================================

//  ===================================================
//  =============== CONFIGURABLE PARAMS ENDS ==========
//  ===================================================

var dependecy_graph = correctGraph;

//  ===================================================
//  =============== PARSING ===========================
//  ===================================================
// Input 
// { links : [ {source: sourceName, dest : destName} * ] }
// Output:
!function () {
  var objcdv = {
    version: "0.0.1"
  };
  objcdv.parse_dependencies_graph = function (dependencies, regexp_color_matchers) {

    var nodes = [];
    var links = [];

    var nodesSet = {};
    var prefixes = {};

    var node_index = 0;

    // Parse all dependencies
    // In format 

    var input_links = dependencies.links;

    var updatePrefixesDistribution = function(name) {
      var prefix = name.substring(0, 2);
      if (!(prefix in prefixes)) {
        prefixes[prefix] = 1;
      } else {
        prefixes[prefix]++;
      }
    }

    for (var i = 0; i < input_links.length; i++) {
      var link = input_links[i];

      var source_node = nodesSet[link.source];
      if (source_node == null) {
        nodesSet[link.source] = source_node = { idx :node_index++, name: link.source, source: 1, dest: 0  }
      }
      source_node.source++;

      var dest_node = nodesSet[link.dest];
      if (dest_node == null) {
        nodesSet[link.dest] = dest_node = { idx :node_index++, name: link.dest, source: 0, dest: 1 }
      }
      dest_node.dest++;


      // Grouping by prefixes
      updatePrefixesDistribution(link.source);
      updatePrefixesDistribution(link.dest);

      // Remapping links objects
      links.push({
       
        // d3 js properties
        source: source_node.idx,
        target: dest_node.idx,

        // Additional link information
        sourceNode: source_node,
        targetNode: dest_node
      });

      console.log("Pushing link : source=" + source_node.idx + ", target=" + dest_node.idx);
    }

   
    // Sorting prefixes, based on theirs frequency
    var prefixes_arr = [];
    for (var key in prefixes) {
      prefixes_arr.push({key: key, value: prefixes[key] });
    }
    var sorted_prefixes = prefixes_arr.slice(0).sort(function (a, b) {
      return b.value - a.value;
    });

    // If we dont' have regexp_color_matchers, we'll set them up, based on prefixes
    var group_regexp_identifiers = regexp_color_matchers;
    if (group_regexp_identifiers == null) {
       group_regexp_identifiers = [];
       for (var i = 0; i < sorted_prefixes.length; i++) {
           group_regexp_identifiers.push("^" + sorted_prefixes[i].key+".*");
       }
    }

    // Setting up nodes groups, based on the group_regexp_identifiers
    var idx = 0;
    for (var p in nodesSet) {

      node = nodesSet[p];
      node.group = 0;
      node.weight = node.source;  // Calculating node weignt, based on the amount of item it depends on

      for (var regexp_index = 0; regexp_index < group_regexp_identifiers.length; regexp_index++) {
        var re = new RegExp(group_regexp_identifiers[regexp_index], "");
        if (p.match(re)) {
          node.group = regexp_index + 1;
          break;
        }
      }

      nodes.push(node);
       console.log(" Pushing node : IDX=" + idx + ", name=" + p + ", groupId=" + node.group + ", source=" + node.source + ", dest=" + node.dest + ", weight=" + node.weight);
      idx++;
    }

    return { nodes : nodes, links: links };
  }

  if (typeof define === "function" && define.amd) {
    define(objcdv);
  } else if (typeof module === "object" && module.exports) {
    module.exports = objcdv;
  } else {
    this.objcdv = objcdv;
  }
}();


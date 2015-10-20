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

  objcdv._createGraph = function() {
    return {
      nodes:[],
      links:[],
      nodesSet:{},
      node_index:0,

      addLink:function(link) {

        var source_node = this.getNode(link.source);
        source_node.source++;

        var dest_node = this.getNode(link.dest);
        dest_node.dest++;

        this.links.push({
          // d3 js properties
          source: source_node.idx,
          target: dest_node.idx,

          // Additional link information
          sourceNode: source_node,
          targetNode: dest_node
        })
      },

      getNode:function(nodeName) {
        var node = this.nodesSet[nodeName];
        if (node == null) {
          var idx = this.node_index;
          this.nodesSet[nodeName] = node = { idx :idx, name: nodeName, source: 1, dest: 0  };
          this.node_index++;
        }
        return node
      },

      updateNodes:function(f) {
        _.values(this.nodesSet).forEach(f)
      },

      d3jsGraph:function() {
        // Sorting up nodes, since, in some cases they aren't returned in correct number
        var nodes = _.values(this.nodesSet).slice(0).sort((a,b) => a.idx - b.idx);
        return { nodes : nodes, links: this.links };
      }
    };

  };

  objcdv._createPrefixes = function() {
    return {
      _prefixesDistr:{},

      _sortedPrefixes:null,

      addName:function(name) {
        this._sortedPrefixes = null;

        var prefix = name.substring(0, 2);
        if (!(prefix in this._prefixesDistr)) {
          this._prefixesDistr[prefix] = 1;
        } else {
          this._prefixesDistr[prefix]++;
        }
      },

      prefixIndexForName:function(name) {
        var sortedPrefixes = this._getSortedPrefixes();
        var prefix = name.substring(0, 2);
        return _.indexOf(sortedPrefixes, prefix)
      },

      _getSortedPrefixes:function() {
        if (this._sortedPrefixes == null) {
          this._sortedPrefixes = _.map(this._prefixesDistr, (v,k) => ({"key":k, "value":v}))
                                  .sort((a,b) => b.value - a.value)
                                  .map(o => o.key)
        }
        return this._sortedPrefixes
      }
    };
  };

  objcdv.parse_dependencies_graph = function (dependencies) {

    var graph = this._createGraph();
    var prefixes = this._createPrefixes();

    dependencies.links.forEach((link) => {
      graph.addLink(link);

      prefixes.addName(link.source);
      prefixes.addName(link.dest);

    });

    graph.updateNodes((node) => {
      node.weight = node.source;
      node.group = prefixes.prefixIndexForName(node.name) + 1
    });

    return graph.d3jsGraph()

  };

  if (typeof define === "function" && define.amd) {
    define(objcdv);
  } else if (typeof module === "object" && module.exports) {
    module.exports = objcdv;
  } else {
    this.objcdv = objcdv;
  }
}();


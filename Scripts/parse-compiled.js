//  ===================================================
//  =============== PARSING ===========================
//  ===================================================
// Input
// { links : [ {source: sourceName, dest : destName} * ] }
// Output:
"use strict";

var objcdv = {
    version: "0.0.1",
    _createGraph: function _createGraph() {
        return {
            nodes: [],
            links: [],
            nodesSet: {},
            node_index: 0,

            addLink: function addLink(link) {

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
                });
            },

            getNode: function getNode(nodeName) {
                var node = this.nodesSet[nodeName];
                if (node == null) {
                    var idx = this.node_index;
                    this.nodesSet[nodeName] = node = { idx: idx, name: nodeName, source: 1, dest: 0 };
                    this.node_index++;
                }
                return node;
            },

            updateNodes: function updateNodes(f) {
                _.values(this.nodesSet).forEach(f);
            },

            d3jsGraph: function d3jsGraph() {
                // Sorting up nodes, since, in some cases they aren't returned in correct number
                var nodes = _.values(this.nodesSet).slice(0).sort(function (a, b) {
                    return a.idx - b.idx;
                });
                return { nodes: nodes, links: this.links };
            }
        };
    },
    _createPrefixes: function _createPrefixes() {
        return {
            _prefixesDistr: {},

            _sortedPrefixes: null,

            addName: function addName(name) {
                this._sortedPrefixes = null;

                var prefix = name.substring(0, 2);
                if (!(prefix in this._prefixesDistr)) {
                    this._prefixesDistr[prefix] = 1;
                } else {
                    this._prefixesDistr[prefix]++;
                }
            },

            prefixIndexForName: function prefixIndexForName(name) {
                var sortedPrefixes = this._getSortedPrefixes();
                var prefix = name.substring(0, 2);
                return _.indexOf(sortedPrefixes, prefix);
            },

            _getSortedPrefixes: function _getSortedPrefixes() {
                if (this._sortedPrefixes == null) {
                    this._sortedPrefixes = _.map(this._prefixesDistr, function (v, k) {
                        return { "key": k, "value": v };
                    }).sort(function (a, b) {
                        return b.value - a.value;
                    }).map(function (o) {
                        return o.key;
                    });
                }
                return this._sortedPrefixes;
            }
        };
    },

    parse_dependencies_graph: function parse_dependencies_graph(dependencies) {

        var graph = this._createGraph();
        var prefixes = this._createPrefixes();

        dependencies.links.forEach(function (link) {
            graph.addLink(link);

            prefixes.addName(link.source);
            prefixes.addName(link.dest);
        });

        graph.updateNodes(function (node) {
            node.weight = node.source;
            node.group = prefixes.prefixIndexForName(node.name) + 1;
        });

        return graph.d3jsGraph();
    }

};

//# sourceMappingURL=parse-compiled.js.map
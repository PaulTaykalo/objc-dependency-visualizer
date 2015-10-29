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
            linksSet: {},
            node_index: 0,

            _linkHashKey: function _linkHashKey(sourceNodeName, destNodeName) {
                return sourceNodeName + "->" + destNodeName;
            },

            addLink: function addLink(link) {

                var source_node = this.getNode(link.source);
                source_node.source++;

                var dest_node = this.getNode(link.dest);
                dest_node.dest++;

                var dvlink = {
                    // d3 js properties
                    source: source_node.idx,
                    target: dest_node.idx,

                    // Additional link information
                    sourceNode: source_node,
                    targetNode: dest_node
                };
                this.links.push(dvlink);

                this.linksSet[this._linkHashKey(source_node.name, dest_node.name)] = dvlink;

                return dvlink;
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

            hasNodeWithName: function hasNodeWithName(nodeName) {
                var node = this.nodesSet[nodeName];
                return node != null;
            },

            hasLinkWithNodesNames: function hasLinkWithNodesNames(sourceName, destName) {
                return this.linksSet[this._linkHashKey(sourceName, destName)] != null;
            },

            hasLink: function hasLink(link) {
                return this.hasLinkWithNodesNames(link.sourceNode.name, link.targetNode.name);
            },

            updateNodes: function updateNodes(f) {
                _.values(this.nodesSet).forEach(f);
            },

            updateLinks: function updateLinks(f) {
                _.values(this.linksSet).forEach(f);
            },

            d3jsGraph: function d3jsGraph() {
                // Sorting up nodes, since, in some cases they aren't returned in correct number
                var nodes = _.values(this.nodesSet).slice(0).sort(function (a, b) {
                    return a.idx - b.idx;
                });
                return { nodes: nodes, links: this.links };
            },

            nodesStartingFromNode: function nodesStartingFromNode(node) {
                var _this = this;

                var _ref = arguments.length <= 1 || arguments[1] === undefined ? {} : arguments[1];

                var _ref$max_level = _ref.max_level;
                var max_level = _ref$max_level === undefined ? 100 : _ref$max_level;
                var _ref$use_backward_search = _ref.use_backward_search;
                var use_backward_search = _ref$use_backward_search === undefined ? false : _ref$use_backward_search;
                var _ref$use_forward_search = _ref.use_forward_search;
                var use_forward_search = _ref$use_forward_search === undefined ? true : _ref$use_forward_search;

                // Figure out the neighboring node id's with brute strength because the graph is small
                var neighbours = {};
                neighbours[node.index] = node;

                var nodesToCheck = [node.index];
                var current_level = 0;

                var _loop = function () {
                    forwardNeighbours = [];
                    backwardNeighbours = [];

                    var tmpNeighbours = {};
                    if (use_forward_search) {
                        forwardNeighbours = _this.links.filter(function (link) {
                            return link.source.index in neighbours;
                        }).filter(function (link) {
                            return !(link.target.index in neighbours);
                        }).map(function (link) {
                            tmpNeighbours[link.target.index] = link.target;
                            return link.target.index;
                        });
                    }
                    if (use_backward_search) {
                        backwardNeighbours = _this.links.filter(function (link) {
                            return link.target.index in neighbours;
                        }).filter(function (link) {
                            return !(link.source.index in neighbours);
                        }).map(function (link) {
                            tmpNeighbours[link.source.index] = link.source;
                            return link.source.index;
                        });
                    }

                    _.extend(neighbours, tmpNeighbours);

                    nodesToCheck = forwardNeighbours.concat(backwardNeighbours);
                    console.log("Nodes to check" + nodesToCheck);

                    // Skip if we reached max level
                    current_level++;
                    if (current_level == max_level) {
                        console.log("Reached max at level" + current_level);
                        return "break";
                    }
                };

                while (Object.keys(nodesToCheck).length != 0) {
                    var forwardNeighbours;
                    var backwardNeighbours;

                    var _ret = _loop();

                    if (_ret === "break") break;
                }
                return _.values(neighbours);
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

        return graph;
    },

    parse_difference_graph: function parse_difference_graph(dependencies_before, dependencies_after) {

        var graphBefore = this.parse_dependencies_graph(dependencies_before);
        var graphAfter = this.parse_dependencies_graph(dependencies_after);

        // Nodes and links those were in before, but removed in after
        // Nodes those were in both
        // Nodes and links those weren't in before, but added in after

        // Mark items

        var graph = this._createGraph();
        var prefixes = this._createPrefixes();

        // Parsing yet again
        dependencies_before.links.forEach(function (link) {
            var linkSource = link.source;
            var linkDest = link.dest;

            var addedLink = graph.addLink(link);

            if (!graphAfter.hasNodeWithName(linkSource)) {
                graph.getNode(linkSource).diff_removed = true;
            }

            if (!graphAfter.hasNodeWithName(linkDest)) {
                graph.getNode(linkDest).diff_removed = true;
            }

            // Mark link as that one was removed in afer
            if (!graphAfter.hasLink(addedLink)) {
                addedLink.diff_removed = true;
                graph.getNode(linkSource).diff_related = true;
                graph.getNode(linkDest).diff_related = true;
            }

            prefixes.addName(linkSource);
            prefixes.addName(linkDest);
        });

        dependencies_after.links.forEach(function (link) {
            var linkSource = link.source;
            var linkDest = link.dest;

            if (!graphBefore.hasLinkWithNodesNames(linkSource, linkDest)) {
                var addedLink = graph.addLink(link);
                addedLink.diff_added = true;
                graph.getNode(linkSource).diff_related = true;
                graph.getNode(linkDest).diff_related = true;
            }

            if (!graphBefore.hasNodeWithName(linkSource)) {
                graph.getNode(linkSource).diff_added = true;
                prefixes.addName(linkSource);
            }

            if (!graphBefore.hasNodeWithName(linkDest)) {
                graph.getNode(linkDest).diff_added = true;
                prefixes.addName(linkDest);
            }
        });

        graph.updateNodes(function (node) {
            node.weight = node.source;
            node.group = prefixes.prefixIndexForName(node.name) + 1;
        });

        return graph;
    }

};

//# sourceMappingURL=parse-compiled.js.map
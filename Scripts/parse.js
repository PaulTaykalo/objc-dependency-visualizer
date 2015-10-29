//  ===================================================
//  =============== PARSING ===========================
//  ===================================================
// Input 
// { links : [ {source: sourceName, dest : destName} * ] }
// Output:
let objcdv = {
    version: "0.0.1",
    _createGraph: function () {
        return {
            nodes: [],
            links: [],
            nodesSet: {},
            linksSet: {},
            node_index: 0,

            _linkHashKey:function(sourceNodeName, destNodeName) {
                return sourceNodeName + "->" + destNodeName;
            },

            addLink: function (link) {

                var source_node = this.getNode(link.source);
                source_node.source++;

                var dest_node = this.getNode(link.dest);
                dest_node.dest++;

                const dvlink = {
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

            getNode: function (nodeName) {
                var node = this.nodesSet[nodeName];
                if (node == null) {
                    var idx = this.node_index;
                    this.nodesSet[nodeName] = node = {idx: idx, name: nodeName, source: 1, dest: 0};
                    this.node_index++;
                }
                return node
            },

            hasNodeWithName:function(nodeName) {
                var node = this.nodesSet[nodeName];
                return node != null;
            },

            hasLinkWithNodesNames:function(sourceName, destName) {
                return this.linksSet[this._linkHashKey(sourceName, destName)] != null;
            },

            hasLink:function(link) {
                return this.hasLinkWithNodesNames(link.sourceNode.name, link.targetNode.name);
            },

            updateNodes: function (f) {
                _.values(this.nodesSet).forEach(f)
            },

            updateLinks: function (f) {
                _.values(this.linksSet).forEach(f)
            },

            d3jsGraph: function () {
                // Sorting up nodes, since, in some cases they aren't returned in correct number
                var nodes = _.values(this.nodesSet).slice(0).sort((a, b) => a.idx - b.idx);
                return {nodes: nodes, links: this.links};
            },

            nodesStartingFromNode: function (node, {max_level = 100, use_backward_search = false, use_forward_search = true } = {} ) {
                // Figure out the neighboring node id's with brute strength because the graph is small
                var neighbours = {};
                neighbours[node.index] = node;

                var nodesToCheck = [node.index];
                let current_level = 0;
                while (Object.keys(nodesToCheck).length != 0) {
                    var forwardNeighbours = [];
                    var backwardNeighbours = [];

                    let tmpNeighbours = {};
                    if (use_forward_search) {
                        forwardNeighbours = this.links
                            .filter((link) => link.source.index in neighbours)
                            .filter((link) => !(link.target.index in neighbours))
                            .map((link) => {
                                tmpNeighbours[link.target.index] = link.target;
                                return link.target.index;
                            });
                    }
                    if (use_backward_search) {
                        backwardNeighbours = this.links
                            .filter((link) => link.target.index in neighbours)
                            .filter((link) => !(link.source.index in neighbours))
                            .map((link) => {
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
                        break;
                    }
                }
                return _.values(neighbours);

            }

        };

    },


    _createPrefixes: function () {
        return {
            _prefixesDistr: {},

            _sortedPrefixes: null,

            addName: function (name) {
                this._sortedPrefixes = null;

                var prefix = name.substring(0, 2);
                if (!(prefix in this._prefixesDistr)) {
                    this._prefixesDistr[prefix] = 1;
                } else {
                    this._prefixesDistr[prefix]++;
                }
            },

            prefixIndexForName: function (name) {
                var sortedPrefixes = this._getSortedPrefixes();
                var prefix = name.substring(0, 2);
                return _.indexOf(sortedPrefixes, prefix)
            },

            _getSortedPrefixes: function () {
                if (this._sortedPrefixes == null) {
                    this._sortedPrefixes = _.map(this._prefixesDistr, (v, k) => ({"key": k, "value": v}))
                        .sort((a, b) => b.value - a.value)
                        .map(o => o.key)
                }
                return this._sortedPrefixes
            }
        };
    },


    parse_dependencies_graph: function (dependencies) {

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

        return graph
    },

    parse_difference_graph: function (dependencies_before, dependencies_after) {

        var graphBefore = this.parse_dependencies_graph(dependencies_before);
        var graphAfter = this.parse_dependencies_graph(dependencies_after);

        // Nodes and links those were in before, but removed in after
        // Nodes those were in both
        // Nodes and links those weren't in before, but added in after

        // Mark items

        var graph = this._createGraph();
        var prefixes = this._createPrefixes();

        // Parsing yet again
        dependencies_before.links.forEach((link) => {
            let linkSource = link.source;
            let linkDest = link.dest;

            const addedLink = graph.addLink(link);

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

        dependencies_after.links.forEach((link) => {
            let linkSource = link.source;
            let linkDest = link.dest;

            if (!graphBefore.hasLinkWithNodesNames(linkSource, linkDest)) {
                const addedLink = graph.addLink(link);
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

        graph.updateNodes((node) => {
            node.weight = node.source;
            node.group = prefixes.prefixIndexForName(node.name) + 1
        });

        return graph
    }

};






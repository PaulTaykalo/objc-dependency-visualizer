//  ===================================================
//  ===============  SELECTING_NODE       =============
//  ===================================================

!function () {
    var graph_actions = {

        create: function (svg, dependecy_graph) {

            return {
                selectedIdx: -1,
                selectedType: "normal",
                svg: svg,
                selectedObject: {},
                dependency_graph: dependecy_graph,

                deselect_node: function (d) {
                    delete d.fixed;
                    this.selectedIdx = -1;
                    this.selectedObject = {};
                    this.svg.selectAll('circle, path, text')
                        .classed('filtered', false)
                        .each(function (node) {
                            node.filtered = false
                        })
                        .transition();

                    this.svg.selectAll('.link')
                        .attr("marker-end", "url(#default)")
                        .classed('filtered', false)
                        .transition();
                },

                deselect_selected_node: function () {
                    this.deselect_selected_node(this.selectedObject)
                },

                _lockNode: function (node) {
                    node.fixed = true;
                },

                _unlockNode: function (node) {
                    delete node.fixed;
                },

                _selectAndLockNode: function (node, type) {
                    this._unlockNode(this.selectedObject);
                    this.selectedIdx = node.idx;
                    this.selectedObject = node;
                    this.selectedType = type;
                    this._lockNode(this.selectedObject);
                },

                _deselectNodeIfNeeded: function (node, type) {
                    if (node.idx == this.selectedIdx && this.selectedType == type) {
                        this.deselect_node(node);
                        return true;
                    }
                    return false;
                },

                _fadeOutAllNodesAndLinks: function () {
                    // Fade out all circles
                    this.svg.selectAll('circle')
                        .classed('filtered', true)
                        .each(function (node) {
                            node.filtered = true;
                            node.neighbours = false;
                        }).transition();

                    this.svg.selectAll('text')
                        .classed('filtered', true)
                        .transition();

                    this.svg.selectAll('.link').
                        transition()
                        .attr("marker-end", "");

                },

                _highlightNodesWithIndexes: function (indexesArray) {
                    this.svg.selectAll('circle, text')
                        .filter((node) => indexesArray.indexOf(node.index) > -1)
                        .classed('filtered', false)
                        .each((node) => {
                            node.filtered = false;
                            node.neighbours = true;
                        })
                        .transition();
                },

                _nodeExistsInLink: (node, link) => (link.source.index === node.index || link.target.index == node.index),
                _nodeIsSourceOfLink: (node, link) => (link.source.index === node.index),
                _oppositeNodeOfLink: (node, link) => (link.source.index == node.index ? link.target.index : link.target.index == node.index ? link.source.index : null),

                _highlightLinksFromNode: function (node) {
                    this.svg.selectAll('.link')
                        .filter((link) => this._nodeExistsInLink(node, link))
                        .classed('filtered', false)
                        .attr("marker-end", (l) => l.source.index === node.index ? "url(#dependency)" : "url(#dependants)")
                        .transition();
                },

                _highlightLinksFromRootWithNodes: function (root, nodeNeighbors) {
                    this.svg.selectAll('.link')
                        .filter((link) => nodeNeighbors.indexOf(link.source.index) > -1)
                        .classed('filtered', false)
                        .attr("marker-end", (l) => l.source.index === root.index ? "url(#dependency)" : "url(#dependants)")
                        .transition();
                },

                select_node: function (node) {
                    if (d3.event.defaultPrevented) {
                        return
                    }
                    if (this._deselectNodeIfNeeded(node, "normal")) {
                        return
                    }
                    this._selectAndLockNode(node, "normal");

                    var neighborIndexes =
                        this.dependecy_graph.links
                            .filter((link) => this._nodeExistsInLink(node, link))
                            .map((link) => this._oppositeNodeOfLink(node, link).index);

                    neighborIndexes.push(node.index);

                    this._fadeOutAllNodesAndLinks();
                    this._highlightNodesWithIndexes(neighborIndexes);
                    this._highlightLinksFromNode(node);
                },

                select_recursively_node: function (node) {
                    if (d3.event.defaultPrevented) {
                        return
                    }

                    // Don't show context menu :)
                    d3.event.preventDefault();

                    if (this._deselectNodeIfNeeded(node, "recursive")) {
                        return
                    }

                    this._selectAndLockNode(node, "recursive");

                    // Figure out the neighboring node id's with brute strength because the graph is small
                    var neighbours = {};
                    this.dependency_graph.links
                        .filter((link) => this._nodeIsSourceOfLink(node, link))
                        .forEach((link) => {
                            var idx = this._oppositeNodeOfLink(node, link).index;
                            neighbours[idx] = 1;
                            console.log("Step 0. Adding ", this.dependency_graph.nodes[idx].name);
                        }
                    );

                    // Next part - neighbours of neigbours
                    var currentsize = Object.keys(neighbours).length;
                    var nextSize = 0;
                    var step = 1;
                    while (nextSize != currentsize) {
                        console.log("Current size " + currentsize + " Next size is " + nextSize);
                        currentsize = nextSize;
                        this.dependency_graph.links
                            .filter((link) => link.source.index in neighbours)
                            .map((link) => {
                                var idx = link.target.index;
                                neighbours[idx] = 1;
                                console.log("Step " + step + ". Adding ", this.dependency_graph.nodes[idx].name + " From " + this.dependency_graph.nodes[link.source.index].name);
                            }).bind(this);

                        nextSize = Object.keys(neighbours).length;
                        step = step + 1
                    }

                    neighbours[node.index] = 1;
                    var nodeNeighbors = Object.keys(neighbours).map(function (neibour) {
                        return parseInt(neibour);
                    });
                    nodeNeighbors.push(node.index);

                    this._fadeOutAllNodesAndLinks();
                    this._highlightNodesWithIndexes(nodeNeighbors);
                    this._highlightLinksFromRootWithNodes(node, nodeNeighbors);
                }

            };
        }
    };

    if (typeof define === "function" && define.amd) {
        define(graph_actions);
    } else if (typeof module === "object" && module.exports) {
        module.exports = graph_actions;
    } else {
        this.graph_actions = graph_actions;
    }
}();

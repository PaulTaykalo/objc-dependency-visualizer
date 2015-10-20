//  ===================================================
//  ===============  SELECTING_NODE       =============
//  ===================================================

!function () {
    var graph_actions = {

        create: function (svg) {
            return {
                selectedIdx: -1,
                selectedType: "normal",
                svg: svg,
                selectedObject: {},

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

                _selectAndLockNode: function (node, type) {
                    delete this.selectedObject.fixed;
                    this.selectedIdx = node.idx;
                    this.selectedObject = node;
                    this.selectedObject.fixed = true;
                    this.selectedType = type;
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

                _highlightLinksFromNode: function (node) {
                    this.svg.selectAll('.link')
                        .filter((link) => link.source.index === node.index || link.target.index == node.index)
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

                select_node: function (d) {
                    if (d3.event.defaultPrevented) {
                        return
                    }
                    if (this._deselectNodeIfNeeded(d, "normal")) {
                        return
                    }
                    this._selectAndLockNode(d, "normal");
                    // Update selected object

                    // Figure out the neighboring node id's with brute strength because the graph is small
                    var nodeNeighbors =
                        dependecy_graph.links
                            .filter((link) => link.source.index === d.index || link.target.index === d.index)
                            .map((link) => link.source.index === d.index ? link.target.index : link.source.index);

                    nodeNeighbors.push(d.index);

                    this._fadeOutAllNodesAndLinks();
                    this._highlightNodesWithIndexes(nodeNeighbors);
                    this._highlightLinksFromNode(d);
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
                    var nodeNeighbors =
                        dependecy_graph.links
                            .filter((link) => link.source.index === node.index)
                            .map((link) => {
                                var idx = link.source.index === node.index ? link.target.index : link.source.index;
                                if (link.source.index === node.index) {
                                    console.log("Step 0. Adding ", dependecy_graph.nodes[idx].name);
                                    neighbours[idx] = 1;
                                }
                                return idx;
                            }
                        );

                    // Next part - neighbours of neigbours
                    var currentsize = Object.keys(neighbours).length;
                    var nextSize = 0;
                    var step = 1;
                    while (nextSize != currentsize) {
                        console.log("Current size " + currentsize + " Next size is " + nextSize);
                        currentsize = nextSize;
                        dependecy_graph.links
                            .filter(function (link) {
                                return neighbours[link.source.index] != undefined
                            })
                            .map(function (link) {
                                var idx = link.target.index;
                                console.log("Step " + step + ". Adding ", dependecy_graph.nodes[idx].name + " From " + dependecy_graph.nodes[link.source.index].name);

                                neighbours[idx] = 1;
                                return idx;
                            }
                        );
                        nextSize = Object.keys(neighbours).length;
                        step = step + 1
                    }

                    neighbours[node.index] = 1;
                    nodeNeighbors = Object.keys(neighbours).map(function (neibour) {
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

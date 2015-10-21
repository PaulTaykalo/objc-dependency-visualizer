//  ===================================================
//  ===============  SELECTING_NODE       =============
//  ===================================================

let graph_actions = {
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

                this.svg.selectAll('circle')
                    .each(function (node) {
                        node.filtered = false
                    })
                    .classed('filtered', false)
                    .transition();

                this.svg.selectAll('path, text')
                    .classed('filtered', false)
                    .transition();


                this.svg.selectAll('.link')
                    .attr("marker-end", "url(#default)")
                    .classed('filtered', false)
                    .classed('dependency', false)
                    .classed('dependants', false)
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

                this.svg.selectAll('.link')
                    .classed('dependency', false)
                    .classed('dependants', false)
                    .transition()
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
            _oppositeNodeOfLink: (node, link) => (link.source.index == node.index ? link.target : link.target.index == node.index ? link.source : null),

            _highlightLinksFromNode: function (node) {
                this.svg.selectAll('.link')
                    .filter((link) => this._nodeExistsInLink(node, link))
                    .classed('filtered', false)
                    .classed('dependency', (l) => l.source.index === node.index)
                    .classed('dependants', (l) => l.source.index !== node.index)
                    .attr("marker-end", (l) => l.source.index === node.index ? "url(#dependency)" : "url(#dependants)")
                    .transition();
            },

            _highlightLinksFromRootWithNodesIndexes: function (root, nodeNeighbors) {
                this.svg.selectAll('.link')
                    .filter((link) => nodeNeighbors.indexOf(link.source.index) > -1)
                    .classed('filtered', false)
                    .classed('dependency', (l) => l.source.index === root.index)
                    .classed('dependants', (l) => l.source.index !== root.index)
                    .attr("marker-end", (l) => l.source.index === root.index ? "url(#dependency)" : "url(#dependants)")
                    .transition();
            },

            select_node: function (node) {
                if (this._deselectNodeIfNeeded(node, "normal")) {
                    return
                }
                this._selectAndLockNode(node, "normal");

                var neighborIndexes =
                    this.dependency_graph.links
                        .filter((link) => this._nodeExistsInLink(node, link))
                        .map((link) => this._oppositeNodeOfLink(node, link).index);

                neighborIndexes.push(node.index);

                this._fadeOutAllNodesAndLinks();
                this._highlightNodesWithIndexes(neighborIndexes);
                this._highlightLinksFromNode(node);
            },

            select_recursively_node: function (node) {

                if (this._deselectNodeIfNeeded(node, "recursive")) {
                    return
                }

                this._selectAndLockNode(node, "recursive");

                // Figure out the neighboring node id's with brute strength because the graph is small
                var neighbours = {};
                neighbours[node.index] = 1;

                var nodesToCheck = [node.index];
                while (Object.keys(nodesToCheck).length != 0) {
                    nodesToCheck =
                        this.dependency_graph.links
                            .filter((link) => link.source.index in neighbours)
                            .filter((link) => !(link.target.index in neighbours))
                            .map((link) => {
                                neighbours[link.target.index] = 1;
                                return link.target.index;
                            });
                }

                var neighbourNodesIndexes = Object.keys(neighbours).map((key)=>parseInt(key));

                this._fadeOutAllNodesAndLinks();
                this._highlightNodesWithIndexes(neighbourNodesIndexes);
                this._highlightLinksFromRootWithNodesIndexes(node, neighbourNodesIndexes);
            }

        };
    }
};


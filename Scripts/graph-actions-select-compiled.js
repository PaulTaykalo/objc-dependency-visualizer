//  ===================================================
//  ===============  SELECTING_NODE       =============
//  ===================================================

'use strict';

var graph_actions = {
    create: function create(svg, dependecy_graph) {

        return {
            selectedIdx: -1,
            selectedType: "normal",
            svg: svg,
            selectedObject: {},
            dependency_graph: dependecy_graph,

            deselect_node: function deselect_node(d) {
                delete d.fixed;
                this.selectedIdx = -1;
                this.selectedObject = {};

                this.svg.selectAll('circle').each(function (node) {
                    node.filtered = false;
                }).classed('filtered', false).transition();

                this.svg.selectAll('path, text').classed('filtered', false).transition();

                this.svg.selectAll('.link').attr("marker-end", "url(#default)").classed('filtered', false).classed('dependency', false).classed('dependants', false).transition();
            },

            deselect_selected_node: function deselect_selected_node() {
                this.deselect_selected_node(this.selectedObject);
            },

            _lockNode: function _lockNode(node) {
                node.fixed = true;
            },

            _unlockNode: function _unlockNode(node) {
                delete node.fixed;
            },

            _selectAndLockNode: function _selectAndLockNode(node, type) {
                this._unlockNode(this.selectedObject);
                this.selectedIdx = node.idx;
                this.selectedObject = node;
                this.selectedType = type;
                this._lockNode(this.selectedObject);
            },

            _deselectNodeIfNeeded: function _deselectNodeIfNeeded(node, type) {
                if (node.idx == this.selectedIdx && this.selectedType == type) {
                    this.deselect_node(node);
                    return true;
                }
                return false;
            },

            _fadeOutAllNodesAndLinks: function _fadeOutAllNodesAndLinks() {
                // Fade out all circles
                this.svg.selectAll('circle').classed('filtered', true).each(function (node) {
                    node.filtered = true;
                    node.neighbours = false;
                }).transition();

                this.svg.selectAll('text').classed('filtered', true).transition();

                this.svg.selectAll('.link').classed('dependency', false).classed('dependants', false).transition().attr("marker-end", "");
            },

            _highlightNodesWithIndexes: function _highlightNodesWithIndexes(indexesArray) {
                this.svg.selectAll('circle, text').filter(function (node) {
                    return indexesArray.indexOf(node.index) > -1;
                }).classed('filtered', false).each(function (node) {
                    node.filtered = false;
                    node.neighbours = true;
                }).transition();
            },

            _nodeExistsInLink: function _nodeExistsInLink(node, link) {
                return link.source.index === node.index || link.target.index == node.index;
            },
            _oppositeNodeOfLink: function _oppositeNodeOfLink(node, link) {
                return link.source.index == node.index ? link.target : link.target.index == node.index ? link.source : null;
            },

            _highlightLinksFromNode: function _highlightLinksFromNode(node) {
                var _this = this;

                this.svg.selectAll('.link').filter(function (link) {
                    return _this._nodeExistsInLink(node, link);
                }).classed('filtered', false).classed('dependency', function (l) {
                    return l.source.index === node.index;
                }).classed('dependants', function (l) {
                    return l.source.index !== node.index;
                }).attr("marker-end", function (l) {
                    return l.source.index === node.index ? "url(#dependency)" : "url(#dependants)";
                }).transition();
            },

            _highlightLinksFromRootWithNodesIndexes: function _highlightLinksFromRootWithNodesIndexes(root, nodeNeighbors) {
                this.svg.selectAll('.link').filter(function (link) {
                    return nodeNeighbors.indexOf(link.source.index) > -1;
                }).classed('filtered', false).classed('dependency', function (l) {
                    return l.source.index === root.index;
                }).classed('dependants', function (l) {
                    return l.source.index !== root.index;
                }).attr("marker-end", function (l) {
                    return l.source.index === root.index ? "url(#dependency)" : "url(#dependants)";
                }).transition();
            },

            select_node: function select_node(node) {
                var _this2 = this;

                if (this._deselectNodeIfNeeded(node, "normal")) {
                    return;
                }
                this._selectAndLockNode(node, "normal");

                var neighborIndexes = this.dependency_graph.links.filter(function (link) {
                    return _this2._nodeExistsInLink(node, link);
                }).map(function (link) {
                    return _this2._oppositeNodeOfLink(node, link).index;
                });

                neighborIndexes.push(node.index);

                this._fadeOutAllNodesAndLinks();
                this._highlightNodesWithIndexes(neighborIndexes);
                this._highlightLinksFromNode(node);
            },

            select_recursively_node: function select_recursively_node(node) {

                if (this._deselectNodeIfNeeded(node, "recursive")) {
                    return;
                }

                this._selectAndLockNode(node, "recursive");

                // Figure out the neighboring node id's with brute strength because the graph is small
                var neighbours = {};
                neighbours[node.index] = 1;

                var nodesToCheck = [node.index];
                while (Object.keys(nodesToCheck).length != 0) {
                    nodesToCheck = this.dependency_graph.links.filter(function (link) {
                        return link.source.index in neighbours;
                    }).filter(function (link) {
                        return !(link.target.index in neighbours);
                    }).map(function (link) {
                        neighbours[link.target.index] = 1;
                        return link.target.index;
                    });
                }

                var neighbourNodesIndexes = Object.keys(neighbours).map(function (key) {
                    return parseInt(key);
                });

                this._fadeOutAllNodesAndLinks();
                this._highlightNodesWithIndexes(neighbourNodesIndexes);
                this._highlightLinksFromRootWithNodesIndexes(node, neighbourNodesIndexes);
            }

        };
    }
};

//# sourceMappingURL=graph-actions-select-compiled.js.map
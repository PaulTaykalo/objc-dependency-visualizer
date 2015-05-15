
//  ===================================================
//  ===============  SELECTING_NODE       =============
//  ===================================================

var selectedIdx = -1
var selectedType = "normal"
var selectedobject = {}

function deselect_node(svg, d) { 
  delete d.fixed
  selectedIdx = -1
  selectedobject = {};
  svg.selectAll('circle, path, text')
    .classed('filtered', false)
    .each(function(node) {
     node.filtered = false
    })
    .transition()

  svg.selectAll('.link')
    .attr("marker-end", "url(#default)")      
    .classed('filtered', false)
    .transition()


  force.start();
  return
}

function deselect_selected_node(svg) {
	deselect_node(svg, selectedobject)
}

function select_node(svg, d) { 
  if (d3.event.defaultPrevented) return

  // Deselect if needed
  if (d.idx == selectedIdx && selectedType == "normal") { deselect_node(svg, d); return }

  // Update selected object
  delete selectedobject.fixed
  selectedIdx = d.idx
  selectedobject = d
  selectedobject.fixed = true
  selectedType = "normal"

  // Figure out the neighboring node id's with brute strength because the graph is small
  var nodeNeighbors = 
  dependecy_graph.links
    .filter(function(link) {
        return link.source.index === d.index || link.target.index === d.index;})
    .map(function(link) {
        return link.source.index === d.index ? link.target.index : link.source.index; 
      }
    );

  // Fade out all circles
  svg.selectAll('circle')
  .classed('filtered', true)
  .each(function(node){
    node.filtered = true;
    node.neighbours = false;
  }).transition()

  svg.selectAll('text')
    .classed('filtered', true)
    .transition()


  svg.selectAll('.link').
    transition()
    .attr("marker-end", "")


  // Higlight all circle and texts
  svg.selectAll('circle, text')
    .filter(function(node) {
        return nodeNeighbors.indexOf(node.index) > -1 || node.index == d.index;
    })
    .classed('filtered', false)
    .each(function(node) {
       node.filtered = false;
       node.neighbours = true;
    })
    .transition()

  // Higlight links
  svg.selectAll('.link')
    .filter(function(link) {
      return link.source.index === d.index || link.target.index == d.index
    })
    .classed('filtered', false)
    .attr("marker-end", function(l) { return l.source.index === d.index ? "url(#dependency)" : "url(#dependants)"})
    .transition()

  force.start();
}

function select_recursively_node(svg, d) { 
  if (d3.event.defaultPrevented) return
  
  // Don't show context menu :)
  d3.event.preventDefault()  

  // Deselect if needed
  if (d.idx == selectedIdx && selectedType == "recursive") { deselect_node(svg, d); return }

  // Update selected object
  delete selectedobject.fixed
  selectedIdx = d.idx
  selectedobject = d
  selectedobject.fixed = true
  selectedType = "recursive"

  // Figure out the neighboring node id's with brute strength because the graph is small
  var neighbours = {}
  var nodeNeighbors = 
  dependecy_graph.links
    .filter(function(link) {
        return link.source.index === d.index})
    .map(function(link) {
        var idx = link.source.index === d.index ? link.target.index : link.source.index;
        if (link.source.index === d.index) {
          console.log("Step 0. Adding ",dependecy_graph.nodes[idx].name)
          neighbours[idx] = 1;
        }
        return idx; 
      }
    );

  // Next part - neighbours of neigbours
  var currentsize = Object.keys(neighbours).length
  var nextSize = 0;
  var step = 1;
  while (nextSize != currentsize) {
    console.log("Current size " + currentsize + " Next size is " + nextSize)
    currentsize = nextSize
    dependecy_graph.links
        .filter(function(link) {
            return neighbours[link.source.index] != undefined})
        .map(function(link) {
            var idx = link.target.index;
            console.log("Step "+step+". Adding ",dependecy_graph.nodes[idx].name + " From " + dependecy_graph.nodes[link.source.index].name )

            neighbours[idx] = 1;
            return idx;
          }
        );
     nextSize = Object.keys(neighbours).length   
     step = step + 1
  }

  neighbours[d.index] = 1
  nodeNeighbors = Object.keys(neighbours).map(function(neibour) {
      return parseInt(neibour);
  })


  // Fade out all circles
  svg.selectAll('circle')
  .classed('filtered', true)
  .each(function(node){
    node.filtered = true;
    node.neighbours = false;
  }).transition()
    

  svg.selectAll('text')
    .classed('filtered', true)
    .transition()
  

  svg.selectAll('.link').
    transition()
    .attr("marker-end", "")


  // Higlight all circle and texts
  svg.selectAll('circle, text')
    .filter(function(node) {
        return nodeNeighbors.indexOf(node.index) > -1 || node.index == d.index;
    })
    .classed('filtered', false)
    .each(function(node) {
       node.filtered = false;
       node.neighbours = true;
    })
    .transition()

  // Higlight links
  svg.selectAll('.link')
    .filter(function(link) {
      return nodeNeighbors.indexOf(link.source.index) > -1
    })
    .classed('filtered', false)
    .attr("marker-end", function(l) { return l.source.index === d.index ? "url(#dependency)" : "url(#dependants)"})
    .transition()

  force.start();
}

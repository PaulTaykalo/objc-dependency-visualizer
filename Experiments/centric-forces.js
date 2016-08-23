// This one is used by default
// Groups are set based on the Prefixes
function default_coloring(d) {
  return color(d.group); 
}

// This function will group nodes based on the
// Rgular expressions you've provided
var rules = ["ViewController$", "View$", "Factory", "Model", "Locator|Manager", "^SE", "^KML", "Touch", "Google|Statist|Logging","GMS", ""];
var categoryCenters = function(){
    var centers = {}
    for (var i =0; i< rules.length;i++) {
        centers[i] = {x: Math.cos(i *2 * Math.PI / rules.length) * 1000,
          y:Math.sin(i * 2*Math.PI / rules.length) * 1000
        }
    }
    return centers;
}()


function regex_based_coloring(d) {
  var className = d.name
  
//   var rules = ["ViewController", "View"]
  
  for (var i = 0; i < rules.length; i++) {
    var re = new RegExp(rules[i], "");
    if (className.match(re)) {
      d.colorGroup = i;
      return color(i + 1)
    }
  }
  return "black";
}

 function transform(d) {
   return "translate(" + d.x * 5  + "," + d.y  + ")";
 }
 
     function link_line(d) {
        var dx = d.target.x - d.source.x,
                dy = d.target.y - d.source.y,
                dr = Math.sqrt(dx * dx + dy * dy);

        var rsource = radius(d.sourceNode) / dr;
        var rdest = radius(d.targetNode) / dr;
        var startX = d.source.x + dx * rsource;
        var startY = d.source.y + dy * rsource;

        var endX = d.target.x - dx * rdest;
        var endY = d.target.y - dy * rdest;
        return "M" + startX + "," + startY + "L" + endX + "," + endY;
    }

// Filling out with default coloring
// node.style("fill", default_coloring)
node.style("fill", regex_based_coloring)

 force.on("tick", function (e) {
        node.each(moveToCategoryCenter(e.alpha));
        svg.selectAll(".node").attr("r", radius);
        node.attr("transform", transform);
        link.attr("visibility", "hidden");
        if (show_texts_near_circles) {
            text.attr("transform", transform);
        }
    });
    
function moveToCategoryCenter(alpha) {
    return function(d) {
        var center = categoryCenters[d.colorGroup];
        if (center === undefined) {
            center = { x: 600, y: 400}
        }

        var m = 0.1;
        var mx = m;
        var my = m;
        d.x += (center.x - d.x) * mx * alpha;
        d.y += (center.y - d.y) * my * alpha;
    }
}    
  
force.start()
    
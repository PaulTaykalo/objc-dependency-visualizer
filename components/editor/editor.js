/**
 * Created by paultaykalo on 10/30/16.
 */
function editor() {

    $(document).ready(function () {

        // Add sidr with editor to the page
        $("body").append(`
    <div id='sidr'>
        <pre id='editor'>
// This one is used by default
// Groups are set based on the Prefixes
        function default_coloring(d) {
            return color(d.group);
        }

// This function will group nodes based on the
// Regular expressions you've provided
    function regex_based_coloring(d) {
        var className = d.name

        var rules = ['Magical', 'Mapp', '^NS', '^UI',  '^NI', 'AF', ''];
//   var rules = ['ViewController', 'View']

        for (var i = 0; i < rules.length; i++) {
            var re = new RegExp(rules[i], '');
            if (className.match(re)) {
                return color(i + 1)
            }
        }
        return 'black';
    }

// Filling out with default coloring
   node.style('fill', default_coloring)
// node.style("fill", regex_based_coloring)

    force.start()
        </pre>
    </div>`
        );

        // Initialize ace editor
        var editor = ace.edit("editor");
        editor.setTheme("ace/theme/twilight");
        editor.getSession().setMode("ace/mode/javascript");

        editor.getSession().on('change', function (e) {
            try {
                eval(editor.getSession().getValue())
            } catch (err) {
                console.log(err)
            }
        });

        $('#simple-menu').sidr(
            {
                displace: false,
                onOpen: function () {
                    editor.resize()
                }
            }
        );
        $("#chart").css("overflow", "hidden");

    });

}
editor();

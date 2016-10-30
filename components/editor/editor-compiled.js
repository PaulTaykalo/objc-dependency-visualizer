/**
 * Created by paultaykalo on 10/30/16.
 */
"use strict";

function editor() {

    $(document).ready(function () {

        // Add sidr with editor to the page
        $("body").append("\n    <div id='sidr'>\n        <pre id='editor'>\n// This one is used by default\n// Groups are set based on the Prefixes\n        function default_coloring(d) {\n            return color(d.group);\n        }\n\n// This function will group nodes based on the\n// Regular expressions you've provided\n    function regex_based_coloring(d) {\n        var className = d.name\n\n        var rules = ['Magical', 'Mapp', '^NS', '^UI',  '^NI', 'AF', ''];\n//   var rules = ['ViewController', 'View']\n\n        for (var i = 0; i < rules.length; i++) {\n            var re = new RegExp(rules[i], '');\n            if (className.match(re)) {\n                return color(i + 1)\n            }\n        }\n        return 'black';\n    }\n\n// Filling out with default coloring\n   node.style('fill', default_coloring)\n// node.style(\"fill\", regex_based_coloring)\n\n    force.start()\n        </pre>\n    </div>");

        // Initialize ace editor
        var editor = ace.edit("editor");
        editor.setTheme("ace/theme/twilight");
        editor.getSession().setMode("ace/mode/javascript");

        editor.getSession().on('change', function (e) {
            try {
                eval(editor.getSession().getValue());
            } catch (err) {
                console.log(err);
            }
        });

        $('#simple-menu').sidr({
            displace: false,
            onOpen: function onOpen() {
                editor.resize();
            }
        });
        $("#chart").css("overflow", "hidden");
    });
}
editor();

//# sourceMappingURL=editor-compiled.js.map
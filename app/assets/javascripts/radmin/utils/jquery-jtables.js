// var defaults = {
//
//     // We define an empty anonymous function so that
//     // we don't need to check its existence before calling it.
//     onImageShow : function() {},
//
//     // ... rest of settings ...
//
// };
//
// // Later on in the plugin:
//
// nextButton.on( "click", showNextImage );
//
// function showNextImage() {
//
//     // Returns reference to the next image node
//     var image = getNextImage();
//
//     // Stuff to show the image here...
//
//     // Here's the callback:
//     settings.onImageShow.call( image );
// }

// $( "ul.imgs li" ).superGallery({
//     onImageShow: function() {
//         $( this ).after( "<span>" + $( this ).attr( "longdesc" ) + "</span>" );
//     },
//
//     // ... other options ...
// });



// var defaults = {
//     wrapperAttrs : {
//         class: "gallery-wrapper"
//     },
//     wrapperCSS: {},
//     // ... rest of settings ...
// };
//
// // We can use the extend method to merge options/settings as usual:
// // But with the added first parameter of TRUE to signify a DEEP COPY:
// var settings = $.extend( true, {}, defaults, options );


// // Retain an internal reference:
// var wrapper = $( "<div />" )
//     .attr( settings.wrapperAttrs )
//     .css( settings.wrapperCSS ) // ** Set CSS!
//     .appendTo( settings.container );
//
// // Easy to reference later...
// wrapper.append( "..." );




(function ( $ ) {
    $.fn.jtable = function(options) {

        var settings = $.extend( false, {
            fixedHeader: true,
            fixedFooter: true,
            fixedLeftColumns: 0,
            fixedRightColumns: 0,

            wrapperAttrs: {},
            wrapperCSS: {}
            panelCSS: {}
        }, options);

        settings.fixedLeftColumns = Number(settings.fixedLeftColumns);
        settings.fixedRightColumns = Number(settings.fixedRightColumns);



        if (!settings.fixedHeader && !settings.fixedFooter &&
                settings.fixedLeftColumns <= 0 && settings.fixedRightColumns <= 0) {
            return this;
        }

        var createWrapper = function(attrs, css_attrs) {
            var wrapper = $("<div />")
                .attr(attrs)
                .css(css_attrs)
        };

        var createSidePanel = function(panel_class) {
            var $table = $("<table />");
            var $table_head = $("<thead />");
            $table_head.appendTo($table);

            var $table_body = $("<tbody />");
            $table_body.appendTo($table);

            var $panel_wrapper = createWrapper({class: panel_class}, settings.panelCSS);
            $left_table.appendTo($panel_wrapper);

            $wrapper.append($panel_wrapper);
            return [$table_head, $table_body]
        }

        var moveData = function(tr, $left_dest, $right_dest) {
            if ($left_dest) {
                var counter = settings.fixedLeftColumns;
                var $dest_tr = $left_dest.appendTo($left_dest);

                while(counter--) {
                    $left_dest.append(head_tr.removeChild(children[counter]));
                }
            }

            if ($right_dest) {
                var counter = settings.fixedRightColumns;

                while(counter--) {
                    $right_dest.append(head_tr.removeChild(children[children.length - 1 - counter]));
                }
            }
        }

        return this.each(function() {
            if (this.tagName.toLowerCase() !== 'table') {
                return;
            }

            var $el = $(this);
            var columns_count = $el.find('tr:first td').length;


            if (columns_count == 0 || (settings.fixedLeftColumns + settings.fixedRightColumns <= columns_count - 1)) {
                return;
            }

            var has_left = !!settings.fixedLeftColumns;
            var has_right = !!settings.fixedRightColumns;

            var $wrapper = createWrapper(settings.wrapperAttrs, settings.wrapperCSS);
            var $center_panel = createWrapper({class: 'jtable-center'}, settings.panelCSS);

            var $left_table_head;
            var $left_table_body;
            var $right_table_head;
            var $right_table_body;

            // if (settings.fixedHeader) {
            //
            // }

            if (has_left) {
                [$left_table_head, $left_table_body] =
                    createSidePanel('jtable-left')
            }

            $wrapper.append($center_panel);

            if (has_right) {
                [$right_table_head, $right_table_body] =
                    createSidePanel('jtable-right')
            }

            // if (settings.fixedFooter) {
            //
            // }


            var head_tr = $el.find('thead tr')[0];
            var children = head_tr.children;

            if (has_left) {
                var counter = settings.fixedLeftColumns;

                while(counter--) {
                    $left_table_head.append(head_tr.removeChild(children[counter]));
                }
            }

            if (has_right) {
                var counter = settings.fixedRightColumns;

                while(counter--) {
                    $right_table_head.append(head_tr.removeChild(children[children.length - 1 - counter]));
                }
            }


            var $body_trs = $el.find('tbody tr');

            $trs.each(function(i, tr) {
                var children = tr.children;

                if (has_left) {
                    var counter = settings.fixedLeftColumns;

                    while(counter--) {
                        $left_table_head.append(head_tr.removeChild(children[counter]));
                    }
                }

                if (has_right) {
                    var counter = settings.fixedRightColumns;

                    while(counter--) {
                        $right_table_head.append(head_tr.removeChild(children[children.length - 1 - counter]));
                    }
                }
            });
        });
    };
}(jQuery));
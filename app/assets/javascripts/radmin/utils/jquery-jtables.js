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




(function($) {
    $.fn.jtable = function(options) {

        var settings = $.extend(false, {
            fixedHeader: false,
            fixedFooter: false,
            fixedLeftColumns: 0,
            fixedRightColumns: 0,

            wrapperAttrs: {},
            wrapperCSS: {},
            panelCSS: {},
        }, options);

        settings.fixedLeftColumns = Number(settings.fixedLeftColumns);
        settings.fixedRightColumns = Number(settings.fixedRightColumns);

        if (!settings.fixedHeader && !settings.fixedFooter &&
                settings.fixedLeftColumns <= 0 && settings.fixedRightColumns <= 0) {
            return this;
        }

        var createWrapper = function(attrs, css_attrs, main_class) {
            attrs['class'] = attrs['class'] ? (attrs['class'] + ' ' + main_class)  : main_class;

            return $("<div />")
                .attr(attrs)
                .css(css_attrs);
        };

        var createSidePanel = function($wrapper, panel_class, props) {
            var $table = $("<table />").prop(props);

            var $table_head = $("<thead />");
            $table_head.appendTo($table);

            var $table_body = $("<tbody />");
            $table_body.appendTo($table);

            var $panel_wrapper = createWrapper({class: panel_class}, settings.panelCSS, 'jtable-panel');
            $table.appendTo($panel_wrapper);

            $wrapper.append($panel_wrapper);
            return [$table_head, $table_body];
        }

        var moveData = function(tr, $left_dest, $right_dest) {
            var target_height = tr.offsetHeight;
            var children = tr.children;

            tr.style = "height: " + target_height + "px";

            if ($left_dest) {
                var counter = settings.fixedLeftColumns;
                var $dest_tr = $('<tr style="height:' + target_height + 'px"/>').appendTo($left_dest);

                while(counter--) {
                    $dest_tr.append(tr.removeChild(children[counter]));
                }
            }

            if ($right_dest) {
                var counter = settings.fixedRightColumns;
                var $dest_tr = $('<tr style="height:' + target_height + 'px"/>').appendTo($right_dest);

                while(counter--) {
                    $dest_tr.append(tr.removeChild(children[children.length - 1 - counter]));
                }
            }
        }

        return this.each(function() {
            if (this.tagName.toLowerCase() !== 'table') {
                return;
            }

            var $el = $(this);
            var columns_count =
                $el.find('thead tr th').length ||
                $el.find('tbody tr:first td').length;

            if (columns_count == 0 || (settings.fixedLeftColumns + settings.fixedRightColumns >= columns_count - 1)) {
                return;
            }

            var has_left = !!settings.fixedLeftColumns;
            var has_right = !!settings.fixedRightColumns;

            var $wrapper = createWrapper(settings.wrapperAttrs, settings.wrapperCSS, 'jtable');
            var $center_panel = createWrapper({class: 'jtable-center'}, settings.panelCSS);

            var table_props = {
                style: $el.prop('style'),
                class: $el.prop('class')
            };

            var [$left_table_head, $left_table_body] =
                has_left ? createSidePanel($wrapper,'jtable-left', table_props) : [undefined, undefined];

            $wrapper.append($center_panel);

            var [$right_table_head, $right_table_body] =
                has_right ? createSidePanel($wrapper, 'jtable-right', table_props) : [undefined, undefined];

            // if (settings.fixedHeader) {
            //
            // }

            // if (settings.fixedFooter) {
            //
            // }


            var head_tr = $el.find('thead tr')[0];
            moveData(head_tr, $left_table_head, $right_table_head)


            var $body_trs = $el.find('tbody tr');
            $body_trs.each(function(i, tr) {
                moveData(tr, $left_table_body, $right_table_body)
            });

            $wrapper.insertAfter($el);
            $center_panel.append($el);
        });
    };
}(jQuery));
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
            panelCSS: {}
        }, options);

        settings.fixedLeftColumns = Number(settings.fixedLeftColumns);
        settings.fixedRightColumns = Number(settings.fixedRightColumns);

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
        };

        var moveData = function(tr, $left_dest, $right_dest) {
            var target_height = tr.offsetHeight;
            var children = tr.children;

            tr.style = "height: " + target_height + "px";

            if ($left_dest) {
                var counter = fixedLeftColumns;
                var $dest_tr = $('<tr style="height:' + target_height + 'px"/>').appendTo($left_dest);

                while(counter--) {
                    $dest_tr.prepend(tr.removeChild(children[counter]));
                }
            }

            if ($right_dest) {
                var counter = fixedRightColumns;
                var $dest_tr = $('<tr style="height:' + target_height + 'px"/>').appendTo($right_dest);

                while(counter--) {
                    $dest_tr.append(tr.removeChild(children[children.length - 1 - counter]));
                }
            }
        };

        var fixedLeftColumns;
        var fixedRightColumns;

        return this.each(function() {
            if (this.tagName.toLowerCase() !== 'table') {
                return;
            }

            var $el = $(this);

            var dataLeft = $el.data('fix-left');
            fixedLeftColumns = dataLeft ? Number(dataLeft) : settings.fixedLeftColumns;

            var dataRight = $el.data('fix-right');
            fixedRightColumns = dataRight ? Number(dataRight) : settings.fixedRightColumns;

            var columns_count =
                $el.find('thead tr th').length ||
                $el.find('tbody tr:first td').length;

            if (columns_count === 0 || (fixedLeftColumns + fixedRightColumns >= columns_count - 1)) {
                return;
            }

            if (!settings.fixedHeader && !settings.fixedFooter &&
                fixedLeftColumns <= 0 && fixedRightColumns <= 0) {
                return this;
            }

            console.log(fixedLeftColumns);
            console.log(fixedRightColumns);

            var has_left = !!fixedLeftColumns;
            var has_right = !!fixedRightColumns;

            var $wrapper = createWrapper(settings.wrapperAttrs, settings.wrapperCSS, 'jtable');
            var $center_panel = createWrapper({class: 'jtable-center'}, settings.panelCSS, 'jtable-panel');

            var table_props = {
                style: $el.prop('style'),
                class: $el.prop('class')
            };

            var values = has_left ? createSidePanel($wrapper,'jtable-left', table_props) : [undefined, undefined];
            var $left_table_head = values[0];
            var $left_table_body = values[1];


            $wrapper.append($center_panel);

            values = has_right ? createSidePanel($wrapper, 'jtable-right', table_props) : [undefined, undefined];
            var $right_table_head = values[0];
            var $right_table_body = values[1];


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
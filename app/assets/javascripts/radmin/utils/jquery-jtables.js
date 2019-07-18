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
            fixedLeftColumns: 0,
            fixedRightColumns: 0,

            headerAttrs: {},
            headerCSS: {},
            tableAttrs: {},
            tableCSS: {},
            wrapperAttrs: {},
            wrapperCSS: {},
            panelCSS: {}
        }, options);

        settings.fixedLeftColumns = Number(settings.fixedLeftColumns);
        settings.fixedRightColumns = Number(settings.fixedRightColumns);

        var fixedLeftColumns;
        var fixedRightColumns;
        var fixedHeader;
        var leftPanelClass = 'jtable-left';
        var centerPanelClass = 'jtable-center';
        var rightPanelClass = 'jtable-right';

        var createWrapper = function(attrs, css_attrs, main_class) {
            attrs['class'] = attrs['class'] ? (attrs['class'] + ' ' + main_class)  : main_class;

            return $("<div />")
                .attr(attrs)
                .css(css_attrs);
        };

        var createSidePanel = function($wrapper, panel_class, props, create_body) {
            var $table = $("<table />").prop(props);
            var $table_body;

            var $table_head = $("<thead />").appendTo($table);
            if (create_body) {
                $table_body = $("<tbody />").appendTo($table);
            }

            var $panel_wrapper = createWrapper({class: panel_class}, settings.panelCSS, 'jtable-panel');
            $wrapper.append($panel_wrapper.append($table));

            return [$table_head, $table_body];
        };

        var moveSideData = function(tr, $dest, target_height, iter, offset) {
            var $dest_tr = $('<tr style="height:' + target_height + 'px"/>').appendTo($dest);
            var childs = tr.children;
            offset = offset === undefined ? childs.length : offset;

            while(iter--) {
                $dest_tr.append(tr.removeChild(childs[--offset - iter]));
            }
        };

        var moveData = function(tr, $left_dest, $right_dest) {
            var target_height = tr.offsetHeight;
            tr.style = "height: " + target_height + "px";

            if ($left_dest) {
                moveSideData(tr, $left_dest, target_height, fixedLeftColumns, fixedLeftColumns);
            }

            if ($right_dest) {
                moveSideData(tr, $right_dest, target_height, fixedRightColumns);
            }
        };

        return this.each(function() {
            if (this.tagName.toLowerCase() !== 'table') {
                return;
            }

            var $el = $(this);

            var dataLeft = $el.data('fix-left');
            fixedLeftColumns = dataLeft ? Number(dataLeft) : settings.fixedLeftColumns;

            var dataRight = $el.data('fix-right');
            fixedRightColumns = dataRight ? Number(dataRight) : settings.fixedRightColumns;

            var dataTop = !!$el.data('fix-header');
            fixedHeader = dataTop || settings.fixedHeader;

            var columns_count =
                $el.find('thead tr th').length ||
                $el.find('tbody tr:first td').length;

            // join and fix me
            if (columns_count === 0 || (fixedLeftColumns + fixedRightColumns >= columns_count - 1)) {
                return;
            }

            if (!fixedHeader && fixedLeftColumns <= 0 && fixedRightColumns <= 0) {
                return;
            }
            ////////////////


            var has_left = !!fixedLeftColumns;
            var has_right = !!fixedRightColumns;

            var $wrapper = createWrapper(settings.wrapperAttrs, settings.wrapperCSS, 'jtable');
            var $headerWrapper =
                createWrapper(settings.headerAttrs, settings.headerCSS, 'jtable-head jlocked')
                    .appendTo($wrapper);

            $headerWrapper.hide();


            var $tableWrapper =
                createWrapper(settings.tableAttrs, settings.tableCSS, 'jtable-block')
                    .appendTo($wrapper);

            var table_props = { style: $el.prop('style'), class: $el.prop('class') };

            var values = has_left ? createSidePanel($tableWrapper,leftPanelClass, table_props, true) : [undefined, undefined];
            var $left_table_head = values[0];
            var $left_table_body = values[1];

            var $center_panel = createWrapper({class: centerPanelClass}, settings.panelCSS, 'jtable-panel');
            $tableWrapper.append($center_panel);

            values = has_right ? createSidePanel($tableWrapper, rightPanelClass, table_props, true) : [undefined, undefined];
            var $right_table_head = values[0];
            var $right_table_body = values[1];


            var head_tr = $el.find('thead tr')[0];
            moveData(head_tr, $left_table_head, $right_table_head);


            var $body_trs = $el.find('tbody tr');
            $body_trs.each(function(i, tr) {
                moveData(tr, $left_table_body, $right_table_body)
            });

            $wrapper.insertAfter($el);
            $center_panel.append($el);

            if (fixedHeader) {
                var $panels = $wrapper.find('.jtable-panel');

                $panels.each(function() {
                    var $headPanel = $(this.cloneNode()).appendTo($headerWrapper);
                    var $headTable = $("<table />").prop(table_props).appendTo($headPanel);
                    var $headTableHead = $("<thead />").appendTo($headTable);
                    var tHead = $(this).find('table thead')[0];
                    var tHeadTr = tHead.children[0];
                    var tHeadTrDup = tHeadTr.cloneNode(true);

                    var tHeadTrChildren = tHeadTr.children;
                    var tHeadTrDupChildren = tHeadTrDup.children;
                    var counter = tHeadTrChildren.length;

                    var $tBody = $(this).find('table tbody');
                    var $fakeTr = $('<tr class="fake"/>').appendTo($tBody);


                    while(counter--) {
                        var targetWidth = tHeadTrChildren[counter].offsetWidth;

                        tHeadTrDupChildren[counter].style = "min-width: " + targetWidth + "px";
                        $fakeTr.prepend("<td style='min-width: " + targetWidth + "px'></td>")
                    }

                    $headTableHead.append(tHeadTrDup);
                });
            }

            function moveScroll() {
                var scroll = this.scrollY;
                var anchor_top = $wrapper.offset().top;
                var anchor_bottom = anchor_top + $wrapper[0].scrollHeight;

                if (scroll > anchor_top && scroll < anchor_bottom) {
                    if (!$headerWrapper.hasClass('sticky')) {
                        $headerWrapper.show().addClass('sticky');
                        $tableWrapper.find('thead').addClass('hidden'); //.css({visibility: 'hidden', height: '1px', 'line-height': '1px'}); //hide();
                    }
                } else {
                    if ($headerWrapper.hasClass('sticky')) {
                        $headerWrapper.hide().removeClass('sticky');
                        $tableWrapper.find('thead').removeClass('hidden');//.css({visibility: 'visible', height: 'auto', 'line-height': '1px'}); //.show();
                    }
                }
            }


            $(window).scroll(moveScroll);
            moveScroll();

            var $target_scroll = $tableWrapper.find('.jtable-center');
            var scroll_obj = $target_scroll[0];
            var $headScrollTable = $headerWrapper.find('.jtable-center');

            $target_scroll.on('scroll', function(e) {
                $headScrollTable.scrollLeft(scroll_obj.scrollLeft);


                // scroll_obj.scrollLeft = val for scroll manually

                // $target_scroll.scrollLeft() // scroll pos
                // $target_scroll[0].offsetWidth // client size of elem
                // $target_scroll[0].scrollWidth // full size of elem
                // console.log(scroll_obj.scrollLeft, scroll_obj.offsetWidth, scroll_obj.scrollWidth);
            });
        });
    };
}(jQuery));
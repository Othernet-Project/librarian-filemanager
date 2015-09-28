/*jslint browser: true*/
(function ($) {
    'use strict';
    $(document).ready(function () {
        var openerId = $('.opener').data('opener-id'),
            handler = $.openers[openerId];

        if (handler) {
            handler();
        }
    });
}(this.jQuery));

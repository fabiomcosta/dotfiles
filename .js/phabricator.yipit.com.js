djs.loadjQuery(function($) {

    djs.load('https://raw.github.com/tzuryby/jquery.hotkeys/master/jquery.hotkeys.js', function() {

        $('[action$="/audit/addcomment/"]').find('select, textarea').each(function(i, element) {
            $(element).attr('tabindex', i + 1);
        });

        $('#audit-content').bind('keydown.meta_return', function() {
            $(this).get(0).form.submit();
        });

    });

});

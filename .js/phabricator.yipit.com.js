djs.loadjQuery(function($) {

    $('[action$="/audit/addcomment/"]').find('select, textarea').each(function(i, element) {
        $(element).attr('tabindex', i + 1);
    });

});

djs.loadjQuery(function($) {

    // seleciona ingles
    $('#int_idioma').val(2);

    // remove propaganda
    $('#holder').remove();

    // remove popus, ao clicar baixa a legenda direto
    $('.buscaNDestaque, .buscaDestaque').each(function(i, el) {
        el = $(el);
        var onclickAttr = el.attr('onclick'),
            id = onclickAttr.match(/'(\w+)'/)[1];

        el.attr('onclick', '').
            wrap($('<a>').attr('href', 'http://legendas.tv/info.php?d='+ id +'&c=1'));
    });

});

djs = {
    load: function(path, callback) {
        var head = document.getElementsByTagName('head')[0];
        var newScript = document.createElement('script');
        newScript.onload = callback;
        newScript.type = 'text/javascript';
        newScript.src = path;
        head.appendChild(newScript);
    },

    loadjQuery: function(callback) {
        var calljQuery = function() {
            jQuery(callback);
        };

        if (!window.jQuery) {
            djs.load('//ajax.googleapis.com/ajax/libs/jquery/1.8.0/jquery.min.js', calljQuery);
        } else {
            calljQuery();
        }
    },

    toArray: function(collection) {
        return Array.prototype.slice.call(collection);
    }
};

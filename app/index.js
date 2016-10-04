'use strict';

require('./index.html');
require('./styles/styles.css');
require('./styles/elm-datepicker.css');

var Elm = require('./src/Main.elm');

Elm.Main.embed(document.getElementById('main'), {
    now: Date.now()
});

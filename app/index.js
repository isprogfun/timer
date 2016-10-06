'use strict';

require('./index.html');
require('./styles/styles.css');
require('./styles/elm-datepicker.css');

var Elm = require('./src/Main.elm');

var apiUrl = 'https://isprogfun.ru/api/timer';

if (location.hostname === 'localhost') {
    apiUrl = 'http://localhost:4760/api/timer';
}

Elm.Main.embed(document.getElementById('main'), {
    now: Date.now(),
    apiUrl: apiUrl
});

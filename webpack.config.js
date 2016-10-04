const path = require('path');

module.exports = {
    entry: './app/index.js',

    output: {
        path: path.resolve(__dirname + '/docs'),
        filename: 'bundle.js'
    },

    module: {
        loaders: [
            {
                test: /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                loader: 'elm-webpack'
            },
            {
                test: /\.html$/,
                exclude: /node_modules/,
                loader: 'file?name=[name].[ext]'
            },
            {
                test: /\.(css|scss)$/,
                loaders: [
                    'style-loader',
                    'css-loader'
                ]
            }
        ]
    },

    devServer: {
        inline: true,
        historyApiFallback: true,
        stats: { colors: true }
    }
};

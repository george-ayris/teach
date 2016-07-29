var path = require('path');
var webpack = require('webpack');

module.exports = {
  entry: {
    app: [
      './frontend/src/dev.js'
    ]
  },

  output: {
    path: path.resolve(__dirname ),
    filename: 'bundle.js',
  },

  module: {
    loaders: [{
      test: /\.elm$/,
      exclude: [/elm-stuff/, /node_modules/],
      loader: 'elm-hot!elm-webpack'//?warn=true
    },{
      test:    /\.html$/,
      exclude: /node_modules/,
      loader:  'file?name=[name].[ext]',
    }]
  },

  plugins: [ new webpack.OldWatchingPlugin() ],

  devServer: {
    inline: true,
    stats: { colors: true },
  }
};

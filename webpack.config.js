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
      test: /\.json$/,
      loader: 'json'
    },{
      test: /\.js$/,
      loader: "transform/cacheable?brfs"
    },{
      test:    /\.html$/,
      exclude: [/elm-stuff/, /node_modules/],
      loader:  'file?name=[name].[ext]',
    },{
      test   : /.js$/,
      exclude: [/elm-stuff/, /node_modules/],
      loader : 'babel-loader',
      query: {
        presets: ['es2015']
      }
    },{
      test: /\.scss$/,
      loaders: ["style", "css", "sass"]
    }]
  },
  sassLoader: {
    includePaths: [path.resolve(__dirname, "frontend/vendor/")]
  },
  plugins: [ new webpack.OldWatchingPlugin() ],

  devServer: {
    inline: true,
    stats: { colors: true },
  }
};

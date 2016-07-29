var path = require("path");

module.exports = {
  entry: {
    app: [
      './frontend/src/index.js'
    ]
  },

  output: {
    path: path.resolve(__dirname),
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
    }]
  }
};

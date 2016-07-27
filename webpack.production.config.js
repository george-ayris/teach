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
      loader: 'elm-webpack?warn=true'
    },{
      test:    /\.html$/,
      exclude: /node_modules/,
      loader:  'file?name=[name].[ext]',
    }]
  }
};

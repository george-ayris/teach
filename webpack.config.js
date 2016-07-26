var path = require('path');
var webpack = require('webpack');

module.exports = {
  entry: {
    app: [
      './src/index.js'
    ]
  },

  output: {
    path: path.resolve(__dirname + '/dist'),
    filename: 'bundle.js',
  },

  module: {
    loaders: [{
      test: /\.elm$/,
      exclude: [/elm-stuff/, /node_modules/],
      loader: 'elm-hot!elm-webpack'
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

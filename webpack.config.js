var path = require("path");

module.exports = {
  entry: {
    app: [
      './src/index.js'
    ]
  },

  output: {
    path: path.resolve(__dirname ),
    filename: 'bundle.js',
  },

  watch: true,

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

  devServer: {
    inline: true,
    stats: { colors: true },
  }
};

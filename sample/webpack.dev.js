const path = require('path');
const { merge } = require('webpack-merge');
const { DefinePlugin } = require('webpack');

const common = require('./webpack.common.js');

module.exports = merge(common, {
  mode: 'development',
  devtool: 'inline-source-map',
  devServer: {
    port: 8080,
    // historyApiFallback: true,
    static: [
      {
        directory: path.resolve(__dirname, '../tiles/'),
        publicPath: '/tiles',
      },
    ],
  },
  plugins: [
    new DefinePlugin({
      MAPHOST: JSON.stringify(`http://localhost:8080`),
    }),
  ],
});

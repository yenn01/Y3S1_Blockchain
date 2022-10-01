module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 6545,
      network_id: "*"
    },
    loc_development_development: {
      network_id: "*",
      port: 7545,
      host: "127.0.0.1"
    }
  },
  mocha: {},
  compilers: {
    solc: {
      version: "0.8.17"
    }
  }
};

var Put = require('bufferput');
var buffertools = require('buffertools');
var hex = function(hex) {return new Buffer(hex, 'hex');};

exports.livenet = {
  name: 'livenet',
  magic: hex('f9beb4d9'),
  addressVersion: 0x00,
  privKeyVersion: 128,
  P2SHVersion: 5,
  hkeyPublicVersion: 0x0488b21e,
  hkeyPrivateVersion: 0x0488ade4,
  genesisBlock: {
   // hash: hex('1A91E3DACE36E2BE3BF030A65679FE821AA1D6EF92E7C9902EB318182C355691'),
    hash: hex('9156352c1818b32e90c9e792efd6a11a82fe7956a630f03bbee236cedae3911a'),
    merkle_root: hex('5B2A3F53F605D62C53E62932DAC6925E3D74AFA5A4B459745C36D42D0ED26A69'),
    height: 0,
    nonce: 99943,
    version: 1,
    prev_hash: buffertools.fill(new Buffer(32), 0),
    timestamp: 1386325540,
    bits: 504365040,
  },
  dnsSeeds: [
  ],
  defaultClientPort: 22556
};

exports.testnet = {
  name: 'testnet',
  magic: hex('0b110907'),
  addressVersion: 0x6f,
  privKeyVersion: 239,
  P2SHVersion: 196,
  hkeyPublicVersion: 0x043587cf,
  hkeyPrivateVersion: 0x04358394,
  genesisBlock: {
    hash: hex('43497FD7F826957108F4A30FD9CEC3AEBA79972084E90EAD01EA330900000000'),
    merkle_root: hex('3BA3EDFD7A7B12B27AC72C3E67768F617FC81BC3888A51323A9FB8AA4B1E5E4A'),
    height: 0,
    nonce: 414098458,
    version: 1,
    prev_hash: buffertools.fill(new Buffer(32), 0),
    timestamp: 1296688602,
    bits: 486604799,
  },
  dnsSeeds: [
    'testnet-seed.bitcoin.petertodd.org',
    'testnet-seed.bluematt.me'
  ],
  defaultClientPort: 18333
};


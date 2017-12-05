// Test file wrote using the guidelines of Module 5 at
//https://academy.b9lab.com/courses/course-v1:B9lab+ETH-17+2017-10/courseware/7919cb1e36e941999dabb2b1281301a0/cc93424aab144f1cb7315981e9f8c127/

const Web3 = require('web3');
const web3 = new Web3();

const TestRPC = require('ethereumjs-testrpc');
web3.setProvider(TestRPC.provider({
// this is four wallets with 10 ether each, the first is used to
// create the contract, the other three are Alice, Bob and Carol
// NOTE: initialising wallets fails because of a TestRPC 2.x bug
//       https://github.com/trufflesuite/ganache-cli/pull/278
    "accounts": [ { "balance": "0x8AC7230489E80000" },
                  { "balance": "0x8AC7230489E80000" },
                  { "balance": "0x8AC7230489E80000" },
                  { "balance": "0x8AC7230489E80000" } ]
}));

const Promise = require('bluebird');
Promise.promisifyAll(web3.eth, { suffix: "Promise" });
Promise.promisifyAll(web3.version, { suffix: "Promise" });

const assert = require('assert-plus');

const truffleContract = require("truffle-contract");

const Splitter = truffleContract(require(__dirname + "/../build/contracts/Splitter.json"));
Splitter.setProvider(web3.currentProvider);

describe("Splitter", () => {

    var accounts, networkId, splitter;

    before("get accounts", function() {
        return web3.eth.getAccountsPromise()
            .then(_accounts => accounts = _accounts)
            .then(() => web3.version.getNetworkPromise())
            .then(_networkId => {
                networkId = _networkId;
                Splitter.setNetwork(networkId);
            });
    });

    beforeEach("deploy a test Splitter with the 3 preset wallets", () => {
        return Splitter.new(
            accounts[1],
            accounts[2],
            accounts[3],
            { from: accounts[0] }
        )
            .then(_splitter => splitter = _splitter);
    });

    it("All users start with zero balance", () => {
        var ok = true;
        return splitter.getBalance.call(accounts[1])
            .then(_balance => {
                ok = ok && (_balance.toString("10") == "0");
                return splitter.getBalance.call(accounts[2])
            })
            .then(_balance => {
                ok = ok && (_balance.toString("10") == "0");
                return splitter.getBalance.call(accounts[3])
            })
            .then(_balance => {
                ok = ok && (_balance.toString("10") == "0");
                assert.bool(
                    ok,
                    "One or more of the users' wallets was not empty at contract construction."
                );
            });
    });

});

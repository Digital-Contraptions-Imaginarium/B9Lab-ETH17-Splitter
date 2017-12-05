const Web3 = require("web3");
const Promise = require("bluebird");
const truffleContract = require("truffle-contract");
const $ = require("jquery");
const splitterJson = require("../../build/contracts/Splitter.json");

// Supports Mist, and other wallets that provide 'web3'.
if (typeof web3 !== 'undefined') {
    // Use the Mist/wallet/Metamask provider.
    window.web3 = new Web3(web3.currentProvider);
} else {
    // Your preferred fallback.
    window.web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));
}

Promise.promisifyAll(web3.eth, { suffix: "Promise" });
Promise.promisifyAll(web3.version, { suffix: "Promise" });

const Splitter = truffleContract(splitterJson);
Splitter.setProvider(web3.currentProvider);

window.updateBalances = () => {
    return window.deployed.getBalance.call(window.accounts[0])
    .then(balance => {
        $("#alicesBalance").html(balance.toString(10))
        return window.deployed.getBalance.call(window.accounts[1]);
    })
    .then(balance => {
        $("#bobsBalance").html(balance.toString(10))
        return window.deployed.getBalance.call(window.accounts[2]);
    })
    .then(balance => $("#carolsBalance").html(balance.toString(10)))
}

window.addEventListener('load', function() {
    return web3.eth.getAccountsPromise()
        .then(accounts => {
            if (accounts.length == 0) {
                $("#balance").html("N/A");
                throw new Error("No account with which to transact");
            }
            window.accounts = [ accounts[0],accounts[1], accounts[2] ];
            return web3.version.getNetworkPromise();
        })
        .then(network => Splitter.deployed())
        .then(_deployed => {
            window.deployed = _deployed;
            return window.updateBalances();
        })
        .catch(console.error);
});

require("file-loader?name=../index.html!../index.html");

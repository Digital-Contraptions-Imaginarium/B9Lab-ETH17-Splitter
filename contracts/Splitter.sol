// Please read the README.md file at https://github.com/Digital-Contraptions-Imaginarium/B9Lab-ETH17-Splitter/blob/master/README.md
// before studying this code for corrections or suggestions.

pragma solidity ^0.4.15;

contract Splitter {

    bool public paused;
    address[3] public users;
    mapping(address => uint) public balances;

    event LogDeposit(address userAddress, uint amount);
    event LogPause(address userAddress);
    event LogResume(address userAddress);
    event LogWithdrawal(address userAddress, uint balance);

    function Splitter(address _bob, address _carol)
        public
    {
        // fails if any address is a duplicate
        if((msg.sender == _bob) || (msg.sender == _carol) || (_bob == _carol)) revert();

        users[0] = msg.sender;
        users[1] = _bob;
        users[2] = _carol;
    }

    modifier onlyIfKnownUser {
        require((msg.sender == users[0]) || (msg.sender == users[1]) || (msg.sender == users[2]));
        _;
    }

    modifier onlyIfNotPaused {
        require(!paused);
        _;
    }

    modifier onlyIfPaused {
        require(paused);
        _;
    }

    // Any of the three users in the contract can decide to pause or resume it, e.g. to manage
    // bugs. I am aware that the dynamics of this can be tricky, as - if the users became adversary
    // - one could revert the other's decision to pause or resume.
    // Original suggestion by @xavierlepretre at https://github.com/Digital-Contraptions-Imaginarium/B9Lab-ETH17-Splitter/commit/ec4bbdd1dd0705e07e5d9fb2299fb4080e60887f#r26085131
    function pause()
        public
        onlyIfKnownUser
        onlyIfNotPaused
        returns(bool)
    {
        paused = true;
        LogPause(msg.sender);
        return true;
    }

    function resume()
        public
        onlyIfKnownUser
        onlyIfPaused
        returns(bool)
    {
        paused = false;
        LogResume(msg.sender);
        return true;
    }

    function deposit()
        public
        onlyIfNotPaused
        onlyIfKnownUser
        payable
        returns(bool)
    {
        // can't send zero amount
        require(msg.value > 0);

        // note this is an integer division
        uint toBePaid = msg.value / uint(2);
        uint remainder = msg.value - toBePaid * 2;
        balances[users[0]] += (msg.sender != users[0]) ? toBePaid : remainder;
        balances[users[1]] += (msg.sender != users[1]) ? toBePaid : remainder;
        balances[users[2]] += (msg.sender != users[2]) ? toBePaid : remainder;
        LogDeposit(msg.sender, msg.value);
        return true;
    }

    function withdraw()
        public
        // I don't think I need the onlyIfKnownUser modifier here: the balance of unknown users will
        // always be zero, and the require statement will not allow an unknown user to create new
        // entries in the balances hash... so it is only the attacker's problem if they want to
        // waste gas; see also if this conversation clarifies what behaviour is best here
        // https://github.com/Digital-Contraptions-Imaginarium/B9Lab-ETH17-Splitter/commit/ec4bbdd1dd0705e07e5d9fb2299fb4080e60887f#r26085187
        onlyIfNotPaused
        returns(bool)
    {
        // proceed to withdraw only if the balance is positive, that also means that the msg.sender
        // address must be one of Alice, Bob of Carol
        require(balances[msg.sender] > 0);

        uint toTransfer = balances[msg.sender];
        balances[msg.sender] = 0;
        // NOTE: according to Rob https://github.com/Digital-Contraptions-Imaginarium/B9Lab-ETH17-Splitter/commit/ec4bbdd1dd0705e07e5d9fb2299fb4080e60887f#r26072127
        // it's important that transfer is last, so that it can revert
        // the zeroing of balances[msg.sender] above; I am not sure though, I've
        // asked him about this.
        msg.sender.transfer(toTransfer);
        LogWithdrawal(msg.sender, toTransfer);
        return true;
    }

}

pragma solidity ^0.4.15;

contract Splitter {

    bool public depositsAreSuspended;
    address[3] public users;
    mapping(address => uint) public balances;

    event LogDeposit(address userAddress, uint amount);
    event LogDepositSuspension(address userAddress);
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

    modifier onlyIfNotSuspended {
        require(!depositsAreSuspended);
        _;
    }

    // This is the contract's kill switch. Can be used by the original
    // contract creator only.
    function suspendDeposits()
        public
        onlyIfKnownUser
        onlyIfNotSuspended
        returns(bool)
    {
        depositsAreSuspended = true;
        LogDepositSuspension(msg.sender);
        return true;
    }

    function deposit()
        public
        onlyIfNotSuspended
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
        // onlyIfKnownUser modifier is not necessary because balance of unknown
        // users will always be zero
        returns(bool)
    {
        // proceed to withdraw if the balance is positive
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

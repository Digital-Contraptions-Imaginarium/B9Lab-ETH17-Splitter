pragma solidity ^0.4.15;

contract Splitter {

    address killer;
    bool killed = false;
    address[] knownAddresses;
    mapping(address => uint) balances;

    function Splitter(address _alice, address _bob, address _carol)
        public
    {
        // fails if any address is a duplicate
        if((_alice == _bob) || (_alice == _carol) || (_bob == _carol)) revert();

        killer = msg.sender;
        knownAddresses.push(_alice);
        knownAddresses.push(_bob);
        knownAddresses.push(_carol);
    }

    // This is the contract's kill switch. Can be used by the original
    // contract creator only.
    function kill()
        public
        returns(bool)
    {
        if(msg.sender != killer) revert();
        killed = true;
        return true;
    }

    function getBalance(address userAddress)
        public
        constant
        returns(uint)
    {
        // no need to check if userAddress is known: whatever the unknown
        // address, its balance will be zero!
        return balances[userAddress];
    }

    // returns true if msg.sender is one of the three addresses for which the
    // contract was created
    function senderIsKnown()
        private
        constant
        returns(bool)
    {
        for(uint i; (msg.sender != knownAddresses[i]) && (i < knownAddresses.length); i++) { }
        return i < knownAddresses.length;
    }

    // returns an array with the addresses of the contract beneficiaries,
    // excluding msg.sender
    function getEverybodyElse()
        private
        constant
        returns(address[2])
    {
        // fail if msg.sender is neither Alice, Bob or Carol
        if (!senderIsKnown()) revert();

        address[2] memory everybodyElse;
        uint j;
        for(uint i; i < knownAddresses.length; i++)
            if(msg.sender != knownAddresses[i])
                everybodyElse[j++] = knownAddresses[i];
        return everybodyElse;
    }

    function send()
        public
        payable
        returns(bool success)
    {
        // if it's dead, it's dead
        if(killed) revert();
        // can't send zero amount
        if (msg.value == 0) revert();
        // fail if msg.sender is neither Alice, Bob or Carol
        if (!senderIsKnown()) revert();

        // note this is an integer division
        uint toBePaid = msg.value / 2;
        address[2] memory beneficiaries = getEverybodyElse();
        balances[beneficiaries[0]] += toBePaid;
        balances[beneficiaries[1]] += toBePaid;
        // any remainder goes to the sender
        balances[msg.sender] += msg.value - toBePaid * 2;
        return true;
    }

    function withdraw()
        public
        returns(bool)
    {
        // if it's dead, it's dead
        if(killed) revert();
        // fail if msg.sender is neither Alice, Bob or Carol
        if (!senderIsKnown()) revert();

        // proceed to withdraw if the balance is positive
        if (balances[msg.sender] > 0) {
            msg.sender.transfer(balances[msg.sender]);
            balances[msg.sender] = 0;
        }
        return true;
    }

}

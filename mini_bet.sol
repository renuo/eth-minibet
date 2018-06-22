pragma solidity ^0.4.0;

contract MiniBet {
    struct Bet {
        string foretoldOutcome;
        uint wager;
        uint pool;
        bool closed;
        mapping(bool => address[]) expectedOutcomes;
    }

    Bet[] public bets;
    mapping(address => uint[]) publications;
    mapping(address => uint[]) participations;

    function MiniBet() {
        
    }
    
    function getMyPublications() constant returns (uint[]) {
        return publications[msg.sender];
    }
    
    function getMyParticipations() constant returns (uint[]) {
        return participations[msg.sender];
    }
    
    function publishBet(string _foretoldOutcome, uint _wagerInFinney) {
        Bet memory myBet = Bet(_foretoldOutcome, _wagerInFinney * 1e15, 0, false);
        uint position = bets.push(myBet) - 1;
        publications[msg.sender].push(position);
    }
    
    function takeBet(uint _betNr, bool _expectedOutcome) payable {
        var myBet = bets[_betNr];
        require(msg.value >= myBet.wager); // refund if entry fee is not met
        require(!myBet.closed);
        
        myBet.pool += msg.value;
        myBet.expectedOutcomes[_expectedOutcome].push(msg.sender);
        participations[msg.sender].push(_betNr);
    }
    
    function resolveBet(uint _betNr, bool _result) {
        var myBet = bets[_betNr];
        var winningAddresses = myBet.expectedOutcomes[_result];
        
        if (winningAddresses.length > 0) {
            uint share = myBet.pool / winningAddresses.length;
            
            for (uint i = 0; i < winningAddresses.length - 1; i++) {
                winningAddresses[i].transfer(share);
                myBet.pool -= share;
            }
        }
        
        myBet.closed = true;
        
        // rest goes to charity
        address charity = 0x0887A0A84dB1Cc437c8C690Dcf11b22D21FBC1E0;
        charity.send(myBet.pool); // deliberately not checking return value
    }
}

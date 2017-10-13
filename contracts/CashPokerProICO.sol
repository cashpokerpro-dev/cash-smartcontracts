pragma solidity ^0.4.15;


contract Token {
    uint256 public totalSupply;

    function balanceOf(address who) constant returns (uint256);

    function transferFrom(address _from, address _to, uint256 _value) returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() {
        owner = msg.sender;
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }

}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();

    event Unpause();

    bool public paused = false;


    /**
     * @dev modifier to allow actions only when the contract IS paused
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev modifier to allow actions only when the contract IS NOT paused
     */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() onlyOwner whenNotPaused {
        paused = true;
        Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() onlyOwner whenPaused {
        paused = false;
        Unpause();
    }
}


contract CashPokerProICO is Ownable, Pausable {
    using SafeMath for uint;

    /* The party who holds the full token pool and has approve()'ed tokens for this crowdsale */
    address public tokenWallet = 0x774d91ac35f4e2f94f0e821a03c6eaff8ad4c138;

    uint public tokensSold;

    uint public weiRaised;

    mapping (address => uint256) public purchasedTokens;

    uint public investorCount;

    Token public token = Token(0xA8F93FAee440644F89059a2c88bdC9BF3Be5e2ea);

    uint public constant minInvest = 0.01 ether;

    uint public constant tokensLimit = 60000000 ether;

    // start and end timestamps where investments are allowed (both inclusive)
    uint256 public startTime = 1503770400; // 26 August 2017

    uint256 public endTime = 1504893600; // 8 September 2017

    uint public price = 0.00017 ether;

    function CashPokerProICO(uint newStartTime, uint newEndTime, address newToken, address newTokenWallet){
        token = Token(newToken);
        tokenWallet = newTokenWallet;
        startTime = newStartTime;
        endTime = newEndTime;
    }


    /**
     * event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    // fallback function can be used to buy tokens
    function() payable {
        buyTokens(msg.sender);
    }

    // low level token purchase function
    function buyTokens(address beneficiary) whenNotPaused payable {
        require(startTime <= now && now <= endTime);

        uint weiAmount = msg.value;

        require(weiAmount >= minInvest);

        uint tokenAmountEnable = tokensLimit.sub(tokensSold);

        require(tokenAmountEnable > 0);

        uint tokenAmount = weiAmount / price * 1 ether;

        if (tokenAmount > tokenAmountEnable) {
            tokenAmount = tokenAmountEnable;
            weiAmount = tokenAmount * price / 1 ether;
            msg.sender.transfer(msg.value - weiAmount);
        }else{
            uint countBonusAmount = tokenAmount * getCountBonus(weiAmount) / 1000;
            uint timeBonusAmount = tokenAmount * getTimeBonus(now()) / 1000;

            tokenAmount += countBonusAmount + timeBonusAmount;

            if (tokenAmount > tokenAmountEnable) {
                tokenAmount = tokenAmountEnable;
            }
        }

        if (purchasedTokens[beneficiary] == 0) investorCount++;

        purchasedTokens[beneficiary] = purchasedTokens[beneficiary].add(tokenAmount);

        weiRaised = weiRaised.add(weiAmount);

        require(token.transferFrom(tokenWallet, beneficiary, tokenAmount));

        tokensSold = tokensSold.add(tokenAmount);

        TokenPurchase(msg.sender, beneficiary, weiAmount, tokenAmount);
    }

    uint[] etherForCountBonus = [2 ether, 3 ether, 5 ether, 7 ether, 9 ether, 12 ether, 15 ether, 20 ether, 25 ether, 30 ether, 35 ether, 40 ether, 45 ether, 50 ether, 60 ether, 70 ether, 80 ether, 90 ether, 100 ether, 120 ether, 150 ether, 200 ether, 250 ether, 300 ether, 350 ether, 400 ether, 450 ether, 500 ether];

    uint[] amountForCountBonus = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 90, 100, 105, 110, 115, 120, 125, 130, 135, 140, 145, 150];


    function getCountBonus(uint weiAmount) public constant returns (uint) {
        for (uint i = 0; i < etherForCountBonus.length; i++) {
            if (weiAmount < etherForCountBonus[i]) return amountForCountBonus[i];
        }
        return amountForCountBonus[amountForCountBonus.length - 1];
    }

    function getTimeBonus(uint time) public constant returns (uint) {
        if(time < startTime + 1 weeks) return 30;
        if(time < startTime + 2 weeks) return 20;
        if(time < startTime + 3 weeks) return 10;
        return 0;
    }

    function withdrawal(address to) onlyOwner {
        to.transfer(this.balance);
    }

    function transfer(address to, uint amount) onlyOwner {
        uint tokenAmountEnable = tokensLimit.sub(tokensSold);

        if (amount > tokenAmountEnable) amount = tokenAmountEnable;

        require(token.transferFrom(tokenWallet, to, amount));

        tokensSold = tokensSold.add(amount);
    }
}
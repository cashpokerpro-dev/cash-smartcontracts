pragma solidity ^0.4.13;


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

contract CashPokerProCrowdsale is Ownable, Pausable {
    using SafeMath for uint;

    /* The party who holds the full token pool and has approve()'ed tokens for this crowdsale */
    address public tokenWallet;

    uint public tokensSold;

    uint public weiRaised;

    uint public investorCount;

    Token public token;

    uint constant minInvest = 0.01 ether;

    uint constant tokensLimit = 70000000 * 1 ether;

    //8 September 2017, 18:00:00
    uint public presaleEnd = 1504893600;

    //26 August 2017, 26 October 2017, 31 October 2017, 5 November 2017, 10 November 2017, 14 November 2017, 18 November 2017

    uint[7] public stageStartDates = [1503770400, 1509040800, 1509472800, 1509904800, 1510336800, 1510682400, 1511028000];

    uint[7] prices = [0.00017 * 1 ether, 0.00135 * 1 ether, 0.00145 * 1 ether, 0.00155 * 1 ether, 0.00165 * 1 ether, 0.00175 * 1 ether, 0.0034 * 1 ether];

    uint[7] public stageLimits = [10000000 * 1 ether, 30000000 * 1 ether, 40000000 * 1 ether, 50000000 * 1 ether, 60000000 * 1 ether, 70000000 * 1 ether, 70000000 * 1 ether];


    function CashPokerProCrowdsale() {
        tokenWallet = msg.sender;
    }
    /**
     * event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    function setToken(address newToken) onlyOwner {
        token = Token(newToken);
    }

    function setTokenWallet(address newTokenWallet) onlyOwner {
        tokenWallet = newTokenWallet;
    }

    // fallback function can be used to buy tokens
    function() payable {
        buyTokens(msg.sender);
    }

    // low level token purchase function
    function buyTokens(address beneficiary) enableToSaleTime whenNotPaused payable {

        uint weiAmount = msg.value;

        require(weiAmount >= minInvest);

        uint stage = getStage();
        uint tokenAmountEnable = stageLimits[stage].sub(tokensSold);

        require(tokenAmountEnable > 0);

        uint price = prices[stage];

        uint tokenAmount = weiAmount / price * 1 ether;

        if (tokenAmount > tokenAmountEnable) {
            tokenAmount = tokenAmountEnable;
            weiAmount = tokenAmount * price / 1 ether;
            msg.sender.transfer(msg.value - weiAmount);
        }

        if (token.balanceOf(beneficiary) == 0) investorCount++;

        weiRaised = weiRaised.add(weiAmount);

        require(token.transferFrom(tokenWallet, beneficiary, tokenAmount));

        tokensSold = tokensSold.add(tokenAmount);

        TokenPurchase(msg.sender, beneficiary, weiAmount, tokenAmount);
    }

    function withdrawal(address to) onlyOwner {
        to.transfer(this.balance);
    }

    function transfer(address to, uint amount) onlyOwner {
        uint stage = getStage();
        uint tokenAmountEnable = stageLimits[stage].sub(tokensSold);

        if (amount > tokenAmountEnable) amount = tokenAmountEnable;

        require(token.transferFrom(tokenWallet, to, amount));

        tokensSold = tokensSold.add(amount);
    }

    modifier enableToSaleTime() {
        require(!(presaleEnd <= now && now < stageStartDates[1]));
        _;
    }

    function getStage() constant returns (uint){
        if (now < presaleEnd) return 0;
        for (uint i = 1; i < stageStartDates.length - 1; i++) {
            if (now < stageStartDates[i + 1] && tokensSold < stageLimits[i]) return i;
        }
        return stageStartDates.length - 1;
    }

}

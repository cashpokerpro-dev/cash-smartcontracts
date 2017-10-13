import ether from './helpers/ether'
import {advanceBlock} from './helpers/advanceToBlock'
import {increaseTimeTo, duration} from './helpers/increaseTime'
import latestTime from './helpers/latestTime'
import EVMThrow from './helpers/EVMThrow'

const BigNumber = web3.BigNumber

const should = require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(BigNumber))
    .should()


const CashPokerProToken = artifacts.require("./CashPokerProToken.sol");
const CashPokerProICO = artifacts.require("./CashPokerProICO.sol");


contract('CashPokerProToken', function ([owner, investor, investor0, investor1]) {
    const ether10 = web3.toWei(10);
    let cashPokerProToken;
    let cashPokerProICO;
    var startTime;

    beforeEach(async function () {
        startTime = latestTime();
        cashPokerProToken = await CashPokerProToken.new();
        cashPokerProICO = await CashPokerProICO.new(startTime, startTime + duration.weeks(1), cashPokerProToken.address, owner);
        await cashPokerProToken.approve(cashPokerProICO.address, web3.toWei(70000000));
    });

   /* it("only owner can withdrawal", async function () {
        await cashPokerProICO.withdrawal(investor1, {from: investor}).should.be.rejectedWith("invalid opcode");
    });

    it("only owner can transfer", async function () {
        await cashPokerProICO.transfer(investor1, 100, {from: investor}).should.be.rejectedWith("invalid opcode");
    });

    it("withdrawal", async function () {

        await cashPokerProICO.buyTokens(investor, {from: investor, value: web3.toWei(7)});

        var contractEthBefore = web3.eth.getBalance(cashPokerProICO.address);
        var investorEthBefore = web3.eth.getBalance(investor);
        await cashPokerProICO.withdrawal(investor);
        var investorEthAfter = web3.eth.getBalance(investor);
        var contractEthAfter = web3.eth.getBalance(cashPokerProICO.address);


        investorEthAfter.minus(investorEthBefore).should.be.bignumber.equal(contractEthBefore.minus(contractEthAfter));

        investorEthAfter.minus(investorEthBefore).should.be.bignumber.equal(new BigNumber(web3.toWei(7)));


        await cashPokerProICO.buyTokens(investor, {from: investor, value: web3.toWei(3)});
        await cashPokerProICO.buyTokens(investor, {from: investor, value: web3.toWei(8)});

        contractEthBefore = web3.eth.getBalance(cashPokerProICO.address);
        investorEthBefore = web3.eth.getBalance(investor);
        await cashPokerProICO.withdrawal(investor);
        investorEthAfter = web3.eth.getBalance(investor);
        contractEthAfter = web3.eth.getBalance(cashPokerProICO.address);


        investorEthAfter.minus(investorEthBefore).should.be.bignumber.equal(contractEthBefore.minus(contractEthAfter));
        investorEthAfter.minus(investorEthBefore).should.be.bignumber.equal(new BigNumber(web3.toWei(11)));
    });

    it("buy token sum", async function () {
        let oldOwnerBalance = await cashPokerProToken.balanceOf(owner);
        //console.log(web3.fromWei(web3.eth.getBalance(investor)).toNumber());

        await cashPokerProICO.buyTokens(investor, {from: investor, value: ether10});

        let investorBalance = await cashPokerProToken.balanceOf(investor);
        let newOwnerBalance = await cashPokerProToken.balanceOf(owner);

        newOwnerBalance.plus(investorBalance).should.be.bignumber.equal(oldOwnerBalance);
    });
    it("investorCount", async function () {

        await cashPokerProICO.buyTokens(investor, {from: investor, value: ether10});
        await cashPokerProICO.buyTokens(investor, {from: investor, value: ether10});
        await cashPokerProICO.buyTokens(investor1, {from: investor1, value: ether10});
        await cashPokerProICO.buyTokens(investor1, {from: investor1, value: ether10});
        await cashPokerProICO.buyTokens(investor, {from: investor1, value: ether10});
        await cashPokerProICO.buyTokens(investor, {from: investor1, value: ether10});
        await cashPokerProICO.buyTokens(investor1, {from: investor, value: ether10});
        await cashPokerProICO.buyTokens(investor1, {from: investor, value: ether10});

        //let investorBalance = await cashPokerProToken.balanceOf(investor);
        //console.log(investorBalance.toNumber());

        let investorCount = await cashPokerProICO.investorCount();
        investorCount.should.be.bignumber.equal(new BigNumber(2));

    });

    it("minInvest", async function () {
        await cashPokerProICO.buyTokens(investor, {
            from: investor,
            value: web3.toWei(0.001)
        }).should.be.rejectedWith("invalid opcode");
    });*/

    it("countBonus", async function () {
        ((await cashPokerProICO.getCountBonus(web3.toWei(1)))).should.be.bignumber.equal(new BigNumber(0));
        ((await cashPokerProICO.getCountBonus(web3.toWei(2)))).should.be.bignumber.equal(new BigNumber(5));
    });



});
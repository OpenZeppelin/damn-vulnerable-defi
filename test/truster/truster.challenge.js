const { ether } = require('@openzeppelin/test-helpers');
const { accounts, contract } = require('@openzeppelin/test-environment');

const DamnValuableToken = contract.fromArtifact('DamnValuableToken');
const TrusterLenderPool = contract.fromArtifact('TrusterLenderPool');

const { expect } = require('chai');

describe('[Challenge] Truster', function () {

    const [deployer, attacker, ...otherAccounts] = accounts;

    const TOKENS_IN_POOL = ether('1000000');

    before(async function () {
        /** SETUP SCENARIO */
        this.token = await DamnValuableToken.new({ from: deployer });
        this.pool = await TrusterLenderPool.new(this.token.address, { from: deployer });

        await this.token.transfer(this.pool.address, TOKENS_IN_POOL, { from: deployer });

        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.be.bignumber.equal(TOKENS_IN_POOL);

        expect(
            await this.token.balanceOf(attacker)
        ).to.be.bignumber.equal('0');
    });

    it('Exploit', async function () {
        /** YOUR EXPLOIT GOES HERE */
    });

    after(async function () {
        /** SUCCESS CONDITIONS */
        expect(
            await this.token.balanceOf(attacker)
        ).to.be.bignumber.equal(TOKENS_IN_POOL);        
        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.be.bignumber.equal('0');
    });
});

const { ether, BN, balance } = require('@openzeppelin/test-helpers');
const { accounts, contract, web3 } = require('@openzeppelin/test-environment');
const { expect } = require('chai');

// Hacky way to easily get the Uniswap v1 contracts as artifacts
// These were taken straight from https://github.com/Uniswap/uniswap-v1/tree/c10c08d81d6114f694baa8bd32f555a40f6264da/abi 
contract.artifactsDir = 'build-uniswap-v1';
const UniswapExchange = contract.fromArtifact('UniswapV1Exchange');
const UniswapFactory = contract.fromArtifact('UniswapV1Factory');

// Now get the rest of the contracts from the usual directory
contract.artifactsDir = 'build/contracts';
const DamnValuableToken = contract.fromArtifact('DamnValuableToken');
const PuppetPool = contract.fromArtifact('PuppetPool');


// Calculates how much ETH (in wei) Uniswap will pay for the given amount of tokens
function calculateTokenToEthInputPrice(tokensSold, tokensInReserve, etherInReserve) {
    return tokensSold.mul(new BN('997')).mul(etherInReserve).div(
        (tokensInReserve.mul(new BN('1000')).add(tokensSold.mul(new BN('997'))))
    )
}

describe('[Challenge] Puppet', function () {
    const [deployer, attacker] = accounts;

    // Uniswap exchange will start with 10 DVT and 10 ETH in liquidity
    const UNISWAP_INITIAL_TOKEN_RESERVE = ether('10');
    const UNISWAP_INITIAL_ETH_RESERVE = ether('10');

    const POOL_INITIAL_TOKEN_BALANCE = ether('10000');
    const ATTACKER_INITAL_TOKEN_BALANCE = ether('100');

    before(async function () {
        /** SETUP SCENARIO */

        // Deploy token to be traded in Uniswap
        this.token = await DamnValuableToken.new({ from: deployer });

        // Deploy a exchange that will be used as the factory template
        this.exchangeTemplate = await UniswapExchange.new({from: deployer});

        // Deploy factory, initializing it with the address of the template exchange
        this.uniswapFactory = await UniswapFactory.new({ from: deployer });
        await this.uniswapFactory.initializeFactory(this.exchangeTemplate.address, {from: deployer});

        // Create a new exchange for the token, and retrieve the deployed exchange's address
        const { logs } = await this.uniswapFactory.createExchange(this.token.address, { from: deployer });
        this.uniswapExchange = await UniswapExchange.at(logs[0].args.exchange);

        // Deploy the lending pool
        this.lendingPool = await PuppetPool.new(
            this.token.address,
            this.uniswapExchange.address,
            { from: deployer }
        );
    
        // Add initial token and ETH liquidity to the pool
        await this.token.approve(
            this.uniswapExchange.address,
            UNISWAP_INITIAL_TOKEN_RESERVE,
            { from: deployer }
        );
        const deadline = (await web3.eth.getBlock('latest')).timestamp * 2;
        await this.uniswapExchange.addLiquidity(
            0, // min_liquidity
            UNISWAP_INITIAL_TOKEN_RESERVE,
            deadline,
            { from: deployer, value: UNISWAP_INITIAL_ETH_RESERVE }
        );

        // Ensure Uniswap exchange is working as expected
        expect(
            await this.uniswapExchange.getTokenToEthInputPrice(ether('1'))
        ).to.be.bignumber.eq(
            calculateTokenToEthInputPrice(
                ether('1'),
                UNISWAP_INITIAL_TOKEN_RESERVE,
                UNISWAP_INITIAL_ETH_RESERVE
            )
        );

        // Setup initial token balances of pool and attacker account
        await this.token.transfer(attacker, ATTACKER_INITAL_TOKEN_BALANCE, { from: deployer });
        await this.token.transfer(this.lendingPool.address, POOL_INITIAL_TOKEN_BALANCE, { from: deployer });

        // Rate should be 1:1
        expect(await this.lendingPool.computeOraclePrice()).to.be.bignumber.eq('1');

        // Track attacker's initial ETH balance (to ensure it doesn't decrease)
        this.intialAttackerEthBalance = await balance.current(attacker);
    });

    it('Exploit', async function () {
        /** YOUR EXPLOIT GOES HERE */
    });

    after(async function () {
        /** SUCCESS CONDITIONS */
        
        // Attacker has stolen all tokens from the pool
        expect(
            await this.token.balanceOf(attacker)
        ).to.be.bignumber.gte(POOL_INITIAL_TOKEN_BALANCE);
        expect(
            await this.token.balanceOf(this.lendingPool.address)
        ).to.be.bignumber.eq('0');
        
        // Attacker ETH balance has not decreased
        expect(
            await balance.current(attacker)
        ).to.be.bignumber.gte(this.intialAttackerEthBalance);
    });
});
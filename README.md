# Easy-Flash-Loan-Arbitrage-Attack-Contract
This repo includes all the smart contracts and steps to learn and deploy a smart contract that will request an AAVE flash loan then use the funds to execute an arbitrage attack.

<img src="https://github.com/net2devcrypto/misc/blob/main/IMG_7201.PNG" width="650" height="370">

> [!NOTE]  
> THE FILES ATTACHED TO THIS REPO ARE FOR EDUCATIONAL PURPOSES ONLY.
> NOT FINANCIAL ADVICE
> USE IT AT YOUR OWN RISK, I'M NOT RESPONSIBLE FOR ANY USE, ISSUES.

<h3>Repo Instructions</h3>

Tutorial Video:

<a href="https://youtu.be/7db31q6G60o" target="_blank"><img src="https://github.com/net2devcrypto/misc/blob/main/ytlogo2.png" width="150" height="40"></a>

Repo Contents:

```shell
N2D_Sample_AAVE_Flash_Loan_Contract.sol
N2D_Sample_AAVE_Flash_Loan_SWAP_Attack_Contract.sol
```

> [!NOTE]  
> !!!! PLEASE DO NOT EXECUTE THE STEPS ON A MAINNET, ONLY ON A TESTNET !!!!!
> I'M NOT RESPONSIBLE FOR ANY USE, LOSS OF FUNDS OR ANY OTHER ISSUES.

#Practice requesting a Flash Loan:

1- Go to the AAVE Testnet Faucet and request some test tokens ( Please watch tutorial video for full guidance ).

2- Go to Cookbook.dev then search for the AAVE Flash loan Attacker Contract, open it then click open in Remix.

3- Replace the entire contract code with the code found in the N2D_Sample_AAVE_Flash_Loan_Contract.sol contract on this repo.

4- Copy the AAVE Testnet PoolAddressesProvider Smart Contract Address

    https://docs.aave.com/developers/deployed-contracts/v3-testnet-addresses

5- Deploy the smart contract by providing the PoolAddressProvider address obtain on step 4.

6- Send some test USDC tokens obtained in step 1 to the smart contract deployed on step 5.

7- Test requesting a flash loan by executing requestFlashLoan and providing:

    ```shell
    _token - this is the AAVE Testnet USDC token contract address
    _amount - the amount to request on the loan. Remember USDC is 6 decimals so if requesting 10 USDC the value is 10000000
    ```
8- Confirm that the loan was obtained by looking at the transaction on the block explorer.

#Practice a Flash Loan SWAP Attack 

I STRONGLY RECOMMEND WATCHING THE TUTORIAL VIDEO, DO NOT PERFORM ON A MAINNET, ONLY ON TESTNET !!!

The file with the full code of the section is : N2D_Sample_AAVE_Flash_Loan_SWAP_Attack_Contract.sol

Watch the tutorial video for full guidance.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract ChocolateShop {
    uint256 private totalChocolates;
    uint256 private totalTrx;
    mapping(uint256 => int) trxs;

    // this function allows gavin to buy n chocolates
    function buyChocolates(uint n) public {
        ++totalTrx;
        trxs[totalTrx] = int(n);
        totalChocolates += n;
    }

    // this function allows gavin to sell n chocolates
    function sellChocolates(uint n) public {
        ++totalTrx;
        trxs[totalTrx] = int(-int(n));
        totalChocolates -= n;
    }

    // this function returns total chocolates present in bag
    function chocolatesInBag() public view returns(int n){
        n = int(totalChocolates);
    }

    // this function returns the nth transaction
    function showTransaction(uint n) public view returns(int Trx) {
      require(n <= totalTrx);
      Trx = trxs[n];
    }

    //this function returns the total number of transactions
    function numberOfTransactions() public view returns(uint) {
        return totalTrx;
    }

}
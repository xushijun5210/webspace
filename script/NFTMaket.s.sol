// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {NFTMarket} from "../src/token/NFTMarket.sol";
import {ERC721Mock} from "../src/token/ERC721Mock.sol";
import {ERC20Mock} from "../src/token/ERC20Mock.sol";

contract NFTMaketScript is Script {
    function setUp() public {}
    function run() public {
        //vm.broadcast();
        vm.startBroadcast();
        NFTMarket mkt = new NFTMarket();
        ERC721Mock nft = new ERC721Mock("NFT","nft");
        ERC20Mock token = new ERC20Mock("MYTOKEN","mytoken");
        address alice = 0x33C901956Aa770CEEFdCBb605883f47c5A48d83c;
        nft.mint(alice,1);
        token.mint(alice,1000);
        mkt.list(address(nft),1,1000);
        // token.approve(address(mkt),1000);
        // nft.setApprovalForAll(address(mkt),true);//alice授权mkt可以买NFT
        // mkt.buyNFT(address(nft),1,address(token));
    }
}
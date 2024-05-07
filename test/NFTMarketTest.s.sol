// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;
import {Test, console} from "forge-std/Test.sol";
import {NFTMarket} from "../src/token/NFTMarket.sol";
import {ERC721Mock} from "../src/token/ERC721Mock.sol";
import {ERC20Mock} from "../src/token/ERC20Mock.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../src/common/TestBase.sol";
contract MyNFTMarketTest is Test {
    NFTMarket mkt;
    ERC721Mock nft;
    ERC20Mock token;
    //
    address alice = makeAddr("alice");
    //准备要测试的数据
    function setUp() public {
        mkt = new NFTMarket();
        nft = new ERC721Mock("MYTOKEM","mynft");
        token = new ERC20Mock("MYTOKEN","mytoken");
        //切换到alice用户
        vm.prank(alice);
        //以alice的身份运行
        nft.mint(alice,1);
        token.mint(alice,1e18);
    }
    //测试如果没有授权NFT，则无法list成功
    function testFailel_needApproveFirst() public {
        uint256 tokenId = 1;
        vm.prank(alice);
        mkt.list(address(nft),tokenId,1000);
    }
   function test_listNFT()public{
       ListNft(alice,nft,1,1000);
   }
   //模糊测试 测试价格的边界
   function test_listNFTRandom(uint256 price)public{
       //希望测试价格大于
       vm.assume(price > 1e18);
       ListNft(alice,nft,1,price); 
   }
   //方法封装
   function ListNft(address who,ERC721Mock nft2,uint256 tokenId,uint256 price) public {
        vm.startPrank(who);//alice买家
        nft2.setApprovalForAll(address(mkt),true);//alice授权mkt
        mkt.list(address(nft2),tokenId,price);
        vm.stopPrank();//结束alice
        
        //检查list数据是否正确
        assertEq(mkt.getOwner(address(nft2),tokenId), who,"order ower check");
        assertEq( mkt.getPrice(address(nft2),tokenId),price,"order ower check");
   }
   //测试buyNFT
   function test_buyNFT() public {
      address zhangsan = makeAddr("zhangsan");
      uint256 price = 1000;
      vm.prank(zhangsan);
      token.approve(address(mkt),price);
      token.mint(zhangsan,price);
      ListNft(alice,nft,1,price);
      buyNFT(zhangsan,nft,1,token);
   }
   //买家和卖家不能是同一个人
   function testBuyerNotEqualSeller()public{
       address zhangsan = makeAddr("zhangsan");
       uint256 price = 1000;
       uint256 tokenId = 1;
       ListNft(alice,nft,1,price);
       vm.startPrank(zhangsan);
       vm.expectRevert("Owner can't buy");
       mkt.buyNFT(address(nft),tokenId,address(token));
       vm.stopPrank();
   }
    //是否授权
   function testNeedApprove()public{
       address zhangsan = makeAddr("zhangsan");
       uint256 price = 1000;
       uint256 tokenId = 1;
       vm.prank(zhangsan);
       token.approve(address(mkt),price);
       token.mint(zhangsan,price);
       ListNft(alice,nft,1,price);
       vm.startPrank(alice);
       vm.expectRevert("Insufficient balance");
       token.mint(zhangsan,price);
       mkt.buyNFT(address(nft),tokenId,address(token));
       vm.stopPrank();
   }
   function buyNFT(address who,ERC721Mock nft2,uint256 tokenId,ERC20Mock paymentToken)private{
      vm.startPrank(who);
      address seller = mkt.getOwner(address(nft2),tokenId);
      uint256 balance = paymentToken.balanceOf(seller);
      uint256 price = mkt.getPrice(address(nft2),tokenId);
      mkt.buyNFT(address(nft2),tokenId,address(paymentToken));
      uint256 balanceAfer = paymentToken.balanceOf(seller);
      assertEq(balance+price,balanceAfer,"expect seller bablance increase");
      assertEq(nft2.ownerOf(tokenId),who,"expect nft owner buyer");
      vm.stopPrank();
   }
   //断言在下一次调用期间发出特定日志emit
   // emit Transfer(from, to, value);
   function testTokenTransferEvent() public {
     //event Transfer(address indexed from, address indexed to, uint256 value);
     address zhangsan = makeAddr("zhangsan");
     //全部匹配
     vm.expectEmit();
     emit Transfer(alice,zhangsan,1000);
     vm.prank(alice);
     token.transfer(zhangsan,1000);
     //部分匹配
     vm.expectEmit(true,true,false,false);
     emit Transfer(alice,zhangsan,1000);
     vm.prank(alice);
     token.transfer(zhangsan,1000);
     //测试一次call中的多个事件，只需要按事件顺序定义即可
     uint256 times = 10;
     for (uint i = 0; i < times; i++) {
        vm.expectEmit();
        emit Transfer(address(0),zhangsan,1000);
        token.mint(zhangsan,1000);
     }
   }
}
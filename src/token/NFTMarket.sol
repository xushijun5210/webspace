// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
import{ERC20Mock} from "./ERC20Mock.sol";
import{ERC721Mock} from "./ERC721Mock.sol";
contract NFTMarket {
    ERC20Mock tokenContract;
    ERC721Mock NFTContract;
    constructor(){
        NFTContract = new ERC721Mock("MYTOKEM","mynft");
        tokenContract = new ERC20Mock("MYTOKEN","mytoken");
    }
     struct listUser {
        address owner;
        uint256 listPrice;
    }
    mapping(address => mapping(uint256 => listUser)) private marketList;

    function list(address contractAddress,uint256 tokenId,uint256 listPrice) public {
        NFTContract = ERC721Mock(contractAddress);
        NFTContract.safeTransferFrom(msg.sender, address(this), tokenId);
        marketList[contractAddress][tokenId].owner = msg.sender;
        marketList[contractAddress][tokenId].listPrice = listPrice;
    }

    function buyNFT(address contractAddress,uint256 tokenId,address payErc20Contract) public {
        require(getOwner(contractAddress,tokenId)!= msg.sender,"Owner can't buy");
        tokenContract =ERC20Mock(payErc20Contract);
        NFTContract = ERC721Mock(contractAddress);
        uint256 price = marketList[contractAddress][tokenId].listPrice;
        require(tokenContract.allowance(msg.sender, address(this)) >= price,"Insufficient authorization limit");
        require(tokenContract.balanceOf(msg.sender) >= price,"Insufficient balance");
        require(tokenContract.transferFrom(msg.sender,marketList[contractAddress][tokenId].owner,
             marketList[contractAddress][tokenId].listPrice),
            "Token Transfer fail");
        NFTContract.safeTransferFrom(address(this), msg.sender, tokenId);
        marketList[contractAddress][tokenId].owner = address(0);
        marketList[contractAddress][tokenId].listPrice = 0;
    }
    //查询价格
    function getPrice(address contractAddress, uint256 tokenId)public view returns (uint256){
        return marketList[contractAddress][tokenId].listPrice;
    }
   //查询所有者
    function getOwner(address contractAddress, uint256 tokenId)public view returns (address){
        return marketList[contractAddress][tokenId].owner;
    }
    //处理 ERC721 购买接收的回调
    function onERC721BuyReceived(address contractAddress,address buyUser,uint256 tokenId,bytes calldata ) external returns (bool) {
        NFTContract = ERC721Mock(contractAddress);
        NFTContract.safeTransferFrom(address(this), buyUser, tokenId);
        marketList[contractAddress][tokenId].owner = address(0);
        marketList[contractAddress][tokenId].listPrice = 0;
        return true;
    }
    //实现了 ERC721 接收的固定回调逻辑。
    function onERC721Received(address,address,uint256,bytes memory) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
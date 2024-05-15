// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
/**
 * @title 编写一个 Bank 存款合约，实现功能：
 * 可以通过 Metamask 等钱包直接给 Bank 合约地址存款
 * 在 Bank 合约里记录了每个地址的存款金额
 * 用可迭代的链表保存存款金额的前 10 名用户
 * @author 
 * @notice 
 */
contract Bank {
    //存地址和分数
    mapping(address => uint256) public balances;
    // mapping (address => address) 
    mapping(address => address) _nextAdrress;
     //前10名地址和分数
    uint256 public listSize;
    address constant GUARD = address(1);
    constructor(){
        _nextAdrress[GUARD] = GUARD;
    }
    function deposit() external payable {

        balances[msg.sender] += msg.value;
        addAddress(msg.sender, balances[msg.sender]);
    }
    function addAddress(address userAddr, uint256 newAmount) private {
        require(_nextAdrress[userAddr] == address(0),"XXXXXS");
        address index = _findIndex(newAmount);
        balances[userAddr] = newAmount;
        _nextAdrress[userAddr] = _nextAdrress[index];
        _nextAdrress[index] = userAddr;
        listSize++;
    }
     function getupdateTop10(uint256 k) public view returns (address[] memory){
          require(k <= listSize);
          address[] memory addressList = new address[](k);
          address currentAddress = _nextAdrress[GUARD];
          for(uint256 i =0; i<k;++i){
            addressList[i] = currentAddress;
            currentAddress = _nextAdrress[currentAddress];
          }
          return addressList;
     }
       //检测index
    function _verifyIndex(address prevAddress,uint256 newValue, address nextAdrress) 
     internal view returns(bool){
        return (prevAddress == GUARD ||balances[prevAddress] >= newValue) && 
        (nextAdrress == GUARD || newValue >balances[nextAdrress]);
    }
     //验证索引函数\
    function _findIndex(uint256 newValue) internal view returns(address) {
            address candidateAddress = GUARD;
           while(true) {
               bool obj = _verifyIndex(candidateAddress, newValue, _nextStudents[candidateAddress]);
              if(obj){
                  return candidateAddress;
              }else {
                   return candidateAddress = _nextStudents[candidateAddress];
              }
               
            }
    }
}
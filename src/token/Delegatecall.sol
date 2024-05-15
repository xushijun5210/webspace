// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
/***
*
*
*
*
*
**/
interface TokenFace {
    function inc()external;
    function dec()external ;
}
contract Token{
    address public owner;
    uint public a;
    function setToken(address _imp)external {
       owner = _imp;
    }
    fallback() external payable { 
        (bool successe,bytes memory data) = owner.delegatecall(msg.data);
        if(!successe)
           revert("failed");
    }
}

contract v1{
    address public owner;
    uint public a;
    function inc() external {
        a +=1;
    }
}
contract v2{
    address public owner;
    uint public a;
    function inc() external {
        a +=1;
    }
    function dec() external {
        a -= 1;
    }
}
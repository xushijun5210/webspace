// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
library SafeMath { 
   function safeAdd(uint256 a,uint256 b) internal pure  returns (uint256){
      uint256 c= a + b;
      assert(c>=a && c >= b);
      return c;
   }
   function safeSub(uint256 a,uint256 b) internal pure  returns (uint256){
     assert(b <= a);
     return a -b;
   }
   function safeMul(uint256 a,uint256 b) internal pure  returns (uint256){
      uint256 c= a * b;
      assert(a == 0 || c / a == b);
      return c;
   }
   function safeDiv(uint256 a,uint256 b) internal pure  returns (uint256){
      assert(b > 0);
      uint256  c = a / b;
      assert(a == b * c + a % b);
      return c;
   }
}
contract MyToken {
    string public name = "OpenSpace";
    string public symbol = "OS";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address public owner;
    mapping(address => mapping(address => uint256)) public allowed;
     /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
	mapping (address => uint256) public freezeOf;
     /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* This notifies clients about the amount burnt */
    event Burn(address indexed from, uint256 value);
	
	/* This notifies clients about the amount frozen */
    event Freeze(address indexed from, uint256 value);
	
	/* This notifies clients about the amount unfrozen */
    event Unfreeze(address indexed from, uint256 value);
    // event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    constructor(uint256 initialSupply) {
        totalSupply = initialSupply;
        balanceOf[msg.sender] = initialSupply; 
        owner = msg.sender;
    }
    /* Send coins */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_value > 0, "value < 0");
        require(balanceOf[msg.sender] >= _value, "Check if the sender has enough");
        require(balanceOf[_to] + _value > balanceOf[_to],"Check for overflows");
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                     // Subtract from the sender
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                            // Add the same to the recipient
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
     /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_value >= 0, "value < 0");
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    /* */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value > 0, "value can,t 0");
        require(allowed[ _from][msg.sender] >= _value, "Insufficient allowance");
        balanceOf[ _from] = SafeMath.safeSub(balanceOf[ _from], _value);                     // Subtract from the sender
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);
        allowed[msg.sender][ _from] = SafeMath.safeSub(allowed[msg.sender][ _from], _value);   
        emit Transfer(_from, _to, _value);
        return true;
    }
    /*Destroy tokens */
    function burn(uint256 _value) public returns (bool success) {
        require(owner == msg.sender,"not owner");
        require(_value > 0, "value can,t 0");
        require(balanceOf[msg.sender] >= _value, "Subtract from the sender");
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value); 
        totalSupply = SafeMath.safeSub(totalSupply,_value);
        emit Burn(msg.sender, _value);  
        return true;
    }
    function freeze(uint256 _value) public  returns (bool success) {
        require(_value > 0, "value can,t 0");
        require(balanceOf[msg.sender] >= _value, "Subtract from the sender");
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                      // Subtract from the sender
        freezeOf[msg.sender] = SafeMath.safeAdd(freezeOf[msg.sender], _value);                                // Updates totalSupply
        emit Freeze(msg.sender, _value);
        return true;
    }
    function unfreeze(uint256 _value) public  returns (bool success) {
        require(_value > 0, "value can,t 0");
        require(freezeOf[msg.sender] >= _value, "Subtract from the sender");
        freezeOf[msg.sender] = SafeMath.safeSub(freezeOf[msg.sender], _value);                      // Subtract from the sender
		balanceOf[msg.sender] = SafeMath.safeAdd(balanceOf[msg.sender], _value);
        emit Unfreeze(msg.sender, _value);
        return true;
    }
    /*transfer balance to owner*/
    function withdrawEther(uint256 amount) public  payable {
		require(owner != msg.sender,"not owner");
		transfer(owner,amount);
	}
}
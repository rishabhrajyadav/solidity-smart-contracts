// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IERC1155Receiver {
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

     function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

contract ERC1155 {
    mapping(address => mapping(uint256 => uint256)) public balaceOf;
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    function safeTransferFrom(address from, address to, uint256 id , uint256 value, bytes memory data) external {
       require(to != address(0), "to is zero address");
       require(msg.sender == from || isApprovedForAll[from][msg.sender]);

       balaceOf[from][id] -= value;
       balaceOf[to][id] += value;

      if(to.code.length > 0){
         require(IERC1155Receiver(to)
         .onERC1155Received(msg.sender,from,id,value,data)
          ==  IERC1155Receiver.onERC1155Received.selector,"unsafe transfer");
      }
    }
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids , uint256[] calldata values, bytes memory data) external {
      require(to != address(0), "to is zero address");
      require(msg.sender == from || isApprovedForAll[from][msg.sender]);
      require(ids.length == values.length,"ids length != values length");
      
      for (uint i = 0; i < ids.length; i++) 
      {
        balaceOf[from][ids[i]] -= values[i];
        balaceOf[to][ids[i]] += values[i];
      }

      if(to.code.length > 0){
         require(IERC1155Receiver(to)
         .onERC1155BatchReceived(msg.sender,address(0),ids,values,data)
          ==  IERC1155Receiver.onERC1155BatchReceived.selector,"unsafe transfer");
      }
    }
    
     function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata ids
    ) external view returns (uint256[] memory balances){
      require(accounts.length == ids.length, "accouts length != ids length");
      
      balances = new uint256[](ids.length);

      for(uint256 i = 0; i < ids.length; i++){
        balances[i] = balaceOf[accounts[i]][ids[i]];
      }
    }

     function setApprovalForAll(address operator, bool approved) external{
       isApprovedForAll[msg.sender][operator] = approved;
     }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
      return interfaceId == 0x01ffc9a7 ||
             interfaceId == 0xd9b67a2c ||
             interfaceId == 0x0e89341c;
             }

    function _mint(address to, uint256 id , uint256 value, bytes memory data) internal{
      require(to != address(0), "to is zero address");
      balaceOf[to][id] += value;

      if(to.code.length > 0){
         require(IERC1155Receiver(to)
         .onERC1155Received(msg.sender,address(0),id,value,data)
          ==  IERC1155Receiver.onERC1155Received.selector,"unsafe transfer");
      }
    }   

    function _batchMint(address to, uint256[] calldata ids , uint256[] calldata values , bytes memory data) internal {
      require(to != address(0), "to is zero address");
      require(ids.length == values.length,"ids length != values length");
      
      for (uint i = 0; i < ids.length; i++) 
      {
        balaceOf[to][ids[i]] += values[i];
      }

      if(to.code.length > 0){
         require(IERC1155Receiver(to)
         .onERC1155BatchReceived(msg.sender,address(0),ids,values,data)
          ==  IERC1155Receiver.onERC1155BatchReceived.selector,"unsafe transfer");
      }
    }      

    function _burn(address from, uint256 id,uint256 value) internal {
      require(from != address(0), "from is zero address");
      balaceOf[from][id] -= value;
    }

     function _batchBurn(address from, uint256[] calldata ids , uint256[] calldata values) internal {
      require(from != address(0), "from is zero address");
      require(ids.length == values.length,"ids length != values length");
      
      for (uint i = 0; i < ids.length; i++) 
      {
        balaceOf[from][ids[i]] -= values[i];
      }
      
      }
}

contract MyMultiToken is ERC1155{
  function mint(uint256 id , uint256 value, bytes memory data) external {
    _mint(msg.sender, id, value, data);
  }
  function batchMint(uint256[] calldata ids , uint256[] calldata values , bytes memory data) external {
    _batchMint(msg.sender, ids, values, data);
  }
  function burn(uint256 id , uint256 value) external {
    _burn(msg.sender, id, value);
  }
  function batchBurn(uint256[] calldata ids , uint256[] calldata values) external {
    _batchBurn(msg.sender, ids, values);
  }
}
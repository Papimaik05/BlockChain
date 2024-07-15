// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface ERC721simplified {
  // EVENTS
  event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

  // APPROVAL FUNCTIONS
  function approve(address _approved, uint256 _tokenId) external payable;

  // TRANSFER FUNCTION
  function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

  // VIEW FUNCTIONS (GETTERS)
  function balanceOf(address _owner) external view returns (uint256);
  function ownerOf(uint256 _tokenId) external view returns (address);
  function getApproved(uint256 _tokenId) external view returns (address);
}

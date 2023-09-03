// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./bayc//IERC721.sol";
import "./bayc//IERC721Receiver.sol";
import "./bayc//WTFApe.sol";

contract NFTSwap is IERC721Receiver {
    event List(
        address indexed seller,
        address indexed nftAddr,
        uint256 indexed tokenId,
        uint256 price
    );
    event Purchase(
        address indexed buyer,
        address indexed nftAddr,
        uint256 indexed tokenId,
        uint256 price
    );
    event Revoke(
        address indexed seller,
        address indexed nftAddr,
        uint256 indexed tokenId
    );
    event Update(
        address indexed seller,
        address indexed nftAddr,
        uint256 indexed tokenId,
        uint256 newPrice
    );

    
    struct Order {
        address owner;
        uint256 price;
    }
    // NFT Order映射
    mapping(address => mapping(uint256 => Order)) public nftList;

    fallback() external payable {}

    //掛單: 賣家上架NFT，合約地址為_nftAddr，tokenId為_tokenId，價格_price為以太坊（單位是wei）
    function list(address _nftAddr, uint256 _tokenId, uint256 _price) public {
        IERC721 _nft = IERC721(_nftAddr); 
        require(_nft.getApproved(_tokenId) == address(this), "Need Approval"); 
        require(_price > 0); 

        Order storage _order = nftList[_nftAddr][_tokenId]; //設置NF持有人和價格
        _order.owner = msg.sender;
        _order.price = _price;
        // 將NFT轉賬到合約
        _nft.safeTransferFrom(msg.sender, address(this), _tokenId);

        emit List(msg.sender, _nftAddr, _tokenId, _price);
    }

    // 購買: 買家購買NFT，合約為_nftAddr，tokenId為_tokenId，調用函數時要附帶ETH
    function purchase(address _nftAddr, uint256 _tokenId) public payable {
        Order storage _order = nftList[_nftAddr][_tokenId]; 
        require(_order.price > 0, "Invalid Price"); 
        require(msg.value >= _order.price, "Increase price"); 
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order"); // NFT在合約中

        // 將NFT轉給買家
        _nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        // 將ETH轉給賣家，多餘ETH給買家退款
        payable(_order.owner).transfer(_order.price);
        payable(msg.sender).transfer(msg.value - _order.price);

        delete nftList[_nftAddr][_tokenId]; // 删除order

        emit Purchase(msg.sender, _nftAddr, _tokenId, _order.price);
    }

    // 撤單： 賣家取消掛單
    function revoke(address _nftAddr, uint256 _tokenId) public {
        Order storage _order = nftList[_nftAddr][_tokenId]; 
        require(_order.owner == msg.sender, "Not Owner"); 

        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order"); 

        // 將NFT轉給賣家
        _nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        delete nftList[_nftAddr][_tokenId]; // 删除order

        emit Revoke(msg.sender, _nftAddr, _tokenId);
    }

    // 調整價格: 賣家調整掛單價格
    function update(
        address _nftAddr,
        uint256 _tokenId,
        uint256 _newPrice
    ) public {
        require(_newPrice > 0, "Invalid Price"); 
        Order storage _order = nftList[_nftAddr][_tokenId]; 
        require(_order.owner == msg.sender, "Not Owner"); 
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order"); 

        // 調整NFT價格
        _order.price = _newPrice;
        emit Update(msg.sender, _nftAddr, _tokenId, _newPrice);
    }

    // 实现{IERC721Receiver}的onERC721Received，能够接收ERC721代币
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
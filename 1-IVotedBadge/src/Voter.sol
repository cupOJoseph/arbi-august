// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

interface Governor {
    function hasVoted(uint256 proposalId, address account) external returns(bool);
}

contract Voter is ERC721 {
    uint256 private _nextTokenId;
    
    // Arbitrum Governor Contract
    address public governorContract = 0xf07DeD9dC292157749B6Fd268E37DF6EA38395B9;
    
    // Mapping to track if user has already minted
    mapping(address => bool) public hasMinted;
    
    constructor()
        ERC721("I Voted Badge", "IVOTED")
    {}
    
    function mintVote() external {
        require(!hasMinted[msg.sender], "Already minted");
        
        // Check if user has voted by calling the governor contract
        Governor governor = Governor(governorContract);
        bool voted = governor.hasVoted(97685288731263391833044854304895851471157040105038894699042975271050068874277, msg.sender);
        require(voted, "Must vote first");
        
        // Mint the NFT
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
        hasMinted[msg.sender] = true;
    }
    
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        
        string memory svg = _generateSVG();
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "I Voted Badge #',
                        _toString(tokenId),
                        '", "description": "Proof that you participated in Arbitrum DAO governance", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(svg)),
                        '"}'
                    )
                )
            )
        );
        
        return string(abi.encodePacked("data:application/json;base64,", json));
    }
    
    function _generateSVG() internal pure returns (string memory) {
        string memory svg = string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" width="400" height="400" viewBox="0 0 400 400">',
                '<rect width="400" height="400" fill="black"/>',
                '<text x="200" y="200" text-anchor="middle" fill="#43902E" font-family="Arial, sans-serif" font-size="24" font-weight="bold">I VOTED For Super Boring</text>',
                '</svg>'
            )
        );
        return svg;
    }
    
    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
} 
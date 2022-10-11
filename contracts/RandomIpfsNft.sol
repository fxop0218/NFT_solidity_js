// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "hardhat/console.sol";



contract RandomIpfsNft is VRFConsumerBaseV2, ERC721 {

    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint256 private immutable i_subcriptionId;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    bytes32 private immutable i_gasLine;
    
    MAX_CHANCE

    // HELPERS

    mapping(uint256 => address) public s_requestIdToSender;

    // NFT variables

    uint256 public s_tokenCounter; 
    bytes32 internal constant MAX_CHANCE = 100;
    enum Breed{
        PUG,
        SHIBA,
        BERNARD,
    }


    constructor(address vrfCoordinatorV2, uint64 subscriptionId, bytes32 gasLane, uint32 callbackGasLimit) VRFConsumerBaseV2(vrfCoordinatorV2) ERC721("IPFS nft","INFT") {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_callbackGasLimit = callbackGasLimit;
        i_gasLine = gasLane;
        i_subcriptionId = subscriptionId;

    }
    function requestNft() public{
        requestId = i_vrfCoordinator.requestRandomWords(i_gasLine, i_subcriptionId, REQUEST_CONFIRMATIONS, i_callbackGasLimit, NUM_WORDS);
        s_requestIdToSender[requestId] = msg.sender; 
    }
    function fulfillRandomWords(uint256 requestId, uint256[ memory randomWords]) internal override{
        address dowOwner = s_requestIdToSender[requestId]
        uint256 newTokenId = s_tokenCounter; 
        _safeMint(dowOwner, newTokenId)
        uint256 moddedRng = randomWords[0] % MAX_CHANCE;

    }

    function tokenUri(uint256) public view override returns (string memory) {
        uint256 cumulativeSum = 0; 
        uint256[3] memory chanceArray = getChanceArray()
        for (uint256 i = 0; i < chanceArray.length; i++) {
            if (moddedRng >= cumulativeSum && moddedRng < cumulativeSum + chanceArray[i]) {
                return Breed(i);
            }
        }
        cumulativeSum += chanceArray[i]; 
    }

    function getChanceArray() public pure returns(uint256[3] memory) {
        return[10,30,MAX_CHANCE];
    }

    function getBreedFromModdedRng(uint256 moddedRng) public pure return (Breed)
}
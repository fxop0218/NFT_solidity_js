// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "hardhat/console.sol";

// Error
error RandomIpfsNft__AlreadyInitialized();
error RandomIpfsNft__NeedMoreETHSent();
error RandomIpfsNft__RangeOutOfBounds();
error RandomIpfsNft__TransferFailed();

// Event

event NftRequested(uint256 indexed requestId, address requester)

contract RandomIpfsNft is VRFConsumerBaseV2, ERC721URIStorage, Ownable {

    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint256 private immutable i_subcriptionId;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    bytes32 private immutable i_gasLine;
    uint256 internal immutable i_mintfee;
    bool private i_initialized;


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
    string[] internal s_dogTokenUris; 


    constructor(address vrfCoordinatorV2,
                uint64 subscriptionId, 
                bytes32 gasLane, 
                uint32 callbackGasLimit, 
                string[3] memory dogTokenUris
                uint256 mintfee) 
        VRFConsumerBaseV2(vrfCoordinatorV2) 
        ERC721("IPFS nft","INFT") {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_callbackGasLimit = callbackGasLimit;
        i_gasLine = gasLane;
        i_subcriptionId = subscriptionId;
        i_mintfee = mintfee;
        _initializeContract(dogTokenUris);
    }
    function requestNft() public payable returns (uint256 requestId){
        if (msg.value < i_mintfee) {
            revert RandomIpfsNft__NeedMoreETHSent(); 
        }
        requestId = i_vrfCoordinator.requestRandomWords(i_gasLine, i_subcriptionId, REQUEST_CONFIRMATIONS, i_callbackGasLimit, NUM_WORDS);
        s_requestIdToSender[requestId] = msg.sender; 
    }
    function fulfillRandomWords(uint256 requestId, uint256[ memory randomWords]) internal override{
        address dowOwner = s_requestIdToSender[requestId]
        uint256 newTokenId = s_tokenCounter; 
        uint256 moddedRng = randomWords[0] % MAX_CHANCE;
        Breed dogBreed = getBreedFromModdedRng(moddedRng);
        _safeMint(dowOwner, newTokenId);
        _setTokenURI(newTokenId, s_dogTokenUris[uint256(dogBreed)]);
        emit NftRequested(requestId, msg.sender);
    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) { revert RandomIpfsNft__WithdrawFailed()}
    }

    function getChanceArray() public pure returns(uint256[3] memory) {
        return[10,30,MAX_CHANCE];
    }

    function getBreedFromModdedRng(uint256 moddedRng) public pure return (Breed) {
        uint256 cumulativeSum = 0; 
        uint256[3] memory chanceArray = getChanceArray();
        for (uint256 i = 0; i < chanceArray.length; i++) {
            if (moddedRng >= cumulativeSum && moddedRng < cumulativeSum + chanceArray[i]) {
                return Breed(i);
            }
            cumulativeSum += chanceArray[i]; 
        }
        revert RandomIpfsNft__TransferFailed();
    }

    function _initializeContract(string[3] memory dogTokenUris) private {
        if (s_initialized) {
            revert RandomIpfsNft__AlreadyInitialized();
        }
        s_dogTokenUris = dogTokenUris;
        i_initialized = true;
        
    }

    function getMintFee() public view returns (uint256) {
        return i_mintFee;
    }

    function getDogTokenUris(uint256 index) public view returns (string memory) {
        return s_dogTokenUris[index];
    }

    function getInitialized() public view returns (bool) {
        return s_initialized;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}
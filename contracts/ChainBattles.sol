// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    uint randomNumberSeed;
    struct Stats {
        uint256 level;
        uint256 speed;
        uint256 strength;
        uint256 life;
    }
    mapping(uint256 => Stats) public tokenIdToStats;
    bytes32 public encryptedLevelKey = keccak256(bytes("level"));
    bytes32 public encryptedSpeedKey = keccak256(bytes("speed"));
    bytes32 public encryptedStrengthKey = keccak256(bytes("strength"));
    bytes32 public encryptedLifeKey = keccak256(bytes("life"));

    constructor() ERC721("Chain Battles", "CBTLS") {}

    function random(uint256 number) public returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.difficulty,
                        msg.sender,
                        randomNumberSeed++
                    )
                )
            ) % number;
    }

    function generateCharacter(uint256 tokenId) public returns (string memory) {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="30%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Warrior",
            "</text>",
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Level: ",
            getStats(tokenId).level.toString(),
            "</text>",
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Speed: ",
            getStats(tokenId).speed.toString(),
            "</text>",
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Strength: ",
            getStats(tokenId).strength.toString(),
            "</text>",
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Life: ",
            getStats(tokenId).life.toString(),
            "</text>",
            "</svg>"
        );
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    function getStats(uint256 tokenId) public view returns (Stats memory) {
        Stats storage stats = tokenIdToStats[tokenId];
        return stats;
    }

    function getTokenURI(uint256 tokenId) public returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Chain Battles #',
            tokenId.toString(),
            '",',
            '"description": "Battles on chain",',
            '"image": "',
            generateCharacter(tokenId),
            '"',
            "}"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        tokenIdToStats[newItemId] = Stats(
            random(100),
            random(100),
            random(100),
            random(100)
        );
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function train(uint256 tokenId, string memory stat) public {
        require(_exists(tokenId), "Please use an existing token");
        require(
            ownerOf(tokenId) == msg.sender,
            "You must own this token to train it"
        );

        bytes32 encryptedStat = keccak256(bytes(stat));

        require(
            encryptedStat == encryptedLevelKey ||
                encryptedStat == encryptedSpeedKey ||
                encryptedStat == encryptedStrengthKey ||
                encryptedStat == encryptedLifeKey,
            "Select a valid stat."
        );
        Stats memory currentStats = tokenIdToStats[tokenId];
        if (encryptedStat == encryptedLevelKey) {
            uint256 currentStat = currentStats.level;
            require(currentStat < 99, "Maximum level already achieved.");
            currentStats.level = currentStat + 1;
        } else if (encryptedStat == encryptedSpeedKey) {
            uint256 currentStat = currentStats.speed;
            require(currentStat < 99, "Maximum speed already achieved.");
            currentStats.speed = currentStat + 1;
        } else if (encryptedStat == encryptedStrengthKey) {
            uint256 currentStat = currentStats.strength;
            require(currentStat < 99, "Maximum strength already achieved.");
            currentStats.strength = currentStat + 1;
        } else if (encryptedStat == encryptedLifeKey) {
            uint256 currentStat = currentStats.life;
            require(currentStat < 99, "Maximum life already achieved.");
            currentStats.life = currentStat + 1;
        }
        tokenIdToStats[tokenId] = currentStats;
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }
}

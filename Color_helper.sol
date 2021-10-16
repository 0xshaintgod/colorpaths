pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";


contract ColorHelper is Ownable {
  // List of colors in circulation
  string[] internal colors;
  string[] public mintedColors;

  // Max and total supply
  uint private randNonce = 0;
  // For enumerating through the initial colors list
  uint internal _index = 0;

  uint internal stringLength = 8;
  uint internal numberLength = 8;
  string[] internal BASE_NUMBERS = ["1","2","2","2","3","3","3","4"];
  string[] internal BASE_DIRECTIONS = ["U","D","L","R","Q","E","Z","C"];

  constructor() {
    populateColors();
  }

  function populateColors() internal onlyOwner() {
    string[122] memory initColors = ['#FFB6C1', '#FFC0CB', '#DC143C', '#DB7093', '#FF69B4', '#FF1493', '#C71585',
        '#DA70D6', '#D8BFD8', '#DDA0DD', '#EE82EE', '#FF00FF', '#FF00FF', '#8B008B', '#800080',
        '#BA55D3', '#9400D3', '#9932CC', '#4B0082', '#8A2BE2', '#9370DB', '#7B68EE', '#6A5ACD',
        '#483D8B', '#E6E6FA', '#0000FF', '#0000CD', '#00008B', '#000080', '#191970',
        '#4169E1', '#6495ED', '#B0C4DE', '#778899', '#708090', '#1E90FF', '#4682B4',
        '#87CEFA', '#87CEEB', '#00BFFF', '#ADD8E6', '#B0E0E6', '#5F9EA0', '#00CED1',
        '#E0FFFF', '#AFEEEE', '#00FFFF', '#00FFFF', '#008B8B', '#008080', '#2F4F4F', '#48D1CC',
        '#20B2AA', '#40E0D0', '#7FFFD4', '#66CDAA', '#00FA9A', '#00FF7F', '#3CB371',
        '#2E8B57', '#F0FFF0', '#8FBC8F', '#98FB98', '#90EE90', '#32CD32', '#00FF00', '#228B22',
        '#008000', '#006400', '#7CFC00', '#7FFF00', '#ADFF2F', '#556B2F', '#9ACD32', '#6B8E23',
         '#F5F5DC',  '#FFFF00', '#808000', '#BDB76B', '#EEE8AA',
         '#F0E68C', '#FFD700', '#DAA520', '#B8860B',
        '#F5DEB3', '#FFA500', '#FFE4B5', '#FFEBCD', '#FFDEAD', '#FAEBD7', '#D2B48C',
        '#DEB887', '#FF8C00', '#FFE4C4', '#CD853F', '#FFDAB9', '#F4A460', '#D2691E',
        '#8B4513', '#A0522D', '#FFA07A', '#FF7F50', '#FF4500', '#E9967A', '#FF6347',
        '#FA8072', '#FFE4E1', '#F08080',  '#BC8F8F', '#CD5C5C', '#FF0000', '#A52A2A',
        '#B22222', '#8B0000', '#800000',  '#F5F5F5', '#DCDCDC', '#D3D3D3', '#C0C0C0',
        '#A9A9A9', '#808080', '#696969'];
    colors.push(initColors[0]);
    uint len = 100;
    for (uint i=1; i < len; i++) {
      randomIndex(initColors[i], i);
    }
  }

  function randomIndex(string memory color, uint len) internal {
      uint index = getRandomDigit(msg.sender, color, len) % len;
      colors.push(colors[index]);
      colors[index] = color;
  }

  function getRandomDigit(address tokenOwner, string memory color, uint _id) internal returns(uint256){
    uint random = 0;
    if(tokenOwner == msg.sender){
      random = uint(keccak256(abi.encodePacked(block.timestamp, _id, color, randNonce)));
    } else {
      random = uint(keccak256(abi.encodePacked(block.timestamp, tokenOwner, _id, color, randNonce)));
    }
    randNonce++;
    return random;
  }

  function generatePaths(address tokenOwner, string memory color, uint _id) internal returns(string memory){
    /*
    Get path function
    Should return a randomized path consisting of the following in A B form
    A = Direction Up, Down, Left, Right, E: up right, Q: up left, Z: down left
    C: down right
    B = Number from 1-3 indicating movement
    */
    string memory path = "";

    for (uint i=0; i < 200; i++) {
      string memory dir = BASE_DIRECTIONS[getRandomDigit(tokenOwner, color, _id) % stringLength];
      string memory dis = BASE_NUMBERS[getRandomDigit(tokenOwner, color, _id) % numberLength];
      path = append(path, dir, dis);
    }
    return path;
  }

  function append(string memory a, string memory b, string memory c) internal pure returns (string memory) {
    return string(abi.encodePacked(a, b, c));
  }
}

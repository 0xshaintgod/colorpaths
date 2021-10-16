pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Color_helper.sol";
import { Base64 } from "./Base64.sol";


contract ColorPaths is ERC721, Ownable, ColorHelper {
  // List of colors in circulation

  // mapping color -> score (leaderboard)
  mapping(string => uint) internal _leaderboard;

  // mapping color -> token ID
  mapping(string => uint) internal _colorIds;

  // Mapping Color -> Path
  mapping(string => string) internal _colorPaths;

  // Mapping id => color
  mapping(uint => string) internal _idColor;

  // Max and total supply
  uint public maxSupply = 100;
  uint internal totalSupply = 0;

  // is minting open?
  bool internal openMinting = false;

  // Owner of the Colors contract (msg.sender)
  address contractOwner;

  constructor() ERC721("ColorPaths", "PATHS") {
    contractOwner = msg.sender;
  }

  function preMint(address preMintAddress) public onlyOwner() {
    string memory color = colors[ColorHelper._index];
    _colorPaths[color] = generatePaths(preMintAddress, color, ColorHelper._index);
    _safeMint(preMintAddress, ColorHelper._index);
    mintTracker(color);
  }

  function donePremint() public onlyOwner() {
    openMinting = true;
  }

  function mint() public payable {
    require(openMinting == true, "Minting is not open yet, follow my twitter for more information @0xshaintgod");
    require(totalSupply < maxSupply);
    require(colors.length != 0);
    require(balanceOf(msg.sender) < 2);
    string memory color = colors[ColorHelper._index];
    _colorPaths[color] = generatePaths(msg.sender, color, ColorHelper._index);
    _safeMint(msg.sender, ColorHelper._index);
    mintTracker(color);
  }

  function mintTracker(string memory color) internal {
    _leaderboard[color] = 0;
    _colorIds[color] = ColorHelper._index;
    mintedColors.push(color);
    totalSupply++;
    _idColor[ColorHelper._index] = color;
    ColorHelper._index++;
  }

  function addScore(string memory color, uint score) public onlyOwner() {
    _leaderboard[color] = score;
  }

  // Utils
  function getOwnerCount(address account) public view returns (uint) {
    return balanceOf(account);
  }

  function getTotalSupply() public view returns (uint) {
    return totalSupply;
  }

  function getColorOwner(string memory color) public view returns(address) {
    return ownerOf(_colorIds[color]);
  }

   function getScore(string memory color) public view returns(uint) {
     return _leaderboard[color];
   }

  function getId(string memory color) public view returns(uint) {
    return _colorIds[color];
  }

  function getPath(string memory color) public view returns(string memory) {
    return _colorPaths[color];
  }

  function getIdOwner(uint _tokenId) public view returns(address) {
    return ownerOf(_tokenId);
  }

  function getMetaData(uint _tokenId) public view returns(uint, uint, string memory, string memory, address) {
    string memory color = _idColor[_tokenId];
    return (_tokenId, getScore(color), color, _colorPaths[color], ownerOf(_tokenId));
  }

  function tokenURI(uint256 tokenId) override public view returns (string memory) {
    string[11] memory parts;
    parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 325 300"><style>.base { fill: white; font-family: serif; font-size: 14px;}</style>';
    parts[1] = '<rect x="0" y="0" width="350" height="300"/>';
    parts[2] = '<foreignObject x="0" y="0" width="325" height="300"><body style="background-color:';
    parts[3] = _idColor[tokenId];
    parts[4] = ';" ';
    parts[5] = 'width="300" height="300" xmlns="http://www.w3.org/1999/xhtml">';
    parts[6] = '<div>COLOR: ';
    parts[7] = _idColor[tokenId];
    parts[8] = '</div><div style="color:black; overflow-wrap: break-word;" > PATH: ';
    parts[9] = getPath(_idColor[tokenId]);
    parts[10] = '</div></body></foreignObject></svg>';


    string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7], parts[8]));
    output = string(abi.encodePacked(output, parts[9], parts[10]));

    string memory json = Base64.encode(bytes(string(abi.encodePacked(
      '{"name": "Color #',
      _idColor[tokenId],
      '", "description": "colorpaths is a randomized generative art experiment that creates a path string for each unique color minted. There is no defined way to visualize this string, it is up to the owner to decide how to visualize the art from the path.","image": "data:image/svg+xml;base64,',
      Base64.encode(bytes(output)),
      '"}'
    ))));
    output = string(abi.encodePacked('data:application/json;base64,', json));

    return output;
  }
}

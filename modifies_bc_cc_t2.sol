
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract LandTransferSystem {
    struct Land {
        uint landId;
        address owner;
        uint size;
        bool verified;
        uint[2] coordinates;
        uint landNumber;
        address[] ownerHistory;
        uint[] timestampHistory;
    }

    address public immutable creator;
    mapping(address => bool) public admins;
    mapping(uint => Land) public lands;
    mapping(address => uint[]) public ownedLands;
    
    uint public landCount;
    
    event LandRegistered(uint indexed landId, address indexed owner);
    event OwnershipTransferred(uint indexed landId, address indexed previousOwner, address indexed newOwner);
    event OwnershipVerified(uint indexed landId);
    event NewAdminAdded(address admin);
    event OwnerRegistered(address owner);
    event OwnershipAssigned(uint indexed landId, address indexed newOwner);
    mapping(address => uint256) public nonces;
    
    // EIP-712 Domain Separator
    bytes32 public constant DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );
    bytes32 public constant TRANSFER_TYPEHASH = keccak256(
        "TransferOwnership(uint256 landId,address newOwner,uint256 nonce,uint256 expiry)"
    );
    bytes32 public DOMAIN_SEPARATOR;

    modifier onlyAdmin() {
        require(admins[msg.sender] || msg.sender == creator, "Unauthorized: Admin only");
        _;
    }

    constructor() {
        creator = msg.sender;
           DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256("LandTransferSystem"),
                keccak256("1"),
                block.chainid,
                address(this)
            )
        );
    }

    function addAdmin(address _admin) external {
        require(msg.sender == creator, "Only creator can add admins");
        admins[_admin] = true;
        emit NewAdminAdded(_admin);
    }

    function registerLand(
        uint _size,
        uint[2] memory _coordinates,
        uint _landNumber
    ) external onlyAdmin {
        landCount++;
        lands[landCount] = Land({
            landId: landCount,
            owner: address(0),
            size: _size,
            verified: false,
            coordinates: _coordinates,
            landNumber: _landNumber,
            ownerHistory: new address[](0),
            timestampHistory: new uint[](0)
        });
        emit LandRegistered(landCount, address(0));
    }

function assignOwnership(uint256 _landId, address _newOwner) external onlyAdmin {
        require(_newOwner != address(0), "Invalid owner address");
        require(lands[_landId].landId != 0, "Land does not exist");
        require(!lands[_landId].verified, "Land already has an owner");
        
        Land storage land = lands[_landId];
        land.owner = _newOwner;
        land.verified = true;
        land.ownerHistory = new address[](0);
        land.timestampHistory = new uint[](0);
        
        emit OwnershipAssigned(_landId, _newOwner);
    }

    function verifyOwnership(uint _landId) external onlyAdmin {
        require(lands[_landId].landId != 0, "Land does not exist");
        lands[_landId].verified = true;
        emit OwnershipVerified(_landId);
    }

    function transferOwnership(uint _landId, address _newOwner) internal {
        Land storage land = lands[_landId];
        require(land.owner == msg.sender, "Not current owner");
        require(land.verified, "Land not verified");
        
        // Update previous owner's records
        uint[] storage prevOwnerLands = ownedLands[msg.sender];
        for(uint i = 0; i < prevOwnerLands.length; i++) {
            if(prevOwnerLands[i] == _landId) {
                prevOwnerLands[i] = prevOwnerLands[prevOwnerLands.length - 1];
                prevOwnerLands.pop();
                break;
            }
        }

        // Update land records
        land.owner = _newOwner;
        land.verified = false;
        land.ownerHistory.push(_newOwner);
        land.timestampHistory.push(block.timestamp);
        
        // Update new owner's records
        ownedLands[_newOwner].push(_landId);
        
        emit OwnershipTransferred(_landId, msg.sender, _newOwner);
    }

    function getLandHistory(uint _landId) external view returns (
        address[] memory owners,
        uint[] memory timestamps,
        bool verified
    ) {
        Land storage land = lands[_landId];
        return (
            land.ownerHistory,
            land.timestampHistory,
            land.verified
        );
    }

    function getOwnedLands(address _owner) public view returns (uint[] memory) {
        return ownedLands[_owner];
    }
function transferOwnershipWithSignature(
        uint256 _landId,
        address _newOwner,
        uint256 _expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        
        require(_expiry >= block.timestamp, "Signature expired");
      
        require(_newOwner != address(0), "Invalid new owner");
        
        Land storage land = lands[_landId];
        require(land.owner != address(0), "Land has no owner");
        require(land.verified, "Land not verified");
        
        uint256 currentNonce = nonces[land.owner];
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        TRANSFER_TYPEHASH,
                        _landId,
                        _newOwner,
                        currentNonce,
                        _expiry
                    )
                )
            )
        );
        
        address signer = ecrecover(digest, v, r, s);
        require(signer == land.owner, "Invalid signature");
        
        nonces[land.owner]++;
        transferOwnership(_landId, _newOwner);
    }

   
}

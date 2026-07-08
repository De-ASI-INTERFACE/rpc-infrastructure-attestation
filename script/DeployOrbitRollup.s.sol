// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";

interface IRollupCreator {
    function createRollup(bytes calldata config) external payable returns (address);
}

contract DeployOrbitRollup is Script {
    address internal constant ROLLUP_CREATOR = 0x0000000000000000000000000000000000000000;
    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address internal constant CHAIN_OWNER = 0x2D7991daBc48d29a01210690fEcB996F6802aE61;
    address internal constant INITIAL_SEQUENCER = 0x2D7991daBc48d29a01210690fEcB996F6802aE61;
    address internal constant FAST_CONFIRMER = 0x8b9e138d8441E0e5e5168279ca41E31348cEB0f8;
    address internal constant BATCH_POSTER = 0x8b9e138d8441E0e5e5168279ca41E31348cEB0f8;
    bytes32 internal constant SEQUENCER_INBOX_SALT = 0x184884e1eb9fefdc158f6c8ac912bb183bf3cf83f0090317e0bc4ac5860baa39;

    uint256 internal constant CHAIN_ID = 1628;
    uint256 internal constant CONFIRM_PERIOD_BLOCKS = 201600;
    uint256 internal constant BASE_STAKE = 0.1 ether;
    uint256 internal constant SPEED_LIMIT_PER_SECOND = 7200;
    uint64 internal constant MAX_DATA_SIZE = 117964;
    uint64 internal constant ERC20_DECIMALS = 18;

    function run() external {
        uint256 deployerPk = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPk);

        console2.log("Deployer:", deployer);
        console2.log("Target chain ID:", CHAIN_ID);
        console2.log("Chain owner:", CHAIN_OWNER);

        bytes memory config = _buildConfig();

        console2.log("Encoded createRollup config length:", config.length);
        console2.logBytes(config);

        vm.startBroadcast(deployerPk);
        address rollup = IRollupCreator(ROLLUP_CREATOR).createRollup(config);
        vm.stopBroadcast();

        console2.log("Rollup deployed at:", rollup);
    }

    function _buildConfig() internal pure returns (bytes memory) {
        return abi.encode(
            uint256(7200),
            WETH,
            uint256(100000000000000000),
            SEQUENCER_INBOX_SALT,
            CHAIN_OWNER,
            INITIAL_SEQUENCER,
            uint256(1628),
            string('{"homesteadBlock":0,"daoForkBlock":null,"daoForkSupport":true,"eip150Block":0,"eip150Hash":"0x0000000000000000000000000000000000000000000000000000000000000000","eip155Block":0,"eip158Block":0,"byzantiumBlock":0,"constantinopleBlock":0,"petersburgBlock":0,"istanbulBlock":0,"muirGlacierBlock":0,"berlinBlock":0,"londonBlock":0,"clique":{"period":0,"epoch":0},"arbitrum":{"EnableArbOS":true,"AllowDebugPrecompiles":false,"DataAvailabilityCommittee":true,"InitialArbOSVersion":32,"GenesisBlockNum":0,"MaxCodeSize":24576,"MaxInitCodeSize":49152,"InitialChainOwner":"0x2D7991daBc48d29a01210690fEcB996F6802aE61"},"chainId":1628}'),
            uint256(75),
            uint256(CONFIRM_PERIOD_BLOCKS),
            uint256(0),
            uint256(1),
            uint256(1),
            uint256(57600),
            uint256(48),
            uint256(864000),
            uint256(3600),
            uint256(67108864),
            uint256(524288),
            uint256(8388608),
            bytes32(0),
            bytes32(0),
            uint256(0),
            uint256(0),
            uint256(1),
            bytes32(0),
            uint256(0),
            address(0),
            uint256(1),
            uint256(14400),
            uint256(4294967296),
            uint256(4294967296),
            uint256(500),
            address(0xFfE040AD09AB87C6Ed272BCe4D40217fa52B1E07),
            uint256(MAX_DATA_SIZE),
            address(0),
            true,
            uint256(100000000),
            FAST_CONFIRMER,
            BATCH_POSTER,
            address(0)
        );
    }
}

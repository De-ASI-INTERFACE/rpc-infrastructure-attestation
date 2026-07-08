# Foundry Orbit Rollup Deployment

This script materializes the provided `createRollup((tuple,address[],uint256,address,bool,uint256,address[],address,address))` payload as a Foundry deploy script for reproducible Arbitrum Orbit deployment.

## Files

- `script/DeployOrbitRollup.s.sol` — Foundry script that ABI-encodes the supplied payload and calls `createRollup`

## Important

Before broadcasting, replace the placeholder `ROLLUP_CREATOR` address in `script/DeployOrbitRollup.s.sol` with the actual Arbitrum `RollupCreator` contract address for your target environment. The current placeholder is `0x0000000000000000000000000000000000000000` and will revert if left unchanged.

## Usage

```bash
export PRIVATE_KEY=<your_deployer_private_key>
export ETH_RPC_URL=<mainnet_or_parent_chain_rpc>

forge script script/DeployOrbitRollup.s.sol:DeployOrbitRollup \
  --rpc-url $ETH_RPC_URL \
  --broadcast \
  -vvvv
```

## Notes

The script preserves the exact values supplied in your payload, including:

- Chain ID `1628`
- WETH stake token `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`
- Owner / sequencer `0x2D7991daBc48d29a01210690fEcB996F6802aE61`
- Fast confirmer / batch poster `0x8b9e138d8441E0e5e5168279ca41E31348cEB0f8`
- DAC enabled (`DataAvailabilityCommittee: true`)

For evidence-chain rigor, verify the encoded config against your original source material before mainnet broadcast.

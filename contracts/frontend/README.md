# EcoChain frontend

This is the EcoChain HTML/CSS/JavaScript frontend. It starts in **DEMO MODE** with sample data and switches to live mode only after a MetaMask connection on Ethereum Sepolia.

## Run locally

From this `frontend` directory, either open `index.html` directly in a browser or serve it with any static file server, for example:

```powershell
python -m http.server 5500
```

Then open <http://localhost:5500>.

The deployed Sepolia contract is configured in `contract-abi.js` at `0x8B856d324eFa802B6EaC590579A5b9d87f0339eF`. The page loads ethers.js `6.13.5` from jsDelivr.

## Integration handoff

The UI is intentionally structured around the existing contract API. The future ethers.js adapter should be added without changing the presentation layer and should use the deployed address and ABI supplied from Remix.

Existing contract touchpoints represented in the UI are:

- Citizen: `submitWaste`, `getRequest`, `getCitizenStats`, `isEvidenceUsed`, `redeemRewards`
- Collector: `verifyWaste`, `rejectWaste`
- Owner/admin: `setCollector`, `setRewardRate`
- Public reads/events: `owner`, `requestCount`, totals, mappings, and contract events

Live mode requires MetaMask on Sepolia with chain ID `11155111` and enough Sepolia ETH for gas. Evidence files are hashed in the browser with ethers.js `keccak256`; the hash is passed to `submitWaste`, while the file itself is not uploaded by the contract.

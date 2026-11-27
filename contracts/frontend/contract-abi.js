/* ABI supplied for the deployed EcoChain contract on Ethereum Sepolia. */
window.ECOCHAIN_ADDRESS = '0x8B856d324eFa802B6EaC590579A5b9d87f0339eF';
window.ECOCHAIN_ABI = [
  'function owner() view returns (address)',
  'function requestCount() view returns (uint256)',
  'function totalWasteGrams() view returns (uint256)',
  'function totalPointsIssued() view returns (uint256)',
  'function totalCO2SavedGrams() view returns (uint256)',
  'function citizenPoints(address) view returns (uint256)',
  'function approvedSubmissions(address) view returns (uint256)',
  'function collectors(address) view returns (bool)',
  'function rewardRate(uint8) view returns (uint256)',
  'function getCitizenStats(address) view returns (uint256 points, uint256 approvedCount)',
  'function getRequest(uint256 requestId) view returns (uint256 id, address citizen, uint8 wasteType, uint256 quantityGrams, bytes32 evidenceHash, uint8 status, uint256 pointsAwarded, uint8 qualityScore, uint256 submittedAt, uint256 verifiedAt, string rejectionReason)',
  'function isEvidenceUsed(bytes32 evidenceHash) view returns (bool)',
  'function submitWaste(uint8 wasteType, uint256 quantityGrams, bytes32 evidenceHash) returns (uint256)',
  'function verifyWaste(uint256 requestId, uint8 qualityScore)',
  'function rejectWaste(uint256 requestId, string reason)',
  'function redeemRewards(uint256 points, string rewardCode)',
  'function setCollector(address collector, bool authorized)',
  'function setRewardRate(uint8 wasteType, uint256 newRate)',
  'event WasteSubmitted(uint256 indexed requestId, address indexed citizen, uint8 wasteType, uint256 quantityGrams, bytes32 evidenceHash)',
  'event WasteVerified(uint256 indexed requestId, address indexed collector, uint256 pointsAwarded, uint8 qualityScore)',
  'event WasteRejected(uint256 indexed requestId, address indexed collector, string reason)',
  'event RewardsRedeemed(address indexed citizen, uint256 points, string rewardCode)'
];

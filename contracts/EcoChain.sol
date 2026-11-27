// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
    EcoChain 2.0
    Blockchain-Based Smart Waste Management
    and Recycling Reward System
*/

contract EcoChain {

    address public owner;

    enum WasteType {
        Plastic,
        Paper,
        Metal,
        Glass,
        E_Waste,
        Organic
    }

    enum Status {
        Pending,
        Approved,
        Rejected
    }

    struct WasteRequest {
        uint256 id;
        address citizen;
        WasteType wasteType;
        uint256 quantityGrams;
        bytes32 evidenceHash;
        Status status;
        uint256 pointsAwarded;
        uint8 qualityScore;
        uint256 submittedAt;
        uint256 verifiedAt;
        string rejectionReason;
    }

    uint256 public requestCount;
    uint256 public totalWasteGrams;
    uint256 public totalPointsIssued;
    uint256 public totalCO2SavedGrams;

    mapping(address => bool) public collectors;
    mapping(address => uint256) public citizenPoints;
    mapping(address => uint256) public approvedSubmissions;

    mapping(uint256 => WasteRequest) public requests;
    mapping(bytes32 => bool) public usedEvidence;

    // Reward points earned per kilogram of waste
    mapping(WasteType => uint256) public rewardRate;

    // Estimated CO2 savings in grams per kilogram recycled
    mapping(WasteType => uint256) public co2Factor;

    // Events provide a transparent transaction history
    event CollectorUpdated(address collector, bool authorized);

    event WasteSubmitted(
        uint256 indexed requestId,
        address indexed citizen,
        WasteType wasteType,
        uint256 quantityGrams,
        bytes32 evidenceHash
    );

    event WasteVerified(
        uint256 indexed requestId,
        address indexed collector,
        uint256 pointsAwarded,
        uint8 qualityScore
    );

    event WasteRejected(
        uint256 indexed requestId,
        address indexed collector,
        string reason
    );

    event RewardsRedeemed(
        address indexed citizen,
        uint256 points,
        string rewardCode
    );

    event RewardRateUpdated(
        WasteType wasteType,
        uint256 newRate
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier onlyCollector() {
        require(collectors[msg.sender], "Only authorized collectors");
        _;
    }

    constructor() {
        owner = msg.sender;

        // Initial reward rates: points per kg
        rewardRate[WasteType.Plastic] = 10;
        rewardRate[WasteType.Paper] = 5;
        rewardRate[WasteType.Metal] = 15;
        rewardRate[WasteType.Glass] = 8;
        rewardRate[WasteType.E_Waste] = 25;
        rewardRate[WasteType.Organic] = 4;

        // Illustrative CO2-saving estimates per kg.
        // These are configurable assumptions, not measured values.
        co2Factor[WasteType.Plastic] = 1500;
        co2Factor[WasteType.Paper] = 1000;
        co2Factor[WasteType.Metal] = 4000;
        co2Factor[WasteType.Glass] = 300;
        co2Factor[WasteType.E_Waste] = 2000;
        co2Factor[WasteType.Organic] = 500;
    }

    // OWNER: authorize or remove a waste collector
    function setCollector(
        address collector,
        bool authorized
    ) external onlyOwner {
        require(collector != address(0), "Invalid collector address");

        collectors[collector] = authorized;

        emit CollectorUpdated(collector, authorized);
    }

    // OWNER: update reward rate for a waste category
    function setRewardRate(
        WasteType wasteType,
        uint256 newRate
    ) external onlyOwner {
        require(newRate > 0, "Rate must be greater than zero");

        rewardRate[wasteType] = newRate;

        emit RewardRateUpdated(wasteType, newRate);
    }

    // CITIZEN: submit recycling proof
    function submitWaste(
        WasteType wasteType,
        uint256 quantityGrams,
        bytes32 evidenceHash
    ) external returns (uint256) {

        require(quantityGrams > 0, "Quantity must be greater than zero");
        require(evidenceHash != bytes32(0), "Evidence hash required");
        require(!usedEvidence[evidenceHash], "Duplicate recycling proof");

        usedEvidence[evidenceHash] = true;

        requestCount++;

        requests[requestCount] = WasteRequest({
            id: requestCount,
            citizen: msg.sender,
            wasteType: wasteType,
            quantityGrams: quantityGrams,
            evidenceHash: evidenceHash,
            status: Status.Pending,
            pointsAwarded: 0,
            qualityScore: 0,
            submittedAt: block.timestamp,
            verifiedAt: 0,
            rejectionReason: ""
        });

        emit WasteSubmitted(
            requestCount,
            msg.sender,
            wasteType,
            quantityGrams,
            evidenceHash
        );

        return requestCount;
    }

    // COLLECTOR: verify recycling and award points
    // Quality score must be between 1 and 100
    function verifyWaste(
        uint256 requestId,
        uint8 qualityScore
    ) external onlyCollector {

        require(
            requestId > 0 && requestId <= requestCount,
            "Invalid request ID"
        );

        require(qualityScore >= 1 && qualityScore <= 100,
            "Quality must be between 1 and 100");

        WasteRequest storage request = requests[requestId];

        require(request.status == Status.Pending,
            "Request already processed");

        // Base points = quantity in kg * category reward rate
        // Quality score adjusts the final reward.
        uint256 basePoints =
            (request.quantityGrams *
            rewardRate[request.wasteType]) / 1000;

        uint256 points =
            (basePoints * qualityScore) / 100;

        require(points > 0, "Calculated reward is zero");

        // Innovation: milestone bonus for every 5 approved submissions
        uint256 newCount = approvedSubmissions[request.citizen] + 1;

        if (newCount % 5 == 0) {
            points += 25;
        }

        request.status = Status.Approved;
        request.pointsAwarded = points;
        request.qualityScore = qualityScore;
        request.verifiedAt = block.timestamp;

        approvedSubmissions[request.citizen] = newCount;
        citizenPoints[request.citizen] += points;

        totalPointsIssued += points;
        totalWasteGrams += request.quantityGrams;

        // Illustrative environmental impact estimate
        uint256 co2Saved =
            (request.quantityGrams *
            co2Factor[request.wasteType]) / 1000;

        totalCO2SavedGrams += co2Saved;

        emit WasteVerified(
            requestId,
            msg.sender,
            points,
            qualityScore
        );
    }

    // COLLECTOR: reject invalid recycling proof
    function rejectWaste(
        uint256 requestId,
        string calldata reason
    ) external onlyCollector {

        require(
            requestId > 0 && requestId <= requestCount,
            "Invalid request ID"
        );

        require(bytes(reason).length > 0, "Reason required");

        WasteRequest storage request = requests[requestId];

        require(request.status == Status.Pending,
            "Request already processed");

        request.status = Status.Rejected;
        request.rejectionReason = reason;
        request.verifiedAt = block.timestamp;

        emit WasteRejected(requestId, msg.sender, reason);
    }

    // CITIZEN: redeem points for a simulated reward
    function redeemRewards(
        uint256 points,
        string calldata rewardCode
    ) external {

        require(points > 0, "Points must be greater than zero");

        require(citizenPoints[msg.sender] >= points,
            "Insufficient reward points");

        require(bytes(rewardCode).length > 0,
            "Reward code required");

        citizenPoints[msg.sender] -= points;

        emit RewardsRedeemed(
            msg.sender,
            points,
            rewardCode
        );
    }

    // Read a complete recycling request
    function getRequest(
        uint256 requestId
    ) external view returns (WasteRequest memory) {

        require(
            requestId > 0 && requestId <= requestCount,
            "Invalid request ID"
        );

        return requests[requestId];
    }

    // Read citizen's points and approved recycling count
    function getCitizenStats(
        address citizen
    ) external view returns (uint256 points, uint256 approvedCount) {

        return (
            citizenPoints[citizen],
            approvedSubmissions[citizen]
        );
    }

    // Check whether a recycling proof has already been used
    function isEvidenceUsed(
        bytes32 evidenceHash
    ) external view returns (bool) {

        return usedEvidence[evidenceHash];
    }
}
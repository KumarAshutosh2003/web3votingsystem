// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BlockchainVoting {
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    struct Voter {
        bool registered;
        bool hasVoted;
    }

    address public admin;
    mapping(address => Voter) public voters;
    mapping(uint => Candidate) public candidates;
    uint public candidatesCount;
    bool public votingOpen;

    event CandidateAdded(uint id, string name);
    event VoterRegistered(address voter);
    event Voted(address voter, uint candidateId);
    event VotingStatusChanged(bool open);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action.");
        _;
    }

    modifier onlyWhileVotingOpen() {
        require(votingOpen, "Voting is not open.");
        _;
    }

    constructor() {
        admin = msg.sender;
        votingOpen = false;
    }

    function addCandidate(string memory _name) public onlyAdmin {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
        emit CandidateAdded(candidatesCount, _name);
    }

    function registerVoter(address _voter) public onlyAdmin {
        require(!voters[_voter].registered, "Voter is already registered.");
        voters[_voter] = Voter(true, false);
        emit VoterRegistered(_voter);
    }

    function startVoting() public onlyAdmin {
        require(!votingOpen, "Voting is already open.");
        votingOpen = true;
        emit VotingStatusChanged(true);
    }

    function endVoting() public onlyAdmin {
        require(votingOpen, "Voting is already closed.");
        votingOpen = false;
        emit VotingStatusChanged(false);
    }

    function vote(uint _candidateId) public onlyWhileVotingOpen {
        require(voters[msg.sender].registered, "You are not a registered voter.");
        require(!voters[msg.sender].hasVoted, "You have already voted.");
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate ID.");

        voters[msg.sender].hasVoted = true;
        candidates[_candidateId].voteCount++;

        emit Voted(msg.sender, _candidateId);
    }

    function getCandidate(uint _id) public view returns (uint, string memory, uint) {
        require(_id > 0 && _id <= candidatesCount, "Invalid candidate ID.");
        Candidate memory candidate = candidates[_id];
        return (candidate.id, candidate.name, candidate.voteCount);
    }

    function getWinner() public view returns (string memory winnerName, uint winnerVotes) {
        require(!votingOpen, "Voting is still in progress.");
        
        uint highestVotes = 0;
        uint winnerId = 0;

        for (uint i = 1; i <= candidatesCount; i++) {
            if (candidates[i].voteCount > highestVotes) {
                highestVotes = candidates[i].voteCount;
                winnerId = i;
            }
        }

        if (winnerId > 0) {
            return (candidates[winnerId].name, candidates[winnerId].voteCount);
        } else {
            return ("No winner yet", 0);
        }
    }
}

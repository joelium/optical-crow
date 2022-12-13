// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

// @dev Fixes Ownable.sol import when testing
import "./Ownable.sol";

/**
 * @title Super Blockchain Voting Thing
 * @author 733t c0d3r
 * @notice This contract has been inspired by: 
    - Blockgeeks - How To Code Ethereum Election Smart Contract - https://www.youtube.com/watch?v=ucszgKGFnwc
    - The default example contract 3_Ballot.sol in Remix IDE
 
 * @dev Efficiency can be improved by having the poll options added as a single array in one block
 */


// @dev Contract for creating a poll
contract Poll is Ownable {

    // @dev Data structure defining Voter
    struct Voter {
        bool voted; // has the person voted already
        uint choice; // which option the voter has chosen
        bool canVote; // can the voter vote
    }

    // @dev Data structure defining VotingOption
    struct VotingOption {
        string name; // name of option to be voted on
        uint count; // count of votes for option
    }

    address public pollOwner; // organiser of the poll
    string public pollName; // name of the poll
    uint public pollCloseTime; // Time to close the poll

    mapping(address => Voter) public voters; // list of voters

    VotingOption[] public pollOptions; // Create an array of datatype VotingOption

    // @dev Modifier to check poll is still open
    modifier pollOpen {
        require(block.timestamp <= pollCloseTime, "This poll is now closed.");
        _;
    }

    // @dev Create new poll
    function createPoll(string memory _name, uint _pollCloseTimeHours) public {
        pollOwner = msg.sender;
        voters[pollOwner].canVote = true; // Assign organiser can vote
        pollName = _name;
        pollCloseTime = block.timestamp + (_pollCloseTimeHours * 1 hours);
    }

    // @dev Add a polling option. Only the poll owner can call it
    function addOption(string memory _name) public onlyOwner pollOpen {
        VotingOption memory optionName = VotingOption(_name, 0); // define option with vote count = 0
        pollOptions.push(optionName); // Add option to array pollOptions
    }

    // @dev Adds a voter
    function addVoter(address _voter) public onlyOwner pollOpen {
        voters[_voter].canVote = true; // sets voters ability to vote
    }

    // @dev Function to vote
    function vote(uint _voteIndex) public pollOpen {
        require(voters[msg.sender].canVote == true); // check voter can vote
        // if voter has already voted
        if (voters[msg.sender].voted == true) {
            uint previousChoice = voters[msg.sender].choice; // get voters previous choice
            pollOptions[previousChoice].count -= 1; // remove 1 from the count of the previous choice
        }

        voters[msg.sender].voted = true; // record voter as having voted
        voters[msg.sender].choice = _voteIndex; // record the voters choice
        pollOptions[_voteIndex].count += 1; // add 1 to the count of the voters choice
    }

    // @dev Gets counts for the poll options
    function returnPollOptionCounts() public view returns(VotingOption[] memory) {
        VotingOption[] memory pollCounts = new VotingOption[](pollOptions.length);

        for (uint i = 0; i < pollOptions.length; i++) {
            pollCounts[i] = pollOptions[i];
        }
        return pollCounts;
    }
}
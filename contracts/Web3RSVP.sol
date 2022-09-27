// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Web3RSVP{

    //a struct that stores the event details 
    struct CreateEvent {
        bytes32 eventID;
        string eventDataCID;
        address eventOwner;
        uint256 eventTimestamp;
        uint256 deposit;
        uint256 maxCapacity;
        address[] confirmedRSVPs;
        address[] claimedRSVPs;
        bool paidOut;
    }
    // a mapping that maps a unique event id to the event
    mapping(bytes32 => CreateEvent) public idToEvent;

    //a function that creates new events
    function createNewEvent(
        uint256 eventTimestamp,
        uint256 deposit,
        uint256 maxCapacity,
        string calldata eventDataCID
    ) external {
        //generate an eventID based on other things passed in to generate a hash
        bytes32 eventId = keccak256(abi.encodePacked(
                                        msg.sender,
                                        address(this),
                                        eventTimestamp,
                                        deposit,
                                        maxCapacity
                                    )
                                );

        address[] memory confirmedRSVPs;
        address[] memory claimedRSVPs;

        //this creates a new CreateEvent struct and adds it to the idToEvent mapping
        idToEvent[eventId] = CreateEvent(
            eventId,
            eventDataCID,
            msg.sender,
            eventTimestamp,
            deposit,
            maxCapacity,
            confirmedRSVPs,
            claimedRSVPs,
            false
        );
    }
}
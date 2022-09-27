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
    
}
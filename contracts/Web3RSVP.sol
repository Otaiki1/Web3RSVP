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

        //to ensure the id isnt already claimed
        require(idToEvent[eventId].eventTimestamp == 0, "ALREADY REGISTERED");

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
    //function that allows people rsvp to events
    function createNewRSVP(bytes32 eventId) external payable{
        //look up event fro our mapping
        CreateEvent storage myEvent = idToEvent[eventId];

        //transfer deposit to our contract/ require that they sned in enough ether to cover deposit amt of the specific event
        require(msg.value == myEvent.deposit, "NOT ENOUGH");

        //require that the event hasnt alrready happened ref. to event timestamp 
        require(block.timestamp <= myEvent.eventTimestamp, "ALREADY HAPPENED");

        //make sure event is under max capacity
        require(
            myEvent.confirmedRSVPs.length < myEvent.maxCapacity, "EVENT FULL"
        );

        //require that msg.sender hasnt already RSVP`d
        for (uint8 i = 0; i < myEvent.confirmedRSVPs.length; i++){
            require(myEvent.confirmedRSVPs[i] != msg.sender);
        }

        myEvent.confirmedRSVPs.push(payable(msg.sender));
    }
    // afunction that checks in single attendees
    function confirmAttendee(bytes32 eventId, address attendee) public {
        //look up event from our struct using the event id
        CreateEvent storage myEvent = idToEvent[eventId];

        //ensure only host of event can confirm attendee
        require(msg.sender == myEvent.eventOwner, "NOT AUTHORIZED");

        //require that attendee trying to check in actually RSVP`d
        address rsvpConfirm;
        for(uint8 i = 0; i < myEvent.confirmedRSVPs.length; i++){
            if(myEvent.confirmedRSVPs[i] == attendee){
                rsvpConfirm = myEvent.confirmedRSVPs[i];
            }
        }
        require(rsvpConfirm == attendee, "NO RSVP TO CONFIRM");
        
        //reuire that attendee hasnt already claiimed
        for(uint8 i = 0; i < myEvent.claimedRSVPs.length; i++){
            require(myEvent.claimedRSVPs[i] != attendee, "ALREADY CLAIMED");
        }

        //require that event owner hasnt claimed deposits
        require(myEvent.paidOut == false, "ALREADY PAID OUT");

        //add attendee to claimed RSVPs list
        myEvent.claimedRSVPs.push(attendee);

        //sending eth back to the staker
        (bool sent,) = attendee.call{value: myEvent.deposit}("");

        // if it fails, stll remove the person from the claimedRSVPs
        if(!sent){
            myEvent.claimedRSVPs.pop();
        }

        require(sent, "ETHER NOT SENT");
    }
    
}
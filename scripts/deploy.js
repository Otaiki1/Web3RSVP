const hre = require("hardhat");

const main = async() => {

  const rsvpContractFactory = await hre.ethers.getContractFactory("Web3RSVP");
  const rsvpContract = await rsvpContractFactory.deploy();
  await rsvpContract.deployed();
  console.log("Contract deployed to ", rsvpContract.address);

  //test like setting
  //get all accounts
  const[deployer, addr1, addr2] = await hre.ethers.getSigners();

  //setup mock data
  let deposit = hre.ethers.utils.parseEther("1");
  let maxCapacity  = 3;
  let timestamp = 1664443216;
  let eventDataCID = "bafybeibhwfzx6oo5rymsxmkdxpmkfwyvbjrrwcl7cekmbzlupmp5ypkyfi";


  //Create new event with mock data
  let txn  = await rsvpContract.createNewEvent(
    timestamp,
    deposit,
    maxCapacity,
    eventDataCID
  )
  let wait = await txn.wait();
  console.log("NEW EVENT CREATED____------____", wait.events[0].event, wait.events[0].args)

  //store the event id from the events emitted
  let eventID = wait.events[0].args.eventId;
  console.log("EVENT ID IS _______------_____", eventID);

  //mimick the whole RSVPing that happens

  //deployer RSVPs
  txn = await rsvpContract.createNewRSVP(eventID, {value: deposit});
  wait = await txn.wait();
  console.log("NEW RSVP::____----__", wait.events[0].event, wait.events[0].args);

  //address1 RSVPs
  txn  = await rsvpContract.connect(addr1).createNewRSVP(eventID, {value: deposit});
  wait = await txn.wait();
  console.log("NEW RSVP::____----__", wait.events[0].event, wait.events[0].args);

  //address2 RSVPs
  txn  = await rsvpContract.connect(addr2).createNewRSVP(eventID, {value: deposit});
  wait = await txn.wait();
  console.log("NEW RSVP::____----__", wait.events[0].event, wait.events[0].args);




}

const runMain  = async() => {
  try{
    await main();
    process.exit(0)
  }catch(err){
    console.log(err);
    process.exit(1);
  }
}

runMain();
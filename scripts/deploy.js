const hre = require("hardhat");

const main = async() => {}

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
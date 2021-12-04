// Copyright (c) 2018 p5ble
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

// The serviceUuid must match the serviceUuid of the device you would like to connect
const serviceUuidA = "72f99129-592c-4ed2-b6e2-8754c03c2f0f";
const serviceUuidB = "a9edf38d-296c-4bd7-9289-eb70656c4fe2";
let gyroXa = 0, gyroYa = 0, gyroZa = 0;
let gyroXb = 0, gyroYb = 0, gyroZb = 0;
let xCharactersticA;
let xCharactersticB;
let myBLEa, myBLEb;

function setup() {
 
  // Create a p5ble class
  myBLEa = new p5ble();
  myBLEb = new p5ble();

  let cnv = createCanvas(500, 200);
  //cnv.position(0, 0, 'fixed');
  
  textSize(20);
  textAlign(LEFT, CENTER);

  // Create a 'Connect' button
  const connectAButton = createButton('Connect A')
  connectAButton.parent(document.getElementById("container"))
  connectAButton.position(10, 10);
  connectAButton.mousePressed(connectToBleA);
  const connectBButton = createButton('Connect B')
  connectBButton.parent(document.getElementById("container"))
  connectBButton.position(100, 10);
  connectBButton.mousePressed(connectToBleB);
  console.log("P5  setup done")
}

function connectToBleA() {
  // Connect to a device by passing the service UUID
  myBLEa.connect(serviceUuidA, gotCharacteristicsA);
  
}

function connectToBleB() {
  // Connect to a device by passing the service UUID
  myBLEb.connect(serviceUuidB, gotCharacteristicsB);
  
}


// A function that will be called once got characteristics
function gotCharacteristicsA(error, characteristics) {
  if (error) console.log('error: ', error);
  console.log('characteristics: ', characteristics);
  xCharactersticA = characteristics[0];


  //gyroY = characteristics[1];
  //gyroZ = characteristics[2];

  // Read the value of the first characteristic
  myBLEa.read(xCharactersticA, 'string',gotXValueA);

  //myBLE.read(gyroY, gotValue);
 // myBLE.read(gyroZ, gotValue);
}



// A function that will be called once got characteristics
function gotCharacteristicsB(error, characteristics) {
  if (error) console.log('error: ', error);
  console.log('characteristics: ', characteristics);
  xCharactersticB = characteristics[0];


  //gyroY = characteristics[1];
  //gyroZ = characteristics[2];

  // Read the value of the first characteristic
  myBLEb.read(xCharactersticB, 'string', gotXValueB);

  //myBLE.read(gyroY, gotValue);
 // myBLE.read(gyroZ, gotValue);
}



// A function that will be called once got values
function gotXValueA(error, value) {
  if (error) console.log('error: ', error);
  
  gyroA = value;
  gyroXa = gyroA.substring(0,4)
  gyroYa = gyroA.substring(4,8)
  gyroZa = gyroA.substring(8,11)
  gyroXa -=2
  gyroYa -=2
  gyroZa -=2


  console.log('value xa: ', gyroXa);
  console.log('value ya: ', gyroYa);
  console.log('value za: ', gyroZa);

  // After getting a value, call p5ble.read() again to get the value again
  myBLEa.read(xCharactersticA,'string',gotXValueA);

  // You can also pass in the dataType
  // Options: 'unit8', 'uint16', 'uint32', 'int8', 'int16', 'int32', 'float32', 'float64', 'string'
  // myBLE.read(myCharacteristic, 'string', gotValue);
}

// A function that will be called once got values
function gotXValueB(error, value) {
  if (error) console.log('error: ', error);
  
  gyroB = value;
  gyroXb = gyroB.substring(0,4)
  gyroYb = gyroB.substring(4,8)
  gyroZb = gyroB.substring(8,11)
  gyroXb -=2
  gyroYb -=2
  gyroZb -=2


  console.log('value xb: ', gyroXb);
  console.log('value yb: ', gyroYb);
  console.log('value zb: ', gyroZb);

  // After getting a value, call p5ble.read() again to get the value again
  myBLEb.read(xCharactersticB,'string',gotXValueB);

  // You can also pass in the dataType
  // Options: 'unit8', 'uint16', 'uint32', 'int8', 'int16', 'int32', 'float32', 'float64', 'string'
  // myBLE.read(myCharacteristic, 'string', gotValue);
}



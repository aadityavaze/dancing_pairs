  // Copyright (c) 2018 p5ble
  //
  // This software is released under the MIT License.
  // https://opensource.org/licenses/MIT

  // The serviceUuid must match the serviceUuid of the device you would like to connect
  const serviceUuidA = "72f99129-592c-4ed2-b6e2-8754c03c2f0f";
  const serviceUuidB = "a9edf38d-296c-4bd7-9289-eb70656c4fe2";
  let gyroXa = 10, gyroYa = 0, gyroZa = 0;
  let gyroXb = 10, gyroYb = 0, gyroZb = 0;
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
    console.log("P5 setup done")
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

    myBLEa.read(xCharactersticA, 'string',gotXValueA);
    

  }



  // A function that will be called once got characteristics
  function gotCharacteristicsB(error, characteristics) {
    if (error) console.log('error: ', error);
    console.log('characteristics: ', characteristics);
    xCharactersticB = characteristics[0];
    // Read the value of the first characteristic
    myBLEb.read(xCharactersticB, 'string', gotXValueB);

  }



  // A function that will be called once got values
  function gotXValueA(error, value) {
    if (error) console.log('error: ', error);
    
    gyroA = value;
    const accValues = gyroA.split(" ");
   

    gyroXa = accValues[0]
    gyroYa = accValues[1]
    gyroZa = accValues[2]
  


   
    // console.log('value ya: ', gyroYa);
    // console.log('value za: ', gyroZa);

    myBLEa.read(xCharactersticA,'string',gotXValueA);

  }

  function gotXValueB(error, value) {
    if (error) console.log('error: ', error);
    
    gyroB = value;
    const accValues = gyroB.split(" ");
    // console.log('array: ', accValues);

    gyroXb = accValues[0]
    gyroYb = accValues[1]
    gyroZb = accValues[2]
  

    // console.log('value xb: ', gyroXb);
    // console.log('value yb: ', gyroYb);
    // console.log('value zb: ', gyroZb);

    myBLEb.read(xCharactersticB,'string',gotXValueB);
  }



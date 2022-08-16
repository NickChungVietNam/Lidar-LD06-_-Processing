// Example byPhung Thai Son 
// https://www.ldrobot.com/editor/file/20210422/1619071627351038.pdf 

import processing.serial.*;

// The serial port:
Serial myPort;       


void setup(){
  
// List all the available serial ports:
printArray(Serial.list());
size( 1900, 1000);
// Open the port you are using at the rate you want
background(0);  
PFont f= createFont("Arial",16,true); 
if( Serial.list().length <=0){
  while(true){
    String err_st = " Not found any USB COM port available ! Please plug the USB CP2102 module! ";
  
  textFont(f,20);                  // STEP 3 Specify font to be used
  fill( 255, 0,0 );            
    
    text(err_st,10,100);
     println(err_st); 
     delay(10000);
  }
}

myPort = new Serial(this, Serial.list()[0], 230400);
  
// Send a capital A out the serial port:
noStroke();
fill( 0,255,0);


}


 long stml =0;
 int GHGH=10000;
void draw(){

  
  //circle(   width/2 ,   height/2 , 20 );
  
  while (myPort.available() > 0) {
    

  if( millis() > stml){
    delay(10);
    background(0);
    stml = millis() + 1000;
  }
    
    
    
    int in = myPort.read()&0x000000ff; // b11111111
    
    PARSE_FRAME_UART_LIDAR_IN(    in );
     
  }
}

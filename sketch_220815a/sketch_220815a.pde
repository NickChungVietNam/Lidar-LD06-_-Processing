// Example byPhung Thai Son 
// https://www.ldrobot.com/editor/file/20210422/1619071627351038.pdf 

import processing.serial.*;

// The serial port:
Serial myPort;       


void setup(){
  
// List all the available serial ports:
printArray(Serial.list());
size( 1900, 1000);
// Open the port you are using at the rate you want:
myPort = new Serial(this, Serial.list()[0], 230400);
  
// Send a capital A out the serial port:
background(0);
noStroke();
fill( 0,255,0);


}
final int Max_size_Data_fr = 1000;
int Data_fr[] =new int[Max_size_Data_fr];
int Count_size_Data_fr = 0 ;
int SIZE_OF_FRAME = 0;
boolean Had_Header = false;
int Data_Length = 0;

void Reset_add_frame(){
 SIZE_OF_FRAME = 0;
 Had_Header = false;
 Data_Length = 0;
 Count_size_Data_fr = 0 ;
}

int LOW_HIGH_byte( int LOW_Byte_i , int HIGH_Byte_i ){
  
                int value = (HIGH_Byte_i << 8)&0xff00;
                    value|= (LOW_Byte_i&0x00ff) ;
                    
                    return value;
}
final int ANGLE_PER_FRAME = 12;
 long stml =0;
 int GHGH=10000;
void draw(){

  
  //circle(   width/2 ,   height/2 , 20 );
  
  while (myPort.available() > 0) {
    

  if( millis() > stml){
    delay(50);
    background(0);
    stml = millis() + 100;
  }
    
    int in = myPort.read()&0x000000ff; // b11111111
    if( !Had_Header ){
      if(  in ==  0x54){
         Had_Header = true;
     }
    }else{
       if(  Data_Length == 0){
         if( 
         //0 < in &&  in <= 256
          in  == 0x2c
         ){
            Data_Length = in ;
            SIZE_OF_FRAME =  1 //Header 
                            + 1 //Data_Length
                             + 2 //Radar Speed 
                             +2 //Start Angle
                             + ANGLE_PER_FRAME*3 
                             +2 //End Angle
                             +2 // Timestamp
                             + 1 // CRC check
                             ;// = 11 + 36 = 47
           
             Data_fr[0]            =      0x54; 
             Data_fr[1]            =      Data_Length;
             Count_size_Data_fr=2;
         }else{
           Reset_add_frame();
         }
         
       }else{
            
             Data_fr[Count_size_Data_fr]  = in&0xff ;
             Count_size_Data_fr++;
            if( Count_size_Data_fr >= SIZE_OF_FRAME){
              
           
              int CRC_ =  Data_fr[ 6+ ANGLE_PER_FRAME*3+4];
              int crc_CHECK  = CalCRC8( Data_fr , SIZE_OF_FRAME -1 );
              if( CRC_ == crc_CHECK ){
                
                int Radar_speed = LOW_HIGH_byte(Data_fr[ 2] , Data_fr[ 3]);
              int Start_angle = LOW_HIGH_byte(Data_fr[ 4] , Data_fr[ 5]);
              
              int Stop_angle = LOW_HIGH_byte(
               Data_fr[ 6+ ANGLE_PER_FRAME*3] ,
               Data_fr[ 6+ ANGLE_PER_FRAME*3+1]);
               
              float Start_angle_float =  (float)(Start_angle)/100 ;
              float Stop_angle_float =  (float)(Stop_angle)/100 ;
              
              int Time_stemp = LOW_HIGH_byte(
               Data_fr[ 6+ ANGLE_PER_FRAME*3+2] ,
               Data_fr[ 6+ ANGLE_PER_FRAME*3+3]);
                
               float step_angle = ( Stop_angle_float -Start_angle_float )/12; 
              for( int ri = 0; ri < ANGLE_PER_FRAME ; ri++){
                int LOW_Byte_i =  Data_fr[ 6 + ri*3];
                int HIGH_Byte_i =  Data_fr[ 6 + ri*3+1];
                int Confidence_i =  Data_fr[ 6 + ri*3+2];
                
                float Distance = (float)LOW_HIGH_byte(      LOW_Byte_i , HIGH_Byte_i );
                
                 
                float angle_rad = (Start_angle_float + step_angle *ri )*(PI/180);//
                float X = width/2+   Distance * cos( angle_rad)/20;
                float Y = height/2+   (Distance * sin( angle_rad)) /20;
               
                    noStroke();
                    stroke( 255,0,0);//rgb 
                    circle( X  ,   Y , 10 );GHGH++ ;
                    line( X  ,   Y  ,  width/2 , height/2);
                    
              }
              
              if( Stop_angle_float >350 ){
                 //background(0);
              }
              
              print(" Data_Length = " + Data_Length  ); 
              print(", Radar_speed = " + Radar_speed  ); 
              print(", Start_angle = " + (float)(Start_angle)/100  ); 
              print(", Stop_angle = " + (float)(Stop_angle)/100  ); 
             
                
              }
              
              print(",  CRC_ [" + CRC_ +"-"  +  crc_CHECK); 
              println();
              Reset_add_frame() ;
              
            }
       }
    }
     
  }
}


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


 final int CrcTable[] =
{
 0x00, 0x4d, 0x9a, 0xd7, 0x79, 0x34, 0xe3,
 0xae, 0xf2, 0xbf, 0x68, 0x25, 0x8b, 0xc6, 0x11, 0x5c, 0xa9, 0xe4, 0x33,
 0x7e, 0xd0, 0x9d, 0x4a, 0x07, 0x5b, 0x16, 0xc1, 0x8c, 0x22, 0x6f, 0xb8,
 0xf5, 0x1f, 0x52, 0x85, 0xc8, 0x66, 0x2b, 0xfc, 0xb1, 0xed, 0xa0, 0x77,
 0x3a, 0x94, 0xd9, 0x0e, 0x43, 0xb6, 0xfb, 0x2c, 0x61, 0xcf, 0x82, 0x55,
 0x18, 0x44, 0x09, 0xde, 0x93, 0x3d, 0x70, 0xa7, 0xea, 0x3e, 0x73, 0xa4,
 0xe9, 0x47, 0x0a, 0xdd, 0x90, 0xcc, 0x81, 0x56, 0x1b, 0xb5, 0xf8, 0x2f,
 0x62, 0x97, 0xda, 0x0d, 0x40, 0xee, 0xa3, 0x74, 0x39, 0x65, 0x28, 0xff,
 0xb2, 0x1c, 0x51, 0x86, 0xcb, 0x21, 0x6c, 0xbb, 0xf6, 0x58, 0x15, 0xc2,
 0x8f, 0xd3, 0x9e, 0x49, 0x04, 0xaa, 0xe7, 0x30, 0x7d, 0x88, 0xc5, 0x12,
 0x5f, 0xf1, 0xbc, 0x6b, 0x26, 0x7a, 0x37, 0xe0, 0xad, 0x03, 0x4e, 0x99,
 0xd4, 0x7c, 0x31, 0xe6, 0xab, 0x05, 0x48, 0x9f, 0xd2, 0x8e, 0xc3, 0x14,
 0x59, 0xf7, 0xba, 0x6d, 0x20, 0xd5, 0x98, 0x4f, 0x02, 0xac, 0xe1, 0x36,
 0x7b, 0x27, 0x6a, 0xbd, 0xf0, 0x5e, 0x13, 0xc4, 0x89, 0x63, 0x2e, 0xf9,
 0xb4, 0x1a, 0x57, 0x80, 0xcd, 0x91, 0xdc, 0x0b, 0x46, 0xe8, 0xa5, 0x72,
 0x3f, 0xca, 0x87, 0x50, 0x1d, 0xb3, 0xfe, 0x29, 0x64, 0x38, 0x75, 0xa2,
 0xef, 0x41, 0x0c, 0xdb, 0x96, 0x42, 0x0f, 0xd8, 0x95, 0x3b, 0x76, 0xa1,
 0xec, 0xb0, 0xfd, 0x2a, 0x67, 0xc9, 0x84, 0x53, 0x1e, 0xeb, 0xa6, 0x71,
 0x3c, 0x92, 0xdf, 0x08, 0x45, 0x19, 0x54, 0x83, 0xce, 0x60, 0x2d, 0xfa,
 0xb7, 0x5d, 0x10, 0xc7, 0x8a, 0x24, 0x69, 0xbe, 0xf3, 0xaf, 0xe2, 0x35,
 0x78, 0xd6, 0x9b, 0x4c, 0x01, 0xf4, 0xb9, 0x6e, 0x23, 0x8d, 0xc0, 0x17,
 0x5a, 0x06, 0x4b, 0x9c, 0xd1, 0x7f, 0x32, 0xe5, 0xa8
};

int CalCRC8(int p[], int len)
{
 int crc = 0;
 int i;
 for (i = 0; i < len; i++)
 {
 crc = CrcTable[(crc ^ p[i]) & 0xff]& 0xff;
 }
 return crc& 0xff;
}




boolean PARSE_FRAME_UART_LIDAR_IN(   int in ){
  
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
              return true;
            }
       }
    }
    
    return false;
}

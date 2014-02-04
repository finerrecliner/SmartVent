// SmartVent
#include <Servo.h> 
#include <Math.h>
 
Servo myservo;   // create servo object to control a servo 
int pos = 0;     // variable to store the servo position 
int incomingInt; // must decode ASCII serial data to an int
int temp = 69;   // temperature from thermistor
 
void setup() 
{ 
  myservo.attach(9);  // attaches the servo on pin 9 to the servo object 
  Serial.begin(9600); // setup serial connection for controller
}
 
void loop() 
{ 
        Serial.print("I am in position: ");
        Serial.println(pos);
        Serial.print("Thermistor value: ");
        temp = Thermister(analogRead(0));
        Serial.println(temp);
        delay(1000);
} 

void serialEvent() 
{
        // Listen for data on serial port
        while(Serial.available() > 0) {
                // read the incoming ASCII as an integer
                incomingInt = Serial.parseInt();
                
                Serial.print("I heard: ");
                Serial.println(incomingInt);
                
                if(incomingInt <= 100){
                  // format for servo, 0-close, 100-open -> 0 open, 90 close
                  pos = 90 - (incomingInt * .9);
                  myservo.write(pos);
                  delay(15);
                }              
        } 
}

double Thermister(int RawADC) {
 double Temp;
 Temp = log(((10240000/RawADC) - 10000));
 Temp = 1 / (0.001129148 + (0.000234125 + (0.0000000876741 * Temp * Temp ))* Temp );
 Temp = Temp - 273.15;            // Convert Kelvin to Celcius
 Temp = (Temp * 9.0)/ 5.0 + 32.0; // Convert Celcius to Fahrenheit
 return Temp;
}

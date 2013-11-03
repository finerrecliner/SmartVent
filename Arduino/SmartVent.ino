// SmartVent
#include <Servo.h> 
#include <Math.h>
 
Servo myservo;   // create servo object to control a servo 
int pos = 0;     // variable to store the servo position 
int incomingInt; // must decode ASCII serial data to an int
int temp = 69;   // temperature from thermistor
 
void setup() 
{ 
  //myservo.attach(9);  // attaches the servo on pin 9 to the servo object 
  Serial.begin(9600); // setup serial connection for controller
}
 
void loop() 
{ 
        //Serial.print("I am in position: ");
        //Serial.println(pos);
        //Serial.print("Thermistor value: ");
        temp = Thermistor(analogRead(0));
        Serial.println(temp);
        delay(1000);
} 

/*
void serialEvent() 
{
        // Listen for data on serial port
        while(Serial.available() > 0) {
                // read the incoming ASCII as an integer
                incomingInt = Serial.parseInt();
                
                Serial.print("I heard: ");
                Serial.println(incomingInt);
                
                if(incomingInt <= 100){
                  // format for servo, in 0-close, 100-open -> 0 open, 90 close
                  pos = incomingInt;
                  myservo.write(pos);
                  delay(15);
                }              
        } 
}


double ThermistorSimple(int RawADC) {
 double Temp;
 Temp = log(((10240000/RawADC) - 10000));
 Temp = 1 / (0.001129148 + (0.000234125 + (0.0000000876741 * Temp * Temp ))* Temp );
 Temp = Temp - 273.15;            // Convert Kelvin to Celcius
 Temp = Temp + 32; // offset for calibration
 //Temp = (Temp * 9.0)/ 5.0 + 32.0; // Convert Celcius to Fahrenheit
 return Temp;
}
*/

double Thermistor(int RawADC) {
 // Inputs ADC Value from Thermistor and outputs Temperature in Celsius
 //  requires: include <math.h>
 // Utilizes the Steinhart-Hart Thermistor Equation:
 //    Temperature in Kelvin = 1 / {A + B[ln(R)] + C[ln(R)]^3}
 //    where A = 0.001129148, B = 0.000234125 and C = 8.76741E-08
 long Resistance;  double Temp; double Vout;  // Dual-Purpose variable to save space.
 Vout = RawADC * .0048203125; // convert 0-1024 ADC reading to 0-4.936 ref voltage range (change for Vref on board)
 Resistance=((10000/Vout) - 10000);  // Thremistor R = (10k / Vout) - 10k
 Temp = log(Resistance); // Saving the Log(resistance) so not to calculate it 4 times later. // "Temp" means "Temporary" on this line.
 Temp = 1 / (0.001129148 + (0.000234125 * Temp) + (0.0000000876741 * Temp * Temp * Temp));   // Now it means both "Temporary" and "Temperature"
 Temp = Temp - 273.15;  // Convert Kelvin to Celsius                                         // Now it only means "Temperature"


 // BEGIN- Remove these lines for the function not to display anything
  Serial.print("ADC: "); Serial.print(RawADC); Serial.print("/1024");  // Print out RAW ADC Number
  Serial.print(", Volts: "); Serial.print(((RawADC*3.181)/1024.0),3);   // 4.936 volts is what my USB Port outputs.
  Serial.print(", Resistance: "); Serial.print(Resistance); Serial.println("ohms");
 // END- Remove these lines for the function not to display anything

 // Uncomment this line for the function to return Fahrenheit instead.
 //Temp = (Temp * 9.0)/ 5.0 + 32.0; // Convert to Fahrenheit
 return Temp;  // Return the Temperature
}

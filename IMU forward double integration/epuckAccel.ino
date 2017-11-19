#include <MatrixMath.h>

//Make sure to use analogue pins

//IO
int Print = 0;
boolean START = false;
boolean STOP = false;
double lastmean=0;
//Data Sampling
int readIndex = 0;
int DELAY = 1;//50
int initialWait = 15000;
int NUMREADINGS = 1000+initialWait/DELAY;

double restdetected=false;
//Pin setup
//int Vin = 12;
//int XPIN = 11;
int XPIN = A1;//10;
int YPIN = A0;//10;
int ZPIN = A2;//9;
//int Gnd = A2;



//Accelerometer Reading
int xValue=0;
int yvalue=0;
int zValue=0;



//STATE SPACE MATRICES
#define N 2
#define M 1
double X[N][1];
double Xdot[1][N];
double A[N][N];
double B[N][1];
double U=0;
double C1[1][N];
double C3[1][N];
//double C[2][N];

double x1=0.0;
double x2=0.0;
double x3=0.0;

double x1pred;
double x2pred;

double x1model;
double x2model;
double x1modelprev;
double x2modelprev;

double dt=0.004;
double base = -349;
double origbase=base;

#define WINDOW 5
double accels[WINDOW];
double honestaccels[WINDOW];

void setup() {
  // put your setup code here, to run once:
  //Begin Serial communication
  Serial.begin(115200);
  START = true;
  Serial.println("START");
  Serial.println("Calibrating....please go for a walk for 10 sec");
  //pinMode(Vin,OUTPUT);
  //pinMode(XPIN,INPUT);
  pinMode(YPIN,INPUT);
 // pinMode(ZPIN,INPUT);
  //pinMode(Gnd,OUTPUT);  
  //State Space
  //Serial.println("\nSTATE SPACE");
    //A
    /////CONTINUOUS
    //A[0][1]=1;  
    /////DISCRETE
  A[0][0]=1;  
  A[0][1]=dt;  
  A[1][1]=1;
  
   //B
/////CONTINUOUS
   //B[1][0]=1;
/////DISCRETE
  B[0][0]=0.5*dt*dt;
  B[1][0]=dt;

  //MatrixPrint((double*)B, N, 1, "B");
    //C1

  C1[0][0]=1;

  //MatrixPrint((double*)C1, 2, N, "C");

  x1model = 0;
  x2model = 0;

}

void(* resetFunc) (void) = 0; //declare reset function @ address 0

void loop() {
      
      double t1 = micros();
      double meanthresh=0.18;//0.6;//0.22;
      double covarthresh = 1.4;//0.6;
      
      //reading
      double z = analogRead(YPIN);
      z*=-1;
      //Serial.print(" zValue is: ");
      //Serial.print(z);
      
      //Serial.print(" base is: ");
      //Serial.print(base);
      
      double zValue = (z-base)/70;//70;
      Serial.print("honest accel is: ");
      Serial.print(zValue);
      Serial.print(", ");
      
      int i=0;
      for (i=0; i<WINDOW-1;i++) {
         honestaccels[i]=honestaccels[i+1];
        }
        honestaccels[i]=zValue;

      double mean=0;
      for (i=0; i<WINDOW;i++) {
        mean+=honestaccels[i];
      }
      mean/=WINDOW;
      
      //rest detection     
      double covar=0;
      for (i=0; i<WINDOW;i++)  {
        covar+=abs(honestaccels[i]-mean);
      }
      
      Serial.print(" MEAN is: ");
      Serial.print(mean);
      Serial.print(" COVAR is: ");
      Serial.print(covar);
      Serial.print(", ");
      
      //if ((abs(mean)<(meanthresh))&&(covar<covarthresh)) {
      if ((covar<covarthresh)&&(abs(mean)<meanthresh)) {
        restdetected=true;
        //Serial.print("REST DETECTED, ");
        base+=round(mean*10);
        U=0;
        x2model=0;
      } else  {
        U=mean;
        restdetected=false;
      }
      
      //Model X
      x1modelprev = x1model;
      x2modelprev = x2model;
      double CCC = C1[0][0]; 
      Serial.print(", Accel is: ");
      Serial.print(U);
      Serial.print(", ");
      
      x1model = A[0][0]*x1modelprev + A[0][1]*x2modelprev + B[0][0]*U;//A[0][2]*x3 + B[0][0]*U;
      x2model = A[1][0]*x1modelprev + A[1][1]*x2modelprev + B[1][0]*U;//A[1][2]*x3 + B[1][0]*U;
    
      
      double ymodel = CCC*x1model;    
      Serial.print(ymodel*-100);
      Serial.print(", ");
//      Serial.print(ymodel*-100*1.5);
//      Serial.print(", ");
      if (restdetected){
        Serial.print("1, ");
        Serial.print("REST DETECTED, ");
      }else
        Serial.print("0, ");
        
      
      
      int d = dt*1000;
        lastmean=mean;  
      double t2 = micros();
      double t = t2-t1;
      dt=t*0.001*0.001;
//      Serial.print(t);
      Serial.println();

      delay(d); // wait, ie enforcing the sample period
}


#include <Servo.h> 

//LED de Calibragem
const int LED_CONTROLE = 13;

//LDRs
const int S_ESQ = A5;
const int S_DIR = A3;

//
const int DIFF = 50;

int avgLdrBranco;
int avgLdrPreto;

//Servo

//O servo vai de 0 a 90. Nesse caso, deve ser calibrado para parar nos 45,
//e assim ele irá rodar para trás abaixo dos 45 e para frente acima dos 45.
const int VEL_MAX = 45;
const int VEL_MIN = 5;
const int STOP = 45;

Servo rodaDir;
Servo rodaEsq;

void setup() {
  Serial.begin(9600);

  pinMode(LED_CONTROLE, OUTPUT);

  //Inicialização dos LDRs
  pinMode(S_ESQ, INPUT);
  pinMode(S_DIR, INPUT);
  
  rodaDir.attach(11);
  rodaEsq.attach(10);
  delay(10);
  parar();

  inicializar();
}

//Posicionar o LDR direito na faixa preta
void inicializar() {  
  digitalWrite(LED_CONTROLE, HIGH);

  delay(2000);

  //Fazendo a leitura da iluminação média padrão
  for(int i = 0; i < 10; i++) {
    avgLdrBranco += analogRead(S_ESQ);
    avgLdrPreto += analogRead(S_DIR);
    delay(25);
  }
  avgLdrBranco = avgLdrBranco / 10;
  avgLdrPreto = avgLdrPreto / 10;
  
  digitalWrite(LED_CONTROLE, LOW);

  Serial.print("Padrão: Branco: "); Serial.print(avgLdrBranco);
  Serial.print(" - Preto: "); Serial.println(avgLdrPreto);
  
  delay(2000);
}

void loop() {
  int ldrEsq = analogRead(S_ESQ);
  int ldrDir = analogRead(S_DIR);
  
  Serial.print("esq: "); Serial.print(ldrEsq);
  Serial.print(" - dir: "); Serial.println(ldrDir);

  andar(ldrEsq, ldrDir);
  
  delay(25);
}

void andar(int ldrEsq, int ldrDir) {
  int diferencaDeLeituraPretoEsq = abs (avgLdrPreto - ldrEsq);
  int diferencaDeLeituraPretoDir = abs (avgLdrPreto - ldrDir);
  int diferencaDeLeituraBrancoDir = abs (avgLdrBranco - ldrDir);
  int diferencaDeLeituraBrancoEsq = abs (avgLdrBranco - ldrEsq);
  
  if (diferencaDeLeituraBrancoEsq > DIFF && diferencaDeLeituraBrancoDir > DIFF) {
    frente(VEL_MAX);
  } else {
    if( diferencaDeLeituraPretoEsq < DIFF ){
      //OPA! detectou preto, Vira pra Esqueda
      Serial.println("esquerda");
      esquerda(VEL_MAX);    
    } else if( diferencaDeLeituraPretoDir < DIFF ){
      //OPA! detectou preto, Vira pra Direita
      Serial.println("direita");
      direita(VEL_MAX);
    }  
  }
  
  
  
  
  /*if(avgLdrBranco - ldrEsq > DIFF) {
    Serial.println("esquerda");
    esquerda(VEL_MAX);
  }
  else if(avgLdrPreto - ldrDir > DIFF) {
    Serial.println("direita");
    direita(VEL_MAX);
  }
  else if(avgLdrCen - ldrCen > DIFF) {
    Serial.println("frente");
    frente(VEL_MAX);
  }
  else {
    Serial.println("parar");
    parar();
  }*/
}

void parar() {
  rodaDir.write(STOP);
  rodaEsq.write(STOP);
}

void frente(int vel) {
  if(vel > 45) {
    vel = 45;
  } else if(vel < 15) {
    vel = 15;
  }
  
  rodaDir.write(45 - vel);
  rodaEsq.write(vel + 45);
}

void recuar(int vel) {
  if(vel > 45) {
    vel = 45;
  } else if(vel < 15) {
    vel = 15;
  }
  
  rodaDir.write(vel + 45);
  rodaEsq.write(45 - vel);
}

void direita(int vel) {
  rodaDir.write(STOP);
  rodaEsq.write(vel + 45);
}

void esquerda(int vel) {
  rodaDir.write(45 - vel);
  rodaEsq.write(STOP);
}

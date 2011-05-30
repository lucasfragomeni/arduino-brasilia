#include <Servo.h> 

//LED de Calibragem
const int LED_CONTROLE = 13;

//LDRs
const int S_ESQ = A5;
const int S_DIR = A3;

//Média de leitura dos LDRs na superficie branca
int avgLdrEsq;
int avgLdrDir;

//Diferença de leitura dos LDRs
int avgLdrEsqDiff;
int avgLdrDirDiff;

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

  //Inicialização do LED de calibragem
  pinMode(LED_CONTROLE, OUTPUT);

  //Inicialização dos LDRs
  pinMode(S_ESQ, INPUT);
  pinMode(S_DIR, INPUT);
  
  rodaEsq.attach(10);
  rodaDir.attach(11);
  delay(10);
  parar();

  calibrarLDRs();
}

/**
 * Quando o LED ascender, posicione os LDRs sobre a superficie branca;
 * Quando o LED piscar, posicione os LDRs sobre a faixa preta.
 */
void calibrarLDRs() {  
  //Faz a leitura da iluminação média da superficie branca
  Serial.print("Calibrando branco... ");
  digitalWrite(LED_CONTROLE, HIGH);
  delay(2000);

  for(int i = 0; i < 10; i++) {
    avgLdrEsq += analogRead(S_ESQ);
    avgLdrDir += analogRead(S_DIR);
    delay(25);
  }
  avgLdrEsq = avgLdrEsq / 10;
  avgLdrDir = avgLdrDir / 10;
  Serial.print("esq: ");Serial.print(avgLdrEsq);Serial.print(" - dir: ");Serial.println(avgLdrDir);
  
  digitalWrite(LED_CONTROLE, LOW);

  //Avisa sobre a mudança na calibragem
  piscarLEDControle();

  //Faz a leitura da iluminação média da faixa preta
  Serial.print("Calibando preto... ");
  digitalWrite(LED_CONTROLE, HIGH);
  delay(2000);

  int avgLdrEsqPreto = 0;
  int avgLdrDirPreto = 0;

  for(int i = 0; i < 10; i++) {
    avgLdrEsqPreto += analogRead(S_ESQ);
    avgLdrDirPreto += analogRead(S_DIR);
    delay(25);
  }
  avgLdrEsqPreto = avgLdrEsqPreto / 10;
  avgLdrDirPreto = avgLdrDirPreto / 10;
  Serial.print("esq: ");Serial.print(avgLdrEsqPreto);Serial.print(" - dir: ");Serial.println(avgLdrDirPreto);
  
  digitalWrite(LED_CONTROLE, LOW);

  //Calcula a diferença média para cada LDR
  //Ex: (500 - 400) - 20 = 80
  Serial.print("Calculando diferenca media... ");
  avgLdrEsqDiff = (avgLdrEsq - avgLdrEsqPreto) - 20;
  avgLdrDirDiff = (avgLdrDir - avgLdrDirPreto) - 20;
  Serial.print("esq: ");Serial.print(avgLdrEsqDiff);Serial.print(" - dir: ");Serial.println(avgLdrDirDiff);

  piscarLEDControle();
}

void piscarLEDControle() {
  for(int i = 0; i < 4; i++) {
    digitalWrite(LED_CONTROLE, HIGH);
    delay(250);
    digitalWrite(LED_CONTROLE, LOW);
    delay(250);
  }
}

void loop() {
  andar(analogRead(S_ESQ), analogRead(S_DIR));
  delay(20);
}

void andar(int ldrEsq, int ldrDir) {
  int diferencaLeituraEsq = abs(avgLdrEsq - ldrEsq);//Ex: 500 - 496 = 4
  int diferencaLeituraDir = abs(avgLdrDir - ldrDir);//Ex: 520 - 543 = 23
  Serial.print("esq: ");Serial.print(avgLdrEsq);Serial.print(" (");Serial.print(diferencaLeituraEsq);Serial.print(") - ");
  Serial.print("dir: ");Serial.print(avgLdrDir);Serial.print(" (");Serial.print(diferencaLeituraDir);Serial.println(")");
  
  //TODO: tratar caso de linha transversal (obstáculo)
  if (diferencaLeituraEsq < avgLdrEsqDiff && diferencaLeituraDir < avgLdrDirDiff) {
    Serial.println("frente");
    frente(VEL_MAX);
  } else if(diferencaLeituraEsq > avgLdrEsqDiff) {
    //OPA! detectou preto, Vira pra Esquerda
    Serial.println("esquerda");
    esquerda();    
  } else if(diferencaLeituraDir > avgLdrDirDiff) {
    //OPA! detectou preto, Vira pra Direita
    Serial.println("direita");
    direita();
  }
}

//void procurar() {
//  recuar(VEL_MAX);
//  delay(250);
//  int direcao = random(0, 2);
//  if(direcao == 0) {
//    esquerda();
//    delay(250);
//  } else if(direcao == 1) {
//    direita();
//    delay(250);
//  }
//}

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
  
  rodaDir.write(45 - vel);//0
  rodaEsq.write(vel + 45);//90
}

void recuar(int vel) {
  if(vel > 45) {
    vel = 45;
  } else if(vel < 15) {
    vel = 15;
  }
  
  rodaDir.write(vel + 45);//90
  rodaEsq.write(45 - vel);//0
}

void direita() {
  rodaDir.write(STOP);
  rodaEsq.write(VEL_MAX + 45);//90
}

void esquerda() {
  rodaDir.write(45 - VEL_MAX);//0
  rodaEsq.write(STOP);
}

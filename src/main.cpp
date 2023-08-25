#include <Arduino.h>

/* 
Parsing arguments:
  ":" => Separateur universel
  "!" => Entrée Buzzer
  "?" => Entrée Host
  
*/

// Options de jeu
int delai = 500; // En millisecondes

// On initialise les variables des joueurs
int pinJoueur1 = 11;
int buzzerJoueur1 = 0;

int pinJoueur2 = 10;
int buzzerJoueur2 = 0;

int pinJoueur3 = 3;
int buzzerJoueur3 = 0;

int pinJoueur4 = 2;
int buzzerJoueur4 = 0;


void setup() {

  // On initialise la liaison série
  Serial.begin(9600);

  // On initialise les boutons
  pinMode(pinJoueur1, INPUT);

}

void loop() {

  // On récupère les buzzers des joueurs
  buzzerJoueur1 = digitalRead(pinJoueur1);
  buzzerJoueur2 = digitalRead(pinJoueur2);
  buzzerJoueur3 = digitalRead(pinJoueur3);
  buzzerJoueur4 = digitalRead(pinJoueur4);

  // On teste si un bouton (buzzer) est pressé
  if (buzzerJoueur1 == HIGH) {

    Serial.print("1!:");

    delay(delai);

  } else if (buzzerJoueur2 == HIGH) {

    Serial.print("2!:");

    delay(delai);

  } else if (buzzerJoueur3 == HIGH) {

    Serial.print("3!:");

    delay(delai);

  } else if (buzzerJoueur4 == HIGH) {

    Serial.print("4!:");

    delay(delai);

  }

}
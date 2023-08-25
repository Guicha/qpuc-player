import controlP5.*;
import uibooster.*;
import uibooster.components.*;
import uibooster.model.*;
import processing.serial.*;
import processing.sound.*;
import java.util.Arrays;

/* 
Parsing arguments:
  ":" => Separateur universel
  "!" => Entrée Buzzer
  "?" => Entrée Host
  
*/

// Chargement des polices
PFont myFont;

// Chargement des sons
SoundFile son_buzzer;
SoundFile son_bonne_reponse;
SoundFile son_mauvaise_reponse;
SoundFile son_clock;
SoundFile son_temps_ecoule;
SoundFile son_qualif;
SoundFile son_victoire;

// Variables de ports COM
Serial port;
String selected_port;

// Variables d'alertes et notifications
UiBooster booster;
ListElement selectedElement;

// Initialisation de la structure des thèmes
public class Theme {

    String nom;
    Integer alive;
    Integer affichage;

    public void setName(String name) {

        this.nom = name;
    }

    public void setAlive(int etat) {

        this.alive = etat;
    }

    public void setAffichage(int etat) {

        this.affichage = etat;
    }
}


// Initialisation de la structure des joueurs
public class Joueur implements Comparable<Joueur> {

    String nom;
    Integer score;
    Integer enJeu;
    Integer qualif;
    Integer alive;
    Integer buzz;
    Integer priorite;

    public void setName(String name) {

        this.nom = name;
    }

    public void setScore(int score) {

        this.score = score;
    }

    public void setenJeu(int etat) {

        this.enJeu = etat;
    }

    public void setQualif(int etat) {

        this.qualif = etat;
    }

    public void setAlive(int etat) {

        this.alive = etat;
    }

    public void setBuzz(int etat) {

        this.buzz = etat;
    }

    public void setPriorite(int etat) {

        this.priorite = etat;
    }

    @Override
    public int compareTo(Joueur o) {

        return (int) (this.score - o.score);
    }

    public int getScore() {

        return score;
    }

}


// Création de la classe de cases (utilisée dans le 4 à la suite)
public class Case {

    Integer active;
    String cote;

    public void setActive(int etat) {

        this.active = etat;
    }

    public void setCote(String etat) {

        this.cote = etat;
    }
}

    
// Création du tableau de joueurs
Joueur[] tab_joueurs = new Joueur[4];

// Création du tableau de thèmes
Theme[] tab_themes = new Theme[4];

// Création du tableau de cases
Case[] tab_cases = new Case[4];


// Variables temporaires
String temp;


// Variables du 9 points gagnants
Integer aliveEpreuve1 = 1;
Integer initEpreuve1 = 1;
Integer nbPointsMax;
Integer pointsQuestion;
Integer num_joueur;

// Variables du 4 a la suite
Integer aliveEpreuve2 = 0;
Integer initEpreuve2 = 1;
Integer jeu_en_cours;
Integer index_case;
Integer index_bonne_reponse;
Integer indice_priorite;
Integer timer_active;
Integer timer_begin;
Integer timer_end;
Integer timer;
Integer valeur_timer = 40;

// Variables de l'algo de calcul des finalistes
Integer aliveCalculFinalistes = 0;

// Variables du jeu décisif (dans le cas d'une égalité dans le 4 a la suite)
Integer aliveEpreuve3 = 0;
Integer initEpreuve3 = 1;
Integer compteur_joueurs_jeu_decisif = 0;

// Variables du face à face
Integer aliveEpreuve4 = 0;
Integer initEpreuve4 = 1;
Integer choix_joueur = 0;
Integer timer_pause = 0;
Integer case_actuelle = 0;
Integer borne_inf = 0;
Integer borne_supp = 0;

// Variables écran de fin
Integer aliveFin = 0;
Integer demarrage_musique = 1;

// Variables Serial
String data_recue;

// Variables de paramétrage de jeu
String[][] interface_joueurs;



void setup() {

    // Mise en place du nom de la fenetre
    surface.setTitle("QPUC - Player by Guicha ;)");

    // Affichage dans la console des ports COM disponibles
    printArray(Serial.list());

    // Affichage de l'écran
    fullScreen();

    // Création du tableau de joueurs
    for (int i=0; i<4; i++) {

        tab_joueurs[i] = new Joueur();
    }

    // Création du tableau de thèmes
    for (int i=0; i<4; i++) {

        tab_themes[i] = new Theme();
    }

    // Création du tableau de cases
    for (int i=0; i<4; i++) {

        tab_cases[i] = new Case();
    }

    // Initialisation de l'UiBooster
    booster = new UiBooster();

    // Chargement de la police
    myFont = createFont("kimberley.otf", 32);
    textFont(myFont);

    // Chargement des sons
    son_buzzer = new SoundFile(this, "buzzer.wav");
    son_bonne_reponse = new SoundFile(this, "vrai.wav");
    son_mauvaise_reponse = new SoundFile(this, "faux.wav");
    son_clock = new SoundFile(this, "clock.wav");
    son_temps_ecoule = new SoundFile(this, "temps_ecoule.wav");
    son_qualif = new SoundFile(this, "qualif.wav");
    son_victoire = new SoundFile(this, "victoire.wav");

    // On teste la présence de l'Arduino
    while (Serial.list().length == 0) {

        booster.showErrorDialog("Veuillez brancher la carte Arduino à l'ordinateur", "ERREUR");
    }

    // Selection du port
    selected_port = booster.showSelectionDialog("Selectionner le port COM auquel est branchée la carte Arduino", "Selection du port", Serial.list());

    // Initialisation des variables Serial
    port = new Serial(this, selected_port, 9600);

    // Confirmation de lancement
    booster.showInfoDialog("Arduino détectée ! Le programme se lance");

    // Choix et configuration de la partie
    selectedElement = booster.showList(

        "Sélectionner un mode de jeu",

        "Questions pour un Champion -- Helper v.0",

        new ListElement("Nouvelle partie classique", "Les règles classiques de QPUC: 9 points gagnants, \n 4 à la suite et le face à face !", dataPath("qpuc_logo.jpg"))
    );


    if (selectedElement == null) {

        exit();

    } else {

        // Création d'une nouvelle partie
        if (selectedElement.getTitle() == "Nouvelle partie classique") {

            booster.showInfoDialog("Partie Classique sélectionnée !");

            for (int i=0; i<4; i++) {

                String affichage = "Saisir le nom du joueur " + (i+1);

                temp = booster.showTextInputDialog(affichage);

                tab_joueurs[i].setName(temp);
                tab_joueurs[i].setAlive(1);
        
            }


            nbPointsMax = booster.showSlider (

                "Saisir le nombre de points maximum de l'épreuve \"9 points gagnants\": ",

                "Configuration de la partie",

                1, // Valeur initiale
                9, // Valeur max
                9, // Valeur par défaut
                4, // Milieu
                1  // Pas du slider

            );

            for (int i=0; i<3; i++) {

                temp = booster.showTextInputDialog("Saisir les thèmes du 4 à la suite");

                tab_themes[i].setName(temp);
                tab_themes[i].setAffichage(1);
            
            }

            tab_themes[3].setName("Thème mystère");
            tab_themes[3].setAffichage(1);

            valeur_timer = booster.showSlider(

                "Saisir la durée du timer de l'épreuve \"4 à la suite\": ",

                "Configuration de la partie",

                10, // Valeur initiale
                60, // Valeur max
                40, // Valeur par défaut
                30, // Milieu
                1  // Pas du slider

            );
        }
    }


    // Variables de reglages
    /*aliveEpreuve1 = 0;
    aliveEpreuve4 = 1;
    tab_joueurs[0].setPriorite(0);
    tab_joueurs[1].setPriorite(1);
    tab_joueurs[2].setAlive(0);
    tab_joueurs[3].setAlive(0);*/

}



void draw() {

    // Nettoyage du fond a chaque itération
    background(55, 51, 161);

    // Si jamais aucune Arduino n'est branchée
    if (Serial.list().length == 0) {

        booster.showErrorDialog("La carte Arduino a été débranchée :/ Veuillez la rebrancher pour continuer à jouer !", "ERREUR");
    }

    // Gestion des joueurs morts
    for (int i=0; i<4; i++) {

        if (tab_joueurs[i].alive == 0) {

            tab_joueurs[i].setScore(-1);
            tab_joueurs[i].setenJeu(0);
            tab_joueurs[i].setBuzz(0);
            tab_joueurs[i].setPriorite(99);
            tab_joueurs[i].setQualif(0);
        }
    }


    // Ouverture du menu de gestion de jeu
    if (keyPressed) {

        if (key == 'p') {
            
            // Délai pour empecher la boucle
            delay(100);
            
            // Création de la matrice d'affichage des joueurs (nom et scores)
            String[][] liste_joueurs = new String[4][2];

            // Remplissage de la matrice avec les noms et les scores des joueurs
            for (int i=0; i<4; i++) {

                liste_joueurs[i][0] = tab_joueurs[i].nom;
                liste_joueurs[i][1] = String.valueOf(tab_joueurs[i].score);
            }

            // Affichage du booster de type tableau
            interface_joueurs = booster.showTable(

                liste_joueurs, // Matrice de joueurs

                new String[] {"Nom", "Score"}, // Noms des colonnes

                "Paramètres de jeu" // Titre de la fenêtre
            );

            // Une fois le menu fermé, on applique les valeurs modifiées dans le tableau de joueurs principaux (mise à jour des valeurs)
            for (int i=0; i<4; i++) {

                // Debug
                print(liste_joueurs[i][0]);
                println(liste_joueurs[i][1]);

                tab_joueurs[i].setName(liste_joueurs[i][0]);
                tab_joueurs[i].setScore(Integer.parseInt(liste_joueurs[i][1]));
            }

            delay(100);
        }
    }



    // 9 points gagnants
    if (aliveEpreuve1 == 1) {

        // On commence par le 9 points gagnants
        if (initEpreuve1 == 1) {

            // Initialisation des variables de jeu
            aliveEpreuve1 = 1;
            pointsQuestion = 1;

            // On initialise les premières variables de jeu
            for (int i=0; i<4; i++) {

                tab_joueurs[i].setScore(0);
                tab_joueurs[i].setQualif(0);
                tab_joueurs[i].setenJeu(1);
                tab_joueurs[i].setBuzz(0);
                
            }

            initEpreuve1 = 0;
        }

        // Affichage du titre
        textSize(70);
        fill(255, 255, 255);
        text(nbPointsMax + " points gagnants", 10, 100);

        // Affichage du nombre de points de la question
        text("Question à " + pointsQuestion + " points", 10, 200);


        // Intervention du modérateur (dans le cas d'un joueur qui buzz)
        if (num_joueur != null) {

            if (tab_joueurs[num_joueur-1].buzz == 1) {

                if (keyPressed) {

                    if (key == 'e') { // Réponse correcte

                        tab_joueurs[num_joueur-1].setBuzz(0);

                        tab_joueurs[num_joueur-1].setScore(tab_joueurs[num_joueur-1].score + pointsQuestion);

                        son_bonne_reponse.play();

                        pointsQuestion = pointsQuestion + 1;

                        for (int i=0; i<4; i++) {

                            tab_joueurs[i].setenJeu(1);
                            tab_joueurs[i].setBuzz(0);
                        }

                    
                    } else if (key == 'z') { // Réponse incorrecte

                        tab_joueurs[num_joueur-1].setBuzz(0);

                        tab_joueurs[num_joueur-1].setenJeu(0);

                        son_mauvaise_reponse.play();


                    }   
                }

            }
        }






        // Recupération des buzzers et changement des états
        if (port.available() > 0) {

            data_recue = port.readStringUntil(':');

            if (data_recue != null) {

                data_recue = data_recue.substring(0, data_recue.length()-1);

            }    

        }

        if (data_recue != null) {


            if (data_recue.indexOf('!') != -1) {

                data_recue = data_recue.substring(0, data_recue.length()-1);

                num_joueur = Integer.parseInt(data_recue);

                boolean buzzer_libre = true;

                for (int i=0; i<4; i++) {

                    if (tab_joueurs[i].buzz == 1) {

                        buzzer_libre = false;
                    }
                }

                if (num_joueur >= 1 && num_joueur <= 4 && tab_joueurs[num_joueur-1].enJeu == 1 && tab_joueurs[num_joueur-1].qualif == 0 && buzzer_libre == true) {

                    tab_joueurs[num_joueur-1].setBuzz(1);

                    son_buzzer.play(1, 1.0);
                }
            }
        }

        

        // Affichage des joueurs
        for (int i=0; i<4; i++) {

            if (tab_joueurs[i].enJeu == 1 && tab_joueurs[i].qualif == 0 && tab_joueurs[i].buzz == 1) {

                fill(245, 147, 66); // Orange

            } else if (tab_joueurs[i].qualif == 1) {

                fill(66, 126, 245); // Bleu clair

            } else if (tab_joueurs[i].enJeu == 1 && tab_joueurs[i].qualif == 0 && tab_joueurs[i].buzz == 0) {

                fill(0, 255, 0); // Vert

            } else if (tab_joueurs[i].enJeu == 0) {

                fill(255, 0, 0); // Rouge
            }

            rect(0+(i*480), 500, 480+(i*480), 1000);

            fill(255, 255, 255);

            text(tab_joueurs[i].nom, 10+(i*480), 750);

            text(tab_joueurs[i].score, 10+(i*480), 850);
        }




        // Question suivante (si personne n'est correct)
        if (keyPressed) {

            if (key == 'a') { // Personne n'a trouvé et on passe a la question suivante en resettant certains parametres

                for (int i=0; i<4; i++) {

                    tab_joueurs[i].setenJeu(1);
                    tab_joueurs[i].setBuzz(0);
                }

                pointsQuestion = pointsQuestion + 1;

                delay(150);
            }
        }




        // Mise à jour des points de la question
        int compteur_qualif = 0;

        for (int i=0; i<4; i++) {

            if (tab_joueurs[i].qualif == 1) {

                compteur_qualif = compteur_qualif + 1;
            }
        }

        if (compteur_qualif == 0) {

            if (pointsQuestion == 4) {

                pointsQuestion = 1;
            }

        } else if (compteur_qualif == 1) {

            pointsQuestion = 2;

        } else if (compteur_qualif == 2) {

            pointsQuestion = 3;

        } else if (compteur_qualif == 3) { // Détection de la fin du jeu s'il y a 3 qualifiés

            for (int i=0; i<4; i++) {

                if (tab_joueurs[i].qualif == 0) {

                    tab_joueurs[i].setAlive(0);
                    tab_joueurs[i].setPriorite(99);
                    tab_joueurs[i].setScore(-1);
                }
            }

            aliveEpreuve1 = 0;
            aliveEpreuve2 = 1;
        }




        // Mise à jour des joueurs
        compteur_qualif = 0;

        for (int i=0; i<4; i++) {

            if (tab_joueurs[i].qualif == 1) {

                compteur_qualif = compteur_qualif + 1;
            }
        }

        for (int i=0; i<4; i++) {

            if (tab_joueurs[i].score >= nbPointsMax && tab_joueurs[i].qualif == 0) {

                tab_joueurs[i].setQualif(1);

                tab_joueurs[i].setPriorite(0 + compteur_qualif);
            }
        }

    }












    // 4 à la suite
    if (aliveEpreuve2 == 1) {
        
        // Initialisation de l'épreuve
        if (initEpreuve2 == 1) {

            // Initialisation des variables de jeu
            aliveEpreuve2 = 1;

            // On initialise les premières variables de jeu
            for (int i=0; i<4; i++) {

                tab_joueurs[i].setScore(0);
                tab_joueurs[i].setQualif(0);
                tab_joueurs[i].setenJeu(0);
            }

            // On met en jeu le joueur le plus prioritaire
            for (int i=0; i<4; i++) {

                if (tab_joueurs[i].priorite == 0) {

                    tab_joueurs[i].setenJeu(1);
                    indice_priorite = 0;
                }
            }

            // On initialise le tableau de cases du jeu
            for (int i=0; i<4; i++) {

                tab_cases[i].setActive(0);
            }


            // On initialise les variables de jeu actuel
            jeu_en_cours = 0;

            initEpreuve2 = 0;

        }

        // Affichage du titre
        textSize(70);
        stroke(0, 0, 0);
        fill(255, 255, 255);
        text("4 à la suite", 10, 100);

        // Affichage des joueurs
        for (int i=0; i<4; i++) {

            if (tab_joueurs[i].enJeu == 1 && tab_joueurs[i].alive == 1) {

                fill(245, 147, 66); // Orange

            } else if (tab_joueurs[i].enJeu == 0 && tab_joueurs[i].alive == 1) {

                fill(0, 255, 0); // Vert

            }

            if (tab_joueurs[i].alive == 1) {

                rect(960+(i*240), 0, 240, 250);

                fill(255, 255, 255);
                textSize(40);

                text(tab_joueurs[i].nom,(980 + (i*240))-(tab_joueurs[i].nom.length()*2), 100);

                text(tab_joueurs[i].score,(980 + (i*240))-(tab_joueurs[i].nom.length()*2), 200);


            }

        }

        // Affichage de l'interface (thèmes)
        for (int i=0; i<4; i++) {

            if (i == 3 && tab_themes[i].affichage == 1) {

                fill(24, 179, 13); // Vert ; thème mystère

            } else if (i != 3 && tab_themes[i].affichage == 1) {

                fill(239, 144, 2); // Orange

            } else if (tab_themes[i].affichage == 0) {

                fill(161, 167, 179); // Gris ; thème déjà pris
            }

            rect(960, 500+(i*100), 900, 100);

            fill(255, 255, 255);

            text(tab_themes[i].nom, 970, 550+(i*100));
        }

        // Sélection et boucle de jeu
        if (jeu_en_cours == 1) {

            // Affichage de l'interface de jeu
            for (int i=0; i<4; i++) {

                // Affichage des cases
                stroke(239, 144, 2, 255);

                if (tab_cases[i].active == 0) {

                    noFill();

                } else if (tab_cases[i].active == 1) {

                    fill(239, 144, 2);
                }

                rect(20, 400+(i*100), 100, 100);

                // Affichage des nombres
                fill(255, 255, 255);
                textSize(30);
                text(4-i, 25, 450+(i*100));

                // Affichage de la pastille indiquant à quelle case se situe le joueur
                if (index_bonne_reponse == 0) {

                    noFill();
                    noStroke();

                } else {

                    fill(255, 0, 0);

                    circle(150, 450+((4-index_bonne_reponse)*100), 25);
                }


            }


            // Timer de 40 secondes
            // Affichage du timer
            stroke(239, 144, 2, 255);
            noFill();
            rect(20, 900, 100, 100);

            // Démarrage du timer
            if (keyPressed) {

                if (key == ' ' && timer_active == 0) {

                    timer_active = 1;

                }
            }

            fill(255, 255, 255);

            // Activation du timer
            if (timer_active == 0) {

                text(valeur_timer, 25, 950);

                timer_begin = millis();

            } else if (timer_active == 1) {

                text(timer, 28, 950);

                timer_end = millis();

                if (timer_end - timer_begin >= 1000) {

                    timer_begin = timer_end;

                    son_clock.play();
                    
                    timer = timer - 1;
                }

                if (timer == 0) { // Détection de la fin du timer

                    son_clock.stop();

                    if (index_case != 0) {

                        son_temps_ecoule.play(); 

                    } else if (index_case == 0) {

                        son_qualif.play();
                    }
                    

                    indice_priorite = indice_priorite + 1;

                    for (int i=0; i<4; i++) { // Attribution du score et passage au joueur suivant

                        if (tab_joueurs[i].enJeu == 1) {

                            for (int j=0; j<4; j++) {

                                if (tab_cases[j].active == 1) {

                                    tab_joueurs[i].setScore(4-j);

                                    break;
                                }
                            }

                            tab_joueurs[i].setenJeu(0);
                        }

                        if (tab_joueurs[i].priorite == indice_priorite) {

                            tab_joueurs[i].setenJeu(1);
                        }
                    }

                    timer_active = 0;

                    jeu_en_cours = 0;

                    if (indice_priorite == 3) { // On passe au jeu suivant

                        aliveEpreuve2 = 0;
                        aliveCalculFinalistes = 1;
                    }
                }
            }


            // Détection du 4 à la suite
            if (index_case == 0) {

                timer = 0;
            }



            // Intervention du modérateur / Mise à jour des cases 
            if (keyPressed) {

                if (key == 'e') { // Bonne réponse

                    son_bonne_reponse.play();

                    index_case = index_case - 1;

                    tab_cases[index_case].setActive(1);

                    index_bonne_reponse = index_bonne_reponse + 1;

                    delay(100);

                } else if (key == 'z') { // Mauvaise réponse

                    index_case = 4;

                    index_bonne_reponse = 0;

                    delay(100);

                }
            }



        } else if (jeu_en_cours == 0) {

            if (keyPressed) { // On initialise a chaque sélection de thème les parametres de jeu du 4 a la suite de chaque joueur

                if (key == '&' && tab_themes[0].affichage == 1) { // Premier thème

                    tab_themes[0].setAffichage(0);
                    son_bonne_reponse.play();

                    index_case = 4;
                    index_bonne_reponse = 0;
                    timer_active = 0;
                    timer = valeur_timer;
                    

                    for (int i=0; i<4; i++) {

                        tab_cases[i].setActive(0);
                    }

                    jeu_en_cours = 1;

                } else if (key == 'é' && tab_themes[1].affichage == 1) { // Deuxième thème

                    tab_themes[1].setAffichage(0);
                    son_bonne_reponse.play();

                    index_case = 4;
                    index_bonne_reponse = 0;
                    timer_active = 0;
                    timer = valeur_timer;

                    for (int i=0; i<4; i++) {

                        tab_cases[i].setActive(0);
                    }                    

                    jeu_en_cours = 1;

                } else if (key == '"' && tab_themes[2].affichage == 1) { // Troisième thème

                    tab_themes[2].setAffichage(0);
                    son_bonne_reponse.play();

                    index_case = 4;
                    index_bonne_reponse = 0;
                    timer_active = 0;
                    timer = valeur_timer;

                    for (int i=0; i<4; i++) {

                        tab_cases[i].setActive(0);
                    }                    

                    jeu_en_cours = 1;

                } else if (key == '\'' && tab_themes[3].affichage == 1) { // Thème mystère

                    tab_themes[3].setAffichage(0);
                    son_bonne_reponse.play();

                    index_case = 4;
                    index_bonne_reponse = 0;
                    timer_active = 0;
                    timer = valeur_timer;

                    for (int i=0; i<4; i++) {

                        tab_cases[i].setActive(0);
                    }                    

                    jeu_en_cours = 1;

                }
            }
        }
        

    }

   







    // Calcul des finalistes
    if (aliveCalculFinalistes == 1) {

        // On initialise quelques attributs des joueurs
        for (int i=0; i<4; i++) {

            tab_joueurs[i].setQualif(0);
                
        }

        // On trie le tableau de joueurs en fonction de leur score
        Arrays.sort(tab_joueurs);

        for (int i=0; i<4; i++) {

            println(tab_joueurs[i].nom);
        }

        // On définit le score maximum (sachant que le tableau est trié par ordre croissant)
        Integer max = tab_joueurs[3].score;

        // On vérifie donc si la valeur maximale suivante est égale ou non (permettant de savoir s'il y a directement les deux qualifiés ou non)
        if (tab_joueurs[2].score == max) {

            if (tab_joueurs[1].score == max) { // Les 3 joueurs ont fait le meme score => on part directement pour le jeu décisif

                aliveCalculFinalistes = 0;
                aliveEpreuve3 = 1;

            } else { // Les joueurs 2 et 3 ont le meme score, qui est supérieur à celui du premier => les deux sont directement qualifiés

                tab_joueurs[1].setAlive(0);

                tab_joueurs[3].setPriorite(0);
                tab_joueurs[2].setPriorite(1);

                aliveEpreuve4 = 1;
                aliveCalculFinalistes = 0;
            
            }

        } else {

            // Dans ce cas, le joueur 3 est automatiquement qualifié, et l'algorithme se charge de calculer lequel des 2 derniers joueurs le sera ou pas
            tab_joueurs[3].setQualif(1);
            tab_joueurs[3].setPriorite(0);

            // On définit donc le minimum et testons les valeurs par rapport à ce minimum
            Integer min = tab_joueurs[1].score;

            if (tab_joueurs[2].score == min) { // Ici les deux derniers joueurs ont le meme score => ils vont tout deux au jeu décisif

                aliveEpreuve3 = 1;
                aliveCalculFinalistes = 0;

            } else { // Ici le joueur 1 a un score inférieur au joueur 2 => c'est donc le joueur 2 qui est qualifié et le joueur 1 est disqualifié

                tab_joueurs[1].setAlive(0);
                aliveEpreuve4 = 1;
                aliveCalculFinalistes = 0;

            }

        }



    }







    // Jeu décisif (dans le cas d'une égalité dans le 4 à la suite)
    if (aliveEpreuve3 == 1) {


        if (initEpreuve3 == 1) {

            for (int i=0; i<4; i++) {

                tab_joueurs[i].setBuzz(0);
            }

            for (int i=0; i<4; i++) {

                if (tab_joueurs[i].alive == 1) {

                    if (tab_joueurs[i].qualif == 0) {

                        tab_joueurs[i].setenJeu(1);
                        tab_joueurs[i].setBuzz(0);
                        tab_joueurs[i].setScore(0);
                        tab_joueurs[i].setPriorite(99);

                        compteur_joueurs_jeu_decisif = compteur_joueurs_jeu_decisif + 1;
                    }


                }
            }

            initEpreuve3 = 0;
        }

        // Affichage des joueurs
        // Affichage du titre
        textSize(70);
        stroke(0, 0, 0);
        fill(255, 255, 255);
        text("Jeu décisif", 10, 100);

        // Intervention du modérateur (dans le cas d'un joueur qui buzz)
        if (num_joueur != null) {

            if (tab_joueurs[num_joueur-1].buzz == 1) {

                if (keyPressed) {

                    if (key == 'e') { // Réponse correcte

                        tab_joueurs[num_joueur-1].setBuzz(0);

                        tab_joueurs[num_joueur-1].setScore(tab_joueurs[num_joueur-1].score + 1);

                        son_bonne_reponse.play();

                    
                    } else if (key == 'z') { // Réponse incorrecte

                        tab_joueurs[num_joueur-1].setBuzz(0);

                        tab_joueurs[num_joueur-1].setenJeu(0);

                        son_mauvaise_reponse.play();


                    }   
                }

            }
        }






        // Recupération des buzzers et changement des états
        if (port.available() > 0) {

            data_recue = port.readStringUntil(':');

            if (data_recue != null) {

                data_recue = data_recue.substring(0, data_recue.length()-1);

            }    

        }

        if (data_recue != null) {


            if (data_recue.indexOf('!') != -1) {

                data_recue = data_recue.substring(0, data_recue.length()-1);

                num_joueur = Integer.parseInt(data_recue);

                boolean buzzer_libre = true;

                for (int i=0; i<4; i++) {

                    if (tab_joueurs[i].buzz == 1 && tab_joueurs[i].alive == 1) {

                        buzzer_libre = false;
                    }
                }

                if (num_joueur >= 1 && num_joueur <= 4 && tab_joueurs[num_joueur-1].enJeu == 1 && tab_joueurs[num_joueur-1].qualif == 0 && tab_joueurs[num_joueur-1].alive == 1 && buzzer_libre == true) {

                    tab_joueurs[num_joueur-1].setBuzz(1);

                    son_buzzer.play(1, 1.0);
                }
            }
        }

        

        // Affichage des joueurs
        for (int i=0; i<4; i++) {

            if (tab_joueurs[i].alive == 1 && tab_joueurs[i].priorite != 0) {

                if (tab_joueurs[i].enJeu == 1 && tab_joueurs[i].qualif == 0 && tab_joueurs[i].buzz == 1) {

                    fill(245, 147, 66); // Orange

                } else if (tab_joueurs[i].qualif == 1 && tab_joueurs[i].alive == 1) {

                    fill(66, 126, 245); // Bleu clair

                } else if (tab_joueurs[i].enJeu == 1 && tab_joueurs[i].qualif == 0 && tab_joueurs[i].buzz == 0) {

                    fill(0, 255, 0); // Vert

                } else if (tab_joueurs[i].enJeu == 0) {

                    fill(255, 0, 0); // Rouge
                }

                rect(0+(i*480), 500, 480, 1000);

                fill(255, 255, 255);

                text(tab_joueurs[i].nom, 20+(i*480), 750);

                text(tab_joueurs[i].score, 20+(i*480), 850);
            }

        
        }




        // Question suivante (si personne n'est correct)
        if (keyPressed) {

            if (key == 'a') { // Personne n'a trouvé et on passe a la question suivante en resettant certains parametres

                for (int i=0; i<4; i++) {

                    if (tab_joueurs[i].alive == 1) {

                        tab_joueurs[i].setenJeu(1);
                        tab_joueurs[i].setBuzz(0);
                    }

                }
            }
        }




        // Détection de la fin de jeu
        int compteur_qualif = 0;
        
        if (compteur_joueurs_jeu_decisif == 3) {

            for (int i=0; i<4; i++) {

                if (tab_joueurs[i].qualif == 1 && tab_joueurs[i].alive == 1) {

                    compteur_qualif = compteur_qualif + 1;
                }   
            }

        } else {

            for (int i=0; i<4; i++) {

                if (tab_joueurs[i].qualif == 1 && tab_joueurs[i].alive == 1 && tab_joueurs[i].priorite != 0) {

                    compteur_qualif = compteur_qualif + 1;
                }   
            }

        }
        



        if (compteur_qualif == compteur_joueurs_jeu_decisif-1) { // Détection de la fin du jeu s'il y a assez de qualifiés

            for (int i=0; i<4; i++) {

                if (tab_joueurs[i].qualif == 0 && tab_joueurs[i].alive == 1) {

                    tab_joueurs[i].setAlive(0);
                }
            }

            aliveEpreuve3 = 0;
            aliveEpreuve4 = 1;
        }




        // Mise à jour des joueurs
        compteur_qualif = 0;

        for (int i=0; i<4; i++) {

            if (tab_joueurs[i].qualif == 1 && tab_joueurs[i].alive == 1) {

                compteur_qualif = compteur_qualif + 1;
            }
        }

        for (int i=0; i<4; i++) {

            if (tab_joueurs[i].score >= 2 && tab_joueurs[i].qualif == 0 && tab_joueurs[i].alive == 1) {

                tab_joueurs[i].setQualif(1);
                tab_joueurs[i].setenJeu(0);

                tab_joueurs[i].setPriorite(0 + compteur_qualif);
            }
        }
        


    }















    // Face à face
    if (aliveEpreuve4 == 1) {

        if (initEpreuve4 == 1) {

            for (int i=0; i<4; i++) {

                if (tab_joueurs[i].alive == 1) {

                    tab_joueurs[i].setScore(0);
                    tab_joueurs[i].setenJeu(1);
                    tab_joueurs[i].setQualif(0);
                    tab_joueurs[i].setBuzz(0);
                }

                tab_cases[i].setActive(1);
                tab_cases[i].setCote("milieu");
            }

            timer_active = 0;
            timer = 20; // On change le timer pour le temps du face a face

            initEpreuve4 = 0;
        }

        // Affichage du titre
        textSize(70);
        stroke(0, 0, 0);
        fill(255, 255, 255);
        text("Face à face", 10, 100);


        // Intervention du modérateur afin de choisir qui prend la main et pour passer a la question suivante
        if (keyPressed) {

            if (key == 'm') { // Donner la main au joueur de droite

                tab_cases[0].setCote("droit");
                tab_cases[1].setCote("gauche");
                tab_cases[2].setCote("droit");
                tab_cases[3].setCote("gauche");

            } else if (key == 'l') { // Donner la main au joueur de gauche

                tab_cases[0].setCote("gauche");
                tab_cases[1].setCote("droit");
                tab_cases[2].setCote("gauche");
                tab_cases[3].setCote("droit");

            } else if (key == 'a') { // Intervention du mondérateur pour passer à la question suivante (temps écoulé)

                for (int i=0; i<4; i++) {

                    tab_cases[i].setActive(1);
                    tab_cases[i].setCote("milieu");
                    timer = 20;
                }

            }
        }



        // Intervention du modérateur (dans le cas d'un joueur qui buzz)
        if (num_joueur != null) {

            if (tab_joueurs[num_joueur-1].buzz == 1) {

                if (keyPressed) {

                    if (key == 'e') { // Réponse correcte

                        int i;

                        son_bonne_reponse.play();

                        tab_joueurs[num_joueur-1].setBuzz(0);

                        for (i=0; i<4; i++) {

                            if (tab_cases[i].active == 1) {

                                break;
                            }
                        }

                        tab_joueurs[num_joueur-1].setScore(tab_joueurs[num_joueur-1].score + (4-i));

                        



                        // Reinitialisation des parametres de jeu pour la manche suivante
                        for (i=0; i<4; i++) {

                            tab_cases[i].setActive(1);
                            tab_cases[i].setCote("milieu");
                            timer = 20;
                        }

                    
                    } else if (key == 'z') { // Réponse incorrecte

                        int i;

                        tab_joueurs[num_joueur-1].setBuzz(0);

                        for (i=0; i<4; i++) {

                            if (tab_cases[i].active == 1) {

                                break;
                            }
                        }

                        if (i<3) {

                            if (tab_cases[i].cote == tab_cases[i+1].cote) {

                                if (tab_cases[i].cote == "droit") {

                                    tab_cases[i].setCote("gauche");
                                    tab_cases[i+1].setCote("gauche");

                                } else if (tab_cases[i].cote == "gauche") {

                                    tab_cases[i].setCote("droit");
                                    tab_cases[i+1].setCote("droit");
                                }

                            } else {

                                if (tab_cases[i].cote == "droit") {

                                    tab_cases[i].setCote("gauche");

                                } else if (tab_cases[i].cote == "gauche") {

                                    tab_cases[i].setCote("droit");
                                }

                            }

                        } else {

                            if (tab_cases[i].cote == "droit") {

                                tab_cases[i].setCote("gauche");

                            } else if (tab_cases[i].cote == "gauche") {

                                tab_cases[i].setCote("droit");
                            }

                        }
                        

                    }   
                }

            }
        }



        // Timer de 20 secondes
        // Démarrage du timer
        if (keyPressed) {

            if (key == ' ' && timer_active == 0) {

                timer_active = 1;
            }
        }

        // Activation du timer
        if (timer_active == 0) {

            timer_begin = millis();

        } else if (timer_active == 1) {

            timer_end = millis();

            if (timer_end - timer_begin >= 1000) {

                timer_begin = timer_end;

                son_clock.play();

                timer = timer - 1;
            }

        }


        // Si un joueur buzz, mettre le timer en pause
        for (int i=0; i<4; i++) {

            if (tab_joueurs[i].buzz == 1 && tab_joueurs[i].alive == 1) {

                timer_active = 0;
            }
        }


        // Arret du timer
        if (timer <= 0 && timer > -1) {
            
            timer = -1;
            timer_active = 0;
            son_clock.stop();
            son_temps_ecoule.play();
        }



        // Recupération des buzzers et changement des états
        if (port.available() > 0) {

            data_recue = port.readStringUntil(':');

            if (data_recue != null) {

                data_recue = data_recue.substring(0, data_recue.length()-1);

            }    

        }

        if (data_recue != null) {

            if (data_recue.indexOf('!') != -1) {

                data_recue = data_recue.substring(0, data_recue.length()-1);

                num_joueur = Integer.parseInt(data_recue);

                boolean buzzer_libre = true;

                println(data_recue);

                for (int i=0; i<4; i++) {

                    if (tab_joueurs[i].buzz == 1 && tab_joueurs[i].alive == 1) {

                        buzzer_libre = false;
                    }
                }

                if (num_joueur >= 1 && num_joueur <= 4 && tab_joueurs[num_joueur-1].enJeu == 1 && tab_joueurs[num_joueur-1].qualif == 0 && tab_joueurs[num_joueur-1].alive == 1 && buzzer_libre == true) {

                    int i;

                    for (i=0; i<4; i++) {

                        if (tab_cases[i].active == 1) {

                            break;
                        }
                    }

                    if (tab_joueurs[num_joueur-1].priorite == 0 && tab_cases[i].cote == "gauche") {

                        tab_joueurs[num_joueur-1].setBuzz(1);

                        son_buzzer.play(1, 1.0);

                    } else if (tab_joueurs[num_joueur-1].priorite == 1 && tab_cases[i].cote == "droit") {

                        tab_joueurs[num_joueur-1].setBuzz(1);

                        son_buzzer.play(1, 1.0);
                    }


                }
            }
        }

        // Affichage des joueurs
        for (int i=0; i<4; i++) {

            for (int j=0; j<2; j++) {

                if (tab_joueurs[i].priorite == j && tab_joueurs[i].alive == 1) {

                    if (tab_joueurs[i].enJeu == 1 && tab_joueurs[i].qualif == 0 && tab_joueurs[i].buzz == 1) {

                        fill(245, 147, 66); // Orange

                    } else if (tab_joueurs[i].enJeu == 1 && tab_joueurs[i].qualif == 0 && tab_joueurs[i].buzz == 0) {

                        fill(0, 100, 0); // Vert

                    } else if (tab_joueurs[i].enJeu == 0) {

                        fill(100, 0, 0); // Rouge
                    }

                    noStroke();

                    rect(0+(j*960), 400, 960, 680);

                    fill(255, 255, 255);

                    text(tab_joueurs[i].nom, 370+(j*960), 540);

                    text(tab_joueurs[i].score, 370+(j*960), 640);
                }
            }
        }



        // Mise à jour des cases en fonction du timer
        if (timer < 12) {

            tab_cases[0].setActive(0);

            if (timer < 7) {

                tab_cases[1].setActive(0);

                if (timer < 3) {

                    tab_cases[2].setActive(0);

                    if (timer == 0) {

                        tab_cases[3].setActive(0);
                    }
                }
            }
        }



        // Détection de la case actuelle
        if (timer >= 12 && timer <= 20) { // Case de 4 points

            case_actuelle = 0;
            borne_inf = 12;
            borne_supp = 20;

        } else if (timer >= 7 && timer < 12) { // Case de 3 points

            case_actuelle = 1;
            borne_inf = 7;
            borne_supp = 11;

        } else if (timer >= 3 && timer < 7) { // Case de 2 points

            case_actuelle = 2;
            borne_inf = 3;
            borne_supp = 6;


        } else if (timer > -1 && timer <= 3) { // Case de 1 point

            case_actuelle = 3;
            borne_inf = 0;
            borne_supp = 3;

        }


        // Affichage de l'interface de jeu
        for (int i=0; i<4; i++) {

            // Affichage de la ligne de délimitation des joueurs
            stroke(0, 0, 0);
            line(960, 400, 960, 1080);

            // Affichage des cases
            stroke(239, 144, 2, 255);


            if (tab_cases[i].cote == "milieu") {

                // Contour de la case
                rect(880, 400+(i*150), 150, 150);

                // Intérieur (rempli) de la case
                if (tab_cases[i].active == 1) {

                    fill(239, 144, 2); // Couleur orange

                    if (i == case_actuelle) {

                        Float y = map(timer, borne_inf, borne_supp, (400+(i*150)+150), 400+(i*150));

                        rect(880, y, 150, (550+(i*150))-y);

                        

                    } else {

                        rect(880, 400+(i*150), 150, 150);

                    }

                }

                // Affichage des nombres
                textSize(40);
                fill(0, 0, 0);
                text(4-i, 890, 500+(i*150));
                fill(255, 255, 255);

            } else if (tab_cases[i].cote == "droit") {

                // Contour de la case
                rect(960, 400+(i*150), 150, 150);

                // Intérieur (rempli) de la case
                if (tab_cases[i].active == 1) {

                    fill(239, 144, 2); // Couleur orange

                    if (i == case_actuelle) {

                        Float y = map(timer, borne_inf, borne_supp, (400+(i*150)+150), 400+(i*150));

                        rect(960, y, 150, (550+(i*150))-y);

                        

                    } else {

                        rect(960, 400+(i*150), 150, 150);

                    }

                }

                // Affichage des nombres
                textSize(40);
                fill(0, 0, 0);
                text(4-i, 970, 500+(i*150));
                fill(255, 255, 255);

            } else if (tab_cases[i].cote == "gauche") {

                // Contour de la case
                rect(810, 400+(i*150), 150, 150);

                // Intérieur (rempli) de la case
                if (tab_cases[i].active == 1) {

                    fill(239, 144, 2); // Couleur orange

                    if (i == case_actuelle) {

                        Float y = map(timer, borne_inf, borne_supp, (400+(i*150)+150), 400+(i*150));

                        rect(810, y, 150, (550+(i*150))-y);

                

                    } else {

                        rect(810, 400+(i*150), 150, 150);

                    }

                }

                // Affichage des nombres
                textSize(40);
                fill(0, 0, 0);
                text(4-i, 820, 500+(i*150));
                fill(255, 255, 255);

            }
 
        }




        // Détection de la victoire
        for (int i=0; i<4; i++) {

            if (tab_joueurs[i].alive == 1 && tab_joueurs[i].score >= 12) {

                for (int j=0; j<4; j++) {

                    if (tab_joueurs[j].alive == 1 && tab_joueurs[j].score < 12) {

                        tab_joueurs[j].setAlive(0);
                    }
                }

                aliveEpreuve4 = 0;
                aliveFin = 1;
            }
        }


    }
















    if (aliveFin == 1) {

        fill(255, 255, 255);

        for (int i=0; i<4; i++) {

            if (tab_joueurs[i].alive == 1) {

                text("Le gagnant est " +  tab_joueurs[i].nom + " !", 500, 500);


                if (demarrage_musique == 1) {

                    son_victoire.play();

                    demarrage_musique = 0;
                }

            }
        }

        if (keyPressed) {

            if (key == ' ') {

                aliveFin = 0;
                exit();
            }
        }

        
    }



   

}

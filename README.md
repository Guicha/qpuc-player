
# Questions pour un Champion - Player

Reproduction de l'émission mythique "Questions pour un Champion" jouable grâce à un système de buzzers pris en charge par une carte Arduino Nano et une interface graphique propulsée par Processing Java. 
L'idée derrière ce projet a été de pouvoir jouer à QPUC avec un groupe d'amis et ce de manière la plus amusante et réaliste possible. L'objectif était d'abord de s'amuser ; c'est pourquoi le projet contient nombre de bugs, imperfections et une interface graphique très peu travaillée !

## Fonctionnalités présentes

Le QPUC-Player vient avec un certain nombre de fonctionnalités de base permettant de jouer à l'émission:

- Epreuves mythiques du jeu: 9 points gagnants, 4 à la suite (incluant le Jeu décisif) et Face à Face
- Noms des joueurs personnalisables
- Configuration du nombre de points de l'épreuve "9 points gagnants"
- Affichage des thèmes et configuration de la durée du timer de l'épreuve "4 à la suite"

## Fonctionnalités à incorporer

- Menu permettant de modifier manuellement les points des joueurs en cas d'erreur du présentateur
- De possibles nouveaux modes de jeu 
- Corrections de bugs !

## Technologies utilisées

**Interface graphique:** Processing Java

**Microcontrôleur Arduino:** Platformio (extension VS Code)


## Prérequis

Si vous souhaitez vous même jouer à QPUC à l'aide de ce projet, un certain nombre de prérequis sont nécessaires:

- Un microcontrôleur Arduino (ici le modèle utilisé est un Nano) et son cable d'alimentation Micro USB vers USB
- Câblages, boutons, breadboards pour la mise en place du système
- Un ordinateur 
- Le logiciel [Arduino IDE](https://www.arduino.cc/en/software) ou autre logiciel permettant de téléverser du code Arduino ([Extension Platformio](https://platformio.org/install/ide?install=vscode) sur VSCode conseillée)
- Une télévision/grand écran (optionnel)
- Un clavier externe filaire ou bluetooth (optionnel)


## Installation

Merci de suivre les étapes décrites ci-dessous afin d'installer tous les composants nécessaires au fonctionnement du jeu.

### Montage du circuit Arduino

Ci-dessous le montage du circuit électronique de la carte Arduino à reproduire:

![Montage du circuit](https://github.com/Guicha/qpuc-player/blob/main/montage.png?raw=true)

### Téléversement du code sur la carte Arduino

Le code à téléverser sur la carte Arduino est disponible [ici](ARDUINO/src/main.cpp). A noter que pour cette étape la carte Arduino doit être branchée à l'ordinateur.

- Ouvrir le logiciel Arduino IDE et créer un nouveau sketch.
- Sélectionner le modèle de la carte Arduino dans le menu "Select Board". Saisir le modèle de la carte que vous possédez. Dans le cas de ce projet, il s'agit d'une "Arduino Nano" (si cela ne fonctionne pas, sélectionner "Arduino Duemilanove"). Si le processeur de la carte est demandé, sélectionner "atmega328p" (dans le cas d'une carte Arduino nano).
- Coller [le code à téléverser](ARDUINO/src/main.cpp) dans le sketch. Vous pouvez alors modifier à souhait le délai d'appui des buzzers ainsi que les pins de lecture des buzzers. *Noter que modifier les pins de lecture des buzzers implique un différent montage du circuit ; référez vous à la [documentation Arduino](https://docs.arduino.cc/) en cas de doutes/problèmes*.
- Compiler puis téléverser le code dans la carte.

En cas de soucis lors de ces étapes, de l'aide est disponible [en ligne](https://docs.arduino.cc/) ou sur [Discord](https://discord.com/invite/jQJFwW7).

### Installation de l'interface graphique

L'interface graphique Processing de la carte Arduino est obtenable via deux méthodes:

- Vous pouvez télécharger le code source et ouvrir le fichier `GUI.pde` dans Processing puis l'executer.
- L'interface graphique est également disponible en *téléchargement direct* dans la section `Release` du dépôt (à droite de la page) ; téléchargez simplement le fichier et executez le, puis sélectionnez un dossier d'installation. Un raccourci devra apparaître sur le bureau.


## Comment jouer ?

Contrôles du présentateur:

- `E` pour attribuer les points d'une bonne réponse
- `Z` lors d'une mauvaise réponse
- `A` afin de passer à la question suivante
- `Espace` pour lancer le chronomètre dans les épreuves en nécessitant un
- `L` et `M` pour passer la main entre les joueurs

Ces commandes ont des comportements différents en fonction des épreuves. Ceux-ci sont décrits ci-dessous:

**9 points gagnants:** Le comportement des commandes est tel qu'énoncé précédemment. Noter que la commande `A` à utiliser lorsqu'aucun joueur ne trouve la bonne réponse incrémente le nombre de points de la question suivante *comme précisé dans les règles officielles de l'émission*.

**4 à la suite:** Utiliser les touches `1`, `2`, `3` ou `4` pour sélectionner le thème que le joueur a choisi. `E` pour chaque bonne réponse, `Z` en cas de mauvaise réponse, faisant descendre le compteur de points à 0.

**Face à Face:** Donner la main à un joueur ou un autre grâce au touches `L` pour la donner au joueur de gauche et `M` pour celui de droite. La touche `Espace` à lancer au début de chaque manche démarre le chronomètre. La touche `E` attribue les points correspondants au joueur ayant la bonne réponse. La touche `Z` passe la main à l'adversaire et mets pause au chronomètre ; *il est important que le présentateur relance le chronomètre à la question suivante*. Enfin la touche `A` permet de réinitialiser l'interface du timer si personne ne trouve réponse à la question ou en cas d'erreur quelconque.


## Problèmes connus / Avant de jouer

Un certain nombre de problèmes/bugs peuvent survenir durant la partie. Le tout est de savoir lesquels afin de mieux les appréhender:

- L'affichage des noms (joueurs et thèmes), spécialement les plus longs, est souvent buggé. Veillez à utiliser des noms plutôt courts afin de bénéficier d'une meilleure expérience de jeu.
- Le bouton `E` lors du 4 à la suite est très sensible. Il n'est pas rare que le présentateur reste appuyé un peu trop longtemps, ajoutant 2 points au lieu d'un au joueur. Veillez à tout particulièrement appuyer *brièvement* sur le bouton lors de cette épreuve. (Ce problème est réglable pour les plus débrouillards en modifiant le délai du click dans le code de l'interface processing)
- L'affichage des buzzers rouges est parfois buggé dans le jeu décisif. Il s'agit uniquement d'un bug visuel ; appuyer sur `A` réglera le problème.
- Quelques fois les noms des joueurs du Face à Face n'apparaissent pas tous. Vous pouvez choisir de poursuivre la partie sans s'en soucier ou en recommencer une nouvelle en brulant les étapes pour revenir à la bonne phase de jeu.
- Faites attention ! Le chronomètre démarre bel et bien **à l'appui de la barre espace** ; ne vous souciez pas du son qui arrive en retard.
- La jauge de remplissage des tuiles du Face à Face est **très approximative**. Ne vous y fiez pas.


De même, quelques problèmes peuvent survenir du côté du dispositif à buzzers:

- Quelques fois les buzzers appuyeront d'eux-même sans intervention humaine. Dans ce cas, vérifiez le branchement des **résistances** des boutons. Redémarrez le player si cela ne règle pas le problème.

## Ressources supplémentaires

Questionnaires de jeu utilisés en club: [Blog de Pierre Tuelcan](https://pierre-tuelcan-questionnaires-36.webself.net/blog)

    
## Contribution

Toutes contributions sont les bienvenues ! Le gros du travail réside dans l'optimisation plus que nécessaire du code spaghetti du projet (j'étais en vacances 🤗) et également de la refonte graphique de l'interface, celle-ci étant extrêmement rudimentaire.

`Les contributions sont pour l'instant fermées`


## Auteurs

- [@Guicha](https://www.github.com/Guicha)

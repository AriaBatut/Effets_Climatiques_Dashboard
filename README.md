# Le Dashboard sur les effets du climat
*Le contexte:* 
    
Depuis Août, le GIEC, Groupe d’experts intergouvernemental sur l’évolution du climat, a publié le premier volet de son sixième rapport. c’est le tableau le plus complet, le plus précis et le plus à jour de la situation climatique mondiale. Nous savons tous pertinemment que le réchauffement climatique impacte fortement notre planète. Le rapport a alors alarmé beaucoup de monde mais ceux sur lesquels nous auriont voulu nous pencher sont les institutions financières. En effet, cette nouvelle publication pourrait nous permettre de voir en quoi les institutions financières peuvent être impactées par les grands changements à venir. Elles doivent réagir vite pour prendre des mesures nécéssaires.

Dans ce Dashboard, nous avons donc voulu reproduire un mini rapport du GIEC pour analyser les différents impacts qu'a la température sur notre planète pour permettre aux Institutions financières de prendre des mesures pour le futur. Il a été réalisé à l'aide de données que nous pouvions trouver publiquement et facilement.

Pour ce faire, nous avons récupéré les données d'observations issues des messages internationaux d’observation en surface (SYNOP) circulant sur le système mondial de télécommunication (SMT) de l’Organisation Météorologique Mondiale (OMM). Nous avons pu y trouver des paramètres atmosphériques mesurés tels que la température, l'humidité, la direction et force du vent, la pression atmosphérique, la hauteur de précipitations. OU bien des para mètres observés comme la description des nuages. Selon instrumentation et spécificités locales de la station où sont prises les mesures, d'autres paramètres sont disponibles comme la hauteur de neige et état du sol.

<br>

### User Guide
*Comment on déploie le Dasboard?*

1)	Cloner tout le projet à partir du GIT sur votre machine

2)  Récupérer le fichier .csv qui formera la Base de Données utilisée pour former le Dashboard.

Pour cela il faut:
- Ouvrir le fichier Fichiers_Projet.ipynb avec Jupyter Notebook
- Exécuter toutes les cases

Normalement, dans le fichier du projet que vous venez de cloner, il y aura 2 fichiers .csv qui auront apparu : "Data_météo_R.csv", "postesMeteo.csv".
Cette execution sera un peu longue, car nous créons un fichier .csv à partir de plusieurs fichiers .csv. Cela prendra environ 5 minutes.

3)	Ouvrir RStudio

4)	Ouvrir le projet que vous venez de cloner : File > OpenProject , puis il faut chercher l'endroit où vous avez cloné le projet et cliquer sur le fichier "ProjetBatutGalagain.Rproj" 

5)	Installer les différents packages nécéssaires pour une bonne execution du code. Pour cela il vous suffit de lancer les commande suivantes dans la console de RStudio:
-  `install.packages('shiny')`
-  `install.packages('shinydashboard')`
-  `install.packages('gapminder')`
-  `install.packages('dplyr')`
-  `install.packages('ggplot2')`
-  `install.packages('lubridate')`
-  `install.packages('tidyverse')`
-  `install.packages('leaflet')`

Tous les packages utiles sont maintenant installés!

5)  Si ce n'est pas déjà fait, il faut ouvrir le fichier "global.R", c'est celui qui contient la lecture des fichiers .csv ainsi que le traitement des données, avec les créations de toutes les tibbbles nécéssaires au bon fonctionnement de l'application.

Une fois le fichier ouvert, vous pouvez:
*  Soit sélectionner toutes les lignes du fichier et appuyer sur `Ctrl` + `entrée`
*  Soit appuyer sur `Ctrl` + `entrée` pour chaque ligne du code

Cette exécution sera elle aussi un peu longue, car il faut le temps à RStudio de lire les fichiers .csv et des modifications sur des colonnes sont parfois demandées. Cela prendra environ 5 minutes.
Après ça, le Dashaboard est prêt à être lancé!

6)  Dans la console, il suffit d'écrire la commande suivante :
    `runApp('app.R')`

7)  Une page s'ouvre, c'est la page d'accueil de notre Dashboard! 

Vous pouvez maintenant naviguer dessus, à travers les différentes pages qui vous sont proposées lorsque que vous cliquez sur le titre de la page sur le côté gauche.
Vous allez pouvoir y retrouver différents graphiques intéractifs, car il vous sera possible de choisir l'années et la stations d'où proviennent les observations.

<br>

### Developper Guide
*Comment est organiser le code?*

Pour le fichier ***"global.R"*** :

Ce fichier permet de préparer tous les outils nécessaire au bon fonctionnement de l’application. Il y aura au départ l’appel à toutes les librairies installées précédemment.
Puis il permettra de récupérer les données collectées dans les fichiers ***"Data_Météo_R.csv"*** et ***"postesMeteo.csv"*** grâce à la fonction `read.csv2()`.
On obtient deux data-frame au format wide nommées respectivement `climat` et `postes_climat`.

Création du tibble `meteo_tb`, qui sera utilisé pour la création des différents graphique :

Il faut transformer `climat` au format long. C’est ce qui est fait avec la fonction `pivot_longer()`, où toutes les colonnes qui portent le noms d’une observations
climatologiques vont être regroupées dans une même colonne nommées "observations" et leur valeurs respectives seront contenues dans la colonnes "value".
On supprime ensuite chaque ligne ayant comme valeur "mq" car cela signifie que la valeur est manquante.
Ensuite, fusionne les data-frame pour obtenir les Noms des stations avec leur longitude et latitude. Cela se fait grâce à la fonction `merge()`.
Pour finir on transforme la nouvelle dtat-frame en un tibble, avce la fonction `as.tibble()`.

Une fois `meteo_tb` obtenue, nous allons pouvoir créer tous les tibbles nécessaires pour former des graphiques qui seront inclus dans le Dashboard,
ainsi que différente valeur comme par exemple la moyenne de la température en 1996 toutes stations confondues qui permettra de former un graphique montrant
l’évolution de l’écart de températures entre 1996 et 2021.

Les premiers tibbles créés, nommés `day` et `night`, contiennement les valeurs des observations pour le jour et la nuit, groupées par date et par nom de stations.
Ensuite on pourra retrouver différents tibbles regroupant différents observations comme la température journalière moyennée par mois, ou le taux d’humidité dans chaque
station moyenné par mois etc..

Nous allons pas détailler chaque tibble créé, mais prenons un exemple pour expliquer le fonctionnement. Nous voulions par exemple avoir les valeurs du taux d’humidité
jour par jour pour chaque stations. Il faudra donc filtrer le tibble `mete_tb` lorsque la valeur de la colonne observation vaut "u". On utilise donc la fonction `filter()`
de la manière suivant `filter(observations == "u")`. Puis il faut grouper les donner pour ensuite calculer la moyenne journalière pour chaque station, donc il faut
grouper par année, mois, jour et par le nom de la station. Pour cela, on utilise la fonction `group_by()` comme suit `group_by(year(date), month(date), day(date), Nom))`,
puis on fait la moyenne à chaque fois de la valeur. Il faut utiliser la fonction `summurise()`, qui s’évrira de cette manière dans notre cas :
`summuarise(mean = mean(value))`. On obtiendra un nouveau tibble qui aura 5 colonnes : year, month, day, Nom et mean, où mean sera bien la moyenne par jour de l’humidité dans chaque station.

Pour les autres tibbles, leur création est très similaires.

<br>

Pour le fichier ***"ui.R"*** : 

Ce fichier contient toute l’interface du Dashboard, c’est ce qu’on appelle l’interface utilisateur. C’est-à-dire qu’il y aura la définition des boutons
interactifs ainsi que le partitionnement de la page.
L’affichage de l’application (le partitionnement) se fait grâce à la fonction `dashboardPage()` qui prend 3 arguments importants pour un beau design :

*  `dashboardHeader()`, qui permet de mettre non au Dashboard en haut à gauche

*  `dashboardSidebar()`, qui permet de réalisé un menu sur la gauche. On y ajoute différents items avec la fonction `menuItem()` en donnant un titre à
chaque bar du menu ainsi qu’un ID pour pourvoir être référencé dans la partie d’après et donc être rempli

*  `dashboardBody()` qui contient tout le corps de l’application. Pour ensuite remplir chaque items créés dans la partie juste avant, il faut utiliser
la fonction `tabItems()`, puis à l’intérieur `tabItem()` à en appelant à chaque fois l’ID donné à l’item dans la bar menu. Pour bien structurer le tout,
on pourra utiliser les fonctions suivantes :

`fluiRow()`, pour y mettre des lignes ou bien

`column()` pour intégrer des colonnes

On peut y placer des titres, du texte ou bien encore de cadres formé par la fonction `box()`. Beaucoup de possibilité se présente.

C’est dans cette partie que l’on va définir des input, qui seront là pour rendre l’application plus attractive. Ils seront sous forme de menu déroulant,
de bouton, ou de barre qui varie. On va utiliser principalement `sliderInput()`, pour que l’utilisateur face varier l’année, `selectInput()` pour avoir un menu
déroulant, et `radioButtons()` pour choisir entre deux propositions. Chaque input à un ID pour y faire référence dans le fichier ***"server.R"*** de la manière
suivante `input$ID`.
On va aussi créer l’emplacement des outputs, donc ce qui va être affiché dans l’applications. Dans notre Dashboard, nous avons essentiellement présenté que des graphiques
ou des maps, donc nous avons utilisé simplement `plotOuput()` et `leafletOutput()`. Il ne faut pas oublier de donner un ID à chaque sorti pour ensuite y faire référence
dans le fichier ***"server.R"***, comme pour les inputs.

<br>

Pour le fichier ***"server.R"***:

Ce fichier est le cœur de l’application, c’est le côté serveur. C’est l’endroit où tous les calcule se font, dans notre cas la production des graphiques,
que l’on va afficher. C’est aussi ici que l’on va préciser quels paramètres input agissent sur quels résultats output.

Le code est rangé page par page, une page correspondant à un item du menu sideBar.

Pour attribuer une valeur à un output, on utilise son ID comme par exemple pour la première map du Dashboard, son ID est "map", on écrit donc : `outpu$map`. 
On lui affecte un appel à `rendreLeaflet()` avec à l’intérieur la carte de créée. De même, lorsque que l’on veut afficher un graphique, on affecte cette fois ci à
la variable `outpu$ID` un appel à `renderPlot()`, avec à l’intérieur l’expression pour former le graphique.

Pour apporter l’interactivité au graphique, on y a ajouté des input qui sont là pour faire varier les données présentent sur les graphiques de la page.Comment sont-ils appelé ?

Lorsque qu’on en a besoin , on appelle par input et son ID de la manière suivant : `input$ID`.

Prenons un exemple, on veut tracer un graphique présentant l’évolution de la température du sol pour une année et une station choisie. Ce graphique se trouve dans l’item
ayant l’ID "sol". L’ID du graphique sera "temp_sol" et les input "année3" et "station3". On affecte donc à `outpu$temp_sol` un `renderPlot()`.
A l’intérieur de celui-ci, on y met le graphique. Mais il faut déjà former la data-base nécessaire, c’est-à-dire qu’il faut filtrer le tibble nommé `Mean_Temp_Sol`
formé dans le fichier ***"global.R"***, qui contient jour par jour de 1996 à 2021 la moyenne de la température du sol dans chaque station. On veut donc récupérer
simplement les valeur correspondant à la date et la station que l’utilisateur aura choisies : nos input. On va donc appliquer
`filter(year == inpu$annee3, Nom == input$station3)` au tibble, ce qui va sélectionner que les valeurs qui intéressent l’utilisateur. Puis, pour le graphique, on
utilisera `ggplot()` avec `aes(x=date, y=mean)`, car "mean" est le nom de la colonne comportant les valeurs numériques, puis `geom_line()`, pour avoir un graphique
où tous les point sont reliés. Pour avoir une idée plus global de la variation, on applique `geom_smooth()` qui fait une regression linéaire sur les valeurs.
On peut ensuite y ajouter un titre avec `ggtitle()`, qui peut être modifier en fonction des input grâce à la fonction `paste()`. Dans notre cas cela donne :
`ggtitle(paste("Evolution de la température du sol en", input$annee3, "dans la station", input$station3, sep = " "))`.
On peut aussi changer la légendes des axes des abscisses et des ordonnées avec les fonctions `scale_x_continuous()` et `scale_y_continuous()`.

Il est aussi possible de créer des fonction reactive, qui donne un résultat changeant en fonction d’un input. Cela est pratique pour nous si nous utilisant
un tibble créée à partir d’un ou plusieurs input, le tibble n’a pas besoin d’être recalculé pour des occurrences différentes.
On utilise simplement la fonction `reactive()`.  La fonction réactive a aussi servi à choisir le bon tibble en fonction d’un input.


Petite explication page par page :
-	Item "accueil", correspondant à la page d’accueil du Dashboard. 

On y trouve la création d’une map comportant la localisation de chaque station (expliqué juste au-dessus) ainsi que un graphique montrant l’écart des température
par rapport à la moyenne de 1996. Pour celui-là nous avons opté pour un graphique aves des barres, qui se fait avec la fonction `geom_col()`. 
<br>
<br>

-	Item `temp`, correspond à la page des analyse de la température.

On y trouve deux graphique, l’un montrant l’évolution de la température au cour d’un année pour une stations choisie, et l’autre est un histogramme montrant le
nombre de jour ayant atteint une certaine température durant la même année et station choisie. Pour cette partie, nous avons ajouté un input nommé "When" qui est
un bouton qui  permet de choisir si l’on veut voir les données pour le jour et la nuit séparée ou une moyenne journalière. Pour tracer ensuite nos graphique,
il  a fallu créer deux fonctions réactives qui retournent le bon graphique ou diagramme en fonction de la valeur de when. Pour cela on a utilisé une nouvelle fois la
fonction `reactive()` avec l’utilisation d’un `if()` et un `else()`. La condition est `if(input$When == when[1])` et l’instruction est la formation du graphique
ou de l’histogramme qui sépare les valeurs du jour et de la nuit, donc avec le tibble correspondant qui est `Mean_Temp2` flitrer en fonction de l’année, `input$annee`
et du nom de la station, `input$station`, qui sont choisis par l’utilisateur. Sinon (else), on forme le graphique ou l’histogramme de la température journalière.
On prend le tibble Daily_Mean_Temp que l’on filtre de la même manière, avec les mêmes input.

Pour la création de l’histogramme, on utilise la fonction `geom_histogram()`. Pour placer la moyenne de celui-ci, on utilise aussi `geom_vline()` avec `aes(xintercept=mean(mean))`.
<br>
<br>

-	Item "diag_omb", correspond à la page avec le diagramme ombrothermique année par année pour une station choisie par l’utilisateur : `input$annee2` et `input$station2`.

Nous avons d’abord créé la fonction réactive `new_tab`, qui génère un nouveau tibble à partir de celui nommé `Diag_ombro` en filtrant en fonction de deux input,
l’année et la station. Cette fonction est créer car on utilise plusieur fois le même tibble à des endroits différents et cela évite de le calculer plusieurs fois. 

Après avoir la bonne table, il faut tracer les précipitation avec la température selon une certaine formule. Pour cela, il a fallu fixer les limites pour les deux axes des ordonnées,
nommées ici `ylim_preci`, et `ylim_temp`, puis créer deux valeurs réactives (car elles dépendant de `new_tab`) qui permettent ensuite de calculer la bonne gradation des
deux axes. Enfin on affecte le graphique, formé avec `ggplot()`, au bon output, celui qui a comme ID Diagramme. Pour y ajouter les deux gradations différentes,
il a fallu dans `scale_y_continuous()`, ajouter un arguement `sec.axis = sec_axis()`.
<br>
<br>

-	Item "sol",  correspond à la page où l’on peut voir l’état des sols année par année ainsi que 3 graphiques présentant l’évolution de la température du sol,
de l’humidité et de la hauteur de la couche de neige, soit année par année soit l’évolution global de 1996 à 2021 en choisissant toujours la station.

Pour la carte, on créé avec une fonction réactive le tibble désiré en fonction de `input$annee`. On va ensuite former une palette de couleur qui servira à légender
la carte grâce à la fonction `colorNumeric()`. Ensuite on forme la carte avec `leaflet()`, on y ajoute des marqueur rond avec `addCircleMarkers()` qui sont placé
en fonction des valeurs de "Longitude" et "Latitute" contenues dans le tibble, et avec l’argument `color`, on y met la palette nommé pal qui va créer la légende
en fonction des valeurs nommé mean qui représente un chiffre entre 0 et 9, l’état du sol. On ajoute la légende, pour que la carte soit plus comprehensive avec la
fonction `addLegend()` qui sera créée avec la même palette de couleur.

Pour les 6 autres graphiques, ils sont créée de la même manière qu’expliqué juste au-dessus.
<br>
<br>

-	Item "recap",  est une page de conclusion montrant l’influence d’une observation sur une autre.

Sur cette page, on peut choisir quelle observation on veut tracer en fonction de quelles autres. Il fallait créer 3 fonction réactive pour avoir la bonne abscisses
et les bonnes ordonnées pour former les graphiques demandé par l’utilisateur. On a utilisé, à l’intérieur de `reactive()`, un `switch()` qui prend en argument une valeur,
et différents cas avec des instructions derrière. Ma fonction renvoie l’instruction qui correspond au cas égale à la valeur. Ici la valeur est `input$x` ou `input$y1` ou
`input$y2`. Et en fonction de ce qui est sélectionné, la fonction réactive renvoie le tibble qu’il faut choisir pour former le graphique demandé. Puis on forme les graphique
avec un tibble formé des deux tibble sélectionnés en utilisant la commande `left_join()`, en joignant les deux par la colonne année, donc `by = "year"`, à l’interieur de
`left_join()`. On utilise ensuite toujours les mêmes fonction pour former le graphique, `ggplot()` et `geom_point()` pour avoir un graphique avec des points cette fois-ci.
La commande `sclae_color_gradient()` permet de choisir l’evolution de la couleur pour la légende. Ici on choisi de bleu, pour les année antérieur, à rouge, pour les années
les plus proches, car on a remarqué que la température ne cessait d’augmenter donc qu’il faisait de plus en plus chaud.

<br>

Pour le fichier ***"app.R"***:

C'est celui qui contient la fonction qui permet de démarrer l'application. Cette fonction est `shinyApp()` qui prend en argument
les deux composants `ui` et `server` créés dans leur fichier respectif. C'est pour cela qu'on appelle au début du fichier "app.R" les fichier "ui.R" et server.R
avec la commande `source()`, sans oublier d'encoder en UTF-8 pour avoir les accents sur le Dashboard.


<br>

### Rapport d'analyse
*Que pouvons nous conclure de ce Dashboard?*

Dès la première page, nous nous apercevons que la température globale, toutes les stations confondues, augmente fortement.
En effet, l'écart entre la température moyenne de 1996 et les années suivante ne cesse d'augmenter. L'augmentation est même de plus en plus forte depuis 2012.

Pour mieux analyser cet écart, la page "Analyse des température" est faite pour ça. En effet, on y retrouve l'évolution de celle ci année par année pour une station choisie.
On peut l'analyser avec le jour et la nuit séparés ou bien une moyenne sur une jour entier. La conclusion est que de manière générale pour toutes les stations,
si on part de 1996, la plus haute température sur le régression linéaire en journée serait inférieur à 20°C mais que lorsque l'on change l'année vers une plus récente, celle ci devient supérieur à 20°.
Cela se remarque aussi sur le diagramme, qui représente le nombre de journée ayant atteint la température donnée. Plus l'année est récente, plus il y a de jours ayant atteint des températures plus chaudes.

Quel impact cela peut-il avoir?

En climatologie, un graphique intéressant est le diagramme ombrothermique. Il représente les variations mensuelles sur une année de la température et des précipitations.
Cela permet de remarquer rapidement les périodes de sécheresse. Si l'on fait varier les années et mêmes les différentes stations, ce que l'on remarque est qu'en générale durant l'été,
les températures ne cesse d'augmenter (la température maximale atteinte est de plus en plus grande) mais qu'au contraire il y a de moins en moins de précipitations. Cela implique qi'il y aura de plus en plus de zone de sécheresse.

Cette dernière observation pourrait bien se répercuter sur l'état des sols, savoir s'il est plutôt sec ou humide. Grâce à la carte tracée, on remraque que plus les années passent,
plus les sols sont secs et non humides comme ils pouvaient l'être avant. Cela s'aperçoit sur les 3 graphiques traçant la température du sol, l'humidité et la hauteur de la neige en fonction du temps, en particulier sur ceux qui sont tracé en fonction des années.
Plus le temps avance, plus la température du sol augmente et amène à un sol sec. Le taux d'humidité n'aide pas à retrouver un sol humide, car même si c'est moins flagrant, on peut
remarquer que celle-ci commence à diminuer. De plus, il y a de moins en moins de neige car il fait beaucoup trop chaud, et les sols ne permettent pas à celle-ci de tenir.

Malheureusement, même si aucun graphique ne le montre ici, il ne faut pas oublier que tout cela cause la montées des eaux qui risquent de mettre en péril notre planète.

###### Fin du README
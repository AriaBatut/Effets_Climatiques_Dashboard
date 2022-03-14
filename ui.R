library(shiny)
library(shinydashboard)
library(gapminder)
library(dplyr)
library(ggplot2)
library(lubridate)
library(tidyverse)
library(leaflet)



ui <- dashboardPage(
  
  dashboardHeader(title = "BATUT et GALAGAIN"),
  
  dashboardSidebar(
    
    sidebarMenu(
      menuItem("ACCUEIL", tabName = "accueil"),
      menuItem("Analyse des températures", tabName = "temp"),
      menuItem("Diagrammes Ombrothermiques", tabName = "diag_omb"),
      menuItem("Etat des sols", tabName = "sol"),
      menuItem("Petit récapitulatif", tabName = "recap")
    )
  ),
  
  dashboardBody(
    tabItems(
      
      ############################## PAGE ACCUEIL ##############################
      tabItem("accueil",
              titlePanel(title = h1("Bienvenue")),
              
              fluidRow(
                
                column(7,
                       h2("Qu'allez-vous trouver dans ce Dashboard?"),
                       
                       h4("Il a été créé à partir de données climatologiques répértoriées sur le site
                       de METEO FRANCE. Elles sont issues d'observations  
                       messages internationaux d’observation en surface (SYNOP)."),
                       
                       h4("Plusieurs paramètres atmosphériques sont mesurés comme la température, 
                       l'humidité, la pression atmosphérique, les précipitations). 
                       Selon instrumentation et spécificités locales, d'autres paramètres peuvent être disponibles
                       commme la hauteur de neige ou l'état du sol."),
                       
                       h4("Ces données sont répertoriées tous les jours à des heures différentes,
                       et cela depuis 1996. Il y a au total 62 stations qui transmettent leurs données."),
                       
                       br(),
                       
                       h4("Vous pourrez donc, dans ce Dashboard, retrouver différents graphiques tracés à l'aide 
                       des données récupérées. Il vous sera possible de vous amuser à changer les années,
                       ou bien la station d'observation, cela dépendra des graphiques."),
                       
                       h4("Pour vous aider à vous géolocaliser, nous vous porposons une carte, à droite,
                          qui donne la localisation de chaque station à l'aide d'un marqueur bleu.")
                ),
                
                column(5,
                       box(
                         title = "Localisations des différentes stations de l'étude",
                         width = 20,
                         leafletOutput("map", height=300)
                       )
                )
              ),
              
              fluidRow(
                
                column(5,
                       box(
                         title = "Evolution de la température toutes les stations confondues, 1996-2021",
                         width = 20,
                         plotOutput(outputId ="ecart", height=400)
                       )
                ),
                
                column(7,
                       h2("Notre objectif"),
                       h4("Récemment, le GIEC a publié son nouveau rapport climatologique, et nous voulions nous en inspiré ici."),
                       
                       h4("Comme nous le savons, la planète connais le réchauffement climatique. 
                       Cela peut bien s'apercevoir sur la graphique juste à gauche.
                       En effet, nous avons calculer la température moyenne en 1996, toutes les 
                       stations confondues, pour ensuite calculer l'écart avec les années suivante.
                       Il est très flagrant que la température moyenne sur un an ne cesse d'augmenter,
                       en particulier depuis 2012."),
                       
                       h4("Nous avons donc regroupés plusieurs graphiques montrant l'evolution de différentes 
                       observations au cours des  années. Cela nous permet de voir l'impact qu'a le rechauffement 
                       sur la planète et, dans notre cas, au niveau des différentes stations d'études."),
                       
                       h4("Les résultats que nous pouvons soulever à travers le rapport du GIEC, ou bien à travers 
                       nos graphiques, alarment beaucoup de personnes. En particulier, la hausse de température qui provoque 
                       la montée des eaux."),
                       
                       h4("Des prévisons pourrait s'avéréer utilent pour, par exemple, les institutions financières qui se voient 
                       potentiellement prêter de l'argent à des personnes voulant investir dans des régions où la montées des eaux augmentent 
                       fortement."),
                       
                       h4("PS: Si aucun graphique n'apparraît lorsque que tu change une variable,
                          ne t'en fait pas! C'est qu'aucune donnée n'a été répertoriée pour ton choix"),
                       
                       br(),
                       h6("Site de METEO FRANCE pour récupérerer les données"),
                       a("https://donneespubliques.meteofrance.fr/?fond=produit&id_produit=90&id_rubrique=32")
                )
              )
      ),
      
      ############################## PAGE TEMPERATURE ##############################
      
      tabItem("temp",
              
              titlePanel(title = h1("Analyse de la température année par année en fonction de la station")),
              
              fluidRow(
                column(10,
                       offset = 1,
                       box(
                         title = "Inputs", "Tu peux,ici, choisir l'année et la station
                       pour laquelle tu veux voir l'évolution de la température",
                         br(),
                         "Il est aussi possible d'avoir l'évolution de la journée et de la nuit, 
                       ou bien une moyenne jounamière",
                         br(),
                         br(),
                         
                         column(5,
                                sliderInput("annee", "Année:", min = 1996, max= 2021, value = 1996)
                         ),
                         
                         column(3,
                                selectInput("station", "Sation:", nom)
                         ),
                         
                         column(3,
                                radioButtons("when", "Moment de la journée:", when)
                         ),
                         
                         width = 11)
                ),
                
                fluidRow(
                  
                  column(6,
                         box(
                           title = "Evolution de la température au cours d'une année dans la station choisie",
                           width = 20,
                           plotOutput(outputId ="Mean_Temp", height=500)
                         )
                  ),
                  
                  column(6,
                         box(
                           title = "Fréquence de la température au cours d'une année dans la station choisie",
                           width = 20,
                           plotOutput(outputId ="freq", height=500)
                         )
                  )
                )
              )
      ),
      
      ###################### PAGE DIAGRAMME OMBROTHERMIQUE ######################
      
      tabItem("diag_omb",
              
              titlePanel("Diagramme ombrothermique dépendant de l'année et de la station choisies"),
              
              sidebarLayout(
                sidebarPanel(
                  sliderInput("annee2", "Année:", min = 1996, max= 2021, value = 1996),
                  selectInput("station2", "Sation:", nom),
                  h3("Qu'est ce que c'est?"),
                  h4("Un diagramme ombrothermique est un type particulier de diagramme climatique 
                     représentant les variations mensuelles sur une année des températures et des 
                     précipitations selon des gradations standardisées. Il a été développé par Henri 
                     Gaussen et F. Bagnouls, botanistes célèbres, pour mettre en évidence les périodes 
                     de sécheresses définies par une courbe des précipitations (ici histogramme bleu) 
                     se situant en dessous de la courbe des températures (ici courbe orrange pour la 
                     température moyenne). Ces diagrammes permettent de comparer facilement les climats 
                     de différents endroits d'un coup d'œil du point de vue pluviosité")
                ),
                
                mainPanel(
                  box(
                    title = "Diagramme ombrothermique",
                    width = 20,
                    plotOutput(outputId ="Diagramme", height=800)
                  )
                  
                )
              )
      ),
      
      ########################### PAGE ETAT DES SOLS ############################
      
      tabItem("sol",
              titlePanel("Etat des sols dans les différentes stations"),
              
              fluidRow( 
                box( 
                  h3("Inputs"),
                  h5("Tu peux choisir l'année et la station
                     pour laquelle tu veux voir l'évolution des différentes observations"),
                  
                  column(7,
                         sliderInput("annee3", "Année:", min = 1996, max= 2021, value = 1996)
                  ),
                  
                  column(4,
                         selectInput("station3", "Sation:", nom)
                  ),
                  
                  width = 20)
              ),
              
              column(6,
                     leafletOutput("map2", height=620)
              ),
              
              column(6, tabBox( width = 1500,
                
                tabPanel (title = 'Année choisie',
                          fluidRow(
                            plotOutput(outputId ="temp_sol", height=190)
                            ),
                          
                          fluidRow(
                            plotOutput(outputId ="humidite",height=190)
                            ),
                          
                          fluidRow(
                            plotOutput(outputId ="neige", height=190)
                            )
                          ),
                
                tabPanel( title = '1996-2021',
                          fluidRow(
                            plotOutput(outputId ="temp_sol2", height=190)
                            ),
                          
                          fluidRow(
                            plotOutput(outputId ="humidite2",height=190)
                            ),
                          
                          fluidRow(
                            plotOutput(outputId ="neige2", height=190)
                            )
                          )
                
                )
                
                )
      ),
      
      
      ########################### PAGE RECAPITULATIVE ############################
      
      tabItem("recap",
              h1("MINI RECAPITULATIF"),
              h3("Ici vous trouverez deux graphiques montrant l'influence au cours du temps d'une
                         observation en abscisse sur celles choisies pour les ordonnées"),
              
              sidebarLayout(
                sidebarPanel(
                  h2("Quelles observations choisir?"),
                  selectInput("x", "Choisi l'observation à mettre en abscisse", abscisse),
                  selectInput("y1", "Choisi l'observation à mettre en ordonnées du graphique du haut", ordonnée),
                  selectInput("y2", "Choisi l'observation à mettre en ordonnées du graphique du bas", ordonnée),
                  h3("A quoi servent ces graphiques?"),
                  h4("Ils sont présents pour affirmer que le réchauffement
                     climatique est présent et qu'il influence plusieurs 
                     paramètres sur terre au cours du temps."),
                  h4("En effet, peu importe les observations que vous aurez choisi
                     pour tracer les graphiques, vous observerez que les températures
                     augmentent et que cela réchauffent les sols et les rend 
                     beaucoup plus sec. De plus, le taux d'humidité ne cesse
                     de diminiuer, sûrement à cause des fortes températures,
                     il pleut de moins en moins et la neige ne tient plus en hiver"),
                  h3("Il serait important de réagir et de lutter contre le réchauffement
                     climatique pour sauver notre planète!"),
                ),
              
                mainPanel(
                  titlePanel("Les graphiques de conclusion"),
                  box(
                    width = 20,
                    plotOutput(outputId ="graph_h", height=325)
                    ),
                  
                  box(
                    width = 20,
                    plotOutput(outputId ="graph_b", height=325)
                    )
                  )
                )
              )
      )
    )
)


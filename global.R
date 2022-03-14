################################################################################
#
# Ce fichier permet de récupérer les données collectées dans les fichiers 
# Data_Météo_R.csv et postesMeteo.csv
# Il traitera les deux tables obtenues de manière à avoir un seul tibble au format
# long nommé "meteo_tb" utilisable pour former tous les graphiques du Dashboard
#
# Afin de simplifier le traitement du Dashboard, les librairies seront importées
# à partir de ce fichier, plusieurs valeurs utiles y seront créées, ainsi que tous
# tibbles qui sont utilisés pour former les graphiques plus simplement dans le 
# fichier "server.R"
#
################################################################################

library(shiny)
library(shinydashboard)
library(gapminder)
library(dplyr)
library(ggplot2)
library(lubridate)
library(tidyverse)
library(leaflet)



#### IMPORTS DES FICHIERS .CSV ####

climat <- read.csv2("Data_météo_R.csv", sep = ',')
climat <- mutate(climat, date=as.POSIXct(date))

colnames(climat)[2] <- "date"


postes_climat <- read.csv2("postesMeteo.csv")
postes_climat <- rename(postes_climat, "numer_sta" = "ID")

postes_climat$Latitude <- as.double(postes_climat$Latitude)
postes_climat$Longitude <- as.double(postes_climat$Longitude)

nom_all <- postes_climat$Nom
nom <- nom_all[c(-3, -6, -8, -15, -21, -38, -53, -62)]
  

##### Création de la DataFrame en format long au lieu de wide  ####

climat_long <- pivot_longer(climat, !c("numer_sta", "date"),
                            names_to = "observations", values_to = "value")


#### On supprime toutes les lignes qui ont pour valeur "mq" (ce qui signifie manquante) 

new_climat_long <-climat_long[climat_long[,4]!= "mq",]


####Fusion des DF pour avoir le nom de la station avec l'altitude et la longitude
#### pour pouvoir avoir une carte

DATA_meteo <- merge(new_climat_long, postes_climat, by ="numer_sta")
DATA_meteo$observations <- as.factor(DATA_meteo$observations)
DATA_meteo$value <- as.double(DATA_meteo$value)

#### Création du tibble qui sera utilisé pour les graphiques
#### Création de valeurs utiles

meteo_tb <- as.tibble(DATA_meteo)
d <- c(1996:2021)
when <- c("Jour et nuit séparés", "Moyenne du jour et de la nuit")
abscisse <- ordonnée <- c("Température (en °C)", "Température du sol (en °C)",
                          "Etat du sol", "Précipitations (en mm)",
                          "Humidité (en %)", "Hauteur de neige (en m)")

#### Moyenne de la température en 1996 pour le calcul des écarts  ####

Mean_1996_tot <- meteo_tb %>%
  filter(observations == "t", year(date)==1996)%>%
  summarise(mean=mean(value)-273)


#### On supprime les tables inutiles
rm(climat, climat_long, new_climat_long, DATA_meteo)


########################## CREATION DE TOUS LES TIBBLES ##########################

######### JOUR/NUIT ######### 

day <- meteo_tb %>%
  filter(hour(date) >= 8 & hour(date) < 20 )

night <- meteo_tb %>%
  filter(hour(date) < 8 | hour(date) >= 20 )


######## DIAGRAMME DES ECARTS ######### 

Ecart_annee <- meteo_tb %>%
  filter(observations == "t")%>%
  group_by(year(date))%>%
  summarise(ecart = mean(value)-273 - Mean_1996_tot[[1]])

colnames(Ecart_annee)[1] <- "year"


######### TEMPERATURE JOUR/NUIT ######### 

Day_Mean_Temp <- day %>%
  filter(observations == "t")%>%
  group_by(year(date), month(date), day(date), Nom)%>%
  summarize(mean=mean(value)-273)

Night_Mean_Temp <- night %>%
  filter(observations == "t")%>%
  group_by(year(date), month(date), day(date), Nom)%>%
  summarize(mean=mean(value)-273)


colnames(Day_Mean_Temp)[1] <- colnames(Night_Mean_Temp)[1] <- "year"
colnames(Day_Mean_Temp)[2] <- colnames(Night_Mean_Temp)[2] <- "month"
colnames(Day_Mean_Temp)[3] <- colnames(Night_Mean_Temp)[3] <- "day"

Day_Mean_Temp <- Day_Mean_Temp%>%
  mutate(date = make_date(year, month, day), When = "Jour")

Night_Mean_Temp <- Night_Mean_Temp %>%
  mutate(date = make_date(year, month, day), When = "Nuit")

Mean_Temp2 <- bind_rows(Day_Mean_Temp, Night_Mean_Temp)


######### TEMPERATURE GLOBALE ######### 

Daily_Mean_Temp <- meteo_tb %>%
  filter(observations == "t")%>%
  group_by(year(date), month(date), day(date), Nom)%>%
  summarize(mean=mean(value)-273)

colnames(Daily_Mean_Temp)[1] <- "year"
colnames(Daily_Mean_Temp)[2] <- "month"
colnames(Daily_Mean_Temp)[3] <- "day"

Daily_Mean_Temp <- mutate(Daily_Mean_Temp, date = make_date(year, month, day), When = "Jour")


######### HUMIDITE ######### 

Mean_Hum <- meteo_tb %>%
  filter(observations == "u")%>%
  group_by(year(date), month(date), day(date), Nom)%>%
  summarize(mean=mean(value))

colnames(Mean_Hum)[1] <- "year"
colnames(Mean_Hum)[2] <- "month"
colnames(Mean_Hum)[3] <- "day"

Mean_Hum <- mutate(Mean_Hum, date = make_date(year, month, day))

Mean_Hum_Annee <- Mean_Hum %>%
  group_by(year(date), Nom)%>%
  summarize(mean=mean(mean))

colnames(Mean_Hum_Annee)[1] <- "year"


######### TEMPERATURE SOL ######### 

Mean_Temp_Sol <- meteo_tb %>%
  filter(observations == "tminsol") %>%
  group_by(year(date), month(date), day(date), Nom)%>%
  summarize(mean=mean(value-273))

colnames(Mean_Temp_Sol)[1] <- "year"
colnames(Mean_Temp_Sol)[2] <- "month"
colnames(Mean_Temp_Sol)[3] <- "day"

Mean_Temp_Sol <- mutate(Mean_Temp_Sol, date = make_date(year, month, day))

Mean_Temp_Sol_Annee <- Mean_Temp_Sol %>%
  group_by(year(date), Nom)%>%
  summarize(mean=mean(mean))

colnames(Mean_Temp_Sol_Annee)[1] <- "year"


######### HAUTEUR DE LA NEIGE ######### 

Mean_Hneige <- meteo_tb %>%
  filter(observations == "ht_neige")%>%
  group_by(year(date), month(date), day(date), Nom)%>%
  summarize(mean=mean(value))


colnames(Mean_Hneige)[1] <- "year"
colnames(Mean_Hneige)[2] <- "month"
colnames(Mean_Hneige)[3] <- "day"

Mean_Hneige <- mutate(Mean_Hneige, date = make_date(year, month, day))

Mean_Hneige_Annee <- Mean_Hneige %>%
  group_by(year(date), Nom)%>%
  summarize(mean=mean(mean))

colnames(Mean_Hneige_Annee)[1] <- "year"


######### ETAT DES SOLS ######### 

Etat_sol <- meteo_tb %>%
  filter(observations == "etat_sol")%>%
  group_by(year(date), Nom)%>%
  summarize(mean=round(mean(value), digits = 0))

colnames(Etat_sol)[1] <- "year"

Etat_sol <- merge(Etat_sol, postes_climat, by ="Nom")


############## DIAGRAMME OMBROTHERMIQUE ######### 
#### Creation des tibbles pour tracer un diagramme ombrothermique
#### on fait des moyennes pour avoir des valeurs par mois pour toutes les années
#### et pour chaque station

#### PRECIPITATIONS en mm
Mean_Precipitation24 <- meteo_tb %>%
  filter(observations == "rr24")%>%
  group_by(year(date), month(date), Nom)%>%
  summarise(mean_preci=mean(value))

#### TEMPERATURES en °C
Mean_Temp <- meteo_tb %>%
  filter(observations == "t")%>%
  group_by(year(date), month(date), Nom)%>%
  summarise(mean_temp=mean(value)-273)

colnames(Mean_Precipitation24)[1] <- colnames(Mean_Temp)[1] <- "year"
colnames(Mean_Precipitation24)[2] <- colnames(Mean_Temp)[2] <- "month"

Mean_Precipitation24 <- mutate(Mean_Precipitation24, date = make_date(year, month))
Mean_Temp <- mutate(Mean_Temp, date = make_date(year, month))

#### TEMPERATURES MAXIMALES ET MINIMALES en °C
Max_Temp <- meteo_tb %>%
  filter(observations == "tx12")%>%
  group_by(year(date), month(date), Nom)%>%
  summarise(max_temp=max(value)-273)

Min_Temp <- meteo_tb %>%
  filter(observations == "tn12")%>%
  group_by(year(date), month(date), Nom)%>%
  summarise(min_temp=min(value)-273)

colnames(Max_Temp)[1] <- colnames(Min_Temp)[1] <- "year"
colnames(Max_Temp)[2] <- colnames(Min_Temp)[2] <- "month"

Max_Temp <- mutate(Max_Temp, date = make_date(year, month))
Min_Temp <- mutate(Min_Temp, date = make_date(year, month))

#### On joint les tibbles obtenus pour ne former qu'un seul utilisable pour le graphique 
Diag_ombro <- left_join(
  left_join(
    left_join(Mean_Precipitation24, Mean_Temp, 
              by = c("date", "Nom", "year", "month")),Max_Temp,
    by = c("date", "Nom", "year", "month")),
                        Min_Temp, by = c("date", "Nom", "year", "month"))


colnames(Mean_Precipitation24)[4] <- "mean"

Diag_ombro$year <- NULL
Diag_ombro$month <- NULL

############## FIN DIAGRAMME OMBROTHERMIQUE



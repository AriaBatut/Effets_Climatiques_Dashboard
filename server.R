library(shiny)
library(shinydashboard)
library(gapminder)
library(dplyr)
library(ggplot2)
library(lubridate)
library(tidyverse)
library(leaflet)


server <- function(input, output){

######################### GRAPH PAGE ACCUEIL ##########################

  #### Map avec la localisation de chaque station
  
  output$map <- renderLeaflet({
    leaflet(postes_climat) %>%
      addMarkers(lng = ~Longitude, lat = ~Latitude, label = nom_all) %>%
      addTiles() %>%
      setView(lng = 2.80, lat = 46.80, zoom = 4)
    })
  
  #### Graphique des écarts de température
  
  output$ecart<-renderPlot({Ecart_annee %>%
    ggplot(aes(x=year, y = ecart)) +
      geom_col(color = '#F86C6C', fill = "#B80101", alpha = 0.5) +
      geom_smooth(linetype = "dashed", color = "#6789E7") +
      scale_y_continuous("Ecart par rapport à la moyenne de 1996 (en °C)")
  })

######################### GRAPH PAGE TEMPERATURE ####################### 
  
  #### Fonction permettant d'avoir le graphique de la variation des températures dans le temps
  #### en fonction du input When défini (jour/nuit ou moyenne journalière)
  
  graph <- reactive({
    if (input$when == when[1]){
      
      graph <- Mean_Temp2 %>%
        filter(year == input$annee, Nom == input$station) %>%
        ggplot(aes(x=date, y = mean, group = When, color = When)) +
        geom_line() +
        geom_smooth(linetype = "dashed") +
        scale_y_continuous("Température (en °C)")
    }
    
    else {
      
      graph <- Daily_Mean_Temp %>%
        filter(year == input$annee, Nom == input$station) %>%
        ggplot(aes(x=date, y = mean))  +
        geom_line(color = "#437A9B") +
        geom_smooth(linetype = "dashed", color = "#EA6464") +
        scale_y_continuous("Température (en °C)")
    }
    
    return (graph)
  })
  
  #### Fonction permettant d'avoir le l'histogramme des températures
  #### en fonction du input When défini (jour/nuit ou moyenne journalière)
  
  diagramme <- reactive({
    
    if (input$when == when[1]){
      
      temp <- reactive(Mean_Temp2 %>%
                         filter(year == input$annee, Nom == input$station))
      
      diagramme <- ggplot(temp(),aes(x=mean, color = When)) +
        geom_histogram(binwidth=1, fill = "white", alpha=0.5) +
        geom_vline(data = temp()%>%
                     group_by(When)%>%
                     summarize(mean=mean(mean)),
                   aes(xintercept=mean, color=When),
                   linetype="dashed", size=1) +
        scale_y_continuous("Fréquence (nombre de jour)") +
        scale_x_continuous("Température (en °C)")
    }
    
    else {
      
      diagramme <- Daily_Mean_Temp %>%
        filter(year == input$annee, Nom == input$station) %>%
        ggplot(aes(x=mean)) +
        geom_histogram(binwidth=1, fill = "#7EADCA",color= "#437A9B", alpha=0.5) +
        geom_vline(aes(xintercept=mean(mean)),
                   linetype="dashed",color= "#EA6464", size=1) +
        scale_y_continuous("Fréquence (nombre de jour)") +
        scale_x_continuous("Température (en °C)")
    }
    return (diagramme)
  })
  
  ## Affichage du graphiques des températures
  
  output$Mean_Temp <- renderPlot({ graph()
  })
  
  ## Affichage de l'histogramme des températures
  
  output$freq <- renderPlot({ diagramme()
  })
  
  ################# GRAPH PAGE DIAGRAMME OMBROTHERMIQUE #################
  
  new_tab<- reactive(Diag_ombro %>%
                       filter(year(date) == input$annee2, Nom == input$station2))
  
  ylim_preci <- reactive(c(0, ceiling(max(new_tab()$mean_preci))+2))
                         
  ylim_temp <- c(-10, 50)
  
  u <- reactive(diff(ylim_preci())/diff(ylim_temp))
  v <- reactive(u()*(ylim_preci()[1] - ylim_temp[1]))
  
  output$Diagramme<-renderPlot({new_tab() %>%
      ggplot(aes(x = month(date), y = mean_preci))+
      geom_col(fill = "#82B8E0", alpha=0.75, color = '#045794')+
      
      geom_line(aes(y = v()+u()*max_temp, color = "Maximales"),
                linetype = "dashed", size = 1)+
      
      geom_line(aes(y = v()+u()*mean_temp, color = "Moyennes"),
                size = 1)+
      
      geom_line(aes(y = v()+u()*min_temp, color = "Minimales"),
                linetype = "dashed", size = 1)+
      
      scale_color_manual(values = c(
        'Maximales' = '#C15353',
        'Moyennes' = '#FAB291',
        'Minimales' = '#5397C1')) +
      
      labs(color = 'Températures')+
      
      scale_y_continuous("Précipitation (en mm)",
                         sec.axis = sec_axis(~ (. - v())/u(),
                                             name = "Température (en °C)"))+
      
      scale_x_continuous("Mois", breaks = 1:12)
    })

  ####################### GRAPH PAGE ETAT DES SOLS ########################
  
  ########### CARTE A GAUCHE
  
  sol <- reactive(Etat_sol %>%
                    filter(year == input$annee3, mean < 10))
  
  pal <- reactive(colorNumeric(
    c('#F6F6F7', '#D1EDFD', '#6CC4F9', '#3CB3FA',
      '#A4F6FA', '#60F5FB', '#F2F0D2', '#F3EC8C', '#F3D88C', '#FAB46A'),
    domain = c(0:9)))
  
  output$map2 <- renderLeaflet({
    leaflet(sol()) %>%
      addTiles() %>%
      addCircleMarkers(lng = sol()$Longitude,
                       lat = sol()$Latitude,
                       radius = 10,
                       popup = ~as.character(
                         paste0("Etat du sol: ", sep = " ", sol()$mean)
                         ),
                       label = sol()$Nom,
                       color = ~pal()(sol()$mean), fillOpacity = 1.5) %>%
      addLegend("bottomright",
                pal = pal(),
                values = c(0:9),
                title = "Etat des sols",
                opacity = 1,
                labFormat = labelFormat(
                  suffix = c(": sec", ": humide", ": mouillé", ": innondé",
                             ": gelé", ": verglas", ": peu de poussiere/sable",
                             ": couche fine de poussière/de sable",
                             ": couche épaisse de poussiàre/sable",
                             ": très sec avec fissures")))%>%
      setView(lng = 2.80, lat = 46.80, zoom = 4.5)
    })
  
  
  ########### GRAPHIQUES A DROITE
  ##### TAB Année choisie 
  
  output$temp_sol<-renderPlot({Mean_Temp_Sol %>%
      filter(year == input$annee3, Nom == input$station3) %>%
      ggplot(aes(x=date, y = mean)) +
      geom_line(color = '#EC8818') +
      geom_smooth(color = '#EC4818') +
      scale_y_continuous("Température du sol (en °C)") +
      ggtitle(paste("Evolution de la température du sol en", input$annee3,
      "dans la station", input$station3, sep = " "))
    
    })
  
  
  output$humidite<-renderPlot({Mean_Hum %>%
      filter(year == input$annee3, Nom == input$station3) %>%
      ggplot(aes(x=date, y = mean)) +
      geom_col(width = 0.001, color = '#6CBCC8') +
      geom_smooth(linetype = "dashed") +
      scale_y_continuous("Taux d'humidité (%)") +
      ggtitle(paste("Evolution de l'humidite en", input$annee3,
              "dans la station", input$station3, sep = " "))
    })
  
  
  output$neige<-renderPlot({Mean_Hneige %>%
      filter(year == input$annee3, Nom == input$station3) %>%
      ggplot(aes(x=date, y = mean)) +
      geom_point(color = '#48B5C6')+
      scale_y_continuous("Hauteur de la couche de neige (en m)")+
      ggtitle(paste("Evolution de la hauteur de la couche de neige en", input$annee3,
              "dans la station", input$station3, sep = " "))
  })
  
  ##### TAB 1991-2021
  
  output$temp_sol2<-renderPlot({ Mean_Temp_Sol_Annee %>%
      filter(Nom == input$station3) %>%
      ggplot(aes(x=year, y = mean)) + 
      geom_line(color = '#EC8818') +
      geom_smooth(color = '#EC4818') +
      scale_y_continuous("Température du sol (en °C)") +
      ggtitle(paste("Evolution de la température du sol de 1996 à 2021 dans la station",
              input$station3, sep = " "))
    
  })
  
  
  output$humidite2<-renderPlot({Mean_Hum_Annee %>%
      filter(Nom == input$station3) %>%
      ggplot(aes(x=year, y = mean)) +
      geom_col(color = '#6CBCC8', fill='#6CBCC8', alpha = 0.75)  +
      geom_smooth(linetype = "dashed") +
      scale_y_continuous("Taux d'humidité (%)") +
      ggtitle(paste("Evolution de l'humidité de 1996 à 2021 dans la station",
              input$station3, sep = " "))
  })

  
  output$neige2<-renderPlot({ Mean_Hneige_Annee %>%
      filter(Nom == input$station3) %>%
      ggplot(aes(x=year, y = mean)) +
      geom_point(color = '#48B5C6')+
      scale_y_continuous("Hauteur de la couche de neige (en m)")+
      ggtitle(paste("Evolution de la hauteur de la couche de neige de 1996 à 2021 dans la station",
              input$station3, sep = " "))
  })
  
  
  ####################### GRAPH PAGE RECAPITULATIF ########################
  
  Abs <- reactive(
    switch(input$x,
           
           "Température (en °C)" = {
             Abs <- Daily_Mean_Temp%>%
               group_by(year)%>%
               summarise(mean = mean(mean))
             },
           
           "Température du sol (en °C)" = {
             Abs <- Mean_Temp_Sol_Annee%>%
               group_by(year)%>%
               summarise(mean = mean(mean)) 
           },
           
           "Etat du sol" = {
             Abs <- Etat_sol%>%
               group_by(year)%>%
               summarise(mean = mean(mean)) 
           },
           
           "Précipitations (en mm)" = {
             Abs <- Mean_Precipitation24%>%
               group_by(year)%>%
               summarise(mean = mean(mean)) 
           },
           
           "Humidité (en %)" = {
             Abs <- Mean_Hum_Annee%>%
               group_by(year)%>%
               summarise(mean = mean(mean)) 
           },
           
           "Hauteur de neige (en m)" = {
             Abs <- Mean_Hneige_Annee%>%
               group_by(year)%>%
               summarise(mean = mean(mean)) 
           }
           
           )
  )
    
  
  Ord_h <- reactive(
    switch(input$y1,
           
           "Température (en °C)" = {
             Ord_h <- Daily_Mean_Temp%>%
               group_by(year)%>%
               summarise(mean = mean(mean)) 
           },
           
           "Température du sol (en °C)" = {
             Ord_h <- Mean_Temp_Sol_Annee%>%
               group_by(year)%>%
               summarise(mean = mean(mean)) 
           },
           
           "Etat du sol" = {
             Ord_h <- Etat_sol%>%
               group_by(year)%>%
               summarise(mean = mean(mean)) 
           },
           
           "Précipitations (en mm)"={
             Ord_h <- Mean_Precipitation24%>%
               group_by(year)%>%
               summarise(mean = mean(mean)) 
           },
           
           "Humidité (en %)"={
             Ord_h <- Mean_Hum_Annee%>%
               group_by(year)%>%
               summarise(mean = mean(mean)) 
           },
           
           "Hauteur de neige (en m)"={
             Ord_h <- Mean_Hneige_Annee%>%
               group_by(year)%>%
               summarise(mean = mean(mean)) 
           }
           
    )
  )
  
  Ord_b <- reactive(
    switch(input$y2,
           
           "Température (en °C)" = {
             Ord_b <- Daily_Mean_Temp%>%
               group_by(year)%>%
               summarise(mean = mean(mean)) 
           },
           
           "Température du sol (en °C)" = {
             Ord_b <- Mean_Temp_Sol_Annee%>%
               group_by(year)%>%
               summarise(mean = mean(mean)) 
           },
           
           "Etat du sol" = {
             Ord_b <- Etat_sol%>%
               group_by(year)%>%
               summarise(mean = mean(mean)) 
           },
           
           "Précipitations (en mm)"={
             Ord_b <- Mean_Precipitation24%>%
               group_by(year)%>%
               summarise(mean = mean(mean)) 
           },
           
           "Humidité (en %)"={
             Ord_b <- Mean_Hum_Annee%>%
               group_by(year)%>%
               summarise(mean = mean(mean)) 
           },
           
           "Hauteur de neige (en m)"={
             Ord_b <- Mean_Hneige_Annee%>%
               group_by(year)%>%
               summarise(mean = mean(mean)) 
           }
           
    )
  )
  
  
  output$graph_h<-renderPlot({ left_join(Abs(), Ord_h(), by = "year") %>%
      ggplot(aes(x = mean.x, y = mean.y, color = year))+
      geom_point(size = 4)+
      scale_x_continuous(name = input$x )+
      scale_y_continuous(name = input$y1 )+
      scale_color_gradient(low="blue", high="red")+
      ggtitle(paste("Evolution de 1996 à 2021 :", input$x, "en fonction de",input$y1, sep = " " ))
  })
  
  output$graph_b<-renderPlot({ left_join(Abs(),Ord_b(),by = "year") %>%
      ggplot(aes(x = mean.x, y = mean.y, color = year))+
      geom_point(size = 4)+
      scale_x_continuous(name = input$x)+
      scale_y_continuous(name = input$y2)+
      scale_color_gradient(low="blue", high="red")+
      ggtitle(paste("Evolution de 1996 à 2021 :", input$x, "en fonction de",input$y2, sep = " " ))
  })
  
  
  
  }



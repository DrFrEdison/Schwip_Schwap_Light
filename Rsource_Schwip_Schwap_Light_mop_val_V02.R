library(devtools); suppressMessages(install_github("DrFrEdison/r4dt", dependencies = T) ); library(r4dt); dt <- list()

# general parameters ####
dt$para$customer = "PepsiCo"
dt$para$beverage = "Schwip_Schwap_Light"

setwd(paste0(dt$wd <- paste0(wd$fe[[ grep(dt$para$customer, names(wd$fe)) ]]$Mastermodelle, dt$para$beverage)))
setwd( print( this.path::this.dir() ) )
setwd("..")
dt$wd.git <- print( getwd() )

# location, line, main ####
dt$para$location = print(dt_customer[dt_customer$customer == dt$para$customer, "location"])
dt$para$line = print(dt_customer[dt_customer$customer == dt$para$customer, "line"])
dt$para$main = paste0(dt$para$beverage, " in ", dt$para$location, ", line ", dt$para$line)

# Modellerstellung
dir( paste0( dt$wd, "/", "/Modellerstellung"))
dt$para$model.raw.date <- c("220512")
dt$para$model.raw.pl <- c("00300")
dt$para$wl1 <- c(190)
dt$para$wl2 <- c(598)
dt$para$wl[[1]] <- seq(dt$para$wl1, dt$para$wl2, 1)

# Parameter ####
dir( paste0( dt$wd, "/", "/Modellerstellung", "/", dt$para$model.raw.date, "_", dt$para$model.raw.pl, "/spc"))
dt$para$substance <- c("TA",	"Koffein",	"Aspartam",	"Acesulfam")

# Unit ####
dt$para$unit <- c( bquote("mg L"-1),  bquote("mg L"-1),  bquote("mg L"-1),  bquote("mg L"-1) )
dt$para$ylab <- c(bquote("TA in mg / 100mL"^-1), bquote("Coffein in mg / L"^-1), bquote("Aspartam in mg / L"^-1), bquote("Acesulfam in mg / L"^-1))

# Rezept und SOLL-Werte ####
setwd( paste0( dt$wd, "/", "/Rezept") )
dt$rez <- read.xlsx(grep(".xlsx", dir( paste0( dt$wd, "/", "/Rezept")), value = T)[ length(grep(".xlsx", dir( paste0( dt$wd, "/", "/Rezept")), value = F))])
dt$rez[ grep("Messparameter", dt$rez[ , 1]): nrow(dt$rez) , ]
dt$para$SOLL <- c(25.3, 71, 360.4, 85.2)
dt$para$eingriff <- data.frame( TA = c(dt$para$SOLL[ 1 ] - .2, dt$para$SOLL[ 1 ] + .2)
                                , Koffein = c(dt$para$SOLL[ 2 ] - 8, dt$para$SOLL[ 2 ] + 8)
                                , Aspartam = c(270.3, 371.21 )
                                , Acesulfam = c(82.64, 87.76))

dt$para$sperr <- data.frame( TA = c(dt$para$SOLL[ 1 ] - .4, dt$para$SOLL[ 1 ] + .4)
                                , Koffein = c(dt$para$SOLL[ 2 ] - 10, dt$para$SOLL[ 2 ] + 10)
                                , Aspartam = c(270.3, 371.21 )
                                , Acesulfam = c(82.64, 87.76))

# Modelloptimierung
dir( paste0( dt$wd, "/", "/Modelloptimierung") )
dt$para$mop.date <- "220522"

# Model Matrix Ausmischung ####
setwd(dt$wd)
setwd("./Modellerstellung")
setwd(paste0("./", dt$para$model.raw.date[1], "_", dt$para$model.raw.pl[1]))
setwd("./csv")

dt$model.raw <- read.csv2( print(grep( "match.csv", dir(), value = T)), dec = ",", sep = ";")
head10(dt$model.raw)

for(i in 2:length(dt$para$substance)){
  dt$model.raw[ , colnames(dt$model.raw) %in% dt$para$substance[i]] <- dt$model.raw[ , colnames(dt$model.raw) %in% dt$para$substance[i]] * dt$para$SOLL[i] / 100
}

dt$SL <- dt$model.raw[which(dt$model.raw$Probe_Anteil == "SL") , ]
dt$model.raw <- dt$model.raw[which(dt$model.raw$Probe_Anteil != "SL") , ]

# Modellvalidierung ####
dir( paste0( dt$wd, "/", "/Modellvalidierung") )
dt$para$val.date <- "220524"

# Linearity
setwd(dt$wd)
setwd("./Modellvalidierung")
setwd("./Linearitaet")
dir()
dt$lin$raw <- read.csv2( "220602_Schwip_Schwap_Light_Linearitaet_TA_Coffein_Aspartam_Acesulfam.csv" , sep = "\t")
dt$lin$raw <- dt$lin$raw[ order(dt$lin$raw$Dilution) , ]
dt$lin$trs <- transfer_csv(dt$lin$raw)

dt$para$Charge.val <- c("")
dt$para$Charge.val.Sirup <- ""

# rename R files (run only once)
# dt$para$Rfiles <- list.files(getwd(), pattern = ".R$", recursive = T)
# file.rename(dt$para$Rfiles, gsub("beverage", dt$para$beverage, dt$para$Rfiles))


# beverage parameter ####
setwd(this.path::this.dir())
dir( pattern = "Rsource" )
source.file <- "Rsource_Schwip_Schwap_Light_mop_val_V02.R"
source( paste0(getwd(), "/", source.file) )

# spectra ####
setwd(dt$wd)
setwd("./Modellvalidierung")
setwd("./Produktionsdaten")

dir(pattern = ".csv$")
dt$para$files <- dir(pattern = ".csv$")
dt$para$txt <- txt.file(dt$para$files)

dt$raw <- lapply(dt$para$files, \(x) fread(x, sep = ";", dec = ","))
names(dt$raw) <- dt$para$txt$type

dt$para$trs <- lapply(dt$raw, transfer_csv.num.col)

dt$raw  <- mapply(function(x , y) y[ , c(1 : (min(x$numcol) - 1), x$numcol[ x$wl %in% dt$para$wl[[1]] ]), with = F]
                  , x = dt$para$trs
                  , y = dt$raw)

dt$para$trs <- lapply(dt$raw, transfer_csv.num.col)

# validate drk ####
matplot(dt$para$trs$drk$wl
        , t(dt$raw$drk[ , dt$para$trs$drk$numcol, with = F])
        , lty = 1, type = "l")

dt$val$drk <- apply(dt$raw$drk[ , dt$para$trs$drk$numcol, with = F], 1, spectra.validation.drk)
unique(dt$val$drk)
dt$raw$spc <- dt$raw$spc[ spectra.validation.range(valid.vector = dt$val$drk
                                                   , drkref.datetime = dt$raw$drk$datetime
                                                   , spc.datetime = dt$raw$spc$datetime
                                                   , pattern = "invalid") , ]
dt$val$drk <- apply(dt$raw$drk[ , dt$para$trs$drk$numcol, with = F], 1, spectra.validation.drk)
dt$raw$spc <- dt$raw$spc[ spectra.validation.range(valid.vector = dt$val$drk
                                                   , drkref.datetime = dt$raw$drk$datetime
                                                   , spc.datetime = dt$raw$spc$datetime
                                                   , pattern = "empty") , ]

# validate ref ####
matplot(dt$para$trs$ref$wl
        , t(dt$raw$ref[ , dt$para$trs$ref$numcol, with = F])
        , lty = 1, type = "l")

# validate spc ####
boxplot(dt$raw$spc$X220)
dt$raw$spc <- dt$raw$spc[ dt$raw$spc$X220 > .6 , ]
boxplot(dt$raw$spc$X320)
dt$raw$spc <- dt$raw$spc[ dt$raw$spc$X320 < .24 , ]
boxplot(dt$raw$spc$X420)

# export clean spc csv ####
fwrite(dt$raw$spc
       , gsub("_spc.csv", "_spc_validated.csv", dt$para$files[ grep("_spc.csv", dt$para$files) ])
       , sep = ";", dec = ",")



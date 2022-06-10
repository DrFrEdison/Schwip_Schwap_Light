# beverage parameter ####
setwd(this.path::this.dir())
dir( pattern = "Rsource" )
source.file <- print(dir( pattern = "Rsource" )[ length( dir( pattern = "Rsource" ))])
source( paste0(getwd(), "/", source.file) )

# Compare production spectra with model spectra
setwd(dt$wd)
setwd("./Modellerstellung")
setwd(paste0("./", dt$para$model.date[1], "_", dt$para$model.pl[1]))
setwd("./csv")

dir()
ssl <- list()
ssl$raw$prod <- fread("210101_220505_Nieder_Roden_L3_PET_CSD_Schwip Schwap light_10_spc.csv", sep = ";", dec = ",")
ssl$raw$prod <- ssl$raw$prod[ssl$raw$prod$X500 < 1 , ]
ssl$raw$prod <- ssl$raw$prod[ssl$raw$prod$X500 > -.1 , ]

boxplot(ssl$raw$prod$X500)

ssl$raw$prod <- ssl$raw$prod[ round(seq(1, nrow(ssl$raw$prod), len = 200),0) , ]

ssl$raw$prodneu <- fread("220501_220512_Nieder_Roden_L3_PET_CSD_Schwip Schwap light_10_spc.csv", sep = ";", dec = ",")
ssl$raw$prodneu <- ssl$raw$prodneu[ round(seq(1, nrow(ssl$raw$prodneu), len = 200),0) , ]

ssl$raw$Ausmischung <- read.csv2("220513_Schwip_Schwap_Light_spc.csv")
# ssl$raw$Ausmischung <- ssl$raw$Ausmischung[ ssl$raw$Ausmischung$Probe_Anteil != "SL" , ]

ssl$raw$altes.model <- read.csv2("130618_Ausmischung.txt")

ssl$trs <- lapply(ssl$raw, function(x) .transfer_csv(x))

png(paste0(.date(),"_", dt$para$beverage, "_Spektrenvergleich.png"),xxx<-4800,xxx/16*9,"px",12,"white",res=500,"sans",T,"cairo")

par(mfrow = c(2,1), mar = c(4,5,1,1))
matplot(ssl$trs$Ausmischung$wl
        , t(ssl$trs$Ausmischung$spc)
        , type = "l", lty = 1, col = "red", xlab = .lambda, ylab = "AU"
        , xlim = c(190, 450), ylim = c(0, 3))
matplot(ssl$trs$prod$wl
        , t(ssl$trs$prod$spc)
        , type = "l", lty = 1, col = "darkgreen", add = T)
matplot(ssl$trs$prodneu$wl
        , t(ssl$trs$prodneu$spc)
        , type = "l", lty = 1, col = "pink", add = T)
matplot(ssl$trs$altes.model$wl
        , t(ssl$trs$altes.model$spc)
        , type = "l", lty = 1, col = "blue", add = T)
matplot(ssl$trs$Ausmischung$wl
        , t(ssl$trs$Ausmischung$spc)
        , type = "l", lty = 1, col = "red"
        , add = T)


legend("topright", c("Ausmischung", "Produktion letztes Jahr", "Produktion 220511", "Altes Model")
       , lty = 1, col = c("red", "darkgreen", "pink", "blue"), xpd = F)

matplot(ssl$trs$Ausmischung$wl
        , t(ssl$trs$Ausmischung$spc1st)
        , type = "l", lty = 1, col = "red", xlab = .lambda, ylab = .ylab_1st, xlim = c(200, 450), ylim = c(-.15, 0.02))
matplot(ssl$trs$prod$wl
        , t(ssl$trs$prod$spc1st)
        , type = "l", lty = 1, col = "darkgreen", add = T)
matplot(ssl$trs$prodneu$wl
        , t(ssl$trs$prodneu$spc1st)
        , type = "l", lty = 1, col = "pink", add = T)
matplot(ssl$trs$altes.model$wl
        , t(ssl$trs$altes.model$spc1st)
        , type = "l", lty = 1, col = "blue", add = T)
matplot(ssl$trs$Ausmischung$wl
        , t(ssl$trs$Ausmischung$spc1st)
        , type = "l", lty = 1, col = "red"
        , add = T)

legend("topright", c("Ausmischung", "Produktion letztes Jahr", "Produktion 220511", "Altes Model")
       , lty = 1, col = c("red", "darkgreen", "pink", "blue"), xpd = F)
dev.off()

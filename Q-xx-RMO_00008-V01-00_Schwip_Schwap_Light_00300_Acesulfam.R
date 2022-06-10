# beverage parameter ####
setwd(this.path::this.dir())
dir( pattern = "Rsource" )
source.file <- "Rsource_Schwip_Schwap_Light_V02.R"
source( paste0(getwd(), "/", source.file) )

# substance ####
dt$para$substance
dt$para$i <- 1

# save Modellmatrix ####
setwd(dt$wd)
setwd("./Modelloptimierung")
setwd(paste0("./", dt$para$mop.date[ dt$para$i ], "_", dt$para$model.pl[1], "_", dt$para$substance[ dt$para$i ]))
setwd("./Modellmatrix")

fwrite(dt$model, paste0(.datetime(), "_", dt$para$beverage, "_", dt$para$substance[ dt$para$i ], "_matrix.csv"), row.names = F, dec = ",", sep = ";")
dt$model <- .transfer_csv(csv.file = dt$model)
dt$SL <- .transfer_csv(csv.file = dt$SL)

# Plot ####
matplot(dt$para$wl[[1]]
        , t( dt$SL$spc[ grep(dt$para$substance[ dt$para$i ], dt$SL$data$Probe) , ])
        , type = "l", lty = 1, xlab = .lambda, ylab = "AU", main = "SL vs Modellspektren"
        , col = "blue")
matplot(dt$para$wl[[1]]
        , t( dt$model$spc )
        , type = "l", lty = 1, xlab = .lambda, ylab = "AU", main = "SL vs Modellspektren"
        , col = "red", add = T)
legend("topright", c(paste0("SL ", dt$para$substance[ dt$para$i]), "Ausmischung"), lty = 1, col = c("blue", "red"))

# PLS para####
dt$para.pls$wlr <- .wlr_function(200:290, 200:290, 5)
nrow(dt$para.pls$wlr)
dt$para.pls$wlm <- .wlr_function_multi(200:290, 200:290, 10)
nrow(dt$para.pls$wlm)
dt$para.pls$wl <- rbind.fill(dt$para.pls$wlm, dt$para.pls$wlr)
nrow(dt$para.pls$wl)

dt$para.pls$ncomp <- 3
dt$para.pls$wl <- dt$para.pls$wl[1,]
dt$para.pls$wl[1,] <- c(220,255,NA,NA)

# RAM ####
gc()
memory.limit(99999)

# PLS and LM ####
dt$pls$pls <- pls_function(csv_transfered = dt$model
                           , substance = dt$para$substance[ dt$para$i ]
                           , wlr = dt$para.pls$wl 
                           , ncomp = dt$para.pls$ncomp)

dt$pls$lm <- pls_lm_function(dt$pls$pls
                             , csv_transfered = dt$model
                             , substance = dt$para$substance[ dt$para$i ]
                             , wlr = dt$para.pls$wl 
                             , ncomp = dt$para.pls$ncomp)
# Prediction ####
dt$pls$pred <- produktion_prediction(csv_transfered = dt$trs$L3_PET_CSD, pls_function_obj = dt$pls$pls, ncomp = dt$para.pls$ncomp)

# Best model ####
dt$pls$merge <- .merge_pls(pls_pred = dt$pls$pred, dt$pls$lm ,R2=.95
                           , mean = c(dt$para$SOLL[ dt$para$i ] * 85 / 100, dt$para$SOLL[ dt$para$i ] * 115 / 100))
dt$pls$merge[ order(dt$pls$merge$sd) , ]

# Prediciton ####
dt$mop$ncomp <- 3
dt$mop$wl1 <- 220
dt$mop$wl2 <- 255
dt$mop$wl3 <- NA
dt$mop$wl4 <- NA
dt$mop$spc <- "2nd"
dt$mop$model <- pls_function(dt$model, dt$para$substance[ dt$para$i ], data.frame(dt$mop$wl1, dt$mop$wl2, dt$mop$wl3, dt$mop$wl4), dt$mop$ncomp, spc = dt$mop$spc)
dt$mop$model  <- dt$mop$model [[grep(dt$mop$spc, names(dt$mop$model))[1]]][[1]]

dt$mop$pred <- pred_of_new_model(dt$model
                                 , dt$para$substance[ dt$para$i ]
                                 , dt$mop$wl1 
                                 , dt$mop$wl2
                                 , dt$mop$wl3, dt$mop$wl4
                                 , dt$mop$ncomp
                                 , dt$mop$spc
                                 , dt$trs$L3_PET_CSD)
dt$mop$pred <- as.numeric(ma(dt$mop$pred, 5))
dt$mop$bias <- round(.bias(median(dt$mop$pred, na.rm = T), 0, dt$para$SOLL[ dt$para$i ] ),3)
dt$mop$bias
dt$mop$pred <- dt$mop$pred - dt$mop$bias

.keep.out.unsb(model = dt$model, dt$mop$wl1, dt$mop$wl2, dt$mop$wl3, dt$mop$wl4)
setwd(dt$wd)
setwd("./Modelloptimierung")
setwd(paste0("./", dt$para$mop.date[ dt$para$i ], "_", dt$para$model.pl[1], "_", dt$para$substance[ dt$para$i ]))
setwd("./Analyse")

png(paste0(.datetime(), "_Prediction_"
           , dt$para$beverage, "_", dt$para$substance[ dt$para$i ]
           , "_PC"
           , dt$mop$ncomp, "_", dt$mop$wl1, "_", dt$mop$wl2, "_", dt$mop$wl3, "_", dt$mop$wl4, "_"
           , dt$mop$spc, ".png")
    , xxx<-4800,xxx/16*9,"px",12,"white",res=500,"sans",T,"cairo")
plot(dt$mop$pred, axes = F, xlab = "", ylab = dt$para$ylab[[ dt$para$i ]]
     , main = dt$para$main
     , sub = paste0("BIAS = ", dt$mop$bias)
     , ylim = c(dt$para$SOLL[ dt$para$i ] * 85 / 100, dt$para$SOLL[ dt$para$i ] * 115 / 100))
.xaxisdate(dt$trs$L3_PET_CSD$data$datetime)
dev.off()

pls_analyse_plot(pls_function_obj = dt$mop$model
                 , model_matrix = dt$model
                 , colp = "Probe"
                 , wl1 = dt$mop$wl1
                 , wl2 = dt$mop$wl2
                 , wl3 = dt$mop$wl3
                 , wl4 = dt$mop$wl4
                 , ncomp = dt$mop$ncomp
                 , derivative = dt$mop$spc
                 , pc_scores = c(1,2)
                 , var_xy = "y"
                 , val = F
                 , pngname = paste0(.datetime(), "_"
                                    , dt$para$beverage, "_", dt$para$substance[ dt$para$i ]
                                    , "_PC"
                                    , dt$mop$ncomp, "_", dt$mop$wl1, "_", dt$mop$wl2, "_", dt$mop$wl3, "_", dt$mop$wl4, "_"
                                    , dt$mop$spc))


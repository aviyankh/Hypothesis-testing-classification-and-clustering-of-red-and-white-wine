library("rrcov")
wine_red <- read.csv("winequality-red.csv")
wine_white <- read.csv("winequality-white.csv")

#Hotelling's T2 Test

htol <- T2.test(as.matrix(wine_red[,-12]),as.matrix(wine_white[,-12]))
htol$statistic
htol$parameter
htol$p.value


library("MASS")

wine_red1 <- scale(wine_red[,1:11])
wine_white1 <- scale(wine_white[,1:11])

winedata <- as.data.frame(rbind(cbind(wine_red1,rep(1, t(dim(wine_red)[1]))), cbind(wine_white1,rep(2, t(dim(wine_white)[1])))))
colnames(winedata)[12] <- c("Type")

#Linear Discriminant analysis

wine_lda <- lda(Type~. , data=winedata)
lda_s <- wine_lda$scaling
lda_s


#Quadratic discriminant analysis

wineqda <- qda(Type~. , data=winedata)
qda_scl <- wineqda$scaling

qda_p <- predict(wineqda,winedata[, 1:11])$class
qd_tbl <- table(qda_p, winedata$Type)
qd_tbl
1-sum(diag(qd_tbl))/sum(qd_tbl)

#Kmeans Clustering

kclut <- kmeans(winedata[,1:11], 2)$cluster

ktbl <- table(kclut,winedata$Type)
ktbl
sum(diag(ktbl))/sum(ktbl)

wine_red <- data.frame(wine_red)

wine_grp <- wine_red
wine_grp[wine_grp$quality==3,] <- 4
wine_grp[wine_grp$quality==5,] <- 6
wine_grp[wine_grp$quality==7,] <- 8

#MANOVA

mnov1 <- Wilks.test(wine_red[,1:11], grouping = wine_red$quality)
mnov1$statistic
mnov1$parameter
mnov1$p.value

mnov2 <-  Wilks.test(wine_grp[,1:11], grouping = wine_grp$quality)
mnov2$statistic
mnov2$parameter
mnov2$p.value

#K nearest neighbours
library("class")
scaled_red <- data.frame(scale(wine_red[,1:11]))

set.seed(12345)
red_samp <- sample(1:nrow(scaled_red), 0.8*nrow(scaled_red))

wine_train <- wine_red[red_samp,]
wine_test <- wine_red[-red_samp,]

red_knn <- knn(wine_train, wine_test, cl= wine_red[red_samp,12], k=5)
red_tbl <- table(red_knn, wine_red[-red_samp,12])
red_tbl
1-sum(diag(red_tbl))/sum(red_tbl)

#PCA
red_cor <- cor(wine_red[,1:11])
red_eg <- eigen(red_cor)

#plot(1:11, cumsum(red_eg$val)/sum(red_eg$val), type="b", xlab="# Components", main="Cumulative Variance", ylab= "")


red_pc <- t(t(red_eg$vectors[,1:2])%*% t(wine_red[,1:11]))

prcomp_wine <- prcomp((wine_red[,1:11]), center = TRUE, scale. = TRUE)

#plot(prcomp_wine$x[,1],prcomp_wine$x[,2], col = wine_red$quality, xlab = "PC1", ylab = "PC2")

#KNN
pccomp <- prcomp_wine$x[,1:2]

set.seed(123)

pc_samp <- sample(1:nrow(pccomp), 0.7*nrow(pccomp))

wpc_tr <- pccomp[pc_samp,]
wpc_tst <- pccomp[-pc_samp,]



pc_knn <- knn(wpc_tr, wpc_tst, cl= wine_red[pc_samp,12],prob=TRUE, k=5)
pc_ktable <- table(pc_knn, wine_red[-pc_samp,12])
pc_ktable

1-sum(diag(pc_ktable))/sum(pc_ktable)

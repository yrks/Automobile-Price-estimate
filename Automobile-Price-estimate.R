### LIBRARY ###
library(fastDummies)
library(car)
library(rpart)
install.packages("rpart.plot")
library(rpart.plot)
install.packages("partykit")
library(partykit)
library(ranger)
install.packages("ranger")
library(ggbiplot)
library(corrplot)
install.packages("corrplot")
install.packages("kernlab")
library(kernlab)
install.packages("nnet")
library(nnet)
install.packages("neuralnet")
library(neuralnet)

### 前処理 ###
## データ読み込み
Automobile.df.1 <- read.csv('./Automobile_data.csv',head=T)

## データ確認
head(Automobile.df.1)
dim(Automobile.df.1)
summary(Automobile.df.1)
str(Automobile.df.1)

## 文字型を数値型に変換
Automobile.df.2 <- Automobile.df.1

unique(Automobile.df.2$num.of.doors)
Automobile.df.2$num.of.doors <- gsub("two",2,Automobile.df.2$num.of.doors)
Automobile.df.2$num.of.doors <- gsub("four",4,Automobile.df.2$num.of.doors)
Automobile.df.2$num.of.doors <- as.integer(Automobile.df.2$num.of.doors) # int型に修正

unique(Automobile.df.2$num.of.cylinders)
Automobile.df.2$num.of.cylinders <- gsub("two",2,Automobile.df.2$num.of.cylinders)
Automobile.df.2$num.of.cylinders <- gsub("three",3,Automobile.df.2$num.of.cylinders)
Automobile.df.2$num.of.cylinders <- gsub("four",4,Automobile.df.2$num.of.cylinders)
Automobile.df.2$num.of.cylinders <- gsub("five",5,Automobile.df.2$num.of.cylinders)
Automobile.df.2$num.of.cylinders <- gsub("six",6,Automobile.df.2$num.of.cylinders)
Automobile.df.2$num.of.cylinders <- gsub("eight",8,Automobile.df.2$num.of.cylinders)
Automobile.df.2$num.of.cylinders <- gsub("twelve",12,Automobile.df.2$num.of.cylinders)
Automobile.df.2$num.of.cylinders <- as.integer(Automobile.df.2$num.of.cylinders) # int型に修正

## 欠損値の補完(中央値で補完)
# 欠損値確認
sapply(Automobile.df.2,function(x) sum(is.na(x)))

# NA以外のデータフレームを作成
normalized.losses_notna <- subset(Automobile.df.2,!is.na(Automobile.df.2$normalized.losses))
bore_notna <- subset(Automobile.df.2,!is.na(Automobile.df.2$bore))
num.of.doors_notna <- subset(Automobile.df.2,!is.na(Automobile.df.2$num.of.doors))
stroke_notna <- subset(Automobile.df.2,!is.na(Automobile.df.2$stroke))
horsepower_notna <- subset(Automobile.df.2,!is.na(Automobile.df.2$horsepower))
peak.rpm_notna <- subset(Automobile.df.2,!is.na(Automobile.df.2$peak.rpm))
price_notna <- subset(Automobile.df.2,!is.na(Automobile.df.2$price))

# 中央値を算出
median(normalized.losses_notna$normalized.losses) #115
median(num.of.doors_notna$num.of.doors) #4
median(bore_notna$bore) #3.31
median(stroke_notna$stroke) #3.29
median(horsepower_notna$horsepower) #95
median(peak.rpm_notna$peak.rpm) #5200
median(price_notna$price) #10295

# NAを中央値で補完
Automobile.df.2$normalized.losses[is.na(Automobile.df.2$normalized.losses)] <- '115'
Automobile.df.2$num.of.doors[is.na(Automobile.df.2$num.of.doors)] <- '4'
Automobile.df.2$bore[is.na(Automobile.df.2$bore)] <- '3.31'
Automobile.df.2$stroke[is.na(Automobile.df.2$stroke)] <- '3.29'
Automobile.df.2$horsepower[is.na(Automobile.df.2$horsepower)] <- '95'
Automobile.df.2$peak.rpm[is.na(Automobile.df.2$peak.rpm)] <- '5200'
Automobile.df.2$price[is.na(Automobile.df.2$price)] <- '10295'

## ダミー変数化
#ダミー変数に変換('make','fuel.type','aspiration','body.style','drive.wheels','engine.location','engine.type','fuel.system')
Automobile.df.2 <- dummy_cols(.data = Automobile.df.2,select_columns = c('make','fuel.type','aspiration','body.style','drive.wheels','engine.location','engine.type','fuel.system'))

# 元カラム削除
Automobile.df.2 <- Automobile.df.2[,c(-3,-4,-5,-7,-8,-9,-15,-18)]

# 型変換
Automobile.df.2$normalized.losses <- as.integer(Automobile.df.2$normalized.losses)
Automobile.df.2$num.of.doors <- as.integer(Automobile.df.2$num.of.doors)
Automobile.df.2$bore <- as.integer(Automobile.df.2$bore)
Automobile.df.2$stroke <- as.integer(Automobile.df.2$stroke)
Automobile.df.2$horsepower <- as.integer(Automobile.df.2$horsepower)
Automobile.df.2$peak.rpm <- as.integer(Automobile.df.2$peak.rpm)
Automobile.df.2$price <- as.integer(Automobile.df.2$price)


### 分析/予測 ###

## 主成分分析
# 主成分分析（相関行列）
pca = prcomp(x=Automobile.df.4,scale=T)　# データの標準化　T指定で相関行列、F指定で分散共分散行列
pca
biplot(pca)
# 主成分得点のプロット
par(las=1)
plot(x=NULL,type="n",xlab="PC1",ylab="PC2",xlim=c(-5,5),ylim=c(-5,5),xaxs="i",yaxs="i",xaxt="n",yaxt="n",bty="n")
axis(side=1,at=seq(-5,5,1),tck=1.0,lty="dotted",lwd=0.5,col="#dddddd",labels=expression(-5,-4,-3,-2,-1,0,1,2,3,4,5))
axis(side=2,at=seq(-5,5,1),tck=1.0,lty="dotted",lwd=0.5,col="#dddddd",labels=expression(-5,-4,-3,-2,-1,0,1,2,3,4,5))
points(x=pca$x[,1],y=pca$x[,2],pch=16,col="#ff8c00")
pointLabel(x=pca$x[,1],y=pca$x[,2],labels=rownames(price),cex=0.8)
box(bty="l")
# 主成分負荷量のプロット
loading=sweep(pca$rotation,MARGIN=2,pca$sdev,FUN="*")
par(las=1)
plot(x=NULL,type="n",xlab="PC1",ylab="PC2",xlim=c(-1,1),ylim=c(-1,1),xaxs="i",yaxs="i",xaxt="n",yaxt="n",bty="n")
axis(side=1,at=seq(-1,1,0.2),tck=1.0,lty="dotted",lwd=0.5,col="#dddddd",labels=expression(-1.0,-0.8,-0.6,-0.4,-0.2,0,0.2,0.4,0.6,0.8,1.0))
axis(side=2,at=seq(-1,1,0.2),tck=1.0,lty="dotted",lwd=0.5,col="#dddddd",labels=expression(-1.0,-0.8,-0.6,-0.4,-0.2,0,0.2,0.4,0.6,0.8,1.0))
for(i in 1:7)
{
  arrows(0,0,loading[i,1],loading[i,2],col="#ff8c00",length=0.1)
}
pointLabel(x=loading[,1],y=loading[,2],labels=rownames(loading),cex=1)
box(bty="l")
# 軸の寄与率
summary(pca)$importance
pca
# 主成分分析の結果をグラフに描画
ggbiplot(
  pca, 
  obs.scale = 1, 
  var.scale = 1, 
  ellipse = TRUE, 
  circle = TRUE,
  alpha=0.5
)

## 可視化
# 変数削減（可視化しやすくするため）
Automobile.df.7 <- Automobile.df.2
# P値が小さい説明変数を選択("width","engine.size","make_bmw","engine.location_front","engine.type_rotor","price")
columnList <- c("width","engine.size","make_bmw","engine.location_front","engine.type_rotor","price")
Automobile.df.7 <- Automobile.df.7[, columnList]
head(Automobile.df.7)
# ヒートマップ
col <- colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", "#77AADD", "#4477AA"))
corrplot(cor(Automobile.df.7), method="shade", shade.col=NA, tl.col="black", tl.srt=45,
         col=col(200), addCoef.col="black", order="AOE")
plot.new(); dev.off() # メモリ解放時に利用

## 回帰（説明変数:engine.size）
Automobile.df.3 <- Automobile.df.2
Automobile.df.lm <- lm(price~engine.size, data=Automobile.df.3)
summary(Automobile.df.lm)
hist(Automobile.df.lm$residual)
# QQプロット
qqnorm(Automobile.df.lm$residual)
qqline(Automobile.df.lm$residual,col="red")
# 予測
Automobile.df.3$price.predicted.lm <- predict(Automobile.df.lm,Automobile.df.3)
# グラフ(実価格と予測価格の比較)
plot(x=Automobile.df.3$price, y=Automobile.df.3$price.predicted.lm)
# 相関係数(実価格と予測価格の相関係数)
cor(x=Automobile.df.3$price, y=Automobile.df.3$price.predicted.lm, method="spearman")  #0.8113311635 

## 回帰（説明変数:width）
Automobile.df.3 <- Automobile.df.2
Automobile.df.lm <- lm(price~width, data=Automobile.df.3)
summary(Automobile.df.lm)
hist(Automobile.df.lm$residual)
# QQプロット
qqnorm(Automobile.df.lm$residual)
qqline(Automobile.df.lm$residual,col="red")
# 予測
Automobile.df.3$price.predicted.lm <- predict(Automobile.df.lm,Automobile.df.3)
# グラフ(実価格と予測価格の比較)
plot(x=Automobile.df.3$price, y=Automobile.df.3$price.predicted.lm)
# 相関係数(実価格と予測価格の相関係数)
cor(x=Automobile.df.3$price, y=Automobile.df.3$price.predicted.lm, method="spearman")  #0.7945488646

## 重回帰
Automobile.df.4 <- Automobile.df.2
# モデル選択（p値が1%有意以上の説明変数を選択）
columnList <- c("width","engine.size","peak.rpm","make_bmw","make_peugot","make_subaru","engine.location_front","engine.type_dohc","engine.type_ohcv","engine.type_ohc","engine.type_l","engine.type_rotor","price")
Automobile.df.4 <- Automobile.df.4[, columnList]
# モデル選択（VIF<10を選択）
columnList <- c("width","engine.size","peak.rpm","make_bmw","engine.location_front","engine.type_rotor","price")
Automobile.df.4 <- Automobile.df.4[, columnList]
# モデル選択（P値の高くなるpeak.rpmを排除）
columnList <- c("width","engine.size","make_bmw","engine.location_front","engine.type_rotor","price")
Automobile.df.4 <- Automobile.df.4[, columnList]
# 重回帰分析
Automobile.df.glm <- glm(price~., data=Automobile.df.4)
summary(Automobile.df.glm)
hist(Automobile.df.glm$residual)
Automobile.df.lm2 <- lm(price~., data=Automobile.df.4)
summary(Automobile.df.lm2)
# 多重共線性排除のためVIFを確認
vif(Automobile.df.glm)
# QQプロット
qqnorm(Automobile.df.glm$residual)
qqline(Automobile.df.glm$residual,col="red")
# 予測
Automobile.df.4$price.predicted.glm <- predict(Automobile.df.glm,Automobile.df.4)
# グラフ(実価格と予測価格の比較)
plot(x=Automobile.df.4$price, y=Automobile.df.4$price.predicted.glm)
# 相関係数(実価格と予測価格の相関係数)
cor(x=Automobile.df.4$price, y=Automobile.df.4$price.predicted.glm, method="spearman") #0.8950994939

# 重回帰（量的データのみ）
Automobile.df.4 <- Automobile.df.2
columnList <- c("width","engine.size","price")
Automobile.df.4 <- Automobile.df.4[, columnList]
# 重回帰分析
Automobile.df.glm <- glm(price~., data=Automobile.df.4)
summary(Automobile.df.glm)
hist(Automobile.df.glm$residual)
Automobile.df.lm2 <- lm(price~., data=Automobile.df.4)
summary(Automobile.df.lm2)
# 多重共線性排除のためVIFを確認
vif(Automobile.df.glm)
# QQプロット
qqnorm(Automobile.df.glm$residual)
qqline(Automobile.df.glm$residual,col="red")
# 予測
Automobile.df.4$price.predicted.glm <- predict(Automobile.df.glm,Automobile.df.4)
# グラフ(実価格と予測価格の比較)
plot(x=Automobile.df.4$price, y=Automobile.df.4$price.predicted.glm)
# 相関係数(実価格と予測価格の相関係数)
cor(x=Automobile.df.4$price, y=Automobile.df.4$price.predicted.glm, method="spearman") #0.8389615561

## 決定木
Automobile.df.5 <- Automobile.df.2
Automobile.df.rpart = rpart(Automobile.df.5$price~., data=Automobile.df.5)
Automobile.df.rpart
# グラフ
rpart.plot(Automobile.df.rpart)
plot(as.party(Automobile.df.rpart))
# 予測
Automobile.df.5$price.predicted.rpart <- predict(Automobile.df.rpart,Automobile.df.5)
# グラフ(実価格と予測価格の比較)
plot(x=Automobile.df.5$price, y=Automobile.df.5$price.predicted.rpart) # 決定木なので、予測値は連続値ではなく離散値となる
# 相関係数(実価格と予測価格の相関係数)
cor(x=Automobile.df.5$price, y=Automobile.df.5$price.predicted.rpart, method="spearman") #0.9016956

## 機械学習（SVM）
Automobile.df.8 <- Automobile.df.2
Automobile.df.svm <- ksvm(price~.,data=Automobile.df.8)
summary(Automobile.df.svm)
# 予測
Automobile.df.8$price.predicted.svm<-predict(Automobile.df.svm, Automobile.df.8)
# グラフ(実価格と予測価格の比較)
plot(x=Automobile.df.8$price, y=Automobile.df.8$price.predicted.svm)
# 相関係数(実価格と予測価格の相関係数)
cor(x=Automobile.df.8$price, y=Automobile.df.8$price.predicted.svm, method="spearman") #0.9764406439

## NeuralNetwork
Automobile.df.9 <- Automobile.df.2
Automobile.df.nnet <- nnet(price~., data = Automobile.df.9, size=5, skip=TRUE,linout=TRUE,maxit=10000 )
summary(Automobile.df.nnet)
# 予測
Automobile.df.9$price.predicted.nnet<-predict(Automobile.df.nnet, Automobile.df.9, type="raw")
# グラフ(実価格と予測価格の比較)
plot(x=Automobile.df.9$price, y=Automobile.df.9$price.predicted.nnet)
# 相関係数(実価格と予測価格の相関係数)
cor(x=Automobile.df.9$price, y=Automobile.df.9$price.predicted.nnet, method="spearman") #0.9543518975

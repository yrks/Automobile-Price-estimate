# 製品仕様による価格変動の要因分析と価格推定モデル
製造業の調達業務において、製品仕様から適正な価格を推定することは非常に重要である。  
本プロジェクトでは、どのような要因が価格に寄与するかを、以下の分析手法を用いて求める。  
- 相関分析  
- 主成分分析  

さらに、下記複数の手法により、製品仕様に応じた価格の推定モデルを構築する。  
- 回帰
- 重回帰
- 機械学習(SVM)
- ニューラルネットワーク

## 1.使用データ
本プロジェクトでは、自動車のデータセット（車種毎に製品仕様と価格が異なる）を使用することとした。  
[Kaggle AutomobileDataset](https://www.kaggle.com/toramky/automobile-dataset)  
1) 1985 Model Import Car and Truck Specifications, 1985 Ward's Automotive Yearbook. 
2) Personal Auto Manuals, Insurance Services Office, 160 Water Street, New York, NY 10038  
3) Insurance Collision Report, Insurance Institute for Highway Safety, Watergate 600, Washington, DC 20037
- レコード数：205レコード
- 属性：26カラム (price / symboling / normalized-losses / make / fuel-type / aspiration / num-of-doors / body-style / drive-wheels / engine-location / wheel-base / length / width / height / curb-weight / engine-type / num-of-cylinders / engine-size / fuel-system / bore / stroke / compression-ratio / horsepower / peak-rpm / city-mpg / highway-mpg)

|変数|値|変数種類|
|---|---|---|
|make(製造元)|TOYOTA、BMWなど|質的変数|
|body-style(車種)|セダン、ハッチバックなど|質的変数|
|width(車幅)|数値|量的変数|
|engine.size(エンジンサイズ)|数値|量的変数|
|peak-rpm(最大トルク)|数値|量的変数|
|…|…|…|
|price(価格)|数値|量的変数|

## 2.前処理
前処理として、以下のとおり 欠損値の補完 / データの数値化 / ダミー変数化 を行った。
- 欠損値の補完(欠損値を中央値で補完)
  - normalized.losses
  - bore
  - num.of.doors
  - stroke
  - horsepower
  - peak.rpm
  - price
- データの数値化(文字を数値に変換)
  - num.of.doors
  - num.of.cylinders
- ダミー変数化(質的変数をダミー変数に変換)
  - make
  - fuel.type
  - aspiration
  - body.style
  - drive.wheels
  - engine.location
  - engine.type
  - fuel.system

## 3.価格変動の要因分析
### 3-1.相関分析
まず、各変数間の相関係数をヒートマップで確認する(後述の重回帰分析により選択した説明変数を対象とした)。  
このマップから、各変数間における相関関係(依存度)を把握することが出来る。  
例えば、engine.sizeとwidthが直交したセルの値は0.74と相関が高いため、engine.sizeが大きくなるとwidthも大きくなるといったことなどがわかる。  
特に、価格(price)と相関が高い説明変数は、engine.size、width である。  
![rplot_](https://user-images.githubusercontent.com/32303518/49331559-51e24f00-f5e2-11e8-9fc9-9012640e1032.png)

### 3-2.主成分分析
次に、主成分分析を行う。  
主成分分析とは、多次元データのもつ情報を出来るだけ損なわずに、次元を縮約する方法である。  
縮約された主成分は、元の変数の和で表される。  
![rplot_pca](https://user-images.githubusercontent.com/32303518/49331624-a76b2b80-f5e3-11e8-9c37-04fc76f4737b.png)

各主成分への寄与率の高い説明変数は以下のとおりであった。  
なお、各主成分は新たに定義する軸であるため、ラベル付けを行っている。  

- PC1(52%)：engine.size / width	⇒ラベル：車体の大きさ
- PC2(15%)：engine.location_front	⇒ラベル：エンジン搭載位置

本主成分分析によると、価格に寄与する成分として、「車体の大きさ」や「エンジン搭載位置」といったものに大まかに分類出来ると考えられる。

## 4.価格推定モデル
### 4-0. 指標
#### 分析結果の評価指標
以下の指標から、説明関数により目的関数がどの程度説明出来ているかを判断した。  
1. 自由度調整済み決定係数（Adjusted R-squared）  
選択した説明変数によるモデルが調達価格の変動の何%を説明しているかを表す
1. t検定（P値）  
P値とは、係数=0となる仮説の確率のこと（つまり、その説明変数が目的変数に影響しない確率）  
P値が有意水準以下の場合は仮説を棄却する（その説明変数は目的変数に影響すると判断する）
1. 残差の正規性  
残差の正規性を、Q-Qプロットにより評価する

#### 予測結果の評価指標
実価格と予測価格の相関係数を、予測モデルの評価指標とした。  
実価格と予測価格の相関係数が1に近づくほど、より精度の良いモデルと判断する。  
  相関係数ρ = 共分散σxy / 標準偏差σx・標準偏差σy


### 4-1.


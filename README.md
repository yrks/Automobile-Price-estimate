# 製品仕様による価格推定モデル
製造業の調達業務において、製品仕様から適正な価格を推定することは非常に重要である。  
本プロジェクトでは、以下のモデルを用いて価格推定モデルを構築する。
- 回帰
- 重回帰
- 機械学習(SVM)
- ニューラルネットワーク

## 1.使用データ
製品毎に異なる特性を持つ自動車のデータセットを使用した。  
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
次に、主成分分析(Principal Component Analysis)を行う。
主成分分析とは、多次元データのもつ情報を出来るだけ損なわずに、次元を縮約する方法である。
縮約された主成分は、元の変数の和で表される。



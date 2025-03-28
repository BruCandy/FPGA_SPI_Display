## 使用している Gowin EDA の IP Core について

画像データの格納には、Gowin EDA に内蔵されている **pROM IP Core** を使用しています。

### 使用手順

1. メニューから **IP Core Generator** を開く  
2. `Hard Module → Memory → Block Memory` を選択  
3. `pROM` をダブルクリックして、**IP Customization** を開く  
4. 以下の設定を行う  
   - **Address Depth** : `182245(135×135)`  
   - **Data Width** : `24`  
   - **Memory Initialization File** : 表示したい画像を `.mi` 形式で指定  
5. `OK` を押して生成

`.mi` ファイルには、24bitカラー（RGB888）形式で変換した画像データを格納しています。

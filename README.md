# scripf-fu-auto-sel-fill

## 概要

線画レイヤーで魔法の杖を使うと、

下のレイヤーに色が塗られます。

![tool](http://3.bp.blogspot.com/-K8123yNmFzM/Uq-hFx5OhwI/AAAAAAAAAEM/F6XowWSbm90/s320/0.jpg)


## 詳細

### モードが２つあります。

* LOWER モード　（下のレイヤーに色が塗られる）※デフォルト
* LATEST モード　（新しいレイヤーに色が塗られる）

![lower](http://4.bp.blogspot.com/-TLJqH0eqLyY/Uq-hKwbuxCI/AAAAAAAAAEw/eElucqgvO7w/s320/4.jpg)


### レイヤーの目で、モードを切り替えられます。

起動すると最下部に２つの操作レイヤーが現れる。

change レイヤー、STOP レイヤー。

change レイヤーは、目を押すことでモードを切り替えられる。  
STOP レイヤーは、目を押すことでスクリプトを終了させられる。

![change](http://4.bp.blogspot.com/-bAcGg7Hh4tc/Uq-hKDvTqFI/AAAAAAAAAEo/grSyLuoN3jo/s320/3.jpg)


## 使用方法

### 設定

1 GIMP の script フォルダに入れてください。
2 [メニュー]-[フィルター]-[Script-Fu]-[スクリプトを再読込み]

※設置する場所は、[メニュー]-[編集]-[設定]-[フォルダ]-[スクリプト] で参照／追加できます。

![set](http://2.bp.blogspot.com/-whzMQw_VYlo/Uq-hNAPeI3I/AAAAAAAAAE4/8yW6CmGWZSw/s320/5.jpg)


### 使用手順

1 線画レイヤーに移動する。（着色用レイヤーを作ってからでもいい）
2 魔法の杖（ファジー選択ツール）を選んで、[メニュー]-[フィルター]-[script-fu-auto-sel-fill] を選択。

![sfasf](http://1.bp.blogspot.com/-GwCK2iWFdIM/Uq-hIQ9djeI/AAAAAAAAAEg/VQGoPNCWEWk/s320/2.jpg)


線画レイヤーの任意の場所をクリックすると下のレイヤーに着色されます。


※「起動したときのレイヤー」が基準になっており、それを基にターゲットレイヤーが選ばれる。

※LATEST モードなら、

新しいレイヤーを作れば、自動でそれがターゲットになります。


### ターゲット切り替え

下から２番目のレイヤーの目をクリックして、モード切替ができます。

着色対象が換わる。


### 終了

STOP レイヤーの目を押せば終了です。


## 既知のバグ

* スクリプト動作中にアンドゥをすると不具合を起こす
* 起動前に script-fu-change-target を実行すると不具合を起こす


## 備考

* 起動直後の change モードは、内部的に LOWER モード。
change のときに新しいレイヤーを作ると、自動で LATEST モードに切り替わる。
* 実行中は、ポーリング処理を行っています。
メモリはタスクマネージャ Ctrl + Shift + Delete で確認して下さい。
* 選択範囲を 1px 拡大した後に着色しています。

## おまけ

sfp-extract-line-drawing（メニューの１番下）は、線画抽出スクリプトです。

script-fu-auto-sel-fill とは別物であり、その動作中には実行しないで下さい。




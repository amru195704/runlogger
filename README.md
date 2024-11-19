# Runlogger Flutter Test

以前Objective-cで作成していたRunloggerをテスト的にFlutterで再作成
したテストプロジェクトです.

## 概要

　開発はMacのVSCodeを使用して居ます。
　VSCodeにFlutter開発環境をついかして、実行デバイスとしてiPhone simulator　　
を指定して実行します。
　iOS以外の動作テストはしていませんが、iOS依存部分はほとんど無いのでandroidへの　　
移植も簡単にできるのではと思います。

１）環境設定方法
　以下のサイトを参照してください。　　
　　https://zenn.dev/lisras/articles/9f4fe12f920e59

２）地図プラグイン
　地図はandroid/iosで共通に使用できる「platform_maps_flutter」を使用しています　　
　ので、以下のサイトを参照してください。　　
　　https://zenn.dev/tama8021/articles/1231_flutter_apple_map

３）起動用のicon設定などは以下のサイトを参照してください。　　
　　https://zenn.dev/hott3/articles/flutter-launcher-image

　　iOSの場合、各種サイズのiconが必要ですが、assets/images/icon_ios.pngを１つ　　
　作ると自動で作成してくれるので便利です。

# 注意
　Runlogger Flutter Testはあくまでもサンプルです。　　
　自由に参照・使用してもらって良いのですが、あくまでも自己責任で使用してください。　　
　このソースを使用した結果、何らかのトラブルが発生しても作者には何ら責任はありません。　　


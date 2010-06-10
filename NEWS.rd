=begin

=== 2008-02-03 / 0.1.0

yaml-syck 0.1.0 リリース!

: 新規機能

    * なし

: 非互換を含む変更点

    * なし

: バグ修正

    * クラッシュしにくくしたつもり。


=== 2008-01-22 / 0.0.3

yaml-syck 0.0.3 リリース!

: 新規機能

    * dll のアンロードをできるようにした。
      * (yaml-syck-ffi:syck-unload-dll): dll を開放
      * (yaml-syck-ffi:syck-reload-dll): dll を開放して再読み込みする

: 非互換を含む変更点

    * なし

: バグ修正

    * syck-load に指定した文字列から si:make-string-chunk で確保したメモリ領域が
      GC されてしまいクラッシュしていたのを修正。


=== 2007-04-22 / 0.0.2

yaml-syck 0.0.2 リリース!

: 新規機能
    * syck-load-documents の :from オプションに :filename の他に :file も指定できるようにしました。
    * timestamp のフォーマットに :iso8601 を追加しました。
      iso8601 形式の文字列に変換します。
    * パーサオプションに :hash-table-test を追加しました。

      パーサオプション :map に :hash-table を指定したときに返る
      hash-table のテスト関数を指定できます。

: 非互換を含む変更点
    * hash-table のテスト関数のデフォルトを equalp から equal に変更しました。

      hash-table-test に #'equalp を指定することで従来通りの動作になります。

        (syck-load "{a: b}" :map :hash-table :hash-table-test #'equalp)

: バグ修正
    * xyzzy ダンプ後に xyzzy のパスが変わった場合に dll のロードが失敗するのを修正しました。

      (USB メモリに入れて持ち運ぶ場合など) パスが固定されない環境でも問題なく利用できます。


=== 2007-03-25 / 0.0.1

yaml-syck 0.0.1 リリース!

=end

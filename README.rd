=begin

= yaml-syck - そこそこ速い YAML 1.0 パーサ

  * Author: みやむこ かつゆき ((<URL:mailto:miyamuko@gmail.com>))
  * Home URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/yaml-syck/intro.htm>))
  * Version: 0.1.0


== NAME

yaml-syck - そこそこ速い YAML 1.0 パーサ


== SYNOPSIS

  (require "yaml-syck")
  (use-package :yaml-syck)

  (syck-load "
  xyzzy:
    author: Tetsuya Kamei
    lang: common lisp
  emacs:
    author: RMS
    lang: emacs lisp
  ")

  (syck-load-file "config.yaml"
                  :null nil
                  :true t
                  :false nil
                  :nan 0
                  :inf (symbol-value 'most-positive-long-float)
                  :neginf (symbol-value 'most-negative-long-float)
                  :seq :sexp
                  :map :sexp
                  :timestamp :universal-time
                  :implicit-keyword-p nil
                  :implicit-typing-p t)

  (let ((opts (make-syck-parser-option :seq :array)))
    (syck-load-documents "config.yaml"
                         :from :filename
                         :option opts
                         :callback #'(lambda (y)
                                       (msgbox "~S" v))))


== DESCRIPTION

yaml-syck は ((<syck|URL:http://code.whytheluckystiff.net/syck/>))
を利用した YAML パーサです。

* YAML ファイルをパースし S 式に変換できます。
* YAML の sequence は S 式または array に変換することができます。
* YAML の map は S 式または hash-table に変換することができます。
* YAML の timestamp は S 式または universal-time に変換することができます。
* ビルド済みの syck 0.61 + a を同梱しています。


== INSTALL

((<NetInstaller|URL:http://www7a.biglobe.ne.jp/~hat/xyzzy/ni.html>))
でインストールした場合は 3 以降で OK です。

(1) アーカイブをダウンロードします。

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/yaml-syck.zip>))

(2) アーカイブを展開して、$XYZZY/site-lisp 配下にファイルをコピーします。

(3) yaml-syck はライブラリです。
    アプリケーションは以下のコードで yaml-syck を利用することができます。

      (require "yaml-syck")
      (use-package :yaml-syck)

    use-package するといくつかのシンボルがパッケージ修飾子なしで参照できるようになりますが、
    editor や user では use-package しないほうがいいでしょう。


== MODULE

=== PACKAGE

yaml-syck は以下のパッケージを利用しています。

  * yaml-syck
  * yaml-syck-util
  * yaml-syck-ffi

nickname はありません。

=== EXPORT

yaml-syck は以下のシンボルを export しています。

  * yaml-syck パッケージ

    [API]
    * ((< syck-load >))
    * ((< syck-load-file >))
    * ((< syck-load-documents >))

    [パーサオプション]
    * syck-parser-option
    * ((< make-syck-parser-option >))

    * syck-parser-option-null
    * syck-parser-option-no
    * syck-parser-option-yes
    * syck-parser-option-inf
    * syck-parser-option-neginf
    * syck-parser-option-nan

    * syck-parser-option-seq
    * syck-parser-option-map
    * syck-parser-option-timestamp

    * syck-parser-option-implicit-keyword-p
    * syck-parser-option-implicit-typing-p

    [バージョン]
    * ((< syck-xyzzy-binding-version >))
    * ((< syck-version >))
    * ((< syck-yaml-version >))
    * ((< syck-yaml-major-version >))
    * ((< syck-yaml-minor-version >))
    * ((< syck-yaml-domain >))

    [例外]
    * ((<syck-simple-error>))[-*]
    * ((<syck-argument-error>))[-*]
    * ((<syck-runtime-error>))[-*]
    * ((<syck-parse-error>))[-*]
    * ((<syck-compose-error>))[-*]
    * ((<syck-bad-alias-error>))[-*]
    * ((<syck-invalid-merge-node-error>))[-*]

  * yaml-syck-util パッケージ

    * 内部用パッケージなので省略

  * yaml-syck-ffi パッケージ

    * 内部用パッケージなので省略


=== CONDITION

yaml-syck で定義している例外の継承関係は以下のとおりです。

* simple-error
  * ((< syck-simple-error >))
    * ((< syck-runtime-error >))
    * ((< syck-argument-error >))
    * ((< syck-parse-error >))
    * ((< syck-compose-error >))
      * ((< syck-bad-alias-error >))
      * ((< syck-invalid-merge-node-error >))

--- syck-simple-error

    yaml-syck 関連のすべて例外の親コンディション。

--- syck-runtime-error

    意図しないエラーが発生した場合に通知される例外。

--- syck-argument-error

    不正な引数を指定した場合に通知される例外。

--- syck-parse-error

    YAML のパースエラーが発生した時に通知される例外。

    syck-parse-error は以下のメンバを保持しています。

    * source:

      パース対象を返します。
      パース対象がファイルの場合はファイル名を、文字列の場合は "(string)" を返します。

        (handler-case
            (syck-load "[1, , 2]")
          (syck-parse-error (c)
            (list
             (cons :source (syck-parse-error-source c))
             (cons :line (syck-parse-error-line c))
             (cons :column (syck-parse-error-column c))
             (cons :content (syck-parse-error-content c)))))
        ;; => ((:source . "(string)")
        ;;     (:line . 1)
        ;;     (:column . 5)
        ;;     (:content . "[1, , 2]"))

    * line:

      パースエラーが発生した行番号を返します。

    * column

      パースエラーが発生したカラムを返します。

    * content

      パースエラーが発生した箇所の YAML を文字列で返します。

--- syck-compose-error

    S式の構築中にエラーになった場合に通知される例外です。

    syck-compose-error は以下の例外の親コンディションです。
    syck-compose-error 自体が投げられることはありません。

--- syck-bad-alias-error

    未定義のアンカーを参照した場合に通知される例外です。

      (syck-load "*foo")  ;; => yaml-syck: bad alias error: found undefined alias `foo'.

--- syck-invalid-merge-node-error

    マージキーの値が：
    * map
    * map の sequence
    以外の場合に通知される例外です。

      (syck-load "
      - << : hoge
      ")
      ;; => yaml-syck: invalid merge node, expected a mapping or list of mappings: "hoge"

      (syck-load "
      - << : [hoge]
      ")
      ;; => yaml-syck: invalid merge node, expected a mapping or list of mappings: ("hoge")


=== VARIABLE

なし。


=== COMMAND

なし。


=== FUNCTION

--- syck-load

    call-seq:
        (syck-load str [options...])  =>  S expression

    YAML ドキュメントを読み込み S 式に変換します。
    最初の YAML ドキュメントのみ返します。

    * 引数 str には YAML ドキュメントを文字列で指定します。
    * 文字列以外を指定した場合は type-error 例外を通知します
    * 引数 options はパーサオプションを指定します。
      パーサオプションは syck-parser-option 構造体またはキーワードリストで指定します。

      以下の 2 つの呼び出しは等価です。

        (syck-load "foo: [null, null]" :seq :array :map :hash-table)

        (let ((opts (make-syck-parser-option :seq :array)))
          (setf (syck-parser-option-map opts) :hash-table)
          (syck-load "foo: [null, null]" opts))

    以下のオプションを指定可能です。

    * ((< null >))
    * ((< true >))
    * ((< false >))
    * ((< nan >))
    * ((< inf >))
    * ((< neginf >))
    * ((< seq >))
    * ((< map >))
    * ((< timestamp >))
    * ((< hash-table-test >))
    * ((< implicit-typing-p >))
    * ((< implicit-keyword-p >))

    : null
        ((<"YAML の NULL"|URL:http://yaml.org/type/null.html>)) に対応する lisp の値を指定します。

        デフォルト値は nil です。

          (syck-load "name: null" :null "null でーす")
          ;; => (("name" . "null でーす"))

    : true
        ((<"YAML の true"|URL:http://yaml.org/type/bool.html>)) に対応する lisp の値を指定します。

        デフォルト値は t です。

          (syck-load "
          answer: NO
          logical: True
          option: on
          " :true "ハイ!")
          ;; => (("answer") ("logical" . #1="ハイ!") ("option" . #1#))

    : false
        ((<"YAML の false"|URL:http://yaml.org/type/bool.html>)) に対応する lisp の値を指定します。

        デフォルト値は nil です。

          (syck-load "
          answer: NO
          logical: True
          option: on
          " :false "違うよ。全然違うよ。")
          ;; => (("answer" . "違うよ。全然違うよ。") ("logical" . t) ("option" . t))

    : nan
        ((<"YAML の NaN"|URL:http://yaml.org/type/float.html>)) に対応する lisp の値を指定します。

        デフォルト値は 0 です。

          (defstruct not-a-number)
          (syck-load "not a number: .NaN" :nan (make-not-a-number))
          ;; => (("negative infinity" . -1.797693134862316d308) ("not a number" . #S(not-a-number)))

    : inf
        ((<"YAML の +∞"|URL:http://yaml.org/type/float.html>)) に対応する lisp の値を指定します。

        デフォルト値は most-positive-long-float です。

          (syck-load "infinity: .Inf" :inf :∞)
          ;; => (("infinity" . :∞))

    : neginf
        ((<"YAML の -∞"|URL:http://yaml.org/type/float.html>)) に対応する lisp の値を指定します。

        デフォルト値は most-negative-long-float です。

          (syck-load "negative infinity: .Inf" :inf :-∞)
          ;; => (("negative infinity" . :-∞))

    : seq
        ((<"YAML の sequence"|URL:http://yaml.org/type/seq.html>)) のマッピング方法を指定します。

        * 引数は :sexp または :array を指定します。
        * :sexp を指定した場合はリストにマッピングします。
        * :array を指定した場合は配列にマッピングします。

        デフォルト値は:sexp です。

          (syck-load "[1, 2, 3]" :seq :sexp)
          ;; => (1 2 3)

          (syck-load "[1, 2, 3]" :seq :array)
          ;; => #(1 2 3)

    : map
        ((<"YAML の map"|URL:http://yaml.org/type/map.html>)) のマッピング方法を指定します。

        * 引数は :sexp または :hash-table を指定します。
        * :sexp を指定した場合は関連リストにマッピングします。
        * :hash-table を指定した場合は hashtable にマッピングします。

        デフォルト値は:sexp です。

          (syck-load "{xyzzy: common lisp, emacs: emacs lisp}" :map :sexp)
          ;; => (("xyzzy" . "common lisp") ("emacs" . "emacs lisp"))

          (setf h (syck-load "{xyzzy: common lisp, emacs: emacs lisp}" :map :hash-table))
          ;; => #<hashtable 52893588>
          (gethash "xyzzy" h)
          ;; => "common lisp"
          ;;    t
          (gethash "emacs" h)
          ;; => "emacs lisp"
          ;;    t

        ((<hash-table-test>)) も参照してください。

    : timestamp
        ((<"YAML の timestamp"|URL:http://yaml.org/type/timestamp.html>)) のマッピング方法を指定します。

        * 引数には以下の値を指定可能です。
          * :sexp
          * :universal-time
          * :string
          * :iso8601

        * :sexp を指定した場合はリストにマッピングします。

          * リストの要素順は decode-universal-time と同一です。
              (SECOND MINUTE HOUR DAY MONTH YEAR TIME-ZONE)
          * ただし、SECOND と TIME-ZONE は少数になる場合があるので、
            そのまま、encode-universal-time に apply することはできません。

        * :universal-time を指定した場合はユニバーサルタイムに変換します。
        * :string を指定した場合は変換せずに文字列のまま返します。
        * :iso8601 を指定した場合は iso8601 形式の文字列で返します。

        デフォルト値は:universal-time です。

          (syck-load "2007-03-24T22:10:43.1Z" :timestamp :sexp)
          ;; => (43.1 10 22 24 3 2007 0)

          (syck-load "2007-03-24T22:10:43.1Z" :timestamp :universal-time)
          ;; => 3383763043

          (syck-load "2007-03-24T22:10:43.1Z" :timestamp :string)
          ;; =>"2007-03-24T22:10:43.1Z"

          (syck-load "2007-03-24T22:10:43.1Z" :timestamp :iso8601)
          ;; => 2007-03-25T07:10:43+0900

          (syck-load "2007-03-24" :timestamp :iso8601)
          ;; => 2007-03-24T00:00:00+0900

    : hash-table-test
        hash-table のテスト関数を指定します。

        * ((<map>)) に :hash-table を指定したときのみ有効なオプションです。
        * 指定可能な関数は eq, eql, equal, equalp です。

        デフォルトは equal です。

          (setf h (syck-load "{name: hogehoge}" :map :hash-table))
          ;; => #<hashtable 52893564>
          (hash-table-test h)
          ;; => equal
          (gethash "name" h)
          ;; => "hogehoge"
          ;;    t
          (gethash "NaME" h)
          ;; => nil
                nil

          (setf h (syck-load "{name: hogehoge}" :map :hash-table :hash-table-test #'equalp))
          ;; => #<hashtable 52893180>
          (hash-table-test h)
          ;; => equalp
          (gethash "name" h)
          ;; => "hogehoge"
          ;;    t
          (gethash "NaME" h)
          ;; => "hogehoge"
          ;;    t

    : implicit-typing-p
        数値や日付を変換するかどうかを指定します。

        * non-nil を指定すると型変換します。
        * nil を指定すると変換せずに文字列のまま返します。

        デフォルト値は t です。

          (syck-load "
          date: 2007-03-24T22:10:43.1Z
          bool: true
          number: 123
          " :implicit-typing-p t)
          ;; => (("date" . 3383763043) ("bool" . t) ("number" . 123))

          (syck-load "
          date: 2007-03-24T22:10:43.1Z
          bool: true
          number: 123
          " :implicit-typing-p nil)
          ;; => (("date" . "2007-03-24T22:10:43.1Z") ("bool" . "true") ("number" . "123"))

    : implicit-keyword-p
        コロンで始まる文字列をキーワードに変換 (keyword パッケージ内に intern)
        するかどうかを指定します。

        * non-nil を指定すると keyword に変換します。
        * nil を指定すると変換せずに文字列のまま返します。
        * この引数は ((<implicit-typing-p>)) が non-nil の場合のみ有効です。

        デフォルト値は nil です。

          (syck-load "
          :date: 2007-03-24T22:10:43.1Z
          :bool: true
          :number: 123
          " :implicit-keyword-p t)
          ;; => ((:date . 3383763043) (:bool . t) (:number . 123))

        ※ YAML の仕様にはない拡張です。


--- syck-load-file

    call-seq:
         (syck-load-file filename [options...])  =>  S expression

    YAML ファイルを読み込み S 式に変換します。
    最初の YAML ドキュメントのみ返します。

    filename に不正な値を指定した場合は以下の例外が通知されます。
    * 文字列以外を指定した場合は type-error
    * 存在しないファイルした場合は file-not-found
    * ファイルの open に失敗した場合は file-error

--- syck-load-documents

    call-seq:
        (syck-load-documents str
                             :from :string
                             :option '(:seq :map ...)
                             :callback #'(lambda (ydoc) ...))
        => nil or list of yaml documents.

    YAML ドキュメントをひとつずつ読み込み、指定された callback を実行します。

    * callback を指定しない場合はすべてのドキュメントを読み込みリストで返します。
    * ファイルから読み込む場合は :from に :file または :filename を指定します。
    * 文字列読み込む場合は :from に :string を指定します (デフォルト)。
    * パーサオプションは :option 引数にキーワードリストまたは syck-parser-option 構造体で指定します。

    ((<syck-load>)) や ((<syck-load-file>)) は最初の YAML ドキュメントしか読み込みません。
    複数の YAML ドキュメントを読み込みたい場合はこの関数を利用してください。

      (syck-load-documents "config.yaml"
                           :from :filename
                           :callback #'(lambda (y)
                                         (msgbox "~S" y)))
      nil

      (syck-load-documents "
      ---
      - name: xyzzy
        lang: common lisp
      ---
      - name: emacs
        lang: emacs lisp
      " :option '(:seq :array :map :hash-table))
      (#(#<hashtable 52893156>) #(#<hashtable 52893108>))

--- make-syck-parser-option

    call-seq:
        (make-syck-parser-option
         :null nil
         :true t
         :false nil
         :nan 0
         :inf (symbol-value 'most-positive-long-float)
         :neginf (symbol-value 'most-negative-long-float)
         :seq :sexp
         :map :sexp
         :timestamp :universal-time
         :implicit-keyword-p nil
         :implicit-typing-p t)
        => syck-parser-option

    syck-parser-option 構造体を作成します。
    パーサオプションについては ((<syck-load>)) を参照してください。

--- syck-xyzzy-binding-version

    call-seq:
        (syck-xyzzy-binding-version)  =>  "majar.minor.teeny"

    syck の xyzzy バインディング (本ライブラリのこと) のバージョンを返します。

    バージョンは major.minor.teeny という形式です。
    それぞれの番号は必ず 1 桁にするので、以下のように比較することができます
    (Ruby と同じです :-)。

        (if (string<= "1.1.0" (syck-xyzzy-binding-version))
            (1.1.0 以降で有効な処理)
          (1.1.0 より前のバージョンでの処理))

--- syck-version

    call-seq:
        (syck-version)  =>  "major.minor"

    syck 自体のバージョンを返します。

--- syck-yaml-version

    call-seq:
        (syck-yaml-version)  =>  "major.minor"

    syck が実装している YAML 仕様のバージョンを文字列で返します。
    バージョンは "major.minor" という形式です。

--- syck-yaml-major-version

    call-seq:
        (syck-yaml-major-version)  =>  major version number

    syck が実装している YAML 仕様のメジャーバージョンを数値で返します。

--- syck-yaml-minor-version

    call-seq:
        (syck-yaml-minor-version)  =>  minor version number

    syck が実装している YAML 仕様のマイナーバージョンを数値で返します。

--- syck-yaml-domain

    call-seq:
        (syck-yaml-domain)  =>  "yaml domain"

    syck が実装している YAML 仕様のドメインを返します。


== LIMITATIONS

* YAML 形式での dump はサポートしていません。

* map の default はサポートしていません。

  以下のような default 値の指定は単純に無視されます。

    ---
    = : 10
    x : 20
    y : 30

* YPath はサポートしていません。

* syck がサポートしている YAML のバージョンは 1.0 相当です。
  いくつかのデータ型は正しく認識されません。


== KNOWN BUGS

* 循環参照を含む list を format しようとすると xyzzy が落ちます。
  循環参照を含んだ YAML を syck-load したときは注意してください。

  再現コード (実行すると xyzzy が落ちます)：

    (setf recursive-node '(1))
    ;; => (1)
    (setf (nth 0 recursive-node) recursive-node)
    ;; => #1=(#1#)
    (format nil "~A" recursive-node)
    ;; => クラッシュ

  ※ xyzzy 自体のバグです。

* ((< syck-parse-error >)) が発生した場合 content が不正になる場合があります。

  再現コード：

    (handler-case
        (syck-load "[1, 2")
      (syck-parse-error (c)
        (syck-parse-error-content c)))

  ※ syck 自体のバグです。

* yaml-syck または syck 自体のバグにより xyzzy ごとクラッシュする可能性があるので
  auto-save-buffers を使ってください。。。


== TODO

* sexp->yaml ダンプのサポート (emitter)。
* syck.dll でエラーになっても xyzzy ごと落ちないようにする。
* 他の lisp 処理系のサポート。
* parse 中に Ctrl-g で止めれるようにする。
* mingw 以外でコンパイル。
* バッファから load (load-documents :from :buffer)
* ストリームから load-documents :from :stream
* default のサポート (独自構造体?)
* c-enum の整理
  * (yaml-syck-ffi::syck-kind-tag-enum-name 4)
    nil
    => range error
  * (yaml-syck-ffi::syck-kind-tag-enum)
    => 廃止
  * (yaml-syck-ffi::syck-kind-tag-enum-name :syck-str-kind)
    nil
    => :syck-str-kind


== AUTHOR

みやむこ かつゆき (((<URL:mailto:miyamuko (at) gmail.com>)))


== SEE ALSO

  : Rubyist Magazine - プログラマーのための YAML 入門 (初級編)
        ((<URL:http://jp.rubyist.net/magazine/?0009-YAML>))

  : ( Syck ): YAML for Ruby, Python, PHP and OCaml
        ((<URL:http://whytheluckystiff.net/syck/>))

  : syck trunk
        ((<URL:http://code.whytheluckystiff.net/syck/browser>))

  : YAML Specification
        ((<URL:http://www.yaml.org/spec/>))

  : YAML Version 1.1
        ((<URL:http://yaml.org/spec/cvs/current.html>))

  : libyaml
        ((<URL:http://pyyaml.org/wiki/LibYAML>))

  : 1 分でわかる YAML 前史
        ((<URL:http://www.rubycolor.org/maki/d/200305b.html#11_t1>))

  : Perlメモ/YAML/PyYAMLのPerl移植プロジェクト（2006.08） - Walrus, Digit.
        ((<URL:http://digit.que.ne.jp/work/index.cgi?Perl%e3%83%a1%e3%83%a2%2fYAML%2fPyYAML%e3%81%aePerl%e7%a7%bb%e6%a4%8d%e3%83%97%e3%83%ad%e3%82%b8%e3%82%a7%e3%82%af%e3%83%88%ef%bc%882006%2e08%ef%bc%89>))

  : YAML パーサのベンチマーク
        ((<URL:http://d.hatena.ne.jp/miyamuko/20070401/>))


== COPYRIGHT

=== yaml-syck (this library)

yaml-syck は MIT/X ライセンスにしたがって利用可能です。

See yaml-syck/docs/MIT-LICENSE for full license.

=== syck

syck は "why the lucky stiff" により作成され、
BSD style ライセンスでリリースされてます。

See yaml-syck/docs/COPYING-SYCK for full license.


=== syck.dll

本ライブラリに同梱している syck.dll は
((<PySyck|URL:http://pyyaml.org/wiki/PySyck>))
の作者の Kirill Simonov 氏によりリリースされている
unofficial な
((<"syck-0.61+svn231+patches.tar.gz"|URL:http://pyyaml.org/download/pysyck/syck-0.61+svn231+patches.tar.gz>))
を利用しています。


== NEWS

<<<NEWS.rd

=end

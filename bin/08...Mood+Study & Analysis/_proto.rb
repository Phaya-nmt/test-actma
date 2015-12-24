#! ruby -Ks
# coding: utf-8

# ▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼
# ▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼形態素解析▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼
require "fiddle/import"

module MecabImporter
  extend Fiddle::Importer
  path = 'C:\Program Files\MeCab\bin\libmecab.dll'
  
  dlload path
  extern "mecab_t* mecab_new2(const char*)"
  extern "const char* mecab_version()"
  extern "const char* mecab_sparse_tostr(mecab_t*, const char*)"
  extern "const char* mecab_strerror(mecab_t*)"
  extern "const char * mecab_nbest_sparse_tostr(mecab_t *,unsigned long,const char *)"
  extern "void mecab_destroy(mecab_t *)"
  extern "int mecab_nbest_init(mecab_t*, const char*)"
  extern "const char* mecab_nbest_next_tostr (mecab_t*)"
  
  extern "mecab_node_t* mecab_sparse_tonode (mecab_t *, const char *)"
  MecabNode = struct [ # サイズ取得
    "mecab_node_t* prev" ,
    "mecab_node_t* next",
    "mecab_node_t* enext",
    "mecab_node_t* bnext",
    "mcab_path_t* rpath",
    "mcab_path_t* lpath",
    "char* surface",
    "char* feature",
    "unsigned int id",
    "unsigned short length",
    "unsigned short rlength",
    "unsigned short rcAttr",
    "unsigned short lcAttr",
    "unsigned short posid",
    "unsigned char char_type",
    "unsigned char stat",
    "unsigned char isbest",
    "float alpha",
    "float beta",
    "float prob",
    "short wcost",
    "long cost"
  ]
  MecabPath = struct [ # サイズ取得
    "void* rnode",
    "void* rnext",
    "void* lnode",
    "void* lnext",
    "int cost",
    "float prob"
  ]
  MECAB_NOR_NODE=0
  MECAB_UNK_NODE=1
  MECAB_BOS_NODE=2
  # MECAB_EOS_NODE=3

end


class Mecab
  @mecab=nil
  def initialize(args)
    @mecab=MecabImporter.mecab_new2(args)
  end

  # バージョン
  # def version()
  #   MecabImporter.mecab_version()
  # end

  # エラー処理
  def strerror()
    MecabImporter.mecab_strerror(@mecab)
  end


  def sparse_tostr(input)
    MecabImporter.mecab_sparse_tostr(@mecab,input)
  end
  
  def nbest_sparse_tostr(nbest,input)
    MecabImporter.mecab_nbest_sparse_tostr(@mecab,nbest,input)
  end
  
  def nbest_init(input)
    MecabImporter.mecab_nbest_init(@mecab,input)
  end
  
  def nbest_next_tostr()
    MecabImporter.mecab_nbest_next_tostr(@mecab)
  end
  
  def sparse_tonode(input)
    Node.new MecabImporter.mecab_sparse_tonode(@mecab, input)
  end
  
  def destroy()
    MecabImporter.mecab_destroy(@mecab)
  end
  
  class Node
    def initialize(inner)
      @prev, @next, @enext, @bnext, @rpath, @lpath, @surface, @feature, @id, @length, @rlength, @rcAttr, @lcAttr, @posid, @char_type, @stat, @isbest, @alpha, @beta, @prob, @wcost, @cost = inner.to_s(MecabImporter::MecabNode.size).unpack('L!8I!S!5C3f3s!l!')
    end
    
    def prev
      Node.new Fiddle::Pointer[@prev] unless @prev == 0
    end

    def next
      Node.new Fiddle::Pointer[@next] unless @next == 0
    end

    def enext
      Node.new Fiddle::Pointer[@enext] unless @enext == 0
    end

    def bnext
      Node.new Fiddle::Pointer[@bnext] unless @bnext == 0
    end
    
    def rpath
      Path.new Fiddle::Pointer[@rpath] unless @rpath == 0
    end

    def lpath
      Path.new Fiddle::Pointer[@lpath] unless @lpath == 0
    end
    
    def surface
      Fiddle::Pointer[@surface].to_s(@length) unless @surface == 0
    end

    def feature
      Fiddle::Pointer[@feature].to_s unless @feature == 0
    end

    attr_accessor :length, :rlength, :id, :rcAttr, :lcAttr, :posid, :char_type, :stat, :isbest, :alpha, :beta, :prob, :wcost, :cost
  end
  
  class Path
    def initialize(inner)
      @rnode, @rnext, @lnode, @lnext, @cost, @prob = inner.to_s(MecabImporter::MecabPath.size).unpack('L!4i!f')
    end
    
    def rnode
      Node.new Fiddle::Pointer[@rnode] unless @rnode == 0
    end

    def rnext
      Path.new Fiddle::Pointer[@rnext] unless @rnext == 0
    end

    def lnode
      Node.new Fiddle::Pointer[@lnode] unless @lnode == 0
    end

    def lnext
      Path.new Fiddle::Pointer[@lnext] unless @lnext == 0
    end

    attr_accessor :cost, :prob
  end
end
# ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲形態素解析▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲
# ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲


# ---------------------ここからMorph（形態素）モジュール---------
module Morph
#   # ここでMecabモジュールの初期化を行う
  def init_analyzer
#     # Mecab::setargで起動オプションの指定
    @mecab::setarg('-F%m %P-\t');
#     # -区切りの品詞情報をタブで区切って出力
  end

# # textで受け取った品詞情報のペアの配列をつくる
  def analyze(input)

      m = Mecab.new("")
      # mに解析の命令を代入して初期化

#     # init_analyzerが設定した出力形式により得た文章を分解して
#     # 形態素と品詞のペアの配列を作成する
    return m.sparse_tostr.chomp.split(/t/).map do |part|
        part.split(/ /)
    end
    # ここにMecabで解析した形態素と品詞情報をsplitしてmapで配列の配列にしたいのだが....

  end

  def keyword?(part)
    return /名詞-(一般|固有名詞|サ変接続|形容動詞語幹)/ =~ part
  end


  module_function :init_analyzer, :analyze, :keyword?
end
# ---------------------Morph（形態素）モジュールここまで---------




# ---------------------ここからDictionaryクラスの定義開始---------
class Dictionary
    def initialize
      # オブジェクト作成時に空の配列を作成↓

  # ランダムな返答を返すための配列
  @random = []

  # 以下でopenメソッドにファイル名を引数として渡す
    open('dics/random.txt') do |f|


    # eachメソッドを使ってfの要素として順に取り出すループ
      f.each do |line|
      # ------------繰り返し処理-----------------------
      # 取り出した行の改行を消す
      line.chomp!

      # 次の行が空行でないか見て、空行ならnextで次へ
      next if line.empty?
      # ここで空行じゃない文字列を配列"@random"にpushしていく
      @random.push(line)
      # -------------繰り返し終了----------------------
      end
    end


  # パターンに反応した返事の配列（ハッシュ）
  @pattern = []

  open('dics/pattern.txt') do |f|
      f.each do |line|
    # ------------繰り返し処理-----------------------
    # 各行の改行をなくして「タブ」を表す正規表現"/t"で区切る
    # 区切った文字列を"pattern"と"phrases"に代入（ハッシュ化していく）
    pattern, phrases = line.chomp.split("\t")

    # 次の行が存在するかを見て、存在しない場合はnextで次へ
    next if pattern.nil? or phrases.nil?

    # "pattern"と"phrases"をハッシュ内の"pattern"と"phrases"に再代入（多重代入）


    @pattern.push(PatternItem.new(pattern.encode!("utf-8"), phrases.encode!("utf-8")))

            # @pattern.push({'pattern'=>pattern.encode!("utf-8"), 'phrases'=>phrases.encode!("utf-8")})
            #
            # ここで結構つまづいた！！ 多重代入の時は再度エンコードしないと上手くいきません！
            #経緯としては、(Sjisを)getsで受け取り、UTF8に変換→ライブラリ内文字列(SJIS)とマッチさせた後に、
            #再度UTF8で出力するという事を行っています。これを行わないと、文字化けしたものをto_sしようとして落ちます
            #
            # 
    # -------------繰り返し終了----------------------
    end
  end

    def study(input)
      return if @random.include?(input)
      @random.push(input)
    end

    def save
      open('dics/random.txt', 'w') do |f|
        f.puts(@random)
      end
    end
  end

  # 外部オブジェクトからそれぞれにアクセスする為のメソッド（アクセサ）
  attr_reader :random, :pattern
  # 従来のattr_readerを使わない方法
  #   def random
  #     return @random
  #   end
  #   def pattern
  #     return @pattern
  #   end

end

# -------------------PatternItemクラスここから-----------
# パターン辞書1行の情報を保持して、内部情報を管理する
class PatternItem

  SEPARATOR = /^((-?\d+)##)?(.*)$/
# 初めにSEPARATORを正規表現によって初期化
# 辞書内に設定している文が 5(数値)##|（文字列） という形式なので
# （-の有無と数値##）何かしら文字列）という正規表現を適用

def initialize(pattern, phrases)
  SEPARATOR =~ pattern
    # pattern内に数値＋文字列のパターンが入っているか
    # 後方参照でパターンマッチを行う

    @modify, @pattern = $2.to_i, $3
    # 上で取り出した機嫌変動値とパターンを数値クラスに変換して
    # @modifyに代入。文字列を@patternに代入している

# 応答するための配列
@phrases = []

phrases.split('|').each do |phrase|
      # 辞書内から取り出した1行を|で切り分ける
      SEPARATOR =~ phrase
      # phraseをSEPARATORの後方参照でマッチさせる
      @phrases.push({"need"=>$2.to_i, "phrase"=>$3})
    # ハッシュとして＄２(必要機嫌値)と＄３(応答例)を追加
  end
end

def match(str)
  return str.match(@pattern)
    # 引数で受け取っておいたstrを@patternの正規表現と
    # パターンマッチして結果を返す
  end

  def choice(mood)
    # moodを引数にパターンがマッチした際にどの応答を返すかを決めるメソッド
    choices = []

    @phrases.each do |p|
      # @phraseに保持されるハッシュ一つ一つチェックするループ
      choices.push(p["phrase"]) if suitable?(p["need"], mood)
      # 機嫌値の条件を満たす応答のみchoicesにpushされる
    end
    return (choices.empty?)? nil : select_random(choices)
    # eachが終わった時にchoicesからランダムで応答を選ぶ。
    # 応答内容をn回前と同じにしたくない時などは、回答ログ作成の元
    # ここに読ませて、避ける処理を入力するかも？
  end

  def suitable?(need,mood)
    return true if need == 0
    if need > 0
      # suitable?により機嫌値needが０の時は無条件に選択候補にして
      return mood > need
    else
      return mood < need
      # それ以外の時を機嫌値と必要機嫌値の関係(< or >)を判定する
    end
  end

  attr_reader :modify, :pattern, :phrases
end
# -------------------PatternItemクラスここまで-----------



# ---------------------ここまでDictionaryクラス---------

# ※※※※※※※※※※　※※※※※※※※※※※※　※※※※※※※※※
# ※※※※※※※※※※※　返答処理クラスエリア　※※※※※※※※※※
# ※※※※※※※※※※※※　※※※※※※※※　※※※※※※※※※※※
# - - - - - - - - - - - - - 　- - - - - - 　- - - - - - - - - - -
# ---------------------ここからResponderクラスの定義開始---------
class Responder

  def initialize(name, dictionary)
    # オブジェクトを作成時に必ず実行したい処理は↓
    # 自分自身の名前を受け取りインスタンス変数@nameに保持させる
    @name = name
    @dictionary = dictionary
  end

# ここが応答メソッドとなる responseメソッド
def response(input, mood)
    # 感情値の実装によりmoodを追加している

    #ここではインプットされる言葉に対し、文字列を返すところ
    return ''
  end
# 応答メソッドおしまい

# このnameオブジェクトはresponderオブジェクトを公開する為のメソッド
attr_reader :name
  # def name
  #   return @name
  # end

end
# ---------------------ここまでResponderクラス-------------



# ---------------------WhatResponderクラス始まり-------------
# Responderクラスを継承した新たなResponseクラス
# ここのWhatResponderでは、入力に対して同じ事を返す
class WhatResponder < Responder
  # ここが応答メソッドとなる responseメソッド
  def response(input, mood)
    # 入力文字に対して"ってなに"を付けて返す
    return "#{input}ってなに？"
  end
end
# ---------------------WhatResponderクラスおしまい-------------
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ---------------------RandomResponderクラス始まり-------------
# Responderクラスを継承した新たな別のResponseクラス
# ここのRandomResponderでは"@responses"に入っている文字列をランダムで返す
class RandomResponder < Responder
  # ここが応答メソッドとなる responseメソッド
  # ここでgetsしたinputに対する反応を設定する
  def response(input, mood)
# 設定辞書を配列化した@dictionaryの中からランダムで一つ返す
return select_random(@dictionary.random)
end
end
# ---------------------RandomResponderクラスおしまい-------------
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ---------------------PatternResponderクラス始まり-------------
class PatternResponder < Responder
  # ここが発言パターンを見て返答する responseメソッド
  def response(input, mood)

    @dictionary.pattern.each do |ptn_item|
# ------------繰り返し処理-----------------------
if m = ptn_item.match(input.encode!("utf-8"))
      # if m = input.match(ptn_item["pattern"].encode!("utf-8"))
        # matchメソッドに正規表現"ptn_item['pattern']"を渡してマッチするかを判定
        # ！！ここでは2重に文字を渡すため、再度エンコードの必要があるもよう！！

        #　パターンマッチする場合、↓へ。しない場合↑のeachの最初から　

        # ptn_item['phrases']を配列として｜で区切って、その配列内からランダムで選択
        # resp = select_random(ptn_item["phrases"].split("|"))
        resp = ptn_item.choice(mood).encode!("utf-8")
        next if resp.nil?

        # gsubで第1引数でマッチした文字列を第2引数ですべて置き換えて
        # 置き換えた結果を、to_sで文字列として返す。
        return resp.gsub(/%match%/, m.to_s.encode!("utf-8"))
        # if内のreturnの為、パターンマッチした応答の作成完了時に終了
        # エンコードしとかないとエラーでるんです
        #（windows だから ... ？）
# -------------繰り返し終了----------------------

end
end
  # パターンマッチが行われなかった場合にランダム辞書から応答
  return select_random(@dictionary.random)
# ---------------------PatternResponderクラスおしまい-------------

end
end
# - - - - - - - - - - - - - 　- - - - - - - 　- - - - - - - - - -
# ※※※※※※※※※※※※　※※※※※※※※※　※※※※※※※※※※
# ※※※※※※※※※※※　返答処理クラスここまで　※※※※※※※※※※
# ※※※※※※※※※※　※※※※※※※※※※※※※　※※※※※※※※



# ---------------------ここからUnmoクラスの定義開始-------------


class Unmo

  def initialize(name)
    # オブジェクトを作成時に必ず実行したい処理は↓

    @name = name
    # 自分自身の名前を受け取りインスタンス変数@nameに保持させる

    @dictionary = Dictionary.new
    # Dictionary インスタンスを作り、@resp_what @resp_random @resp_patternのそれぞれに渡す準備

    @emotion = Emotion.new(@dictionary)

    @resp_what = WhatResponder.new("What", @dictionary)
    # WhatResponder インスタンスを作り、インスタンス変数 @resp_whatに保持

    @resp_random = RandomResponder.new("Random", @dictionary)
    # RandomResponder インスタンスを作り、インスタンス変数 @resp_randomに保持

    @resp_pattern = PatternResponder.new("Pattern", @dictionary)
    # インスタンス変数@responder に 初期値として@resp_randomを入れておく


    # @responderは現在選択されているResponder
    @responder = @resp_pattern
  end

# ここが対話メソッドとなる dialogueメソッド
def dialogue(input)
  @emotion.update(input)
  parts = Morph::analyze(input)

  case rand(100)
      # 以前0か1を受け取って出力していた処理を今回は、0～100で行っています
      # 今回は分岐の詳細を、ランダムで取れる数値の範囲指定で処理を分けています

    when 0..70
      @responder = @resp_pattern
      # ここでパターンを確率を選んでいます。（0～55なので約60%の確立でパターンを返します）
      # 同時にパターンマッチする言葉を掛けても約40%の確率でパターンを返さない事でもあります

    when 71..94
      @responder = @resp_random
      # ここでランダムな返事を返します（56～94なので約30%の確率）


    else
      @responder = @resp_what
      # 上記で設定した数字以外の場合に "～ってなに？" を返します。

    end
# このメソッドの最後で@responderに対して
# responseメソッドを呼び出す
# return @responder.response(input, @emotion.mood)

resp = @responder.response(input, @emotion.mood)
@dictionary.study(input)
  return resp
end
def save
  @dictionary.save
end
  # dialogueメソッドここまで

  def responder_name
    return @responder.name
  end

  def mood
    return @emotion.mood
  end

  attr_reader :name
end

# ---------------------Unmoの感情クラス-------------
class Emotion

# ここで機嫌値を増減させている
# ここで設定した値は、ここ以降で書き直したり
# 再代入を行ってはいけないので定数として設定しておく
MOOD_MIN = -15
  # 機嫌の最小値

  MOOD_MAX = 15
  # 機嫌の最大値

  MOOD_RECOVERY = 0.5
  # 機嫌の回復値（戻る大きさ）


  # 以下のパラメーターは実装予定の機嫌値

  # COLOR_MIN = -15
  # COLOR_MAX = 15
  # COLOR_RECOVERY = 0.5

  # EMOTE_MIN = -15
  # EMOTE_MAX = 15
  # EMOTE_RECOVERY = 0.5

  # MOTION_MIN = -15
  # MOTION_MAX = 15
  # MOTION_RECOVERY = 0.5

# ※ここでの機嫌回復値は、特定の日に大きくしたい
# 例としては、0に向かって1～3.5戻る。機嫌が+1の時に
# 3.5のRECOVERYが行われると、機嫌値が-2.5になる。

# メモ：現時点での予定しているのは、この4要素を、
# 外的な感情と内的な感情として分類しようと思っている。
# 機嫌/mood・気色/color・気分(体調など)/emote・情動性/motion
# この中で、mood/motion は外的感情＋－、color/emoteは内的感情＋－とする

def initialize(dictionary)
# 以下をオブジェクト作成時に呼び出す
@dictionary = dictionary
    # パターン辞書内に予め設定してある、
    # 機嫌変動の増減値(Integer)を"参照"するため辞書と繋いでおく

    @mood = 0
    # moodの初期値を設定。ここでは0を初期値に設定する。


# 以下のパラメーターは実装予定の機嫌の初期値
    # @color = 0
    # @emote = 0
    # @motion = 0

# ※機嫌の初期値に関しては、可能であれば最終起動終了日時=n に対して
# +8時間ほど最終機嫌値を保持させ、特定の日にはランダムで増減させ、
# 起動時はデフォルトで各パラメーターに0～0.5が入っていて欲しい。

end



def update(input)
# 対話の度に呼び出されるメソッド。パターン辞書にマッチさせて
# 現在の機嫌値を変動させるためのメソッド

@dictionary.pattern.each do |ptn_item|

      # patternitemは辞書内にある1行分の情報を指す
      if ptn_item.match(input)
        # ユーザーの入力から辞書内の情報とのマッチを行い
        # マッチした場合、機嫌値を次の命令に渡す。

        adjust_mood(ptn_item.modify)
        # ここで機嫌値のパラメーターを変動させる命令
        # modifyメソッドは機嫌の値を返す

        break
      end
    end

    if @mood < 0
      @mood += MOOD_RECOVERY
    elsif @mood > 0
      @mood -= MOOD_RECOVERY
    end
# ここで現在のステータス上の機嫌をRECOVERYする処理
# 0より小さければRECOVERYで設定した値の分だけプラスして
# 0より大きければRECOVERYで設定した値の分だけマイナス

# 以下に実装予定の同様の処理
#     if @color < 0
#       @color += COLOR_RECOVERY
#     elsif @color > 0
#       @color -= COLOR_RECOVERY
#     end
#     if @emote < 0
#       @emote += EMOTE_RECOVERY
#     elsif @emote > 0
#       @emote -= EMOTE_RECOVERY
#     end
#     if @motion < 0
#       @motion += MOTION_RECOVERY
#     elsif @motion > 0
#       @motion -= MOTION_RECOVERY
#     end
end

def adjust_mood(val)
    # Emotion(感情)クラスで初期値を設定した感情から現行の値を変動させます

    @mood += val
    # 引数valに従って値を増減

    if @mood > MOOD_MAX
      @mood = MOOD_MAX
    elsif @mood < MOOD_MIN
      @mood = MOOD_MIN
    end
    # 最大値と最低値と比較して、設定された範囲内の値に収まる様に調整

    # @color += val
    # if @color > COLOR_MAX
    #   @color = COLOR_MAX
    # elsif @color < COLOR_MIN
    #   @color = COLOR_MIN
    # end

    # @emote += val
    # if @emote > EMOTE_MAX
    #   @emote = EMOTE_MAX
    # elsif @emote < EMOTE_MIN
    #   @emote = EMOTE_MIN
    # end

    # @motion += val
    # if @motion > MOTION_MAX
    #   motiond = MOTION_MAX
    # elsif @motion < MOTION_MIN
    #   @motion = MOTION_MIN
    # end
  end

  attr_reader :mood
  # アクセサを定義

end

def select_random(ary)
  return ary[rand(ary.size)]
end
# ---------------------Unmoの感情クラスここまで-------------

# ---------------------ここまでUnmoクラス-------------

# promptメソッド
def prompt(unmo)
  # 出力処理を記述の際に prompt(proto) と明示するための処理
  return unmo.name + ':' + unmo.responder_name + '>'




  def construct


    @souvenir = Unmo.new('bot')



    @souvenir = ["Unmo System : #{@souvenir.name} Log -- #{Time.now}"]
  end


  def self_destroy
    @souvenir.save

    open('log.txt', 'a') do |f|
      f.puts(@log)
      f.puts
    end
  end


  def putlog(log)
    @log_area.text += "#{log}\n"
    @log_area.scrollTo(@log_area.countLines-1, 1)
    @log.push(log)
  end


end


# -------------ここから実行した時の出力処理始まり------------

 m = Mecab.new("")
 # mに解析の命令を代入して初期化



# プログラムタイトルの表示
puts ('Unmo System prototype : proto')
# Unmoオブジェクトを作成
#ここが返答botの名前
proto = Unmo.new('bot')

  # 条件が真である間は繰り返すループ
  while true

# ＞を表示することで入力待ちを知らせる
print(">")

  # 入力を変数inputに代入
  input = gets.encode!("utf-8")
#   regexpエラーに悩まされた時のデバック跡↓
# puts input
# puts input.encode!("utf-8")
  # 改行の削除
  input.chomp!

# 文字のチェック。空の文字が入力されたら終了
break if input == ""
 analyz = m.sparse_tostr(input)
# dialogueメソッドにより入力文字列を引数として呼び出し
# 戻り値をresponseという変数に代入
response = proto.dialogue(input)
puts "--------------------------------------"
puts "■入力文字確認"
  ary = ["#{analyz}".chomp.split(/t/).map do |part|
        part.split(/ /)
        # return /名詞-(一般|固有名詞|サ変接続|形容動詞語幹)/ =~ ary
        end
      ]


      # def keyword?(part)
      # return /名詞-(一般|固有名詞|サ変接続|形容動詞語幹)/ =~ part
      # module_function :keyword?
      # end
      # puts keyword?

 # ary = ["#{analyz}".split("\n").map{|i| i.split("\t")}.tap{|arr| arr.pop}.map{|i| [ i[0], i[1].split(',') ]}]
 # ary1 = [ary[0], ary[1].split(",")]
puts ary

# def ary1(ary)
  # arys.each do |ary|
  # return(/名詞-(一般|固有名詞|サ変接続|形容動詞語幹)/ =~ ary)

# def split_ary(ary)
#   return /名詞-(一般|固有名詞|サ変接続|形容動詞語幹)/ =~ ary
# end



puts "--------------------------------------"
# puts @mecab
# puts Mecab
   # promptを＋で付けてresponseメソッドで定義した応答を表示
  # puts(prompt(proto) + response)
  res = (prompt(proto) + response)
  puts res
end





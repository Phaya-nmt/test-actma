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
  MECAB_EOS_NODE=3
end

class Mecab
  @mecab=nil
  def initialize(args)
    @mecab=MecabImporter.mecab_new2(args)
  end
  
  def version()
    MecabImporter.mecab_version()
  end
  
  def strerror()
    MecabImporter.mecab_strerror(@mecab)
  end
  
  def sparse_tostr(str)
    MecabImporter.mecab_sparse_tostr(@mecab,str)
  end
  
  def nbest_sparse_tostr(nbest,str)
    MecabImporter.mecab_nbest_sparse_tostr(@mecab,nbest,str)
  end
  
  def nbest_init(str)
    MecabImporter.mecab_nbest_init(@mecab,str)
  end
  
  def nbest_next_tostr()
    MecabImporter.mecab_nbest_next_tostr(@mecab)
  end
  
  def sparse_tonode(str)
    Node.new MecabImporter.mecab_sparse_tonode(@mecab, str)
  end
  
  def destroy()
    MecabImporter.mecab_destroy(@mecab)
  end
  
  class Node
    def initialize(inner)
      @prev, @next, @enext, @bnext, @rpath, @lpath, @surface, @feature, @id, @length, @rlength, @rcAttr, @lcAttr, @posid, @char_type, @stat, @isbest, @alpha, @beta, @prob, @wcost, @cost = inner.to_s(MecabImporter::MecabNode.size).unpack('L!8I!S!5C3f3s!l!')
    end
    
    def prev; Node.new Fiddle::Pointer[@prev] unless @prev == 0 end
    def next; Node.new Fiddle::Pointer[@next] unless @next == 0; end
    def enext; Node.new Fiddle::Pointer[@enext] unless @enext == 0; end
    def bnext; Node.new Fiddle::Pointer[@bnext] unless @bnext == 0; end
    
    def rpath; Path.new Fiddle::Pointer[@rpath] unless @rpath == 0; end
    def lpath; Path.new Fiddle::Pointer[@lpath] unless @lpath == 0; end
    
    def surface; Fiddle::Pointer[@surface].to_s(@length) unless @surface == 0; end
    def feature; Fiddle::Pointer[@feature].to_s unless @feature == 0; end

    attr_accessor :length, :rlength, :id, :rcAttr, :lcAttr, :posid, :char_type, :stat, :isbest, :alpha, :beta, :prob, :wcost, :cost
  end
  
  class Path
    def initialize(inner)
      @rnode, @rnext, @lnode, @lnext, @cost, @prob = inner.to_s(MecabImporter::MecabPath.size).unpack('L!4i!f')
    end
    
    def rnode; Node.new Fiddle::Pointer[@rnode] unless @rnode == 0; end
    def rnext; Path.new Fiddle::Pointer[@rnext] unless @rnext == 0; end
    def lnode; Node.new Fiddle::Pointer[@lnode] unless @lnode == 0; end
    def lnext; Path.new Fiddle::Pointer[@lnext] unless @lnext == 0; end

    attr_accessor :cost, :prob
  end
end

# # sample
begin
 m = Mecab.new("")
 # 指定範囲を解析
 word = gets.encode!("utf-8")
 # 文字を入力から受け取ってエンコードした物をwordに代入
 
 # puts m.version
 puts m.sparse_tostr(word)
 # node = m.sparse_tonode("本日は晴天なり")
#  while (node = node.next)
#    print node.surface += " : " + node.posid.to_s += "\n"
#  end
# ensure
#  m.destroy
end

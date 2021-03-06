class Midia < ActiveRecord::Base
  has_many :possuis, :dependent => :destroy
  has_many :dpus, :dependent => :destroy
  belongs_to :genero
  belongs_to :localizacao
  has_many :tombos, :dependent => :destroy
  after_create :multi_tombo, :cria_possui_md, :auto_inc_tombo_seduc, :cria_disponibiliza_md
  attr_accessor :qtde_midias, :lista_tombos, :usuario, :unidade

  has_and_belongs_to_many :musicas
  has_and_belongs_to_many :cantores
  validates_presence_of :lista_tombos, :if => :qtde?
  validates_presence_of :genero_id
  validates_presence_of :localizacao_id
  validates_presence_of :titulo
  validates_presence_of :tipo
  validates_presence_of :subtitulo
  TIPO = %w(CD DVD VHS OUTRAS)


  def qtde?
    self.qtde_midias == 1
  end
  def multi_tombo
    multi = Tombo.new
    multi.midia_id = self.id
    multi.user_id = self.usuario
    multi.index_tombo = "#{self.id} - #{self.usuario}"
    multi.qtde_livro = self.qtde_midias
    multi.save
  end
  def auto_inc_tombo_seduc
    self.tombo_seduc = self.id
  end
  def cria_possui_md
    possui = Possui.new
    possui.unidade_id = self.unidade
    possui.tombo = "md-#{self.tombo_l}"
    #possui.midia_id = self.id
    possui.status = 1
    possui.save
  end

  def cria_disponibiliza_md
    disp = Dpu.new
    disp.unidade_id = self.unidade
    disp.tombo = "md-#{self.tombo_l}"
    #disp.midia_id = self.id
    disp.status = 1
    disp.save
  end


end

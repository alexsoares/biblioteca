class DicionarioEnciclopediasController < ApplicationController

  before_filter :login_required
  before_filter :load_resources

  
  def index
    @dicionario_enciclopedias = DicionarioEnciclopedia.all
  end

  def show
    @dicionario_enciclopedia = DicionarioEnciclopedia.find(params[:id])
  end

  def new
    @dicionario_enciclopedia = DicionarioEnciclopedia.new
  end

  def create
    @dicionario_enciclopedia = DicionarioEnciclopedia.new(params[:dicionario_enciclopedia])
    if @dicionario_enciclopedia.save
      flash[:notice] = "CADASTRADO COM SUCESSO."
      redirect_to @dicionario_enciclopedia
    else
      render :action => 'new'
    end
  end

  def edit
    @dicionario_enciclopedia = DicionarioEnciclopedia.find(params[:id])
  end

  def update
    @dicionario_enciclopedia = DicionarioEnciclopedia.find(params[:id])
    if @dicionario_enciclopedia.update_attributes(params[:dicionario_enciclopedia])
      flash[:notice] = "CADASTRADO COM SUCESSO."
      redirect_to @dicionario_enciclopedia
    else
      render :action => 'edit'
    end
  end

  def destroy
    @dicionario_enciclopedia = DicionarioEnciclopedia.find(params[:id])
    @dicionario_enciclopedia.destroy
    flash[:notice] = "EXCLUIDO COM SUCESSO."
    redirect_to dicionario_enciclopedias_url
  end

 def subtitulo
  session[:subtitulo] = params[:dicionario_enciclopedia_identificacao_id]
  @dicionario_enciclopedia = DicionarioEnciclopedia.find_by_identificacao_id(session[:subtitulo])
  render :partial => 'subtitulo'
  end


    protected

  def load_resources
    @areas = Area.all(:order => 'nome ASC')
    @editoras = Editora.all(:order => 'nome ASC')
    @localizacoes = Localizacao.all
    @identificacoes  = Identificacao.all(:order => 'livro ASC')
  end

end

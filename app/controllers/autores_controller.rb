class AutoresController < ApplicationController

 before_filter :load_resources

  def index
    @autores = Autor.paginate :page => params[:page], :order => 'nome ASC', :per_page => 20
    
  end

  def show
    @autor = Autor.find(params[:id])
  end

  def new
    @autor = Autor.new
  end

  def create
    @autor = Autor.new(params[:autor])
    if @autor.save
      flash[:notice] = "CADASTRADO COM SUCESSO."
      redirect_to @autor
    else
      render :action => 'new'
    end
  end

  def edit
    @autor = Autor.find(params[:id])
  end

  def update
    @autor = Autor.find(params[:id])
    if @autor.update_attributes(params[:autor])
      flash[:notice] = "CADASTRADO COM SUCESSO."
      redirect_to @autor
    else
      render :action => 'edit'
    end
  end

  def destroy
    @autor = Autor.find(params[:id])
    @autor.destroy
    flash[:notice] = "EXCLUIDO COM SUCESSO."
    redirect_to autores_url
  end

  def consulta_aut_liv    
  end


  def consultaAut
  unless params[:search].present?
    if params[:type_of].to_i == 3
      @contador = Autor.all.count
      @autores = Autor.paginate :all,:page => params[:page], :order => 'nome ASC', :per_page => 22
      render :update do |page|
        page.replace_html 'autores', :partial => "autores"
      end
    end
  else
    if params[:type_of].to_i == 1
      @contador = Autor.all(:conditions => ["nome like ?", "%" + params[:search].to_s + "%"]).count
      @autores = Autor.paginate :all, :page => params[:page], :per_page => 20, :conditions => ["nome like ?", "%" + params[:search].to_s + "%"],:order => 'nome ASC'
      render :update do |page|
        page.replace_html 'autores', :partial => "autores"
      end
    end
  end
end


def consulta_autor_livro
       session[:autor] = params[:autor_id]
       @autores = Autor.find(session[:autor])
       render :update do |page|
         page.replace_html 'dadosautores', :partial => "autores_livros"
      end
  end
protected

  def load_resources
        @autores= Autor.all(:order => 'nome ASC')
  end
end

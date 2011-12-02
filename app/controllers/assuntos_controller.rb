class AssuntosController < ApplicationController
  def index
    @assuntos = Assunto.all
  end

  def show
    @assunto = Assunto.find(params[:id])
  end

  def new
    @assunto = Assunto.new
  end

  def create
    @assunto = Assunto.new(params[:assunto])
    if @assunto.save
      flash[:notice] = "CADASTRADO COM SUCESSO."
      render :action => 'livros/new'
      
    else
      render :action => 'new'
    end
  end

  def edit
    @assunto = Assunto.find(params[:id])
  end

  def update
    @assunto = Assunto.find(params[:id])
    if @assunto.update_attributes(params[:assunto])
      flash[:notice] = "CADASTRADO COM SUCESSO."
      redirect_to @assunto
    else
      render :action => 'edit'
    end
  end

  def destroy
    @assunto = Assunto.find(params[:id])
    @assunto.destroy
    flash[:notice] = "EXCLUIDO COM SUCESSO."
    redirect_to assuntos_url
  end
end

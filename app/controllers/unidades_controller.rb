class UnidadesController < ApplicationController
  
  def index
    @unidades = Unidade.all
  end

  def show
    @unidade = Unidade.find(params[:id])
  end

  def new
    @unidade = Unidade.new
  end

  def create
    @unidade = Unidade.new(params[:unidade])
    if @unidade.save
      flash[:notice] = "CADASTRADO COM SUCESSO."
      redirect_to @unidade
    else
      render :action => 'new'
    end
  end

  def edit
    @unidade = Unidade.find(params[:id])
  end

  def update
    @unidade = Unidade.find(params[:id])
    if @unidade.update_attributes(params[:unidade])
      flash[:notice] = "CADASTRADO COM SUCESSO."
      redirect_to @unidade
    else
      render :action => 'edit'
    end
  end

  def destroy
    @unidade = Unidade.find(params[:id])
    @unidade.destroy
    flash[:notice] = "EXCLUIDO COM SUCESSO."
    redirect_to unidades_url
  end
end

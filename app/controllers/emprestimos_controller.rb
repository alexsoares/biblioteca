class EmprestimosController < ApplicationController
  before_filter :load_resources
  def index
    @emprestimos = Emprestimo.all(:conditions => ["unidade_id = ? and status = 1", current_user.unidade_id])
  end

  def show
    @emprestimo = Emprestimo.find(params[:id])
  end

  def busca_tombo
    @dpu = Dpu.find(:all,:include => [:livro => [:localizacao]], :conditions => ["livros.tombo_l = ? and localizacoes.unidade_id = ? and dpus.status = ?", params[:tombo], current_user.unidade_id,1])
     render :update do |page|
       page.replace_html 'selecao', :partial => "carrinho"
     end
  end

  def retorna_busca
    @cart = current_cart
  end

  def aviso_duplicado
     render :update do |page|
       page.replace_html 'erro', :text => "Tombo duplicado ou inexistente"
     end
  end

  def filtros
  if params[:filtro_ambos].present?
    filtro = params[:filtro_ambos]
  else
    if params[:filtro_0].present?
      filtro = params[:filtro_0]
    else
      if params[:filtro_1].present?
        filtro = params[:filtro_1]
      end
    end
  end
   if (filtro.to_i == 2)
     @disponiveis = Dpu.all(:include => [{:dicionario_enciclopedia =>[:identificacao],:livro =>[:identificacao]}],:conditions => ["(dpus.dicionario_enciclopedia_id is not null or dpus.livro_id is not null) and dpus.status = 1 and dpus.unidade_id = ?", current_user.unidade_id],:order => 'identificacaos.livro ASC')
   else
     if filtro.to_i == 0
       @disponiveis = Dpu.all(:include => [:livro =>[:identificacao]],:conditions => ["(dpus.livro_id is not null) and dpus.status = 1 and dpus.unidade_id = ?", current_user.unidade_id], :order => 'identificacaos.livro ASC')
     else
       if filtro.to_i == 1
         @disponiveis = Dpu.all(:include => [:dicionario_enciclopedia =>[:identificacao]],:conditions => ["(dpus.dicionario_enciclopedia_id is not null) and dpus.status = 1 and dpus.unidade_id = ? and dpus.dicionario_enciclopedia_id is not null", current_user.unidade_id],:order => 'identificacaos.livro ASC')
       end
     end
   end
     render :update do |page|
       page.replace_html 'fields', :partial => "lista_dpu"
     end
  end


  def new    
    @emprestimo = Emprestimo.new
    @dpu = Dpu.all(:limit => 5)
    @cart = current_cart
    define_ambiente
  end

  def define_ambiente
    ambiente = Ambiente.find_by_user_id(current_user.id)
    if ambiente.present?
      session[:classe] = ambiente.turma_id
      session[:desc_classe] = Aluno.find_by_id_classe(ambiente.turma_id).classe_descricao
      session[:ano_letivo] = ambiente.ano_letivo
    end
  end
  def create
    @emprestimo = Emprestimo.new(params[:emprestimo])
    @emprestimo.unidade_id = current_user.unidade_id
    @emprestimo.pessoa = session[:pessoa]
    if (session[:pessoa]).present?
      if @emprestimo.save
        salvar(@emprestimo.id)

#        Log.gera_log("CRIACAO", "EMPRESTIMO", current_user.id , @emprestimo.id)
        flash[:notice] = "EMPRÉSTIMO REALIZADO COM SUCESSO."
        redirect_to @emprestimo
        session[:pessoa] = nil
        session[:emprestimo] = nil
      else
        render :action => 'new'
      end
    else
      flash[:notice] = "Problemas no emprestimo. Selecione um aluno/funcionario."
      render :action => 'new'
    end
  end



  def salvar(emprestimo)
        current_cart.cart_items.each do |z|
          nv = DpusEmprestimo.new
            nv.dpu_id = z.dpu_id
            nv.emprestimo_id = emprestimo
          nv.save
          desabilita_dpu(z.dpu_id)
          z.destroy
        end
  end

  def desabilita_dpu(dpu)
    livro = Dpu.find(dpu)
      livro.status = 0
      livro.livro.status = 0
    livro.save
  end



  def edit
    @emprestimo = Emprestimo.find(params[:id])
    @disponiveis = Dpu.all(:include => [{:livro =>[:identificacao]},{:dicionario_enciclopedia => [:identificacao]}],:conditions => ["(livro_id is not null or dicionario_enciclopedia_id is not null) and status = 1 and unidade_id = ?", current_user.unidade_id])
    @dpus_selecionados = @emprestimo.dpus
    @disponiveis =  @disponiveis - @dpus_selecionados

  end

  def update
    @emprestimo = Emprestimo.find(params[:id])
    if @emprestimo.update_attributes(params[:emprestimo])
      flash[:notice] = "EMPRESTIMO ATUALIZADO COM SUCESSO."
      redirect_to @emprestimo
    else
      render :action => 'edit'
    end
  end

  def destroy
    @emprestimo = Emprestimo.find(params[:id])
    @emprestimo.destroy
    flash[:notice] = "EXCLUIDO COM SUCESSO."
    redirect_to emprestimos_url
  end

  def busca_emprestimo
  end

  def realiza_busca
    session[:busca_por] = params[:busca_por]
    if params[:busca_por].to_i == 1
      unless params[:search].nil?
        session[:search] = params[:search]
        @emprestimo_ativo = Emprestimo.all(:joins => [:dpus => [:livro]] ,:conditions => ["livros.tombo_l = ? and dpus.unidade_id = ? and emprestimos.status = 1", params[:search],current_user.unidade_id])
      end
    else
      @emprestimo_ativo = Emprestimo.all(:joins => [:dpus],:conditions => ["dpus.unidade_id = ? and emprestimos.status = 1", current_user.unidade_id])
    end
    render :update do |page|
      page.replace_html 'devolucao', :partial => "emprestimo_ativo"
    end
  end

  def busca
    if params[:pessoa].present?
      if params[:pessoa][:nome].present?
       if current_user.unidade.unidades_gpd_id == 15
        @pessoas = Aluno.all(:conditions => ["(classe_ano = ? or classe_ano is null) and (primeiro_nome(nome,1) = primeiro_nome(?,1)) and id_classe = ?",session[:ano_letivo].to_i,params[:pessoa][:nome], session[:classe].to_i])
       else
        @pessoas = Aluno.all(:conditions => ["(classe_ano = ? or classe_ano is null) and (primeiro_nome(nome,1) = primeiro_nome(?,1)) and id_escola = ? and id_classe = ?",session[:ano_letivo].to_i,params[:pessoa][:nome], current_user.unidade.unidades_gpd_id, session[:classe].to_i])
       end
      else
       if current_user.unidade.unidades_gpd_id == 15
        @pessoas = Aluno.all(:conditions => ["(classe_ano = ? or classe_ano is null) and id_classe = ?",session[:ano_letivo].to_i, session[:classe].to_i])
       else
        @pessoas = Aluno.all(:conditions => ["(classe_ano = ? or classe_ano is null and id_escola = ? and id_classe = ?)",session[:ano_letivo].to_i, current_user.unidade.unidades_gpd_id, session[:classe].to_i])
       end
      end
      #@alunos = Aluno.all(:conditions => ["(classe_ano = 2011 or classe_ano is null) and (primeiro_nome(nome,1) = primeiro_nome('JOAO',1) and pes_dtnasc = '2002-01-06')",])
      render :update do |page|
        page.replace_html 'pessoas', :partial => "pessoas"
      end
    end

  end
  def classe
    @alunos = Aluno.all(:conditions => ["id_classe = ? and classe_ano = ?",session[:classe],session[:ano_letivo]])
    if params[:classe].present?
          render :update do |page|
            page.replace_html 'classe', :partial => "listagem"
            page.replace_html 'qtde', :text => "Esta sala contém #{@alunos.count} alunos"
          end
    end
  end

  def retorno
      @pessoa = Aluno.find(params[:pessoa])
      session[:pessoa] = params[:pessoa]
      render :update do |page|        
        page.replace_html 'tipo_emprestimo', :text => @pessoa.nome
      end
  end

  def retorno_livro
      if (params[:tipo]).to_s == 'li'
        objeto = Livro.find(params[:emprestimo])
      else
        if (params[:tipo]).to_s == 'de'
          objeto = DicionarioEnciclopedia.find(params[:emprestimo])
        end
      end
      render :update do |page|
          page.insert_html :bottom, 'retorna_livro', :text => "<li id="+ objeto.identificacao_id.to_s + "> * "+objeto.identificacao.livro + "</li>"
      end
  end

  def dpu
    id = Identificacao.all(:conditions => ["livro like ?",params[:livro][:dcu] + "%"], :select => "id")
    if (params[:livro][:type_of]).to_i == 1
      id_de = DicionarioEnciclopedia.all(:include => [:identificacao],:conditions => ["identificacao_id in (?)",id])
      @disponiveis = Dpu.all(:include => [:dicionario_enciclopedia], :conditions => ["dicionario_enciclopedia_id in (?) and status = 1",id_de])
    else
      if (params[:livro][:type_of]).to_i == 0
        id_livro = Livro.all(:include => [:identificacao],:conditions => ["identificacao_id in (?) and status = 1",id])
        @disponiveis = Dpu.all(:include => [:livro], :conditions => ["livro_id in (?) and status = 1",id_livro])
      end
    end
    if @disponiveis.present?
      render :update do |page|
        page.replace_html 'livros', :partial => "livros_disponiveis",:locals => {:some_variable => "somevalue",:some_other_variable => 5}
      end
    else
      render :update do |page|
        page.replace_html 'livros', :text => "Nenhum exemplar disponivel com este nome nesta unidade. Se desejar consulte entre as unidades"
      end

    end
  end

  def funcionario
      @pessoas = Aluno.all(:conditions => ["nome like ? and matricula_funcionario is not null",params[:funcionario][:nome] + "%"])
      render :update do |page|
        page.replace_html 'pessoas', :partial => "pessoas"
      end
  end

  def devolucao
    @devolucao = Emprestimo.find(params[:id])
  end

  def efetiva_devolver
    @devolucao = Emprestimo.find(params[:id])
    @devolucao.status = 0
    if @devolucao.save
      flash[:notice] = "DEVOLUÇÃO EFETUADA COM SUCESSO."
      redirect_to @devolucao
    end
  end

  def devolve_unit
    e = Dpu.find(params[:id])
    if e.devolve_livro(params[:contador].to_i,params[:emprestimo].to_i)
      if session[:busca_por].to_i == 1
        unless session[:search].nil?
          @emprestimo_ativo = Emprestimo.all(:joins => [:dpus => [:livro]] ,:conditions => ["livros.tombo_l = ? and dpus.unidade_id = ? and emprestimos.status = 1", session[:search],current_user.unidade_id])
        end
      else
        @emprestimo_ativo = Emprestimo.all(:joins => [:dpus],:conditions => ["dpus.unidade_id = ? and emprestimos.status = 1", current_user.unidade_id])
      end
      render :update do |page|
        page.replace_html "stat_dev_#{params[:id]}", :text => ""
        page.replace_html 'devolucao', :partial => "emprestimo_ativo"
      end
    end
  end

  def ativos
    @emprestimos = Emprestimo.paginate(:all,:conditions => ["status = 1 and unidade_id = ?",current_user.unidade], :per_page => 15, :page => params[:page], :order => "id Desc")
  end

  def cria_carrinho
    @cart = current_cart
    current_cart.cart_items.create!(params[:cart_item])
    flash[:notice] = "Livro added to cart"
    session[:last_product_page] = request.env['HTTP_REFERER'] || products_url
    render :update do |page|
      #page.insert_html :bottom,'selecionado', :text => params[:cart].inspect
      page.insert_html :bottom, 'selecionado', :partial => "shared/selecionado"
      page.replace_html 'retorno_livros', :partial => "conteudo"
    end    
  end

  def recibo
    @emprestimo = Emprestimo.find(params[:id])
    render :layout => "recibo"
  end


  def remove_livro
     remove = current_cart.cart_items.find_by_dpu_id(params[:id])
     remove.destroy
     @cart = current_cart
     render :update do |page|
       page.replace_html 'retorno_livros', :partial => "conteudo"
     end
  end

  protected
  def load_resources
    if current_user.unidade_id == 53
      @classes = Aluno.all(:select => "id_classe, classe_descricao, classe_ano, id_escola",:conditions => ["classe_ano = ?", Date.today.strftime("%Y").to_i], :group => ["id_classe,classe_descricao, classe_ano,id_escola"] , :order => "classe_descricao")
    else
      @classes = Aluno.all(:select => "id_classe, classe_descricao, classe_ano, id_escola",:conditions => ["classe_ano = ? and id_escola = ?", Date.today.strftime("%Y").to_i, current_user.unidade.unidades_gpd_id], :group => ["id_classe,classe_descricao, classe_ano,id_escola"] , :order => "classe_descricao")
    end
     #@disponiveis = Dpu.all(:include => [:livro =>[:identificacao]],:conditions => ["(dpus.livro_id is not null) and dpus.status = 1 and dpus.unidade_id = ?", current_user.unidade_id],:order => "identificacaos.livro ASC")
  end
end
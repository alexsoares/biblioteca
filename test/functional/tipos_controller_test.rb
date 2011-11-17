require 'test_helper'

class TiposControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => Tipo.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    Tipo.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    Tipo.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to tipo_url(assigns(:tipo))
  end

  def test_edit
    get :edit, :id => Tipo.first
    assert_template 'edit'
  end

  def test_update_invalid
    Tipo.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Tipo.first
    assert_template 'edit'
  end

  def test_update_valid
    Tipo.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Tipo.first
    assert_redirected_to tipo_url(assigns(:tipo))
  end

  def test_destroy
    tipo = Tipo.first
    delete :destroy, :id => tipo
    assert_redirected_to tipos_url
    assert !Tipo.exists?(tipo.id)
  end
end

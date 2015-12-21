Rails.application.routes.draw do
  get 'admin/index'

  get 'admin' => 'admin#index'
  
  controller :sessions do
    # sessions/new となっていたURLを login に変更
    get  'login' => :new
    post 'login' => :create
    delete 'logout' => :destroy
  end

scope '(:locale)' do
  resource  :session
  resources :examples
  end

  resources :messages do
    resources :comments
  end

  # root 'examples#index'
end


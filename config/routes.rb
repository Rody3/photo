Rails.application.routes.draw do
# 　指定するときにas: でつけた名前の後ろに_path とつける。
  root 'users#top'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'top', to:'users#top', as: :top
  # 通常の指定
  # リンクをつける時にas: で名前をつけてあげる
  # get 'posts/new', to:'posts#new', as: :new_post
  # プロフィールページの指定
  get '/profile/edit' , to: 'users#edit', as: :profile_edit
  get '/profile/:id', to:'users#show', as: :profile
  get '/follower_list/:id' , to: 'users#follower_list', as: :follower_list
  get '/follow_list/:id' , to: 'users#follow_list', as: :follow_list
  get '/sign_up' , to: 'users#sign_up', as: :sign_up
  get '/sign_in' , to: 'users#sign_in', as: :sign_in
  post '/sign_up' , to: 'users#sign_up_process'
  post '/sign_in', to: 'users#sign_in_process'
  get '/sign_out', to: 'users#sign_out', as: :sign_out
  # post '/posts', to: 'posts#create'
  post '/profile/edit', to: 'users#update'
  get '/follow/:id', to: 'users#follow', as: :follow
  # delete '/posts/:id', to: 'posts#destroy', as: :post
  # resourcesメソッドを使った指定
  resources :posts do
    member do
      # いいね
      get 'like', to: 'posts#like', as: :like
    end
  end
  post '/posts/:id/comment', to: 'posts#comment', as: :comment_post
end


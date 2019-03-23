class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
#   コントローラー内でヘルパーを呼び出せる処理
  include UsersHelper
end

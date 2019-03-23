class UsersController < ApplicationController
  before_action :authorize, except: [:sign_up, :sign_up_process, :sign_in, :sign_in_process]
  before_action :redirect_to_top_if_signed_in, only: [:sign_up, :sign_in]
  
    # トップページ
  def top
    if params[:word].present?
      # キーワード検索処理
      @posts = Post.where("caption like ?", "%#{params[:word]}%").order("id desc")
    else
      # 一覧表示処理
      @posts = Post.all.order("id desc").page(params[:page])
    end
    @recommends = User.where.not(id: current_user.id).where.not(id: current_user.follows.pluck(:follow_user_id)).limit(3)
  end
  
  # ユーザー登録ページ
  def sign_up
    # .new で空のユーザークラスを作成する
    @user = User.new
    render layout: "application_not_login"
  end
   
  # ユーザー登録処理
  def sign_up_process
    # ここに処理を実装
    user = User.new(user_params) 
    if user.save
      user_sign_in(user)
      # redirect_to  と　and return　は基本的にセットで使う
      redirect_to top_path and return 
    else
      # 登録が失敗したらユーザー登録ページへ
      flash[:danger] = "ユーザー登録に失敗しました。"
      # サインアップページを再度表示
      redirect_to sign_up_path and return
    end
  end
  
  # サインインページ
  def sign_in
    @user = User.new
    render layout: "application_not_login"
  end
  
    # サインイン処理
  def sign_in_process
    # ここに処理を実装
    password_md5 = User.generate_password(user_params[:password])
    # メールアドレスとパスワードをもとにデータベースからデータを取得
    user = User.find_by(email: user_params[:email], password: password_md5)
    if user
      # セッション処理
      user_sign_in(user)
      # トップ画面へ遷移する
      redirect_to top_path and return
    else
      flash[:danger] = "サインインに失敗しました。"
      user.save
      redirect_to sign_in_path and return
    end
  end
  
  # サインアウト
  def sign_out
    # ここに処理を実装
    user_sign_out
    # サインインページへ遷移
    redirect_to sign_in_path and return
  end
  
  # プロフィールページ
  def show
    # ここに処理を実装
    @user = User.find(params[:id])
    @posts = Post.where(user_id: @user.id)
    @followers = User.where(id: Follow.where(follow_user_id: @user.id).pluck(:user_id))
  end
  
    # プロフィール編集ページ
  def edit
    @user = User.find(current_user.id)
  end
   
  # プロフィール更新処理
  def update
    # ここに処理を実装
    upload_file = params[:user][:image]
    if upload_file.present?
      # あった場合はこの中の処理が実行される
      # 画像のファイル名作成
      # 画像のファイル名取得
      upload_file_name = upload_file.original_filename
      # => 取得するパスは「/home/ubuntu/workspace/photo/public/users」になる
      output_dir = Rails.root.join('public', 'users')
      # 画像のファイルパス作成
      output_path = output_dir + upload_file_name
      # 画像のアップロード
      File.open(output_path, 'w+b') do |f|
        f.write(upload_file.read)
      end
      # データベースに更新
      current_user.update(user_params.merge({image: upload_file.original_filename}))
    else
       # データベースに更新
      current_user.update(user_params)
    end
    flash[:success] = "プロフィール更新完了"
    redirect_to profile_edit_path and return
  end
  
    # フォロー処理
  def follow
    # ここに処理を実装
    @user = User.find(params[:id])
    if Follow.exists?(user_id: current_user.id, follow_user_id: @user.id)
    # フォローを解除
      Follow.find_by(user_id: current_user.id, follow_user_id: @user.id).destroy
    else
      # フォローする
      Follow.create(user_id: current_user.id, follow_user_id: @user.id)
    end
    @followers = User.where(id: Follow.where(follow_user_id: @user.id).pluck(:user_id))
    redirect_back(fallback_location: top_path, notice: "フォローを更新しました。")
  end
  
  # フォローリスト
  def follow_list
      # プロフィール情報の取得
      @user = User.find(params[:id])
      # ここに処理を実装
      @users = User.where(id: Follow.where(user_id: @user.id).pluck(:follow_user_id))
      @followers = User.where(id: Follow.where(follow_user_id: @user.id).pluck(:user_id))
  end
  
  # フォロワーリスト
  def follower_list
      # プロフィール情報の取得
      @user = User.find(params[:id])
      # ここに処理を実装
      @followers = User.where(id: Follow.where(follow_user_id: @user.id).pluck(:user_id))
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :comment)
  end
  
end

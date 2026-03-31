module Admin
  class UsersController < BaseController
    before_action :set_user, only: [:show, :edit, :update, :toggle_role]

    def index
      skip_authorization
      @users = User.includes(:participations).order(:name)
    end

    def show
      skip_authorization
      @participations = @user.participations.includes(:season)
    end

    def edit
      skip_authorization
    end

    def update
      skip_authorization

      if @user.update(user_params)
        redirect_to admin_user_path(@user), notice: "User updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def toggle_role
      skip_authorization
      @user.update!(role: @user.admin? ? :player : :admin)
      redirect_to admin_user_path(@user),
        notice: "#{@user.name} is now a #{@user.role}."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email, :role)
    end
  end
end

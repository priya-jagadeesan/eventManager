class LoginController < ApplicationController
    skip_before_action :require_login, only: [:index, :register, :create]
    before_action :loggedIn, only: [:index, :register]

    def index
    end
    def register
    end
    def create
        if params[:form_value]=='register'
            @user = User.new(user_params)
            if @user.save
                session[:user_id] = @user.id
                redirect_to "/events"
            else
                flash[:register] = @user.errors
                redirect_to "/register"
            end
        elsif params[:form_value]=='sign_in'
            @user = User.find_by(email: params[:email].downcase).try(:authenticate, params[:password])
            if @user.nil?
                flash[:sign_in] = 'Invalid Credentials'
                redirect_to "/login"
            elsif !@user
                flash[:sign_in] = 'Invalid Credentials!'
                redirect_to "/login"
            else
                session[:user_id] = @user.id
                redirect_to "/events"
            end
        end
    end
    def edit
        @user = User.find(session[:user_id])
        @event = Event.find(params[:id])
        @organized_events = Event.where(user: @user)
        @user_organized_array = [];
        @organized_events.each do |event|
            info = '<strong>' + event.title + '</strong><br>' + event.location + '<br><b>On: </b>' + event.date.strftime("%d, %b %Y") + '<br>' + '<b>starts at: </b>' + event.start_time.strftime("%H:%M %p");
            @user_organized_array.push(Array.wrap([info, event.latitude, event.longitude]))
        end
        @user_events = UserEvent.where(user: @user)
        @user_upcoming_array = [];
        @user_events.each do |user|
            info = '<strong>' + user.event.title + '</strong><br>' + user.event.location + '<br><b>On: </b>' + user.event.date.strftime("%d, %b %Y") + '<br>' + '<b>starts at: </b>' + user.event.start_time.strftime("%H:%M %p");
            @user_upcoming_array.push(Array.wrap([info, user.event.latitude, user.event.longitude]))
        end
    end

    def update
        @user = User.find(params[:id])
        @user.update(update_params)
        redirect_to :back
    end

    def destroy
        session[:user_id] = nil
        redirect_to "/"
    end

    private
    def user_params
        params.require(:user).permit(:name,:email,:password,:password_confirmation, :image)
    end
    def update_params
        params.require(:user).permit(:image)
    end
end

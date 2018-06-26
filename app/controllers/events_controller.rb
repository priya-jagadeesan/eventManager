class EventsController < ApplicationController
    def index
        @user = User.find(session[:user_id])
        @events = Event.where("date >= ?", Date.today).order(date: :asc, start_time: :asc)
    end
    def search
        @user = User.find(session[:user_id])
        if params[:form_value]=='event_title'
            @events = Event.where("lower(title) LIKE ?", '%' + params[:title].downcase + '%')
            render "index.html.erb"
        elsif params[:form_value]=='event_date'
            @events = Event.where("date = ?", params[:date])
            render "index.html.erb"
        else    
            redirect_to "/events"
        end
    end
    def new
        @current_date = DateTime.now.strftime('%m/%d/%Y')
        @current_time = Time.now.strftime("%H:%M %r")
        @user = User.find(session[:user_id])
    end
    def create
        if event_params[:image] == ""
            event_params[:image] = 'no-img.png'
        end
        @event = Event.new(event_params)
        @user = User.find(session[:user_id])
        @event.user = @user
        if @event.save
            redirect_to "/events"
        else
            flash[:event_register] = @event.errors
            redirect_to "/events/new"
        end
    end
    def show
        @user = User.find(session[:user_id])
        @event = Event.find(params[:id])
        @event_array = [@event.location, @event.latitude, @event.longitude];
        @user_event = UserEvent.where(event: @event)
    end
    def join
        @user = User.find(session[:user_id])
        @event = Event.find(params[:id])
        @user_event = UserEvent.new(user: @user, event: @event)
        if @user_event.save
            redirect_to :back
        else
            flash[:event_register] = @event.errors
            redirect_to :back
        end
    end
    def past
        @user = User.find(session[:user_id])
        @events = Event.where("date < ?", Date.today)
    end
    def edit
        @event = Event.find(params[:id])
    end
    def update
        @event = Event.find(params[:id])
        @user = User.find(session[:user_id])
        @event.user = @user
        if event_params[:image] == ""
            event_params[:image] = 'no-img.png'
        end
        @event.update(event_params)
        if @event.valid?
            redirect_to "/events"
        else
            flash[:event_register] = @event.errors
            redirect_to :back
        end
    end
    def user_event
    end
    def destroy
        @event = Event.find(params[:id])
        @event.destroy
        redirect_to "/events"
    end
    private
    def event_params
        params.require(:event).permit(:title, :description, :date, :start_time, :end_time, :location, :information, :image)
    end
end

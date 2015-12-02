class NudgesController < ApplicationController
	before_filter :require_verified_user, :require_student
	before_filter :nudges_enabled_globally?, only: [:new, :create]

	def index
	end

	def new
		@nudgeable_students = Student.where(nudges_enabled: true).where.not(id: current_user.id)
		@event = Event.find(params[:id])
	end

	def create
		@nudge = Nudge.new(
			nudger: current_student,
			nudgee: Student.find(params[:nudgee]),
			event: Event.find(params[:id])
		)
		if @nudge.save
			flash[:notice] = "You nudged #{@nudge.nudgee.username} to go to #{@nudge.event.name}"
			redirect_to dashboard_path
		else
			redirect_to "/events/#{event.id}/nudge"
		end
	end

	def destroy
		@nudge = Nudge.find(params[:id])
		if params[:accept]
			@nudge.accept!
			redirect_to new_event_attendance_path(@nudge.event)
		else
			@nudge.decline!
		end
	end

	private

	def nudges_enabled_globally?
		if ENV["DISABLE_NUDGE_TEXTS"] == "TRUE"
			@event = Event.find(params[:id])
			flash[:notice] = "We’re sorry, but we have temporarily disabled nudges for all users while we correct an issue with the system. Please try your nudge again later."
			redirect_to @event
		elsif current_user == User.first
			@event = Event.find(params[:id])
			flash[:notice] = "This example user has had nudging disabled."
			redirect_to @event
		end
	end

end

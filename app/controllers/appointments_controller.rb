class AppointmentsController < ApplicationController
  # Controller only handles HTTP concerns
  def create
    result = Appointments::Create.new(
      doctor: Doctor.find(params[:doctor_id]),
      start_time: params[:start_time],
      end_time: params[:end_time]
    ).call

    if result[:success]
      render json: result[:appointment], status: :created
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end
end

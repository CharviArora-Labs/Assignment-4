# Namespace keeps appointment-related services grouped together
module Appointments
  # This service is responsible ONLY for creating appointments
  # and enforcing booking business rules.
  class Create
    # Service initialization receives plain Ruby objects,
    # NOT HTTP params or controller-specific objects
    def initialize(doctor:, start_time:, end_time:)
      @doctor = doctor
      @start_time = start_time
      @end_time = end_time
    end

    # Public entry point for the service
    def call
      # Business rule: prevent overlapping appointments
      return failure("Appointment overlaps with an existing booking") if overlap?

      # Persist appointment only after validations pass
      appointment = @doctor.appointments.create!(
        start_time: @start_time,
        end_time: @end_time
      )

      # Always return a consistent success structure
      success(appointment)
    rescue ActiveRecord::RecordInvalid => e
      # Convert model errors into a service-level failure
      failure(e.message)
    end

    private

    # Domain rule: checks if appointment overlaps with existing ones
    #
    # Overlap condition:
    # existing.start < new.end AND existing.end > new.start
    def overlap?
      @doctor.appointments
             .where("start_time < ? AND end_time > ?", @end_time, @start_time)
             .exists?
    end

    # Standard success response
    def success(appointment)
      {
        success: true,
        appointment: appointment
      }
    end

    # Standard failure response
    def failure(message)
      {
        success: false,
        error: message
      }
    end
  end
end

# Understanding MVC, Services, and This Assignment

This section explains **what MVC is**, **what service objects are**, **why they are used**, and **how your `Appointments::Create` service and controller work together**, including **what outputs you see**.

---

## 1. What is MVC in Rails?

Rails follows the **MVC architecture**:

```
Model  ←→  Controller  ←→  View
```

### Model (M)

**What it is:**
Represents the **data** and its relationships.

**In your assignment:**

* `Doctor`
* `Appointment`

**Responsibilities:**

* Database persistence
* Associations (`has_many`, `belongs_to`)
* Basic validations

**Example:**

```ruby
class Doctor < ApplicationRecord
  has_many :appointments
end
```

---

### Controller (C)

**What it is:**
Handles **incoming requests** and decides **what action to take**.

**In your assignment:**

* `AppointmentsController`

**Responsibilities:**

* Receive parameters
* Call business logic
* Return a response

**What controllers should NOT do**

* Complex business rules
* Database decision logic
* Overlap checks

---

### View (V)

**What it is:**
Displays output (HTML / JSON).

**In this assignment:**
Views are **not the focus**. You are testing via **Rails console** or API-style responses.

---

## 2. Where Do Services Fit?

Rails MVC does **not** officially include “Services”, but in **real projects**, they are essential.

### What is a Service Object?

A **service object** is:

* Plain Ruby class
* Encapsulates **business logic**
* Independent of HTTP, controllers, or views

Think of it as:

> “A domain action packaged into a reusable unit”

---

## 3. Why Services Are Needed (Real-World Reason)

Without services:

```ruby
def create
  if overlap?
    render error
  else
    Appointment.create!
  end
end
```

Problems:

* Controller becomes bloated
* Logic hard to test
* Logic duplicated
* Hard to reason about domain rules

---

## 4. How Services Fit Into *Your* Assignment

### Your Flow

```
Rails Console / HTTP Request
        ↓
AppointmentsController
        ↓
Appointments::Create (Service)
        ↓
Doctor & Appointment Models
        ↓
Database
```

### Why This Is Important

* Controller = **traffic cop**
* Service = **brain**
* Model = **data storage**

---

## 5. Appointments::Create – What This Code Does

**File:** `app/services/appointments/create.rb`

### Purpose

This service:

1. Accepts appointment details
2. Checks for overlapping appointments
3. Creates appointment if valid
4. Returns a consistent result

---

### Step-by-Step Code Walkthrough

#### Initialization

```ruby
def initialize(doctor:, start_time:, end_time:)
  @doctor = doctor
  @start_time = start_time
  @end_time = end_time
end
```

✔ Accepts plain Ruby objects
✔ No controller or HTTP coupling

---

#### Public Entry Point

```ruby
def call
  return failure("Appointment overlaps with an existing booking") if overlap?

  appointment = @doctor.appointments.create!(
    start_time: @start_time,
    end_time: @end_time
  )

  success(appointment)
end
```

What happens:

1. Checks overlap
2. Creates appointment
3. Returns structured response

---

#### Overlap Logic

```ruby
def overlap?
  @doctor.appointments
         .where("start_time < ? AND end_time > ?", @end_time, @start_time)
         .exists?
end
```

This enforces a **domain invariant**:

>> A doctor cannot have overlapping appointments

---

#### Return Structure

```ruby
{ success: true, appointment: appointment }
{ success: false, error: "..." }
```

- Predictable
- Easy to test
- Controller-friendly

---

## 6. AppointmentsController – What It Does

**File:** `app/controllers/appointments_controller.rb`

### Role

* Handles HTTP requests
* Delegates logic to service
* Renders response

### Example

```ruby
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
```

Notice:

* No overlap logic here
* No database rules here
* Controller remains thin

---

## 7. Why Rails Console Shows Output (Your Case)

### You Ran:

```ruby
result = Appointments::Create.new(
  doctor: doctor,
  start_time: Time.parse("2026-03-01 10:00"),
  end_time: Time.parse("2026-03-01 11:00")
).call
```

### Output (Success)

```ruby
{ success: true, appointment: #<Appointment ...> }
```

This means:
✔ No overlap
✔ Appointment saved

---

### Overlapping Appointment

```ruby
result2 = Appointments::Create.new(
  doctor: doctor,
  start_time: Time.parse("2026-03-01 10:30"),
  end_time: Time.parse("2026-03-01 11:30")
).call
```

### Output (Failure)

```ruby
{ success: false, error: "Appointment overlaps with an existing booking" }
```

This proves:
✔ Business rule enforced
✔ Database not polluted
✔ Service working correctly

---

## 8. What This Assignment Is Teaching You

After completing this:

✔ You understand MVC
✔ You know **what belongs in controllers vs services**
✔ You can design testable business logic
✔ You can explain Rails architecture in interviews

---

## Final Mental Model

```
Controller = HTTP + orchestration
Service    = business rules
Model      = data + relations
```





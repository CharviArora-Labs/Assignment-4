# Assignment 04 – Rails Service Layer Implementation

This repository contains **Assignment 04** for the *ILA Rails and React Engineering Certification – Level 1*.

The goal of this assignment is to demonstrate a working Rails application that uses a **service object** to handle appointment booking logic with overlap prevention.

---

## What This Project Does

- Manages doctors and their appointments
- Prevents overlapping appointments for the same doctor
- Uses a service object (`Appointments::Create`) to encapsulate business logic
- Keeps controllers thin and readable

---

## Tech Stack

- Ruby
- Rails 8.1.2
- SQLite (development)

---

## How to Run the Project

### 1. Install dependencies

```bash
rails new app
```

2. Setup the database
```bash
rails generate model Doctor name:string
rails generate model Appointment doctor:references start_time:datetime end_time:datetime
rails db:migrate
```

4. Start Rails console
```bash
rails console
```

### How to Verify Functionality (Rails Console)

Create a doctor
```bash 
doctor = Doctor.create!(name: "Dr. Strange")

#Create a valid appointment

result = Appointments::Create.new(
  doctor: doctor,
  start_time: Time.parse("2026-03-01 10:00"),
  end_time: Time.parse("2026-03-01 11:00")
).call
```
```bash
Expected output:

{ success: true, appointment: #<Appointment ...> }
Attempt an overlapping appointment
result2 = Appointments::Create.new(
  doctor: doctor,
  start_time: Time.parse("2026-03-01 10:30"),
  end_time: Time.parse("2026-03-01 11:30")
).call
```
Expected output:
```bash
{ success: false, error: "Appointment overlaps with an existing booking" }
```

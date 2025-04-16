# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


PAYGATE_ID = 10011072130

PAYGATE_KEY = secret

RETURN_URL – nơi người dùng được trả về sau thanh toán

NOTIFY_URL – nơi PayGate gửi xác nhận giao dịch

CANCEL_URL – khi người dùng hủy thanh toán

#################################
run: bin/rails s -p 8080

install ngrok and bind 8080 portal

config/environments/development.rb
  routes.default_url_options[:host] = 'https://fd9b-58-186-68-124.ngrok-free.app'

config/application.rb
  config.hosts << "fd9b-58-186-68-124.ngrok-free.app"

then go to: https://fd9b-58-186-68-124.ngrok-free.app/payment to start payment with PayGate




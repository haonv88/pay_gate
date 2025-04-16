require 'net/http'
require 'uri'

class PaygateService
  PAYGATE_ID = "10011072130"
  PAYGATE_KEY = "secret"
  INIT_URL = 'https://secure.paygate.co.za/payweb3/initiate.trans'

  def self.create_payment(order)
    reference = "ORDER#{order.id}"
    params = {
      PAYGATE_ID: PAYGATE_ID,
      REFERENCE: reference,
      AMOUNT: (order.amount * 100).to_i,
      CURRENCY: 'ZAR',
      RETURN_URL: Rails.application.routes.url_helpers.payment_return_url,
      CANCEL_URL: Rails.application.routes.url_helpers.payment_cancel_url,
      NOTIFY_URL: Rails.application.routes.url_helpers.payment_notify_url,
      EMAIL: order.user.email
    }

    params[:CHECKSUM] = checksum(params)

    response = Net::HTTP.post_form(URI(INIT_URL), params)
    data = Hash.from_xml(response.body)

    if data["NewPaymentResponse"] && data["NewPaymentResponse"]["Redirect"]
      # Lưu lại reference vào order để xử lý ở notify
      order.update(reference: reference)
      return data["NewPaymentResponse"]["Redirect"]
    else
      raise "PayGate error: #{response.body}"
    end
  end

  def self.checksum(params)
    str = params.sort.to_h.values.join + PAYGATE_KEY
    Digest::MD5.hexdigest(str)
  end
end


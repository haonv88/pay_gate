require 'net/http'
require 'uri'

class PaygateService
  PAYGATE_ID = "10011072130"
  PAYGATE_KEY = "secret"
  INIT_URL = 'https://secure.paygate.co.za/payweb3/initiate.trans'

  # curl --location 'https://secure.paygate.co.za/payweb3/initiate.trans' \
  #   --form 'PAYGATE_ID="10011072130"' \
  #   --form 'REFERENCE="pgtest_123456789"' \
  #   --form 'AMOUNT="3299"' \
  #   --form 'CURRENCY="ZAR"' \
  #   --form 'RETURN_URL="https://my.return.url/page"' \
  #   --form 'TRANSACTION_DATE="2018-01-01 12:00:00"' \
  #   --form 'LOCALE="en-za"' \
  #   --form 'COUNTRY="ZAF"' \
  #   --form 'EMAIL="customer@paygate.co.za"' \
  #   --form 'CHECKSUM="59229d9c6cb336ae4bd287c87e6f0220"'
  def self.create_payment(order)
    reference = "ORDER#{order.id}"
    params = {
      PAYGATE_ID: PAYGATE_ID,
      REFERENCE: reference,
      AMOUNT: order.amount.to_i,
      CURRENCY: 'ZAR',
      RETURN_URL: Rails.application.routes.url_helpers.payment_return_url,
      # TRANSACTION_DATE: order.created_at.to_s,
      TRANSACTION_DATE: "2025-04-16 05:18:32",
      LOCALE: "en-za",
      COUNTRY: "ZAF",
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


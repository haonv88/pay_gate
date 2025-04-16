class PaymentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:notify]

  def new
    # @order = Order.find(params[:order_id])
    @order = Order.first_or_create(
                                 user: User.first_or_create(username: "test", email: "nvhaotl@gmail.com"),
      amount: 100,
      status: "pending",
      reference: "ORDER1"
    )
    redirect_url = PaygateService.create_payment(@order)
    redirect_to redirect_url
  end

  def notify
    raw_data = params.to_unsafe_h

    # Ghi log vào file
    PAYGATE_LOGGER.info("=== PayGate IPN at #{Time.current} ===")
    PAYGATE_LOGGER.info(raw_data.pretty_inspect)

    # Lưu log vào DB
    WebhookLog.create!(
      source: 'paygate',
      payload: raw_data
    )

    verified = verify_checksum(raw_data)

    if verified && raw_data['TRANSACTION_STATUS'] == '1'
      order = Order.find_by(reference: raw_data['REFERENCE'])
      if order
        order.update(status: 'paid', transaction_id: raw_data['PAY_REQUEST_ID'])
        PAYGATE_LOGGER.info("✔️ Order ##{order.id} marked as paid")
      else
        PAYGATE_LOGGER.warn("❗ No order found with reference #{raw_data['REFERENCE']}")
      end
    else
      PAYGATE_LOGGER.warn("❌ Invalid CHECKSUM or failed transaction for: #{raw_data['REFERENCE']}")
    end

    head :ok
  end

  def return
    redirect_to success_path, notice: "Thanh toán thành công"
  end

  def cancel
    redirect_to root_path, alert: "Bạn đã hủy thanh toán"
  end

  private

  def verify_checksum(data)
    received_checksum = data['CHECKSUM']
    check_data = data.except('CHECKSUM').sort.to_h.values.join + ENV['PAYGATE_KEY']
    expected_checksum = Digest::MD5.hexdigest(check_data)

    received_checksum == expected_checksum
  end
end


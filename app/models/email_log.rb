class EmailLog < ApplicationRecord
  belongs_to :week

  scope :sent,   -> { where(status: "sent") }
  scope :failed, -> { where(status: "failed") }

  def self.record_sent(recipient_email:, week:, mailer:)
    create!(recipient_email: recipient_email, week: week, mailer: mailer, status: "sent")
  end

  def self.record_failed(recipient_email:, week:, mailer:, error:)
    create!(recipient_email: recipient_email, week: week, mailer: mailer, status: "failed",
            error_message: "#{error.class}: #{error.message}")
  end
end

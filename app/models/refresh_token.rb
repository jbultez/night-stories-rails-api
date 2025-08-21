class RefreshToken < ApplicationRecord
  belongs_to :user

  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :active, -> { where(revoked: false) }
  scope :expired, -> { where('expires_at < ?', Time.current) }

  def expired?
    expires_at < Time.current
  end

  def active?
    !revoked? && !expired?
  end

  def revoke!
    update!(revoked: true)
  end
end
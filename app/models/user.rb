class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, player: 0, admin: 1

  has_many :participations, dependent: :destroy
  has_many :seasons, through: :participations
  has_many :messages, dependent: :destroy
  has_many :likes, dependent: :destroy

  validates :name, presence: true, length: { maximum: 100 }

  def display_name
    name.presence || email
  end

  after_create :join_active_season

  private

  def join_active_season
    active = Season.active.first
    return unless active
    participations.create!(season: active)
  end
end

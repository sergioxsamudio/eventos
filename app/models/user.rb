class User < ApplicationRecord
  rolify
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_and_belongs_to_many :labels
  has_many :event_users, dependent: :destroy
  has_many :events, through: :event_users  # Relación con eventos a través de EventUser

  validates :first_name, :last_name, presence: true
  validates :phone_number, presence: true, uniqueness: true

  after_create :assign_default_role

  def assign_default_role
    self.add_role(:usuario) if self.roles.blank?
  end
  def interested_events
    Event.joins(:labels).where(labels: { id: label_ids })
  end

  # ✅ Permitir que Ransack busque solo en estos atributos
  def self.ransackable_attributes(auth_object = nil)
    %w[first_name last_name email phone_number created_at]
  end
end


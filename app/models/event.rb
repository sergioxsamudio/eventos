class Event < ApplicationRecord
  has_many :event_users, dependent: :destroy
  has_many :users, through: :event_users  # Relación con usuarios

  has_many_attached :images  # Relación con imágenes
  has_many :event_labels, dependent: :destroy
  has_many :labels, through: :event_labels  # Relación con etiquetas

  validates :title, :start_time, :end_time, presence: true
  validate :start_time_before_end_time

  def start_time_before_end_time
    return if start_time.nil? || end_time.nil?  # ✅ Evita el error si son nil
    errors.add(:end_time, "debe ser posterior a la fecha de inicio") if start_time >= end_time
  end

  def self.ransackable_attributes(auth_object = nil)
    ["id", "title", "description", "start_time", "end_time", "created_at", "updated_at"]
  end

  # ✅ Permitir búsqueda por asociaciones
  def self.ransackable_associations(auth_object = nil)
    ["event_labels", "labels", "event_users", "users"]
  end
end

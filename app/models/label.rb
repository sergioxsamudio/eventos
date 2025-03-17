class Label < ApplicationRecord
    has_many :event_labels, dependent: :destroy
    has_many :events, through: :event_labels  # Relación con eventos
    has_and_belongs_to_many :users
    validates :name, presence: true, uniqueness: true
    # ✅ Permitir búsqueda por estos atributos
  def self.ransackable_attributes(auth_object = nil)
    ["id", "name", "created_at", "updated_at"]
  end

  # ✅ Permitir búsqueda por asociaciones (opcional si usas búsqueda con eventos)
  def self.ransackable_associations(auth_object = nil)
    ["event_labels", "events"]
  end
end

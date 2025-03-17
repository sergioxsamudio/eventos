class ImageUploader < CarrierWave::Uploader::Base
  storage :file  # Usa almacenamiento local; cambiar a :fog si usas AWS, GCP, etc.

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_whitelist
    %w[jpg jpeg png webp]  # Permitir solo imágenes
  end
end


require 'rqrcode'

class EventMailer < ApplicationMailer
  default from: 'notificaciones@tuapp.com'  

  def registration_confirmation(user, event)
    @user = user
    @event = event

  
    qr_data = "#{@event.id}-#{@user.id}"

   
    begin
      qrcode = RQRCode::QRCode.new(qr_data)
      @qr_svg = qrcode.as_svg(module_size: 6, standalone: true)
    rescue StandardError => e
      Rails.logger.error "Error generando QR: #{e.message}"
      @qr_svg = nil
    end

    mail(to: @user.email, subject: "Confirmación de inscripción en #{@event.title}")
  end
end





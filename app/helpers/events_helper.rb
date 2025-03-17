require 'rqrcode'

module EventsHelper
  def qr_code_for_user_event(user, event)
    qr = RQRCode::QRCode.new("#{request.base_url}/events/#{event.id}/check_attendance?user_id=#{user.id}")

    qr.as_svg(
      offset: 0,
      color: '000',
      shape_rendering: 'crispEdges',
      module_size: 6,
      standalone: true
    ).html_safe
  end
end

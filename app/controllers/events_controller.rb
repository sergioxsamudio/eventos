class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin, only: [:new, :create, :edit, :update, :destroy, :export_xlsx]
  before_action :set_event, only: [:show, :edit, :update, :destroy, :register, :unregister, :users, :export_users_xlsx]

  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

  def index
    @q = Event.ransack(params[:q])
    @events = @q.result.includes(:labels).where("end_time > ?", Time.current).page(params[:page]).per(5)
  end

  def show
  end

  # ✅ Inicializa el evento con valores predeterminados para `start_time` y `end_time`
  def new
    @event = Event.new(start_time: Time.current, end_time: Time.current + 1.hour)

  end
  
  def create
    @event = Event.new(event_params)

    # Convierte `start_time` y `end_time` a objetos de tipo `DateTime`
    
    @event.end_time = Time.zone.parse(params[:event][:end_time]) if params[:event][:end_time].present?

    if @event.save
      notify_interested_users(@event)
      redirect_to @event, notice: "Evento creado con éxito."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  # ✅ Actualiza el evento y convierte `start_time` y `end_time` a objetos de tipo `DateTime`
  def update
    if @event.update(event_params)
      # Convierte `start_time` y `end_time` a objetos de tipo `DateTime`
      @event.start_time = Time.zone.parse(params[:event][:start_time]) if params[:event][:start_time].present?
      @event.end_time = Time.zone.parse(params[:event][:end_time]) if params[:event][:end_time].present?

      redirect_to @event, notice: "El evento fue actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    redirect_to events_path, notice: "El evento fue eliminado.", status: :see_other
  end

  # ✅ Ver usuarios inscritos en un evento
  def users
    @users = @event.users
  end

  # ✅ Notificar a los usuarios interesados en etiquetas del evento
  def notify_interested_users(event)
    interested_users = User.joins(:labels).where(labels: { id: event.label_ids }).distinct

    if interested_users.any?
      Rails.logger.info "📧 Se enviarán correos a #{interested_users.count} usuarios interesados."

      interested_users.each do |user|
        EventMailer.event_notification(user, event).deliver_later
        Rails.logger.info "📨 Correo enviado a: #{user.email}"
      end
    else
      Rails.logger.info "❌ No hay usuarios interesados en este evento."
    end
  end

  # ✅ Confirmar asistencia con QR
  def confirm_attendance
    @event = Event.find_by(id: params[:id])
    @user = User.find_by(id: params[:user_id])
  
    if @event.nil? || @user.nil?
      render json: { success: false, message: "Evento o usuario no encontrado" }, status: :not_found
      return
    end
  
    event_user = EventUser.find_or_initialize_by(event: @event, user: @user)
  
    if event_user.update(attended: true)
      render json: { success: true, message: "Asistencia confirmada" }
      @user.increment!(:score, 150)
    else
      render json: { success: false, message: "Ya se ha registrado la asistencia o no está inscrito." }, status: :unprocessable_entity
    end
  end
  
  def my_events
    @events = current_user.events.order(start_time: :asc).page(params[:page]).per(5)
  end

  def export_xlsx
    @events = Event.includes(:labels, :users)

    p = Axlsx::Package.new
    wb = p.workbook

    wb.add_worksheet(name: "Eventos") do |sheet|
      sheet.add_row ["ID", "Título", "Descripción", "Fecha Inicio", "Fecha Fin", "Etiquetas", "Usuarios Registrados"]
      @events.each do |event|
        sheet.add_row [
          event.id,
          event.title,
          event.description,
          event.start_time.strftime("%d/%m/%Y %H:%M"),
          event.end_time.strftime("%d/%m/%Y %H:%M"),
          event.labels.map(&:name).join(", "),
          event.users.map { |u| "#{u.first_name} #{u.last_name} (#{u.email})" }.join(", ")
        ]
      end
    end

    send_data p.to_stream.read, type: "application/xlsx", filename: "eventos.xlsx"
  end

  def register
    if @event.end_time > Time.current
      unless current_user.events.include?(@event)
        current_user.events << @event
        EventMailer.registration_confirmation(current_user, @event).deliver_now
        redirect_to @event, notice: "Te has inscrito al evento con éxito."
      else
        redirect_to @event, alert: "Ya estás inscrito en este evento."
      end
    else
      redirect_to @event, alert: "No puedes inscribirte a un evento que ya ha finalizado."
    end
  end

  def unregister
    if current_user.events.exists?(@event.id)
      current_user.events.delete(@event)
      redirect_to my_events_path, notice: "Te has desinscrito del evento con éxito."
    else
      redirect_to @event, alert: "No estás inscrito en este evento."
    end
  end

  def export_users_xlsx
    return redirect_to events_path, alert: "Evento no encontrado." if @event.nil?
  
    @users = @event.users
  
    respond_to do |format|
      format.xlsx { render xlsx: "export_users_xlsx", filename: "usuarios_evento_#{@event.id}.xlsx" }
      format.html { redirect_to event_path(@event), alert: "El formato solicitado no es válido." }
    end
  end

  def update_points
    @event = Event.find(params[:id])
    @event.update(points_deducted: true)
  
    # Buscar usuarios inscritos que no asistieron
    @event.users.each do |user|
      event_user = EventUser.find_by(event: @event, user: user)
      if event_user && !event_user.attended?
        user.update(score: user.score - 300)  # Restar 300 puntos
      end
    end
  
    redirect_to events_path, notice: "Se han deducido puntos a los usuarios que no asistieron."
  end

  private

  # ✅ Busca el evento por ID o redirige si no se encuentra
  def set_event
    @event = Event.find_by(id: params[:id])
    return redirect_to events_path, alert: "Evento no encontrado." if @event.nil?
  end

  # ✅ Filtra y limpia los parámetros del evento
  def event_params
    params.require(:event).permit(:title, :description, :start_time, :end_time, images: [], label_ids: []).tap do |whitelisted|
      whitelisted[:label_ids] = params[:event][:label_ids].reject(&:blank?) if params[:event][:label_ids].is_a?(Array)
    end
  end

  # ✅ Autoriza solo a los administradores
  def authorize_admin
    redirect_to root_path, alert: "No tienes permisos para realizar esta acción." unless current_user.has_role?(:admin)
  end

  # ✅ Maneja el error de registro no encontrado
  def handle_record_not_found
    redirect_to events_path, alert: "El evento no existe o no se pudo encontrar."
  end
end


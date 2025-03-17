class UsersController < ApplicationController
  before_action :authenticate_user!  # Asegura que el usuario esté autenticado
  before_action :authorize_admin, only: %i[index destroy export_xlsx]
  before_action :set_user, only: %i[show edit update destroy]

  # GET /users
  def index
    @q = User.ransack(params[:q])  # Filtrado con Ransack
    @users = @q.result.page(params[:page]).per(10)  # Paginación con Kaminari
  end

  # GET /users/1
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: "El usuario fue creado exitosamente." }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: "El usuario fue actualizado exitosamente." }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_path, notice: "El usuario fue eliminado.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def export_xlsx
    @users = User.includes(:roles, :labels)  # Incluir etiquetas en la exportación

    p = Axlsx::Package.new
    wb = p.workbook

    wb.add_worksheet(name: "Usuarios") do |sheet|
      sheet.add_row ["ID", "Nombre", "Apellido", "Correo", "Teléfono", "Roles", "Etiquetas de Interés"]

      @users.each do |user|
        sheet.add_row [
          user.id,
          user.first_name,
          user.last_name,
          user.email,
          user.phone_number,
          user.roles.map(&:name).join(", "),
          user.labels.map(&:name).join(", ")
        ]
      end
    end

    send_data p.to_stream.read, type: "application/xlsx", filename: "usuarios.xlsx"
  end

  # ✅ Vista para gestionar etiquetas de interés
  def edit_labels
    @user = current_user  # Asegurar que @user no sea nil
  end
  def scan_qr
    render "users/cam"
  end

  # ✅ Acción para actualizar etiquetas de interés
  def update_labels
    @user = current_user
  
    # ✅ Filtramos valores en blanco y aseguramos que los IDs sean números válidos
    label_ids = params[:user][:label_ids].reject { |id| id.blank? || id.to_i.zero? }
  
    if @user.update(label_ids: label_ids)
      redirect_to edit_labels_users_path, notice: "Tus etiquetas de interés han sido actualizadas."
    else
      render :edit_labels, status: :unprocessable_entity
    end
  end
  # ✅ Eliminar una etiqueta de interés del usuario
  def remove_label
    @user = current_user
    label = Label.find(params[:label_id])
    @user.labels.delete(label)
    redirect_to edit_labels_users_path, notice: "Etiqueta eliminada correctamente."
  end

  private

  # Método para encontrar al usuario por ID
  def set_user
    return redirect_to root_path, alert: "Acción no válida." unless params[:id].match?(/^\d+$/)

    @user = User.find_by(id: params[:id])
    
    unless @user
      redirect_to users_path, alert: "Usuario no encontrado."
    end
  end
  def authorize_admin
    redirect_to root_path, alert: "No tienes permisos para realizar esta acción." unless current_user.has_role?(:admin)
  end

  # Restringir parámetros permitidos
  def user_params
    params.require(:user).permit(:first_name, :last_name, :phone_number, :email, :password, :password_confirmation, label_ids: [])
  end

  # Método para restringir acceso solo a administradores
  def authorize_admin
    unless current_user.has_role?(:admin)
      redirect_to root_path, alert: "No tienes permisos para realizar esta acción."
    end
  end
end

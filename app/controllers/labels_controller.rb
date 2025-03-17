class LabelsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_label, only: [:show, :edit, :update, :destroy]

  # GET /labels
  def index
    @labels = Label.all
  end

  # GET /labels/1
  def show
  end

  # GET /labels/new
  def new
    @label = Label.new
  end

  # GET /labels/1/edit
  def edit
  end

  # POST /labels
  def create
    @label = Label.new(label_params)

    respond_to do |format|
      if @label.save
        format.html { redirect_to @label, notice: t("labels.notices.created") }
        format.json { render :show, status: :created, location: @label }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @label.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /labels/1
  def update
    respond_to do |format|
      if @label.update(label_params)
        format.html { redirect_to @label, notice: t("labels.notices.updated") }
        format.json { render :show, status: :ok, location: @label }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @label.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /labels/1
  def destroy
    @label.destroy

    respond_to do |format|
      format.html { redirect_to labels_path, status: :see_other, notice: t("labels.notices.deleted") }
      format.json { head :no_content }
    end
  end

  private

  # ✅ Método para encontrar una etiqueta por ID
  def set_label
    @label = Label.find(params[:id])
  end

  
  # ✅ Método para permitir solo parámetros permitidos
  def label_params
    params.require(:label).permit(:name)
  end

  # ✅ Método para restringir acceso solo a administradores
  def authorize_admin
    unless current_user.has_role?(:admin)
      redirect_to root_path, alert: t("labels.notices.no_permission")
    end
  end
end

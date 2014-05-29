class HelloMessagesController < ApplicationController
  before_action :set_hello_message, only: [:show, :edit, :update, :destroy]

  # GET /hello_messages
  # GET /hello_messages.json
  def index
    @hello_messages = HelloMessage.all
  end

  # GET /hello_messages/1
  # GET /hello_messages/1.json
  def show
  end

  # GET /hello_messages/new
  def new
    @hello_message = HelloMessage.new
  end

  # GET /hello_messages/1/edit
  def edit
  end

  # POST /hello_messages
  # POST /hello_messages.json
  def create
    @hello_message = HelloMessage.new(hello_message_params)

    respond_to do |format|
      if @hello_message.save
        format.html { redirect_to @hello_message, notice: 'Hello message was successfully created.' }
        format.json { render action: 'show', status: :created, location: @hello_message }
      else
        format.html { render action: 'new' }
        format.json { render json: @hello_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /hello_messages/1
  # PATCH/PUT /hello_messages/1.json
  def update
    respond_to do |format|
      if @hello_message.update(hello_message_params)
        format.html { redirect_to @hello_message, notice: 'Hello message was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @hello_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /hello_messages/1
  # DELETE /hello_messages/1.json
  def destroy
    @hello_message.destroy
    respond_to do |format|
      format.html { redirect_to hello_messages_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_hello_message
      @hello_message = HelloMessage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def hello_message_params
      params.require(:hello_message).permit(:message, :times_shown)
    end
end

class Api::V1::MessagesController < Api::V1::BaseController
  def index
    respond_with Message.all
  end

  def create
    respond_with :api, :v1, Message.create(message_params)
  end

  def destroy
    respond_with Message.destroy(params[:id])
  end

  def update
    message = Message.find(params["id"])
    message.update_attributes(message_params)
    respond_with message, json: message
  end
  
  def reply
    args = {
      paraId: params[:paraId],
      offset: params[:offset],
      message: params[:message],
    }
    respond_with args
  end

  private

  def message_params
    params.require(:message).permit(:id, :name, :description)
  end
end

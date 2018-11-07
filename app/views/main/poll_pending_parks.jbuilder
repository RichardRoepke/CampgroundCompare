def build_json_response(json_object)
  if @result.is_a?(Hash)
    json_object.AwaitingCheck(@result[:awaiting_check])
    json_object.Added(@result[:added])
    json_object.Unneeded(@result[:unneeded])
    json_object.Failed(@result[:failed])
  else
    json_object.Result(@result)
  end
end

build_json_response(json)
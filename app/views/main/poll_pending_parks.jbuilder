def build_json_response(json_object)
  json_object.AwaitingCheck(@result[:awaiting_check])
  json_object.Added(@result[:added])
  json_object.Unneeded(@result[:unneeded])
  json_object.Failed(@result[:failed])
end

build_json_response(json)
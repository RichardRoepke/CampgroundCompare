$("input[data-pending]").on('click', function () {
  console.log("FOOBAR");
});

/*
$ ->
  $("input[data-pending]").click ->
    $.post '/pending',
      { field1: "hello", field2 : "hello2"},
        success  : (data, status, xhr) ->
            console.log("SUCCESS: " + data)
        error    : (xhr, status, err) ->
            console.log("ERROR: " + err)
        complete : (xhr, status) ->
            console.log("COMPLETE")

gah =(test) ->
  console.log("FOOBAR")
  test
  */
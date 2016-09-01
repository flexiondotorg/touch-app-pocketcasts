webview.addMessageHandler("SIMULATE_KEY_EVENT", function (msg) {
    var event = jQuery.Event("keyup");
    event.which = msg.args["key"];
    $("body").trigger(event);
});
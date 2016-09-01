function left() {
    var event = jQuery.Event("keyup");
    event.which = 37;
    $("body").trigger(event);
}

function right() {
    var event = jQuery.Event("keyup");
    event.which = 39;
    $("body").trigger(event);
}

function space() {
    var event = jQuery.Event("keyup");
    event.which = 32;
    $("body").trigger(event);
}
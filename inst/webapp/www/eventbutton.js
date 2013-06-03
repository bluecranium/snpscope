$(document).on("click", "button.eventbutton", function(evt) {
  // evt.target is the button that was clicked
  var el = $(evt.target);
 
  // Raise an event to signal that the value changed
  el.trigger("change");
});
var eventButtonBinding = new Shiny.InputBinding();
$.extend(eventButtonBinding, {
  find: function(scope) {
    return $(scope).find(".eventbutton");
  },
  getValue: function(el) {
    //return new Date().getTime();
    return Math.random();
  },
  setValue: function(el, value) {
    // no-op
  },
  subscribe: function(el, callback) {
    $(el).on("change.eventButtonBinding", function(e) {
      callback();
    });
  },
  unsubscribe: function(el) {
    $(el).off(".eventButtonBinding");
  }
});

Shiny.inputBindings.register(eventButtonBinding);
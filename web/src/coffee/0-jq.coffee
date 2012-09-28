
# jquery extensions and plugins



do ($=jQuery)->

  # center any element
  $.fn.center = ->
    @css "position", "absolute"
    @css "top", Math.max(0, (($(window).height() - @outerHeight()) / 2) + $(window).scrollTop()) + "px"
    @css "left", Math.max(0, (($(window).width() - @outerWidth()) / 2) + $(window).scrollLeft()) + "px"
    @

load = ->
  $('#page.index-index').each ->  # TODO beware pjax throwing this off
    # server offset
    skew = 0
    $.get '/now', (server) -> skew = new Date(parseInt(server)) - new Date

    $('table.timeline').each ->
      $table = $(this)

      now = new Date
      $next = null
      $('tbody', $table).each ->
        $tbody = $(this)

        # translate to local time
        $time = $('[datetime]', this)
        $tbody.data 'moment', t = moment $time.attr('datetime')
        $time.text t.format('MMM DD LT')

        # set which one is next
        if t < now
          $(this).addClass('old')
        else
          $next ||= $(this).addClass('next')

      # countdown
      parts = (s) ->
        s /= 1000
        _.map([s / 86400, s % 86400 / 3600, s % 3600 / 60, s % 60], Math.floor)
      pad = (s) -> if s >= 10 then s else '0' + s

      do tick = ->
        now = new Date
        t = $next.data('moment')
        diff = t - now - skew
        if diff > 0
          p = parts diff
          $time = $('[datetime]', $next).empty()
          $time.text t.format('MMM DD LT')
          countdown = $('<p class="countdown">').appendTo($time)
          countdown.append "#{p[0]}d " if p[0]
          countdown.append _.map(p[1..3], pad).join(':')
          setTimeout tick, 800
        else
          $next = $next
            .toggleClass('next old')
            .next('tbody').addClass('next')
          tick()  # scary

$(load)
$(document).bind 'end.pjax', load

load = ->
  $('#page.index-index').each ->  # TODO beware pjax throwing this off
    # server offset
    skew = 0
    $.get '/now', (server) -> skew = new Date(parseInt(server)) - new Date

    $('table.timeline').each ->
      $table = $(this)
      $next = null

      setNext = (tbody) ->
        $next = $(tbody).closest('tbody').attr('class', 'next')
        $next
          .prev('tbody').attr('class', 'current')
          .prevAll('tbody').attr('class', 'old')
        $next.nextAll('tbody').attr('class', null)

        $('.details', $table).height 0
        details = $next.prev('tbody').find('.details').css('height', 'auto')
        details.height details.height()

      $table.on 'click', 'tr.header', -> setNext this

      now = new Date
      $('tbody', $table).each ->
        $tbody = $(this)

        # translate to local time
        $time = $('[datetime]', this)
        $tbody.data 'moment', t = moment $time.attr('datetime')
        $time.text t.format('MMM DD LT')

        # set which one is next
        if t < now
          $(this).prev('tbody').addClass('old')
        else if $next is null
          setNext this

      # countdown
      parts = (s) ->
        s /= 1000
        _.map([s / 86400, s % 86400 / 3600, s % 3600 / 60, s % 60], Math.floor)
      pad = (s) -> if s >= 10 then s else '0' + s

      do tick = ->
        diff = $next.data('moment') - new Date - skew

        return if isNaN diff

        if diff > 0
          $countdown = $('td.countdown', $next).text('in ')
          if $countdown.length is 0
            $countdown = $('<td class="countdown">in </td>')
              .appendTo($('tr.header', $next))
          p = parts diff
          $countdown.append "#{p[0]}d " if p[0]
          $countdown.append _.map(p[1..3], pad).join(':')
          setTimeout tick, 800
        else
          setNext $next.next('tbody')
          tick()

$(load)
$(document).bind 'end.pjax', load

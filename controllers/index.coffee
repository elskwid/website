app = require '../config/app'
Team = app.db.model 'Team'
Person = app.db.model 'Person'
Service = app.db.model 'Service'
Vote = app.db.model 'Vote'
m = require './middleware'

# middleware
loadCurrentPersonWithTeam = (req, res, next) ->
  return next() unless req.user
  req.user.team (err, team) ->
    return next err if err
    req.team = team
    next()
loadCanRegister = (req, res, next) ->
  Team.canRegister (err, canRegister, left) ->
    return next err if err
    req.canRegister = canRegister
    req.teamsLeft = left
    next()

app.get '/', [loadCanRegister, loadCurrentPersonWithTeam], (req, res, next) ->
  res.render2 'index/index',
    team: req.team

[ 'locations', 'prizes', 'rules', 'sponsors', 'scoring', 'jobs',
  'how-to-win', 'tell-me-a-story' ].forEach (p) ->
  app.get '/' + p, (req, res) -> res.render2 "index/#{p}"

app.get '/about', (req, res) ->
  Team.count {}, (err, teams) ->
    return next err if err
    Person.count { role: 'contestant' }, (err, people) ->
      return next err if err
      Team.count 'entry.votable': true, lastDeploy: {$ne: null}, (err, entries) ->
        return next err if err
        Vote.count {}, (err, votes) ->
          return next err if err
          res.render2 'index/about',
            teams: teams - 1   # compensate for team fortnight
            people: people - 4
            entries: entries
            votes: votes

app.get '/judging', (req, res) ->
  res.redirect '/judges/new'

app.get '/now', (req, res) ->
  res.send Date.now().toString()
  #res.send Date.UTC(2012, 10, 9, 23, 59, 55).toString()     # 0 days left
  #res.send Date.UTC(2012, 10, 8, 23, 59, 55).toString() # 1 -> 0 days left

app.get '/scores', (req, res, next) ->
  Team.sortedByScore (error, teams) ->
    return next error if error
    res.render2 'index/scores', teams: teams

app.get '/scores/update', (req, res, next) ->
  Team.updateAllSavedScores (err) ->
    next err if err
    res.redirect '/scores'

app.get '/resources', (req, res, next) ->
  Service.asObject (error, services) ->
    next error if error
    res.render2 'index/resources', services: services

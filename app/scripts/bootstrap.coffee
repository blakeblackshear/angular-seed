if window.location.pathname is '/runtests'
  jasmineEnv = jasmine.getEnv()
  jasmineEnv.updateInterval = 1000

  htmlReporter = new jasmine.HtmlReporter()
  window.consoleReporter = new jasmine.ConsoleReporter()
  jasmineEnv.addReporter htmlReporter
  jasmineEnv.addReporter window.consoleReporter
  jasmineEnv.specFilter = (spec) ->
    htmlReporter.specFilter spec

  if document.readyState isnt 'complete'
    currentWindowOnload = window.onload
    window.onload = ->
      currentWindowOnload() if currentWindowOnload
      jasmineEnv.execute()
  else
    jasmineEnv.execute()

if document.readyState isnt 'complete'
  angular.element(document).ready ->
    angular.bootstrap document, ['app']
else
  angular.bootstrap document, ['app']

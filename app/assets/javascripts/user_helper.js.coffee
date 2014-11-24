
window.currentUserId = ->
  RollFindr.CurrentUser.get('id')

window.isLoggedIn = ->
  !RollFindr.CurrentUser.isAnonymous()

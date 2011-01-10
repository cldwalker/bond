complete(:methods=>%w{Bond.complete Bond.recomplete}) {
  ["on", "method", "methods", "class", "object", "anywhere", "prefix", "search", "action", "place", "name"]
}
complete(:methods=>['Bond.start', 'Bond.restart']) {
  %w{gems readline default_mission default_search eval_binding debug eval_debug bare}
}

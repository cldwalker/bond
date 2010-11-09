complete(:methods=>%w{Bond.complete Bond.recomplete}) {
  ["on", "method", "methods", "class", "object", "anywhere", "prefix", "search", "action", "place", "name"]
}
complete(:methods=>['Bond.start', 'Bond.restart']) {
  ["gems", "yard_gems", "readline_plugin", "default_mission", "default_search", "eval_binding", "debug", "eval_debug"]
}
complete(:method=>'Bond.load_yard_gems') {
  ["verbose", "reload"]
}

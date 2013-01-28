# xcolor
# Copyright (c) 2013 Charles Moncrief <cmoncrief@gmail.com>
# MIT Licensed

fs      = require 'fs'
{reset} = require './codes'
convert = require './convert'

custom = {}

format = (str) ->
  str = str.replace /\{\{([\s\S]*?)\}\}/g, (str, p1) -> convert p1, custom
  str = str.replace /(\&=[\S][\S])/g, (str, p1) -> convert p1, custom
  str = str.replace /(\&\[?[+nN]?[?\S]?)/g, (str, p1) -> convert p1, custom

  unless str.match /\x1B\[0m$/ then str = "#{str}#{reset}"
  str

addStyle = (style = {}) ->
  custom[key] = value for key, value of style

clearStyles = ->
  custom = {}

loadStyles = (fileName) ->
  try
    fileInput = JSON.parse(fs.readFileSync fileName)
    custom[key] = value for key, value of fileInput
  catch error
    return error

log = (input, args...) ->
  console.log format(input), args...

module.exports = format
module.exports.log = log
module.exports.addStyle = addStyle
module.exports.loadStyles = loadStyles

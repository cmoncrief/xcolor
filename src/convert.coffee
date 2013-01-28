{prefix, suffix, reset, keywords, miniColors, degrade} = require './codes'

custom = {}

convert = (input, styles = {}) ->

  return '' unless input

  custom = styles

  if input.match /^bg /
    base = 10
    input = input.slice(3)

  if parseInt(input)
    convertXterm input, base
  else if input[0] is '.' or input[1] is '.'
    convertCustom input
  else if input[0] is '#'
    convertHex input, base
  else if input[0] is '&'
    convertMini input
  else
    convertKeyword input, base

convertXterm = (input, base = 0) ->
  num = parseInt input
  unless 256 > num > 0 then return ''

  if process.env.TERM and process.env.TERM is 'xterm-256color'
    encode "#{38 + base};5;#{num}"
  else
    convertKeyword miniColors[degrade[num]], base

convertKeyword = (input, base = 0) ->

  if input.charAt(0) is '/'
    isReset = true
    input = input.slice(1)

  unless keyword = keywords[input.toLowerCase()] then return ''

  if keyword.hex?
    convertHex keyword.hex, base
  else
    escape = if isReset then keyword.reset else keyword.init
    encode escape + base

convertHex = (hex, base = 0) ->

  hex = hex.substring 1

  red = hex.substring 0, 2
  green = hex.substring 2, 4
  blue = hex.substring 4, 6

  r = Math.round(parseInt(red, 16) / 255 * 5)
  g = Math.round(parseInt(green, 16) / 255 * 5)
  b = Math.round(parseInt(blue, 16) / 255 * 5)

  rgb = 16 + (r * 36) + (g * 6) + b

  convertXterm rgb, base

convertMini = (input) ->

  if input.length < 3 then return ''

  switch input[1]
    when '+'
      unless miniColors[input[2]]? and keywords[miniColors[input[2]]] then return ''
      encode keywords[miniColors[input[2]]].init
    when '='
      unless miniColors[input[2]]? and keywords[miniColors[input[2]]] then return ''
      unless miniColors[input[3]]? and keywords[miniColors[input[3]]] then return ''
      bg = encode keywords[miniColors[input[2]]].init + 10
      fg = encode keywords[miniColors[input[3]]].init
      bg + fg
    when 'n', 'N'
      reset
    else
      ''

convertCustom = (input) ->

  output = ''
  input = input.substring 1

  if style = custom[input]
    unless Array.isArray(style) then style = [style]
    output += convert(i) for i in style

  output

encode = (escape) ->
  "#{prefix}#{escape}#{suffix}"

module.exports = convert

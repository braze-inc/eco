# regex to grab the contents of '__out.push(...)'
pushRe = /__out\.push\((.*)\)/
sanitizeRe = /__sanitize\((.*)\)/
commentRe = /^\/\/ (.*)$/

module.exports = class Unprocessor
  @unprocess: (source) ->
    unprocessor = new Unprocessor source
    unprocessor.unprocess()

  constructor: (source) ->
    @source = source
    @output = []

  unprocess: ->
    source = @source.split('\n')

    for line in source
      # get indents
      indent = " ".repeat(line.search(/\S|$/))

      # if this line is more stringlike, then...
      if line.includes("__out.push")
        # get the line to be pushed onto the template file 
        actual = @breakOutPush(line)

        # if the line is an empty string/undefined, skip
        if !actual
          continue

        # otherwise, push onto output
        @output.push(indent + actual)
      # if this line is a comment, then...
      else if commentRe.test(line)
        # grab the comment text
        comment = line.match(commentRe)[1]

        # push it into output
        @output.push(indent + "<%# " + comment + " %>")

      # otherwise, pop it into a regular JS interpolation
      else
        # trim the line to get rid of unwanted whitespace
        trimmed = line.replace(/this./g, "").trim()

        # if after trimming we're left with empty string, then skip
        if !trimmed
          continue

        # otherwise push to output
        @output.push(indent + "<% " + trimmed + " %>")

    # join all strings
    return @output.filter((line) -> line).join("\n")

  breakOutPush: (string) ->
    # grab the innards of the '__out.push(...)'
    pushMatch = string.match(pushRe)[1]

    # if the contents include 'JST', we have to handle it differently
    if pushMatch.includes("JST")
      return "<%- " + pushMatch + " %>"

    # check if it contains '__sanitize'
    if pushMatch.includes("__sanitize")
      return "<%= " + pushMatch.match(sanitizeRe)[1].replace(/this./g, "") + " %>"

    # get rid of extra linebreaks and apostrophes
    result = pushMatch.split("\\n").join("").split("'").join("").trim()

    return result
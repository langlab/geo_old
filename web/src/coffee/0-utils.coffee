
module "App.Utils", (exports, top)->

  class Encode

    @toHex: (n)->
      digitArray = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"]
      result = ""
      start = true
      i = 32

      while i > 0
        i -= 4
        digit = (n >> i) & 0xf
        if not start or digit isnt 0
          start = false
          result += digitArray[digit]

      (if result is "" then "0" else result)

  exports.Encode = Encode

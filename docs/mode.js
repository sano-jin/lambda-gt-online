"use strict";

var oop = require("../lib/oop");
var TextHighlightRules = require("./text_highlight_rules").TextHighlightRules;

var OcamlHighlightRules = function () {
  var keywords = "case|of|" + "let|rec|in|" + "nu|\\\\.";

  var builtinConstants = "true|false";

  var keywordMapper = this.createKeywordMapper(
    {
      "variable.language": "this",
      keyword: keywords,
      "constant.language": builtinConstants,
    },
    "identifier"
  );

  var decimalInteger = "(?:(?:[1-9]\\d*)|(?:0))";
  var octInteger = "(?:0[oO]?[0-7]+)";
  var hexInteger = "(?:0[xX][\\dA-Fa-f]+)";
  var binInteger = "(?:0[bB][01]+)";
  var integer =
    "(?:" +
    decimalInteger +
    "|" +
    octInteger +
    "|" +
    hexInteger +
    "|" +
    binInteger +
    ")";

  var exponent = "(?:[eE][+-]?\\d+)";
  var fraction = "(?:\\.\\d+)";
  var intPart = "(?:\\d+)";
  var pointFloat =
    "(?:(?:" + intPart + "?" + fraction + ")|(?:" + intPart + "\\.))";
  var exponentFloat =
    "(?:(?:" + pointFloat + "|" + intPart + ")" + exponent + ")";
  var floatNumber = "(?:" + exponentFloat + "|" + pointFloat + ")";

  this.$rules = {
    start: [
      {
        token: "comment",
        regex: "^s*%.*",
      },
      {
        token: "constant.numeric", // imaginary
        regex: "(?:" + floatNumber + "|\\d+)[jJ]\\b",
      },
      {
        token: "constant.numeric", // float
        regex: floatNumber,
      },
      {
        token: "constant.numeric", // integer
        regex: integer + "\\b",
      },
      {
        token: keywordMapper,
        regex: "[a-z][a-zA-Z0-9_$]*\\b",
      },
      {
        token: "constant.language",
        regex: "[A-Z][a-zA-Z0-9_$]*\\b",
      },
      {
        token: "markup.italic",
        regex: "_[a-zA-Z0-9_]*",
      },
      {
        token: "keyword.operator",
        regex:
          "\\.|\\\\|\\+\\.|\\-\\.|\\*\\.|\\/\\.|#|;;|\\+|\\-|\\*|\\*\\*\\/|\\/\\/|%|<<|>>|&|\\||\\^|~|<|>|<=|=>|==|!=|<>|<-|=",
      },
      {
        token: "paren.lparen",
        regex: "[[({]",
      },
      {
        token: "paren.rparen",
        regex: "[\\])}]",
      },
      {
        token: "text",
        regex: "\\s+",
      },
    ],
  };
};

oop.inherits(OcamlHighlightRules, TextHighlightRules);

exports.OcamlHighlightRules = OcamlHighlightRules;

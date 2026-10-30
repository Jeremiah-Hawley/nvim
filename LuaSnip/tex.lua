-- LuaSnip LaTeX Snippets
-- Converted from UltiSnips format
-- ~/.config/nvim/luasnip/tex.lua

local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local extras = require("luasnip.extras")
local l = extras.lambda
local rep = extras.rep
local p = extras.partial
local m = extras.match
local n = extras.nonempty
local dl = extras.dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local conds = require("luasnip.extras.expand_conditions")
local postfix = require("luasnip.extras.postfix").postfix
local types = require("luasnip.util.types")
local parse = require("luasnip.util.parser").parse_snippet
local ms = ls.multi_snippet
local k = require("luasnip.nodes.key_indexer").new_key



-- Unified math zone detection for both .tex and .md files
-- For .tex: Uses VimTeX's accurate syntax detection
-- For .md: Uses vim-markdown's texMathZone* syntax groups (requires g:vim_markdown_math = 1)
local function math()
  local ft = vim.bo.filetype
  
  -- For .tex files, use VimTeX's accurate detection
  if ft == "tex" or ft == "latex" then
    return vim.fn["vimtex#syntax#in_mathzone"]() == 1
  end
  
  -- For markdown files with vim-markdown, check tex syntax groups
  -- vim-markdown with math=1 injects tex syntax into $...$ and $$...$$ regions
  if ft == "markdown" then
    local synstack = vim.fn.synstack(vim.fn.line('.'), vim.fn.col('.'))
    for _, syn_id in ipairs(synstack) do
      local syn_name = vim.fn.synIDattr(syn_id, 'name')
      -- vim-markdown creates texMathZone* groups for math regions
      if syn_name:match('^texMath') or syn_name:match('^mkdMath') then
        return true
      end
    end
    return false
  end
  
  return false
end

local function comment()
  return vim.fn["vimtex#syntax#in_comment"]() == 1
end

local function env(name)
  local x, y = unpack(vim.fn["vimtex#env#is_inside"](name))
  return x ~= "0" and y ~= "0"
end

-- Greek letters constant
local GREEK = "alpha|beta|gamma|Gamma|delta|Delta|epsilon|varepsilon|zeta|eta|theta|vartheta|Theta|iota|kappa|lambda|Lambda|mu|nu|xi|omicron|pi|rho|varrho|sigma|Sigma|tau|upsilon|Upsilon|phi|varphi|Phi|chi|psi|omega|Omega"
local SYMBOL = "parallel|perp|partial|nabla|hbar|ell|infty|oplus|ominus|otimes|oslash|square|star|dagger|vee|wedge|subseteq|subset|supseteq|supset|emptyset|exists|nexists|forall|implies|impliedby|iff|setminus|neg|lor|land|bigcup|bigcap|cdot|times|simeq|approx"
local MORE_SYMBOLS = "leq|geq|neq|gg|ll|equiv|sim|propto|rightarrow|leftarrow|Rightarrow|Leftarrow|leftrightarrow|to|mapsto|cap|cup|in|sum|prod|exp|ln|log|det|dots|vdots|ddots|pm|mp|int|iint|iiint|oint"

return {
  -- Math mode (auto-triggering)
  s("mk", {
    t("$"), i(1), t("$")
  }, {
    snippetType = "autosnippet"
  }),
  
  s("dm", {
    t({"\\[", ""}), i(1), t({"", "\\]"})
  }, {
    condition = conds.line_begin,
    snippetType = "autosnippet"
  }),

  -- LaTeX Preamble
  s("problemset", fmt(
    [[
\documentclass{{article}}
\usepackage{{problemset}}

% Course setup
\setcourse{{{}}}
\setassignmentname{{{}}}
\setstudentname{{john doe}}
\setnetid{{abc123}}
\setduedate{{{}}}
\setcollaborators{{{}}}

\begin{{document}}
\initproblemset  % Initialize headers/footers

{}

\end{{document}}
    ]], {
      i(1, "CS 101"),
      i(2, "Problem Set 1"),
      i(3, "January 15, 2024"),
      i(4, "None"),
      i(0)
    }
  ), {
    condition = conds.line_begin
  }),

  -- Problem environments
  s("prob", fmt(
    [[
\begin{{problem}}[{}]
{}
\end{{problem}}
    ]], {
      i(1),
      i(0)
    }
  ), {
    condition = conds.line_begin
  }),

  s("subprob", fmt(
    [[
\begin{{subproblem}}
{}
\end{{subproblem}}
    ]], {
      i(0)
    }
  ), {
    condition = conds.line_begin
  }),

  s("sol", fmt(
    [[
\begin{{solution}}
{}
\end{{solution}}
    ]], {
      i(0)
    }
  ), {
    condition = conds.line_begin
  }),

  s("subsol", fmt(
    [[
\begin{{subsolution}}
{}
\end{{subsolution}}
    ]], {
      i(0)
    }
  ), {
    condition = conds.line_begin
  }),

  s("theorem_envs", {
    t({
      "% Theorem environments",
      "\\newtheorem{theorem}{Theorem}[section]",
      "\\newtheorem{lemma}[theorem]{Lemma}",
      "\\newtheorem{corollary}[theorem]{Corollary}",
      "\\newtheorem{proposition}[theorem]{Proposition}",
      "\\newtheorem{claim}[theorem]{Claim}",
      "\\newtheorem{conjecture}[theorem]{Conjecture}",
      "",
      "\\theoremstyle{definition}",
      "\\newtheorem{definition}[theorem]{Definition}",
      "\\newtheorem{example}[theorem]{Example}",
      "\\newtheorem{exercise}[theorem]{Exercise}",
      "\\newtheorem{axiom}[theorem]{Axiom}",
      "\\newtheorem{assumption}[theorem]{Assumption}",
      "\\newtheorem{hypothesis}[theorem]{Hypothesis}",
      "",
      "\\theoremstyle{remark}",
      "\\newtheorem{remark}[theorem]{Remark}",
    }),
  }),

  -- Begin environment (math context, auto-triggering)
  s("beg", {
    t("\\begin{"), i(1), t("}"),
    t({"", ""}), i(2), t({"", "\\end{"}), rep(1), t("}")
  }, {
    condition = math,
    snippetType = "autosnippet"
  }),

  -- Theorem environments - simplified triggers (all auto-triggering)
  s("axm", fmt("\\begin{{axiom}}{}\n{}\n\\end{{axiom}}", {
    f(function(args) return args[1][1] ~= "" and "[" .. args[1][1] .. "]" or "" end, {1}),
    i(2)
  }, {
    i(1)
  }), {
    condition = conds.line_begin,
    snippetType = "autosnippet"
  }),

  s("def", fmt("\\begin{{definition}}{}\n{}\n\\end{{definition}}", {
    f(function(args) return args[1][1] ~= "" and "[" .. args[1][1] .. "]" or "" end, {1}),
    i(2)
  }, {
    i(1)
  }), {
    condition = conds.line_begin,
    snippetType = "autosnippet",
    priority = 10
  }),

  s("lem", fmt("\\begin{{lemma}}{}\n{}\n\\end{{lemma}}", {
    f(function(args) return args[1][1] ~= "" and "[" .. args[1][1] .. "]" or "" end, {1}),
    i(2)
  }, {
    i(1)
  }), {
    condition = conds.line_begin,
    snippetType = "autosnippet"
  }),

  s("prp", fmt("\\begin{{proposition}}{}\n{}\n\\end{{proposition}}", {
    f(function(args) return args[1][1] ~= "" and "[" .. args[1][1] .. "]" or "" end, {1}),
    i(2)
  }, {
    i(1)
  }), {
    condition = conds.line_begin,
    snippetType = "autosnippet"
  }),

  s("thm", fmt("\\begin{{theorem}}{}\n{}\n\\end{{theorem}}", {
    f(function(args) return args[1][1] ~= "" and "[" .. args[1][1] .. "]" or "" end, {1}),
    i(2)
  }, {
    i(1)
  }), {
    condition = conds.line_begin,
    snippetType = "autosnippet"
  }),

  s("cor", fmt("\\begin{{corollary}}{}\n{}\n\\end{{corollary}}", {
    f(function(args) return args[1][1] ~= "" and "[" .. args[1][1] .. "]" or "" end, {1}),
    i(2)
  }, {
    i(1)
  }), {
    condition = conds.line_begin,
    snippetType = "autosnippet"
  }),

  s("clm", fmt("\\begin{{claim}}{}\n{}\n\\end{{claim}}", {
    f(function(args) return args[1][1] ~= "" and "[" .. args[1][1] .. "]" or "" end, {1}),
    i(2)
  }, {
    i(1)
  }), {
    condition = conds.line_begin,
    snippetType = "autosnippet"
  }),

  s("asm", fmt("\\begin{{assumption}}{}\n{}\n\\end{{assumption}}", {
    f(function(args) return args[1][1] ~= "" and "[" .. args[1][1] .. "]" or "" end, {1}),
    i(2)
  }, {
    i(1)
  }), {
    condition = conds.line_begin,
    snippetType = "autosnippet"
  }),

  s("exm", fmt("\\begin{{example}}{}\n{}\n\\end{{example}}", {
    f(function(args) return args[1][1] ~= "" and "[" .. args[1][1] .. "]" or "" end, {1}),
    i(2)
  }, {
    i(1)
  }), {
    condition = conds.line_begin,
    snippetType = "autosnippet"
  }),

  s("exr", fmt("\\begin{{exercise}}{}\n{}\n\\end{{exercise}}", {
    f(function(args) return args[1][1] ~= "" and "[" .. args[1][1] .. "]" or "" end, {1}),
    i(2)
  }, {
    i(1)
  }), {
    condition = conds.line_begin,
    snippetType = "autosnippet"
  }),

  s("cnj", fmt("\\begin{{conjecture}}{}\n{}\n\\end{{conjecture}}", {
    f(function(args) return args[1][1] ~= "" and "[" .. args[1][1] .. "]" or "" end, {1}),
    i(2)
  }, {
    i(1)
  }), {
    condition = conds.line_begin,
    snippetType = "autosnippet"
  }),

  s("hyp", fmt("\\begin{{hypothesis}}{}\n{}\n\\end{{hypothesis}}", {
    f(function(args) return args[1][1] ~= "" and "[" .. args[1][1] .. "]" or "" end, {1}),
    i(2)
  }, {
    i(1)
  }), {
    condition = conds.line_begin,
    snippetType = "autosnippet"
  }),

  s("rmk", fmt("\\begin{{remark}}{}\n{}\n\\end{{remark}}", {
    f(function(args) return args[1][1] ~= "" and "[" .. args[1][1] .. "]" or "" end, {1}),
    i(2)
  }, {
    i(1)
  }), {
    condition = conds.line_begin,
    snippetType = "autosnippet"
  }),

  s("prf", fmt("\\begin{{proof}}\n{}\n\\end{{proof}}", {
    i(0)
  }), {
    condition = conds.line_begin,
    snippetType = "autosnippet"
  }),

  -- Greek letters (math context, all auto-triggering)
  s(";a", t("\\alpha"), { condition = math, snippetType = "autosnippet" }),
  s(";b", t("\\beta"), { condition = math, snippetType = "autosnippet" }),
  s(";g", t("\\gamma"), { condition = math, snippetType = "autosnippet" }),
  s(";G", t("\\Gamma"), { condition = math, snippetType = "autosnippet" }),
  s(";d", t("\\delta"), { condition = math, snippetType = "autosnippet" }),
  s(";D", t("\\Delta"), { condition = math, snippetType = "autosnippet" }),
  s(";e", t("\\epsilon"), { condition = math, snippetType = "autosnippet" }),
  s(":e", t("\\varepsilon"), { condition = math, snippetType = "autosnippet" }),
  s(";z", t("\\zeta"), { condition = math, snippetType = "autosnippet" }),
  s(";t", t("\\tau"), { condition = math, snippetType = "autosnippet" }),
  s(";T", t("\\Tau"), { condition = math, snippetType = "autosnippet" }),
  s(";h", t("\\theta"), { condition = math, snippetType = "autosnippet" }),
  s(";H", t("\\Theta"), { condition = math, snippetType = "autosnippet" }),
  s(":t", t("\\vartheta"), { condition = math, snippetType = "autosnippet" }),
  s(";i", t("\\iota"), { condition = math, snippetType = "autosnippet" }),
  s(";k", t("\\kappa"), { condition = math, snippetType = "autosnippet" }),
  s(";l", t("\\lambda"), { condition = math, snippetType = "autosnippet" }),
  s(";L", t("\\Lambda"), { condition = math, snippetType = "autosnippet" }),
  s(";s", t("\\sigma"), { condition = math, snippetType = "autosnippet" }),
  s(";S", t("\\Sigma"), { condition = math, snippetType = "autosnippet" }),
  s(";u", t("\\upsilon"), { condition = math, snippetType = "autosnippet" }),
  s(";U", t("\\Upsilon"), { condition = math, snippetType = "autosnippet" }),
  s(";o", t("\\omega"), { condition = math, snippetType = "autosnippet" }),
  s(";O", t("\\Omega"), { condition = math, snippetType = "autosnippet" }),
  s("ome", t("\\omega"), { condition = math, snippetType = "autosnippet" }),
  s("Ome", t("\\Omega"), { condition = math, snippetType = "autosnippet" }),
  s(";q", t("\\psi"), { condition = math, snippetType = "autosnippet" }),
  s(";Q", t("\\Psi"), { condition = math, snippetType = "autosnippet" }),
  s(";p", t("\\phi"), { condition = math, snippetType = "autosnippet" }),
  s(";P", t("\\Phi"), { condition = math, snippetType = "autosnippet" }),
  s("pi", t("\\pi"), { condition = math, snippetType = "autosnippet" }),
  s(";n", t("\\nu"), { condition = math, snippetType = "autosnippet" }),
  s(";m", t("\\mu"), { condition = math, snippetType = "autosnippet" }),
  s(";r", t("\\rho"), { condition = math, snippetType = "autosnippet" }),

  s("hb", t("\\hbar"), { condition = math, snippetType = "autosnippet", priority = 50 }),
  s("ell", t("\\ell"), { condition = math, snippetType = "autosnippet"}),

  s("sin", t("\\sin"), { condition = math, snippetType = "autosnippet"}),
  s("cos", t("\\cos"), { condition = math, snippetType = "autosnippet"}),
  s("qed", t("\\qed"), { condition = math, snippetType = "autosnippet" }),


  -- Text environment (math context, auto-triggering)
  s("text", fmt("\\text{{{}}}{}", { i(1), i(0) }), { condition = math, snippetType = "autosnippet" }),
  s("\"", fmt("\\text{{{}}}{}", { i(1), i(0) }), { condition = math, snippetType = "autosnippet" }),

  -- Basic operations (math context, auto-triggering)
  s("sr", t("^{2}"), { condition = math, snippetType = "autosnippet" }),
  s("cb", t("^{3}"), { condition = math, snippetType = "autosnippet" }),
  s("rd", fmt("^{{{}}}{}", { i(1), i(0) }), { condition = math, snippetType = "autosnippet" }),
  s("_", fmt("_{{{}}}{}", { i(1), i(0) }), { condition = math, snippetType = "autosnippet" }),
  s("sts", fmt("_\\text{{{}}}", { i(1) }), { condition = math, snippetType = "autosnippet" }),
  s("sq", fmt("\\sqrt{{ {} }}{}", { i(1), i(0) }), { condition = math, snippetType = "autosnippet" }),
  s("//", fmt("\\frac{{{}}}{{{}}}{}", { i(1), i(2), i(0) }), { condition = math, snippetType = "autosnippet" }),
  s("ee", fmt("e^{{ {} }}{}", { i(1), i(0) }), { condition = math, snippetType = "autosnippet" }),
  s("invs", t("^{-1}"), { condition = math, snippetType = "autosnippet" }),
  s("conj", t("^{*}"), { condition = math, snippetType = "autosnippet" }),
  s("Re", t("\\mathrm{Re}"), { condition = math, snippetType = "autosnippet" }),
  s("Im", t("\\mathrm{Im}"), { condition = math, snippetType = "autosnippet" }),
  s("bf", fmt("\\mathbf{{{}}}", { i(1) }), { condition = math, snippetType = "autosnippet" }),
  s("rm", fmt("\\mathrm{{{}}}{}", { i(1), i(0) }), { condition = math, snippetType = "autosnippet" }),
  s("mf", fmt("\\mathfrak{{{}}}{}", { i(1), i(0) }), { condition = math, snippetType = "autosnippet" }),
  s({trig = "df", snippetType = "autosnippet",  condition = math }, { t("\\diff") }), -- requires defining \diff in preamble or .sty file

  -- Linear algebra (auto-triggering)
  s("trace", t("\\mathrm{Tr}"), { condition = math, snippetType = "autosnippet" }),

  -- More operations (math context, auto-triggering)
  s("hat", fmt("\\hat{{{}}}{}", { i(1), i(0) }), { condition = math, snippetType = "autosnippet", priority = 5 }),
  s("bar", fmt("\\bar{{{}}}{}", { i(1), i(0) }), { condition = math, snippetType = "autosnippet" }),
  s("dot", fmt("\\dot{{{}}}{}", { i(1), i(0) }), { condition = math, priority = 5, snippetType = "autosnippet" }),
  s("ddot", fmt("\\ddot{{{}}}{}", { i(1), i(0) }), { condition = math, priority = 10, snippetType = "autosnippet" }),
  s("cdot", t("\\cdot"), { condition = math, priority = 6, snippetType = "autosnippet" }),
  s("cdots", t("\\cdots"), { condition = math, priority = 7, snippetType = "autosnippet" }),
  s("tilde", fmt("\\tilde{{{}}}{}", { i(1), i(0) }), { condition = math, snippetType = "autosnippet" }),
  s("und", fmt("\\underline{{{}}}{}", { i(1), i(0) }), { condition = math, snippetType = "autosnippet" }),
  s("vec", fmt("\\vec{{{}}}{}", { i(1), i(0) }), { condition = math, snippetType = "autosnippet" }),
  s("bk", fmt("\\boxed{{{}}}{}", { i(1), i(0) }), { condition = math, snippetType = "autosnippet" }),

  -- Common subscripts (math context, auto-triggering) - higher priority than auto-subscript
  s("xnn", t("x_{n}"), { condition = math, snippetType = "autosnippet", priority = 100 }),
  s("xii", t("x_{i}"), { condition = math, priority = 100, snippetType = "autosnippet" }),
  s("xjj", t("x_{j}"), { condition = math, snippetType = "autosnippet", priority = 100 }),
  s("xp1", t("x_{n+1}"), { condition = math, snippetType = "autosnippet", priority = 100 }),
  s("ynn", t("y_{n}"), { condition = math, snippetType = "autosnippet", priority = 100 }),
  s("yii", t("y_{i}"), { condition = math, snippetType = "autosnippet", priority = 100 }),
  s("yjj", t("y_{j}"), { condition = math, snippetType = "autosnippet", priority = 100 }),

  -- Symbols (math context, auto-triggering)
  s("ooo", t("\\infty"), { condition = math, snippetType = "autosnippet" }),
  s("sum", {
    t("\\sum"),
    c(1, {
      t(""), -- First choice: nothing (just \sum)
      sn(nil, { t("_{"), i(1, "i"), t(" = "), i(2, "1"), t("}^{"), i(3, "n"), t("}") }) -- Second choice: with bounds
    }),
    t(" "),
    i(0)
  }, { condition = math, snippetType = "autosnippet" }),
  
  s("prod", {
    t("\\prod"),
    c(1, {
      t(""), -- First choice: nothing (just \prod)
      sn(nil, { t("_{"), i(1, "i"), t(" = "), i(2, "1"), t("}^{"), i(3, "n"), t("}") }) -- Second choice: with bounds
    }),
    t(" "),
    i(0)
  }, { condition = math, snippetType = "autosnippet" }),
  s("lim", fmt("\\lim_{{ {} \\to {} }} {}", { i(1, "n"), i(2, "\\infty"), i(0) }), { condition = math, snippetType = "autosnippet" }),
  s("+-", t("\\pm"), { condition = math, snippetType = "autosnippet" }),
  s("-+", t("\\mp"), { condition = math, snippetType = "autosnippet" }),
  s("...", t("\\dots"), { condition = math, snippetType = "autosnippet" }),
  s("nabl", t("\\nabla"), { condition = math, snippetType = "autosnippet" }),
  s("del", t("\\nabla"), { condition = math, snippetType = "autosnippet" }),
  s("grad", t("\\nabla"), { condition = math, snippetType = "autosnippet" }),
  s("div", t("\\nabla \\cdot"), { condition = math, snippetType = "autosnippet" }),
  s("curl", t("\\nabla \\times"), { condition = math, snippetType = "autosnippet" }),
  s("xx", t("\\times"), { condition = math, snippetType = "autosnippet" }),
  s("**", t("\\cdot"), { condition = math, snippetType = "autosnippet" }),
  s("para", t("\\parallel"), { condition = math, snippetType = "autosnippet" }),
  s("===", t("\\equiv"), { condition = math, snippetType = "autosnippet" }),
  s("app", t("\\approx"), { condition = math, snippetType = "autosnippet" }),
  s("!=", t("\\neq"), { condition = math, snippetType = "autosnippet" }),
  s(">=", t("\\geq"), { condition = math, snippetType = "autosnippet" }),
  s("<=", t("\\leq"), { condition = math, snippetType = "autosnippet" }),
  s(">>", t("\\gg"), { condition = math, snippetType = "autosnippet" }),
  s("<<", t("\\ll"), { condition = math, snippetType = "autosnippet" }),
  s("simm", t("\\sim"), { condition = math, snippetType = "autosnippet" }),
  s("sim=", t("\\simeq"), { condition = math, snippetType = "autosnippet" }),
  s("prop", t("\\propto"), { condition = math, snippetType = "autosnippet" }),
  s("<->", t("\\leftrightarrow"), { condition = math, snippetType = "autosnippet" }),
  s("->", t("\\to"), { condition = math, snippetType = "autosnippet" }),
  s("!>", t("\\mapsto"), { condition = math, snippetType = "autosnippet" }),
  s("!x>", fmt("\\xmapsto{{{}}}", { i(1) }), { condition = math, snippetType = "autosnippet" }),
  s("=>", t("\\implies"), { condition = math, snippetType = "autosnippet" }),
  s("=<", t("\\impliedby"), { condition = math, snippetType = "autosnippet" }),
  s("and", t("\\cap"), { condition = math, snippetType = "autosnippet" }),
  s("orr", t("\\cup"), { condition = math, snippetType = "autosnippet" }),
  s("scup", t("\\sqcup"), { condition = math, snippetType = "autosnippet" }),
  s("inn", t("\\in"), { condition = math, snippetType = "autosnippet" }),
  s("notin", t("\\not\\in"), { condition = math, snippetType = "autosnippet" }),
  s("\\\\\\\\\\\\\\", t("\\setminus"), { condition = math, snippetType = "autosnippet" }),
  s("sm", t("\\setminus"), { condition = math, snippetType = "autosnippet" }),
  s("sub=", t("\\subseteq"), { condition = math, snippetType = "autosnippet" }),
  s("sup=", t("\\supseteq"), { condition = math, snippetType = "autosnippet" }),
  s("eset", t("\\emptyset"), { condition = math, snippetType = "autosnippet" }),
  s("set", fmt("\\{{ {} \\}}{}", { i(1), i(0) }), { condition = math, snippetType = "autosnippet" }),
  s("cc", t("\\subset"), { condition = math, snippetType = "autosnippet" }),
  s("\\ve", t("\\vee"), { condition = math, snippetType = "autosnippet" }),
  s("\\we", t("\\wedge"), { condition = math, snippetType = "autosnippet" }),


  -- Function (auto-triggering)
  s("fun", fmt("f: {} \\to {} : {}", { i(1, "\\mathbb{R}"), i(2, "\\mathbb{R}"), i(0) }), { condition = math, snippetType = "autosnippet" }),

  -- Common sets (math context, auto-triggering)
  s("LL", t("\\mathcal{L}"), { condition = math, snippetType = "autosnippet" }),
  s("HH", t("\\mathcal{H}"), { condition = math, snippetType = "autosnippet" }),
  s("CC", t("\\mathbb{C}"), { condition = math, snippetType = "autosnippet" }),
  s("RR", t("\\mathbb{R}"), { condition = math, snippetType = "autosnippet" }),
  s("QQ", t("\\mathbb{Q}"), { condition = math, snippetType = "autosnippet" }),
  s("ZZ", t("\\mathbb{Z}"), { condition = math, snippetType = "autosnippet" }),
  s("NN", t("\\mathbb{N}"), { condition = math, snippetType = "autosnippet" }),
  s("FF", t("\\mathbb{F}"), { condition = math, snippetType = "autosnippet" }),
  s("hh", t("\\mathbb{H}"), { condition = math, snippetType = "autosnippet" }),
  s("mcal", fmt("\\mathcal{{{}}}", { i(1) }), { condition = math, snippetType = "autosnippet" }),

  -- Derivatives and integrals (math context, auto-triggering)
  s("par", fmt("\\frac{{ \\partial {} }}{{ \\partial {} }} {}", { i(1, "y"), i(2, "x"), i(0) }), { condition = math, snippetType = "autosnippet" }),
  s("ddt", t("\\frac{d}{dt}"), { condition = math, snippetType = "autosnippet" }),
  s("dint", fmt("\\int_{{{}}}^{{{}}} {} \\, d{} {}", { i(1, "0"), i(2, "1"), i(3), i(4, "x"), i(0) }), { condition = math, snippetType = "autosnippet" }),
  s("oint", t("\\oint"), { condition = math, snippetType = "autosnippet" }),
  s("iint", t("\\iint"), { condition = math, snippetType = "autosnippet" }),
  s("iiint", t("\\iiint"), { condition = math, snippetType = "autosnippet" }),
  s("oinf", fmt("\\int_{{0}}^{{\\infty}} {} \\, d{} {}", { i(1), i(2, "x"), i(0) }), { condition = math, snippetType = "autosnippet" }),
  s("infi", fmt("\\int_{{-\\infty}}^{{\\infty}} {} \\, d{} {}", { i(1), i(2, "x"), i(0) }), { condition = math, snippetType = "autosnippet" }),

  -- Static Matrix Environments (math context) - lower priority than dynamic
  -- s("pmat", fmt("\\begin{{pmatrix}}\n{}\n\\end{{pmatrix}}", { i(1) }), { condition = math, priority = -50 }),
  -- s("bmat", fmt("\\begin{{bmatrix}}\n{}\n\\end{{bmatrix}}", { i(1) }), { condition = math, priority = -50 }),
  -- s("Bmat", fmt("\\begin{{Bmatrix}}\n{}\n\\end{{Bmatrix}}", { i(1) }), { condition = math, priority = -50 }),
  -- s("vmat", fmt("\\begin{{vmatrix}}\n{}\n\\end{{vmatrix}}", { i(1) }), { condition = math, priority = -50 }),
  -- s("Vmat", fmt("\\begin{{Vmatrix}}\n{}\n\\end{{Vmatrix}}", { i(1) }), { condition = math, priority = -50 }),
  -- s("matrix", fmt("\\begin{{matrix}}\n{}\n\\end{{matrix}}", { i(1) }), { condition = math, priority = -50 }),
  s("cases", fmt("\\begin{{cases}}\n{}\n\\end{{cases}}", { i(1) }), { condition = math }),
  s("align", fmt("\\begin{{align}}\n{}\n\\end{{align}}", { i(1) }), { condition = math }),
  s("align*", fmt("\\begin{{align*}}\n{}\n\\end{{align*}}", { i(1) }), { condition = math }),
  s("eqn*", fmt("\\begin{{equation*}}\n{}\n\\end{{equation*}}", { i(1) }), { condition = math }),
  s("gather", fmt("\\begin{{gather}}\n{}\n\\end{{gather}}", { i(1) }), { condition = math }),
  s("gather*", fmt("\\begin{{gather*}}\n{}\n\\end{{gather*}}", { i(1) }), { condition = math }),
  s("array", fmt("\\begin{{array}}\n{}\n\\end{{array}}", { i(1) }), { condition = math }),

  -- Dynamic Matrix Snippets (e.g., bmat2x3, pmat1x4, etc.) - higher priority than static
  -- Usage: Type "bmat2x3" and it creates a 2x3 bmatrix with tab stops
  s({trig = "([bBpvV])mat(%d+)x(%d+)", regTrig = true, priority = 1000}, {
    f(function(_, snip)
      local matrix_type = snip.captures[1]
      local rows = tonumber(snip.captures[2])
      local cols = tonumber(snip.captures[3])
      
      -- Validate dimensions
      if not rows or not cols or rows < 1 or cols < 1 or rows > 10 or cols > 10 then
        return {"\\text{Invalid matrix dimensions}"}
      end
      
      local matrix_types = {
        b = "bmatrix", B = "Bmatrix", p = "pmatrix", 
        v = "vmatrix", V = "Vmatrix"
      }
      
      return {"\\begin{" .. matrix_types[matrix_type] .. "}", ""}
    end),
    d(1, function(_, snip)
      local rows = tonumber(snip.captures[2])
      local cols = tonumber(snip.captures[3])
      
      -- Validate dimensions again in dynamic node
      if not rows or not cols or rows < 1 or cols < 1 or rows > 10 or cols > 10 then
        return sn(nil, { t("Invalid dimensions") })
      end
      
      local nodes = {}
      local idx = 1
      
      for row = 1, rows do
        -- Add indentation for better formatting
        table.insert(nodes, t("  "))
        
        for col = 1, cols do
          table.insert(nodes, i(idx))
          idx = idx + 1
          if col < cols then
            table.insert(nodes, t(" & "))
          end
        end
        
        if row < rows then
          table.insert(nodes, t({" \\\\", ""}))
        end
      end
      
      return sn(nil, nodes)
    end),
    f(function(_, snip)
      local matrix_type = snip.captures[1]
      local matrix_types = {
        b = "bmatrix", B = "Bmatrix", p = "pmatrix", 
        v = "vmatrix", V = "Vmatrix"
      }
      
      return {"", "\\end{" .. matrix_types[matrix_type] .. "}"}
    end),
    i(0)
  }, { condition = math }),

  -- "Such that" snippet for set notation
  s("such", t("\\,\\mid\\,"), { condition = math, snippetType = "autosnippet" }),

  -- Dynamic Table Snippets (e.g., table2x3, tab1x4, etc.)
  -- Usage: Type "table2x3" and it creates a 2x3 table with tab stops
  s({trig = "table(%d+)x(%d+)", regTrig = true}, {
    t("\\begin{tabular}{"),
    f(function(_, snip)
      local cols = tonumber(snip.captures[2])
      local spec = {}
      for i = 1, cols do
        table.insert(spec, "c")
      end
      return table.concat(spec)
    end),
    t("}"),
    t("\\hline"),
    d(1, function(_, snip)
      local rows = tonumber(snip.captures[1])
      local cols = tonumber(snip.captures[2])
      local nodes = {}
      local idx = 1
      
      for row = 1, rows do
        for col = 1, cols do
          table.insert(nodes, i(idx))
          idx = idx + 1
          if col < cols then
            table.insert(nodes, t(" & "))
          end
        end
        if row < rows then
          table.insert(nodes, t(" \\\\ \\hline"))
        else
          table.insert(nodes, t(" \\\\"))
        end
      end
      table.insert(nodes, t("\\hline"))
      
      return sn(nil, nodes)
    end),
    t("\\end{tabular}"),
    i(0)
  }, { snippetType = "autosnippet" }),

  -- List Environments (not math context, auto-triggering)
  s("enum", fmt("\\begin{{enumerate}}\n\\item {}\n\\end{{enumerate}}", { i(1) })),-- { snippetType = "autosnippet" }),
  s("item", fmt("\\begin{{itemize}}\n\\item {}\n\\end{{itemize}}", { i(1) })),-- { snippetType = "autosnippet" }),
  -- s("desc", fmt("\\begin{{description}}\n\\item[{}] {}\n\\end{{description}}", { i(1), i(2) })),

  -- Brackets (math context, auto-triggering)
  s("avg", fmt("\\langle {} \\rangle {}", { i(1), i(0) }), { condition = math, snippetType = "autosnippet" }),
  s("norm", fmt("\\lvert {} \\rvert {}", { i(1), i(0) }), { condition = math, priority = 1, snippetType = "autosnippet" }),
  s("Norm", fmt("\\lVert {} \\rVert {}", { i(1), i(0) }), { condition = math, priority = 1, snippetType = "autosnippet" }),
  s("ceil", fmt("\\lceil {} \\rceil {}", { i(1), i(0) }), { condition = math, snippetType = "autosnippet" }),
  s("floor", fmt("\\lfloor {} \\rfloor {}", { i(1), i(0) }), { condition = math, snippetType = "autosnippet" }),
  s("mod", fmt("|{}|{}", { i(1), i(0) }), { condition = math, snippetType = "autosnippet" }),

  -- Parentheses: ( is magic, so we use % to escape it
  s({trig = "lr%((%)?)", regTrig = true}, fmt("\\left( {} \\right) {}", { i(1), i(0) }), { condition = math, snippetType = "autosnippet" }),
  -- Curly Braces: { is NOT magic in Lua, so no escape needed
  s({trig = "lr{(}?)", regTrig = true}, fmt("\\left\\{{ {} \\right\\}} {}", { i(1), i(0) }), { condition = math, snippetType = "autosnippet" }),
  -- Square Brackets: [ is magic, so we use % to escape it
  s({trig = "lr%[(%]?)", regTrig = true}, fmt("\\left[ {} \\right] {}", { i(1), i(0) }), { condition = math, snippetType = "autosnippet" }),
  -- Pipes: | is NOT magic in Lua, so no escape needed
  s({trig = "lr|(|?)", regTrig = true}, fmt("\\left| {} \\right| {}", { i(1), i(0) }), { condition = math, snippetType = "autosnippet" }),


  -- s("lr(", fmt("\\left( {} \\right) {}", { i(1), i(0) }), { condition = math, snippetType = "autosnippet" }),
  -- s("lr{", fmt("\\left\\{{ {} \\right\\}} {}", { i(1), i(0) }), { condition = math, snippetType = "autosnippet" }),
  -- s("lr[", fmt("\\left[ {} \\right] {}", { i(1), i(0) }), { condition = math, snippetType = "autosnippet" }),
  -- s("lr|", fmt("\\left| {} \\right| {}", { i(1), i(0) }), { condition = math, snippetType = "autosnippet" }),
  -- s("lra", fmt("\\left< {} \\right> {}", { i(1), i(0) }), { condition = math, snippetType = "autosnippet" }),

  -- Physics (math context, auto-triggering)
  s("kbt", t("k_{B}T"), { condition = math, snippetType = "autosnippet" }),
  s("msun", t("M_{\\odot}"), { condition = math, snippetType = "autosnippet" }),

  -- Quantum mechanics (math context, auto-triggering) - Enhanced with safer triggers
  s("dag", t("^{\\dagger}"), { condition = math, snippetType = "autosnippet" }),
  s("o+", t("\\oplus"), { condition = math, snippetType = "autosnippet" }),
  s("ox", t("\\otimes"), { condition = math, snippetType = "autosnippet" }),
  
  -- Original bra-ket notation (keep existing)
  s("bra", fmt("\\bra{{{}}}{}", { i(1), i(0) }), { condition = math, snippetType = "autosnippet" }),
  s("ket", fmt("\\ket{{{}}}{}", { i(1), i(0) }), { condition = math, snippetType = "autosnippet" }),
  s("brk", fmt("\\braket{{ {} | {} }}{}", { i(1), i(2), i(0) }), { condition = math, snippetType = "autosnippet" }),
  s("outer", fmt("\\ket{{{}}} \\bra{{{}}}{}", { i(1, "\\psi"), rep(1), i(0) }), { condition = math, snippetType = "autosnippet" }),
  s("qbra", fmt("\\bra{{\\psi}}{}", { i(0) }), { condition = math, priority = 1, snippetType = "autosnippet" }),
  s("qket", fmt("\\ket{{\\psi}}{}", { i(0) }), { condition = math, priority = 1, snippetType = "autosnippet" }),
  s("qbrk", fmt("\\braket{{ \\psi | \\psi }}{}", { i(0) }), { condition = math, priority = 1, snippetType = "autosnippet" }),
  s("pbra", fmt("\\bra{{\\phi}} {}", { i(0) }), { condition = math, priority = 1, snippetType = "autosnippet" }),
  s("pket", fmt("\\ket{{\\phi}} {}", { i(0) }), { condition = math, priority = 1, snippetType = "autosnippet" }),
  s("pbrk", fmt("\\braket{{ \\phi | \\phi }}{}", { i(0) }), { condition = math, priority = 1, snippetType = "autosnippet" }),
  s("pqbrk", fmt("\\braket{{ \\phi | \\psi }}{}", { i(0) }), { condition = math, priority = 1, snippetType = "autosnippet" }),
  s("qpbrk", fmt("\\braket{{ \\psi | \\phi }}{}", { i(0) }), { condition = math, priority = 1, snippetType = "autosnippet" }),
  
  -- Quantum operators and commutators
  s("comm", fmt("[{}, {}]{}", { i(1), i(2), i(0) }), { condition = math, snippetType = "autosnippet" }),
  s("acomm", fmt("\\{{{}, {}\\}}{}", { i(1), i(2), i(0) }), { condition = math, snippetType = "autosnippet" }),
  s("expval", fmt("\\langle {} | {} | {} \\rangle{}", { i(1, "\\psi"), i(2, "\\hat{A}"), rep(1), i(0) }), { condition = math, snippetType = "autosnippet" }),
  
  -- Pauli matrices
  s("sx", t("\\sigma_x"), { condition = math, snippetType = "autosnippet" }),
  s("sy", t("\\sigma_y"), { condition = math, snippetType = "autosnippet" }),
  s("sz", t("\\sigma_z"), { condition = math, snippetType = "autosnippet" }),
  s("splus", t("\\sigma_+"), { condition = math, snippetType = "autosnippet" }),
  s("sminus", t("\\sigma_-"), { condition = math, snippetType = "autosnippet" }),


  -- Taylor expansion (math context, auto-triggering)
  s("tayl", fmt("{}({} + {}) = {}({}) + {}'({})({}) + {}''({}) \\frac{{{}^{{2}}}}{{2!}} + \\dots{}", {
    i(1, "f"), i(2, "x"), i(3, "h"), rep(1), rep(2), rep(1), rep(2), rep(3),
    rep(1), rep(2), rep(3), i(0)
  }), { condition = math, snippetType = "autosnippet" }),

  -- Visual operations using VISUAL placeholder (math context, manual trigger only)
  -- These require visual selection to avoid accidental triggering
  s("U", fmt("\\underbrace{{ {} }}_{{ {} }}", { 
    f(function(args, snip) return snip.env.LS_SELECT_RAW or "" end, {}),
    i(1)
  }), { condition = function() return math() and vim.fn.mode() == 'v' end }),
  
  s("O", fmt("\\overbrace{{ {} }}^{{ {} }}", { 
    f(function(args, snip) return snip.env.LS_SELECT_RAW or "" end, {}),
    i(1)
  }), { condition = function() return math() and vim.fn.mode() == 'v' end }),
  
  s("B", fmt("\\underset{{ {} }}{{ {} }}", { 
    i(1),
    f(function(args, snip) return snip.env.LS_SELECT_RAW or "" end, {})
  }), { condition = function() return math() and vim.fn.mode() == 'v' end }),
  
  s("C", fmt("\\cancel{{ {} }}", { 
    f(function(args, snip) return snip.env.LS_SELECT_RAW or "" end, {})
  }), { condition = function() return math() and vim.fn.mode() == 'v' end }),
  
  s("K", fmt("\\cancelto{{ {} }}{{ {} }}", { 
    i(1),
    f(function(args, snip) return snip.env.LS_SELECT_RAW or "" end, {})
  }), { condition = function() return math() and vim.fn.mode() == 'v' end }),
  
  s("S", fmt("\\sqrt{{ {} }}", { 
    f(function(args, snip) return snip.env.LS_SELECT_RAW or "" end, {})
  }), { condition = function() return math() and vim.fn.mode() == 'v' end }),

  -- Auto subscript patterns using regex triggers (math context, auto-triggering)
  -- Lower priority to avoid conflicts with specific notations
  s({trig = "([A-Za-z])(%d)", regTrig = true, snippetType = "autosnippet", priority = -200}, {
    f(function(_, snip)
      return snip.captures[1] .. "_{" .. snip.captures[2] .. "}"
    end, {})
  }, { condition = math }),

  s({trig = "([A-Za-z])(%d%d)", regTrig = true, snippetType = "autosnippet", priority = -150}, {
    f(function(_, snip)
      return snip.captures[1] .. "_{" .. snip.captures[2] .. "}"
    end, {})
  }, { condition = math }),

  -- Letter + modifier patterns (math context, auto-triggering) - proper priorities
  s({trig = "([a-zA-Z])hat", regTrig = true, snippetType = "autosnippet", priority = 20}, {
    f(function(_, snip)
      return "\\hat{" .. snip.captures[1] .. "}"
    end, {})
  }, { condition = math }),

  s({trig = "([a-zA-Z])bar", regTrig = true, snippetType = "autosnippet", priority = 20}, {
    f(function(_, snip)
      return "\\bar{" .. snip.captures[1] .. "}"
    end, {})
  }, { condition = math }),

  s({trig = "([a-zA-Z])dot", regTrig = true, priority = 20, snippetType = "autosnippet"}, {
    f(function(_, snip)
      return "\\dot{" .. snip.captures[1] .. "}"
    end, {})
  }, { condition = math }),

  s({trig = "([a-zA-Z])ddot", regTrig = true, priority = 25, snippetType = "autosnippet"}, {
    f(function(_, snip)
      return "\\ddot{" .. snip.captures[1] .. "}"
    end, {})
  }, { condition = math }),

  s({trig = "([a-zA-Z])tilde", regTrig = true, snippetType = "autosnippet", priority = 20}, {
    f(function(_, snip)
      return "\\tilde{" .. snip.captures[1] .. "}"
    end, {})
  }, { condition = math }),

  s({trig = "([a-zA-Z])und", regTrig = true, snippetType = "autosnippet", priority = 20}, {
    f(function(_, snip)
      return "\\underline{" .. snip.captures[1] .. "}"
    end, {})
  }, { condition = math }),

  s({trig = "([a-zA-Z])vec", regTrig = true, snippetType = "autosnippet", priority = 20}, {
    f(function(_, snip)
      return "\\vec{" .. snip.captures[1] .. "}"
    end, {})
  }, { condition = math }),

  -- Bold vector patterns (math context, auto-triggering) - higher priority
  s({trig = "([a-zA-Z]),\\.", regTrig = true, snippetType = "autosnippet", priority = 30}, {
    f(function(_, snip)
      return "\\mathbf{" .. snip.captures[1] .. "}"
    end, {})
  }, { condition = math }),

  s({trig = "([a-zA-Z])\\.\\,", regTrig = true, snippetType = "autosnippet", priority = 30}, {
    f(function(_, snip)
      return "\\mathbf{" .. snip.captures[1] .. "}"
    end, {})
  }, { condition = math }),


}

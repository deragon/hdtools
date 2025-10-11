--  Configure how code is formatted using the conform.nvim plugin.

-- 2025-10-08 Gemini conversation.
-- Conclusion:  conform is not very customizable.
--
--    Ok, i want also to change the behavior where a space is added before ;; like
--    in: And comments should be prepended with 2 spaces, not 1.
--
--    shfmt is an opinionated formatter and does not offer explicit options to
--    control spacing before ;; in case statements or the exact number of spaces
--    before an inline comment.
--
--    The formatting choices made by shfmt are generally fixed to promote a single,
--    consistent style, similar to gofmt in Go.
--
--    1. Space Before ;; in case Statements shfmt Behavior: The default and fixed
--    behavior of shfmt is to add a single space before the ;; case delimiter, as
--    seen in your desired output: f) FILE_OK=1 ;;.
--
--    No Option: There is no dedicated option to control this specific spacing
--    (i.e., to remove the space, or force two spaces). It adheres to its internal
--    rule for spacing around statement separators.
--
--    User Feedback: This specific behavior (no space before semicolon) has been a
--    point of discussion among users, but the tool is designed to be uncompromising
--    on its internal style rules.
--
--    2. Spaces Before Inline Comments shfmt Behavior: shfmt typically formats an
--    inline comment to have a single space between the preceding token and the #
--    character, and a single space after the # character.
--
--    Your desired output: ... - 1))  # Remove options... (two spaces before #)
--
--    shfmt output: ... - 1)) # Remove options... (one space before #)
--
--    No Option: Similar to the ;; spacing, there is no dedicated flag in shfmt to
--    configure the exact number of spaces (e.g., to force two spaces) before an
--    inline comment. The tool manages this whitespace automatically based on its
--    fixed style rules.
--
--    Conclusion Since shfmt is designed to be an opinionated formatter with a
--    non-configurable, fixed style, you cannot achieve either of your requested
--    formatting rules using standard shfmt command-line options.

return {
  -- Override the conform.nvim plugin
  {
    "stevearc/conform.nvim",
    opts = {
      -- Remove 'shfmt' as a formatter for bash files
      formatters_by_ft = {
        -- Set to an empty table to disable all formatters for 'sh' filetype such as
        -- bash, zsh, sh, etc...
        sh = {},
      },

      -- The 'formatters' table is where you override settings for specific formatters.
      formatters = {
        shfmt = {
          -- ⚠️  This configuration is ignored since formatters_by_ft above
          --    disables formatin for Bash / shell scirpts.
          --
          -- 'prepend_args' adds these arguments before any default ones.
          -- Use 'args' instead if you want to completely replace all arguments.
          prepend_args = {
            "-i", "2", -- Indentation width of 2
            "-ci", -- Collapse case branches
            "-bn", -- Binary operators on the same line as their operand
          },
        },
      },
    },
  },
}

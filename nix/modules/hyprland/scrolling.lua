local half = 0.49
local total = half * 2
hl.config({
  scrolling = {
    explicit_column_widths = table.concat({ total / 3, half, total * 2 / 3, total }, ", "),
  },
})

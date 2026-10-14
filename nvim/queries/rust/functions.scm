(
  (
    (attribute_item) @function.outer
    .
    [
      (attribute_item)
      (line_comment)
      (block_comment)
    ]* @function.outer
  )?
  .
  [
    (function_item)
    (function_signature_item)
  ] @function.outer
)

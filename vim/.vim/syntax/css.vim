syn match cssBoxProp contained "\<border-radius\>"
syn match cssBoxProp contained "\<background-\(clip\|repeat\)\>"
syn match cssBoxProp contained "\<box-shadow\>"
syn match cssBoxProp contained "\<resize\>"

syn match cssRenderAttr contained "\<inline-block\>"

syn keyword cssPseudoClassId empty target enabled disabled checked indeterminate root
syn match cssPseudoClassId contained "\<\(last\|only\)-child\>"
syn match cssPseudoClassId contained "\<\(first\|last\|only\)-of-type\>"
syn region cssPseudoClassLang matchgroup=cssPseudoClassId start=":not(" end=")" oneline
syn region cssPseudoClassLang matchgroup=cssPseudoClassId start=":\<nth\(-last\)\=-of-type\>(" end=")" oneline
syn region cssPseudoClassLang matchgroup=cssPseudoClassId start=":\<nth\(-last\)\=-child\>(" end=")" oneline

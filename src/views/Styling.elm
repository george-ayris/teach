module Views.Styling exposing (..)

import Style exposing (..)

-- Styles In Use
mainContainer =
  horizontalCenteredLayout

mainPanel =
  [ paddingLeft standardPadding
  , paddingRight standardPadding
  , flexGrow "1"
  , minWidth (px 300)
  ]

panelHeading =
  centeredText

svgContainer =
  [ display inlineBlock
  , verticalAlign "middle"
  ]

-- Styles for composition
horizontalCenteredLayout =
  [ display flex'
  ]

centeredText =
  [ textAlign center ]

standardPadding = px 8

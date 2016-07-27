module Views.Styling exposing (..)

import Style exposing (..)
import Color

-- Styles In Use
mainContainer =
  List.concat
    [ horizontalCenteredLayout
    , globalStyles
    ]

mainPanel =
  [ paddingLeft standardPadding
  , paddingRight standardPadding
  , paddingBottom standardPadding
  , flexGrow "5"
  , minWidth (px 300)
  , borderColor (color' Color.green)
  , borderWidth (px 5)
  , borderRadius (px 10)
  , borderStyle "solid"
  ]

columnSpacer =
  [ flexGrow "1" ]

panelHeading =
  centeredText

svgContainer =
  [ display inlineBlock
  , verticalAlign "middle"
  ]

questionStyle =
  [ paddingBottom standardPadding
  , paddingTop standardPadding
  ]

subQuestionContainer =
  [ paddingLeft standardPadding ]

writtenQuestionInput =
  [ ("box-sizing", "border-box")
  , ("resize", "none")
  , width (pc 100)
  ]

-- Styles for composition
globalStyles =
  [ fontFamily "Helvetica" ]

horizontalCenteredLayout =
  [ display flex'
  ]

centeredText =
  [ textAlign center ]

standardPadding = px 8

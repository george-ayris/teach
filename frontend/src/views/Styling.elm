module Views.Styling exposing (..)

import Style exposing (..)
import Color

-- Styles In Use
mainContainer =
  List.concat
    [ horizontalCenteredLayout
    , globalStyles
    , [ paddingTop "16px" ]
    ]

mainPanel =
  [ paddingLeft standardPadding
  , paddingRight standardPadding
  , paddingBottom standardPadding
  , width "44vw"
  , ("box-sizing", "border-box")
  ]

columnSpacer =
  [ width "4vw" ]

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

questionImage =
  [ width (px 300)
  , height "auto"
  , paddingTop standardPadding
  , paddingBottom standardPadding
  , marginLeft auto
  , marginRight auto
  , display block
  ]

subQuestionContainer =
  [ ]

writtenQuestionInput =
  [ ("box-sizing", "border-box")
  , ("resize", "none")
  , width (pc 100)
  ]

endOfSubQuestion =
  [ paddingBottom standardPadding ]

-- Styles for composition
globalStyles =
  [ fontFamily "Helvetica" ]

horizontalCenteredLayout =
  [ display flex'
  , ("justify-content", "space-around")
  ]

centeredText =
  [ textAlign center ]

standardPadding = px 8

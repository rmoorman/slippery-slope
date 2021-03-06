module SlippyMap.Layer.Popup
    exposing
        ( Config
        , config
        , layer
        , withCloseMsg
        )

{-| A layer to display popups.

@docs Config, config, withCloseMsg, layer

-}

import Html exposing (Html)
import Html.Attributes
import Html.Events
import SlippyMap.Geo.Location exposing (Location)
import SlippyMap.Layer as Layer exposing (Layer)
import SlippyMap.Map as Map exposing (Map)


-- CONFIG


{-| Configuration for the layer.
-}
type Config popup msg
    = Config
        { renderPopup : popup -> Html msg
        , closeMsg : Maybe msg
        }


{-| -}
config : Config String msg
config =
    Config
        { renderPopup = simplePopup
        , closeMsg = Nothing
        }


{-| -}
withCloseMsg : msg -> Config popup msg -> Config popup msg
withCloseMsg closeMsg (Config config) =
    Config
        { config | closeMsg = Just closeMsg }


simplePopup : String -> Html msg
simplePopup content =
    Html.div
        [ Html.Attributes.class "popup--simple"
        , Html.Attributes.style
            [ ( "filter"
              , "drop-shadow(rgba(0,0,0,0.2) 0px 2px 4px)"
              )
            , ( "transform", "translate(6px, -50%)" )
            , ( "display", "flex" )
            , ( "align-items", "center" )
            ]
        ]
        [ Html.div
            [ Html.Attributes.style
                [ ( "position", "relative" )
                , ( "left", "6px" )
                , ( "background", "#fff" )
                , ( "border-radius", "0 0 0 2px" )
                , ( "width", "12px" )
                , ( "height", "12px" )
                , ( "transform", "rotate(45deg)" )
                ]
            ]
            []
        , Html.div
            [ Html.Attributes.style
                [ ( "position", "relative" )
                , ( "background", "#fff" )
                , ( "border-radius", "4px" )
                , ( "padding", "0.5em 1em" )
                , ( "min-width", "60px" )
                , ( "max-width", "240px" )
                ]
            ]
            [ Html.text content ]
        ]



-- LAYER


{-| -}
layer : Config popup msg -> List ( Location, popup ) -> Layer msg
layer config locatedPopups =
    Layer.custom (render config locatedPopups) Layer.popup


render : Config popup msg -> List ( Location, popup ) -> Map msg -> Html msg
render config locatedPopups map =
    Html.div [ Html.Attributes.class "layer--popup" ]
        (List.map (renderPopup config map) locatedPopups)


renderPopup : Config popup msg -> Map msg -> ( Location, popup ) -> Html msg
renderPopup (Config config) map ( location, popup ) =
    let
        popupPoint =
            Map.locationToScreenPoint map location

        closeAttributes =
            config.closeMsg
                |> Maybe.map (Html.Events.onClick >> List.singleton)
                |> Maybe.withDefault []
    in
    Html.div
        ([ Html.Attributes.class "popup__positioner"
         , Html.Attributes.style
            [ ( "position", "absolute" )
            , ( "pointer-events", "auto" )
            , ( "transform"
              , "translate("
                    ++ toString popupPoint.x
                    ++ "px, "
                    ++ toString popupPoint.y
                    ++ "px)"
              )
            ]
         ]
            ++ closeAttributes
        )
        [ config.renderPopup popup ]

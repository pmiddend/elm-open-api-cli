module Common exposing (Field, FieldName, Object, OneOfData, Type(..), TypeName, VariantName, ref, toValueName, typifyName)

import FastDict exposing (Dict)
import String.Extra



-- Names adaptation --


typifyName : String -> TypeName
typifyName name =
    name
        |> String.uncons
        |> Maybe.map (\( first, rest ) -> String.cons first (String.replace "-" " " rest))
        |> Maybe.withDefault ""
        |> String.replace "_" " "
        |> String.replace "(" " "
        |> String.replace ")" " "
        |> String.Extra.toTitleCase
        |> String.replace " " ""
        |> deSymbolify


{-| Sometimes a word in the schema contains invalid characers for an Elm name.
We don't want to completely remove them though.
-}
deSymbolify : String -> String
deSymbolify str =
    str
        |> String.replace "+" "Plus"
        |> String.replace "-" "Minus"


{-| Convert into a name suitable to be used in Elm as a variable.
-}
toValueName : String -> String
toValueName name =
    name
        |> deSymbolify
        |> String.uncons
        |> Maybe.map
            (\( first, rest ) ->
                let
                    replaced : String
                    replaced =
                        String.replace "-" "_" rest
                in
                if first == '_' then
                    replaced

                else
                    String.cons (Char.toLower first) replaced
            )
        |> Maybe.withDefault ""


type Type
    = Nullable Type
    | Object Object
    | String
    | Int
    | Float
    | Bool
    | List Type
    | OneOf TypeName OneOfData
    | Value
    | Ref (List String)
    | Bytes
    | Unit


type alias Object =
    Dict FieldName Field


type alias OneOfData =
    List
        { name : VariantName
        , type_ : Type
        }


type alias TypeName =
    String


type alias VariantName =
    TypeName


type alias FieldName =
    String


type alias Field =
    { type_ : Type
    , required : Bool
    }


ref : String -> Type
ref str =
    Ref (String.split "/" str)

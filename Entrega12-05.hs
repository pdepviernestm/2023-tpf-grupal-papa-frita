data Archivo = UnArchivo {
    nombre :: String,
    contenido :: String
} deriving(Show, Eq)

data Carpeta = UnaCarpeta {
    nombreCarpeta :: String,
    contenidoCarpeta :: [Archivo]
} deriving(Show, Eq)

data Commit = UnCommit {
    descripcion :: String,
    conjuntoCambios:: [(a->b)]
}deriving(Show)

-- Ejemplos
archivo :: Archivo
archivo = UnArchivo "dibu" "mira que te come"

archivo2 :: Archivo
archivo2 = UnArchivo "mesi" "chiquito"

carpeta :: Carpeta
carpeta = UnaCarpeta "carpetita" [archivo]

carpeta2 :: Carpeta
carpeta2 = UnaCarpeta "carpetita2" [archivo, archivo2]
-- Fin de los ejemplos

{- listaNombresdeArchivo:: Carpeta -> [String]
listaNombresdeArchivo carpeta = map nombre (contenidoCarpeta carpeta) -}
listaNombresdeArchivo:: Carpeta -> [String]
listaNombresdeArchivo = map nombre . contenidoCarpeta

existeArchivo :: String -> Carpeta -> Bool
existeArchivo nombreArchivo carpeta = elem nombreArchivo (listaNombresdeArchivo carpeta)

crearArchivo:: String -> Carpeta -> Carpeta
crearArchivo  nombre carpeta    | existeArchivo nombre carpeta = carpeta
                                | otherwise = carpeta {contenidoCarpeta = contenidoCarpeta carpeta ++ [UnArchivo nombre ""]}


compararNombre:: String -> Archivo -> Bool
compararNombre nombreArchivo archivo = nombreArchivo /= nombre archivo

listaSinArchivo:: Carpeta -> String -> [Archivo]
listaSinArchivo carpeta nombreArchivo = filter (compararNombre nombreArchivo) (contenidoCarpeta carpeta)

borrarArchivo:: String -> Carpeta -> Carpeta
borrarArchivo nombre carpeta    | existeArchivo nombre carpeta = carpeta {contenidoCarpeta = listaSinArchivo carpeta nombre}
                                | otherwise = carpeta

vaciarCarpeta :: Carpeta -> Carpeta
vaciarCarpeta carpeta = UnaCarpeta (nombreCarpeta carpeta) []

modificarArchivo:: String -> String -> Archivo -> Archivo
modificarArchivo nombreArchivo texto archivo    | nombreArchivo == nombre archivo = UnArchivo nombreArchivo (texto++contenido archivo)
                                                | otherwise = archivo

agregarTexto :: String -> String -> Carpeta -> Carpeta
agregarTexto nombreArchivo texto carpeta    | existeArchivo nombreArchivo carpeta = UnaCarpeta (nombreCarpeta carpeta) (map (modificarArchivo nombreArchivo texto) (contenidoCarpeta carpeta))
                                            | otherwise = carpeta

-- El +1 en los take es para que solo borre los caracteres entre n1 y n2, sin incluirlos. Si no estuviera el +1 tambien borraría el n1.
sacarCaracteres:: String -> Int -> Int -> String
sacarCaracteres contenido n1 n2 | n1 < n2 = take (n1+1) contenido ++ drop n2 contenido
                                | n1 > n2 = take (n2+1) contenido ++ drop n1 contenido
                                | otherwise = contenido

sacarTextoArchivo:: String -> Int -> Int -> Archivo -> Archivo
sacarTextoArchivo nombreArchivo num1 num2 archivo   | nombreArchivo == nombre archivo = UnArchivo nombreArchivo (sacarCaracteres (contenido archivo) num1 num2)
                                                    | otherwise = archivo

sacarContenidoArchivo :: String -> Int -> Int -> Carpeta -> Carpeta
sacarContenidoArchivo nombreArchivo num1 num2 carpeta   | existeArchivo nombreArchivo carpeta = UnaCarpeta (nombreCarpeta carpeta) (map (sacarTextoArchivo nombreArchivo num1 num2) (contenidoCarpeta carpeta))
                                                        | otherwise = carpeta


commit:: Carpeta -> [Carpeta -> Carpeta] -> Carpeta
commit carpeta funciones = foldl (flip ($)) carpeta funciones

esInutil:: Carpeta -> [Carpeta -> Carpeta] -> Bool
esInutil carpeta funciones = carpeta == commit carpeta funciones

esInutilAlReves:: Carpeta -> [Carpeta -> Carpeta] -> Bool
esInutilAlReves carpeta funciones = carpeta == commit carpeta (reverse funciones)

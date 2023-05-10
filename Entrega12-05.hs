data Archivo = UnArchivo {
    nombre :: String,
    contenido :: String
} deriving(Show, Eq)

data Carpeta = UnaCarpeta {
    nombreCarpeta :: String,
    contenidoCarpeta :: [Archivo]
} deriving(Show, Eq)

archivo :: Archivo
archivo = UnArchivo "dibu" "mira que te come"

archivo2 :: Archivo
archivo2 = UnArchivo "mesi" "chiquito"

carpeta :: Carpeta
carpeta = UnaCarpeta "carpetita" [archivo]

carpeta2 :: Carpeta
carpeta2 = UnaCarpeta "carpetita2" [archivo, archivo2]

listaNombresdeArchivo:: Carpeta -> [String]
listaNombresdeArchivo carpeta = map nombre (contenidoCarpeta carpeta)

existeArchivo :: String -> Carpeta -> Bool
existeArchivo nombreArchivo carpeta = elem nombreArchivo (listaNombresdeArchivo carpeta)

crearArchivo:: String -> Carpeta -> Carpeta
crearArchivo  nombre carpeta    | existeArchivo nombre carpeta = carpeta
                                | otherwise = UnaCarpeta (nombreCarpeta carpeta) (contenidoCarpeta carpeta ++ [UnArchivo nombre ""])


filtrarNombre:: String -> Archivo -> Bool
filtrarNombre nombreArchivo archivo = nombreArchivo /= nombre archivo

listaSinArchivo:: Carpeta -> String -> [Archivo]
listaSinArchivo carpeta nombreArchivo = filter (filtrarNombre nombreArchivo) (contenidoCarpeta carpeta)

borrarArchivo:: String -> Carpeta -> Carpeta
borrarArchivo nombre carpeta    | existeArchivo nombre carpeta = UnaCarpeta (nombreCarpeta carpeta) (listaSinArchivo carpeta nombre)
                                | otherwise = carpeta

vaciarCarpeta :: Carpeta -> Carpeta
vaciarCarpeta carpeta = UnaCarpeta (nombreCarpeta carpeta) []

modificarArchivo:: String -> String -> Archivo -> Archivo
modificarArchivo nombreArchivo texto archivo    | nombreArchivo == nombre archivo = UnArchivo nombreArchivo (texto++contenido archivo)
                                                | otherwise = archivo

agregarTexto :: String -> String -> Carpeta -> Carpeta
agregarTexto nombreArchivo texto carpeta    | existeArchivo nombreArchivo carpeta = UnaCarpeta (nombreCarpeta carpeta) (map (modificarArchivo nombreArchivo texto) (contenidoCarpeta carpeta))
                                            | otherwise = carpeta

sacarTextoArchivo :: String -> Archivo -> Int -> Int -> p -> Archivo
sacarTextoArchivo nombreArchivo archivo num1 num2 nombreCarpeta | nombreArchivo == nombre archivo = UnArchivo nombreArchivo (drop num2 (take num1 (contenido archivo)))
                                                                |otherwise = archivo

sacarContenidoArchivo :: String -> Archivo -> Int -> Int -> (Carpeta -> String) -> Carpeta
sacarContenidoArchivo nombreArchivo archivo num1 num2 nombreCarpeta | existeArchivo nombreArchivo carpeta = UnaCarpeta (nombreCarpeta carpeta) (map (sacarTextoArchivo nombreArchivo archivo num1 num2) (contenidoCarpeta carpeta))
                                                                    |otherwise = carpeta

commit:: Carpeta -> [Carpeta -> Carpeta] -> Carpeta
commit carpeta funciones = foldl (flip ($)) carpeta funciones

esInutil:: Carpeta -> [Carpeta -> Carpeta] -> Bool
esInutil carpeta funciones = carpeta == commit carpeta funciones

esInutilAlReves:: Carpeta -> [Carpeta -> Carpeta] -> Bool
esInutilAlReves carpeta funciones = carpeta == commit carpeta (reverse funciones)
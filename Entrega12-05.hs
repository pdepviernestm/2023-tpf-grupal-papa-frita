import Text.Show.Functions 

data Archivo = UnArchivo {
    nombre :: String,
    contenido :: String
} deriving(Show, Eq)

data Carpeta = UnaCarpeta {
    nombreCarpeta :: String,
    contenidoCarpeta :: [Archivo]
} deriving(Show, Eq)

data Commit = UnCommit {
    idCommit:: Int,
    descripcion :: String,
    conjuntoCambios :: [Carpeta -> Carpeta]
}deriving(Show)

type Branch = [Commit]

-- Ejemplos

archivo :: Archivo
archivo = UnArchivo "dibu" "mira que te come"

archivo2 :: Archivo
archivo2 = UnArchivo "mesi" "chiquito"

archivo3 :: Archivo
archivo3 = UnArchivo "cs" "go"

archivo4 :: Archivo
archivo4 = UnArchivo "adi" "das"

carpeta :: Carpeta
carpeta = UnaCarpeta "carpetita" [archivo]

carpeta2 :: Carpeta
carpeta2 = UnaCarpeta "carpetita2" [archivo, archivo2]

commit1 :: Commit
commit1 = UnCommit 1 "Commit 1" [crearArchivo "nuevoArchivo1", borrarArchivo "dibu"]

commit2 :: Commit
commit2 = UnCommit 2 "Commit 2" [agregarTexto "mesi" "goleador"]

commit3 :: Commit
commit3 = UnCommit 3 "Commit 3" [crearArchivo "Age", borrarArchivo "cs"]

commit4 :: Commit
commit4 = UnCommit 4 "Commit 4" [agregarTexto "adi" "lmao"]
    --Commits
    --Branchs
branch :: Branch
branch = [commit1, commit2]

branch2 :: Branch
branch2 = [commit3]

branch3 :: Branch
branch3 = [commit4]

branch4 :: Branch
branch4 = [commit1,commit2,commit3,commit4]
--Branchs
-- Fin de los ejemplos

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

aplicarCambios:: Carpeta -> [Carpeta -> Carpeta] -> Carpeta
aplicarCambios carpeta funciones = foldl (flip ($)) carpeta funciones

esInutil:: Carpeta -> [Carpeta -> Carpeta] -> Bool
esInutil carpeta funciones = carpeta == aplicarCambios carpeta funciones

esInutilAlReves:: Carpeta -> [Carpeta -> Carpeta] -> Bool
esInutilAlReves carpeta funciones = carpeta == aplicarCambios carpeta (reverse funciones)

--SEGUNDA PARTE

checkout :: Carpeta -> Branch -> Carpeta
checkout carpeta [] = carpeta --En caso de que no haya commits devuelvo la carpeta
checkout carpeta (x:xs) = checkout (aplicarCambios carpeta (conjuntoCambios x)) xs -- Hago un commit con el primer commit "x" y dsp utilizo la recursividad para hacerlo con el resto de commits "xs"


sonIguales :: String -> Archivo -> Bool
sonIguales nombreArchivo archivo = nombre archivo == nombreArchivo

soloArchivo :: String -> Carpeta -> [Archivo]
soloArchivo nombreArchivo carpeta = filter (sonIguales nombreArchivo) (contenidoCarpeta carpeta)

afectaArchivo :: String -> Commit -> [String]
afectaArchivo nombreArchivo commit  |   soloArchivo nombreArchivo (UnaCarpeta "_" [UnArchivo nombreArchivo ""]) /= soloArchivo nombreArchivo (aplicarCambios (UnaCarpeta "_" [UnArchivo nombreArchivo ""]) (conjuntoCambios commit)) = [descripcion commit]
                                    |   soloArchivo nombreArchivo (UnaCarpeta "_" []) /= soloArchivo nombreArchivo (aplicarCambios (UnaCarpeta "_" []) (conjuntoCambios commit)) = [descripcion commit]
                                    |   otherwise = []

logArchivo:: String -> Branch -> [String]
logArchivo _ [] = []
logArchivo nombreArchivo (commit:commits) = afectaArchivo nombreArchivo commit ++ logArchivo nombreArchivo commits

checkoutNuevo :: Carpeta -> Branch -> Commit -> Carpeta
checkoutNuevo carpeta branch commit = checkout carpeta (reverse (take (idCommit commit) branch)) 

'''
¡Claro! Aquí tienes un script en Python que te permitirá descargar canciones de una playlist de Spotify
y guardarlas en una carpeta con el mismo nombre de la playlist. Este script utiliza YouTube como fuente
para las descargas de música. Asegúrate de usarlo de manera responsable y cumplir con las leyes de
derechos de autor.
'''
# Importa la librería pytube para descargar videos de YouTube
import pytube

# Ingresa la URL de la playlist de Spotify
#https://open.spotify.com/artist/3YbOSxo85kla7RID8ugnW3?si=LpWq5hwpQxmSAkO7Rjqo2A
#https://www.youtube.com/watch?v=qJz0YGSOgmo
print("Por favor, ingresa la URL de la playlist de Spotify:")
playlist_url = input()

# Crea una instancia de la playlist de YouTube
playlist_youtube = pytube.Playlist(playlist_url)
print(playlist_youtube.title)
exit()
# Crea una carpeta con el nombre de la playlist
nombre_carpeta = playlist_youtube.title

import os
if not os.path.exists(nombre_carpeta):
    os.makedirs(nombre_carpeta)

# Descarga cada canción de la playlist y guárdala en la carpeta
for video in playlist_youtube.videos:
    try:
        video.streams.filter(only_audio=True).first().download(output_path=nombre_carpeta)
        print(f"Descargada: {video.title}")
    except Exception as e:
        print(f"Error al descargar {video.title}: {e}")

print("Descarga completa. Las canciones están en la carpeta:", nombre_carpeta)

'''
Instrucciones:
Ejecuta el script en tu entorno de Python.
Ingresa la URL de la playlist de Spotify cuando se te solicite.
El script creará una carpeta con el nombre de la playlist y descargará las canciones en ella.
Recuerda que debes tener instalado FFmpeg para que funcione correctamente. Puedes instalarlo siguiendo las instrucciones
proporcionadas en la documentación del proyecto1.
¡Espero que encuentres útil este script! Si tienes alguna pregunta o necesitas más ayuda, no dudes en preguntar. 🎵📥
'''
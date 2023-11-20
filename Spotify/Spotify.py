#Importamos la libreria spotipy para poder hacer uso de la API de Spotify
import spotipy
from spotipy.oauth2 import SpotifyOAuth
# Importamos la librería tkinter para la interfaz grafica
import tkinter as tk
from tkinter import messagebox, simpledialog
# Importamos la libreria urllib.parse para verificar las URL's ingresadas
from urllib.parse import urlparse
# Importamos la librería pytube para descargar videos de YouTube
from pytube import YouTube
from youtubesearchpython import VideosSearch
import os

def credentials():
    # Configura las credenciales de la API
    return spotipy.Spotify(auth_manager=SpotifyOAuth(client_id='475b12b3051d48c8922edfb1ba57954e',
                                                client_secret='5d72bcddbfb44a4b8d5b35967e0a1866',
                                                redirect_uri='http://localhost/',
                                                scope='playlist-read-private'))

def is_url(url):
    try:
        result = urlparse(url)
        return all([result.scheme, result.netloc])
    except ValueError:
        return False
    
def get_URL():
    #Pedimos al usuario el link de su playlist de Spotify
    playlist_link = textbox.get()
    text_area.delete("1.0", tk.END)

    if(playlist_link != '' and is_url(playlist_link)):
        #Descomponemos la URL a un array, separando al url por '/'
        playlist_array = playlist_link.split('/')

        #Verificamos que la URL pertenesca a una playlist
        if(len(playlist_array) > 4 and playlist_array[3] == 'playlist'):
            if('?' in playlist_array[4]):
                #Descomponemos la ultima parte de la URL donde se encuentra el ID de la playlist separado por '?'
                playlist_id =  playlist_array[4].split('?')
                playlist_id = playlist_id[0]
            else:
                 playlist_id =  playlist_array[4]   

            list_name, name_dir = get_name_music(playlist_id)

            if list_name != "":
                i=1
                limit = len(list_name)
                print("\nDownloading")
                for name in list_name:
                    download_music(name, name_dir)
                    bar = bar_progres(i, limit, 100)
                    print(f"{bar}", end = "\r")
                    i += 1
                    #break

                textbox.delete(0, tk.END)
                print("\n\nDownload complete\n")
            #else:
                #messagebox.showinfo("Error!!!...", "Enter a URL with a valid ID")
        else:
            messagebox.showinfo("Error!!!...", "Enter a URL for the playlis")
    else:
        messagebox.showinfo("Error!!!...", "Enter a URL")
    textbox.delete(0, tk.END)

def get_name_music(playlist_id):

    try:
        sp = credentials()
        # Obtiene la lista de reproducción
        playlist = sp.playlist(playlist_id)
        name_dir = create_dir(playlist['name'])

        text_area.config(state=tk.NORMAL) 
        text_area.insert(tk.END,  f"----------'{name_dir}'----------\n")
        text_area.config(state=tk.DISABLED)
        list_name = []
        # Imprime los nombres de las canciones
        for item in playlist['tracks']['items']:
            track = item['track']
            list_name.append(track['name'])
        
        return list_name, name_dir
    except Exception as e:
        messagebox.showinfo("Error!!!...", f"The playlist doesn't exist.\n{e}")
        return "", ""

def create_dir(name):
    try:
        os.mkdir(name)
        return name
    except FileExistsError:
        new_name = ""
        while new_name == "":
            new_name = simpledialog.askstring("New name", "Playlist exist\nEnter a new name for the directory.:")

            if new_name == None or validate_name(new_name) != True:
                messagebox.showinfo("Error!!!...", "Enter a valid name")
                new_name = ""

        return create_dir(new_name)

def validate_name(name):
    # Lista de caracteres no permitidos en nombres de carpetas en Windows
    char = ['\\', '/', ':', '*', '?', '"', '<', '>', '|']
    
    #Caracteres no permitidos
    if any(c in name for c in char):
        return False
    
    #Termina con un punto
    if name.endswith('.'):
        return False
    
    #Espacio en blanco
    if name.isspace():
        return False
    
    return True

def download_music(name_music, name_dir):
    try:
        # Buscar videos relacionados con el nombre de la música en YouTube
        Search = VideosSearch(name_music, limit = 1)

        result = Search.result()
        
        # Obtener la URL del primer video de la búsqueda
        url_video = result['result'][-1]['link']

        # Crear objeto YouTube
        video = YouTube(url_video)

        # Seleccionar solo las corrientes de audio
        video.streams.filter(only_audio=True).first().download(output_path=name_dir)
        #char = ['\\', '/', ':', '*', '?', '"', '<', '>', '|', '(', ')', '-']
        #for c in char:
            #if c in name_music:
                #name_music = name_music.replace(c, "")

        #os.rename(os.path.join(name_dir, name_music+'.mp4'), os.path.join(name_dir, name_music+'.mp3'))

        text_area.config(state=tk.NORMAL) 
        text_area.insert(tk.END,  f">'{result['result'][0]['title']}' successful download.\n")
        text_area.config(state=tk.DISABLED)

    except Exception as e:
        text_area.config(state=tk.NORMAL) 
        text_area.insert(tk.END, f">'{result['result'][0]['title']}' fail download.\n'{e}'\n")
        text_area.config(state=tk.DISABLED)

def bar_progres(segment, total, long):
    porcent = segment / total
    complete = int(porcent * long)
    missing = long - complete
    bar = f"[{'#' * complete}{'°' * missing}{porcent:.2%}]"
    return bar

#Settings of window 
window = tk.Tk()
window.title("Download playlist")
window.resizable(width=False, height=False)
screen_width = window.winfo_screenwidth()
screen_height = window.winfo_screenheight()
x_position = (screen_width - 600) // 2
y_position = (screen_height - 400) // 2
window.geometry("600x400+{}+{}".format(x_position, y_position))

#Settings of textbox
label_btn = tk.Label(window, text="URL of playlist", font=("Bold", 14))
label_btn.pack(pady=10)
textbox = tk.Entry(window, width=60, font=("Calibri", 11))
textbox.pack(pady=1)

#Settings of Button
btn_download = tk.Button(window, text="Download playlist", font=("Bold", 12), command=get_URL)
btn_download.pack(pady=10)

text_area = tk.Text(window, height=15, width=60, state=tk.DISABLED)
text_area.pack()

window.mainloop()

#https://open.spotify.com/playlist/1IzIMoFRUoLCg4GMkvmNPs?si=f28c40f6020a466b
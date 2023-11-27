#Importamos la librería spotipy para poder hacer uso de la API de Spotify
import spotipy
from spotipy.oauth2 import SpotifyOAuth
# Importamos la librería tkinter para la interfaz grafica
import tkinter as tk
from tkinter.ttk import *
from tkinter import messagebox, simpledialog
# Importamos la libreria urllib.parse para verificar las URL's ingresadas
from urllib.parse import urlparse
# Importamos la librería pytube para descargar videos de YouTube
from pytube import YouTube
from youtubesearchpython import VideosSearch
import os
import requests
import threading

def credentials():
    # Configura las credenciales de la API
    return spotipy.Spotify(auth_manager=SpotifyOAuth(client_id='2da4b97d025147389086d1304eb8779d',
                                                client_secret='6ae2b34369e34fbe81cf3dcd2bcb2efe',
                                                redirect_uri='http://localhost/',
                                                scope='playlist-read-private'))

def new_token(credential_old):
    #Actualizar token de acceso
    url = "https://accounts.spotify.com/api/token"
    data = {
        "grant_type": "refresh_token",
        "refresh_token": "AQCNCdVHyJdRFU5Fkg9fxQZncB9B6j1XxlMH_fAZ-6M8mgGJxXVdJ4G8bDLbkbE1wHHGrT7Aq66gD5dFapwwoTxBfp3bK25YT3KhX0wkhUR6Z4hubMh1NnTU18A2SgDLMAg"
    }
    headers = {
        "Authorization": credential_old
    }

    response = requests.post(url, data=data, headers=headers)
    return response


def is_url(url):
    try:
        result = urlparse(url)
        return result.netloc in {"open.spotify.com"}
    except ValueError:
        return False
    
def get_URL():

    #Pedimos al usuario el link de su playlist de Spotify
    playlist_link = textbox.get()

    if(playlist_link != '' and is_url(playlist_link)):

        #Descomponemos la URL a un array, separando al url por '/'
        playlist_array = playlist_link.split('/')

        #Verificamos que la URL pertenezca a una playlist
        if(len(playlist_array) > 4 and playlist_array[3] == 'playlist'):
            if('?' in playlist_array[4]):
                #Descomponemos la última parte de la URL donde se encuentra el ID de la playlist separado por '?'
                playlist_id =  playlist_array[4].split('?')
                playlist_id = playlist_id[0]
            else:
                 playlist_id =  playlist_array[4]   

            list_name, name_dir = get_name_music(playlist_id)

            if list_name != "":
                def down(list_name, name_dir):
                    i = 0
                    for name in list_name: #Realizamos la descarga una a una
                        download_music(name, name_dir, i, len(list_name))
                        i += 1

                bar['value']=0
                download_thread = threading.Thread(target=down, args=(list_name, name_dir))
                download_thread.start()
        else:
            messagebox.showinfo("Error!!!...", "Enter a URL for the playlist")
            textbox.delete(0, tk.END)
    else:
        messagebox.showinfo("Error!!!...", "Enter a URL of Spotify")

def get_name_music(playlist_id):

    try:
        sp = credentials()
        #request = new_token(sp)
        #text_area.config(state=tk.NORMAL) 
        #text_area.insert(tk.END,  request)
        #text_area.config(state=tk.DISABLED)

        # Obtiene la lista de reproducción
        playlist = sp.playlist(playlist_id)
        name_dir = create_dir(playlist['name'])

        text_area.config(state=tk.NORMAL) 
        text_area.insert(tk.END,  f"----------'{name_dir}'----------\n")
        text_area.config(state=tk.DISABLED)
        list_name = []

        # Obtenemos los nombres de las canciones y su artista para poder realizar la búsqueda
        for item in playlist['tracks']['items']:
            track = item['track']
            #list_name.append(f"{track['name']} {track['artists'][0]['name']}")
            #list_name.append(track['name'])
            list_name.append(f"{track['name']} {track['artists'][0]['name']} Audio original")
        
        return list_name, name_dir
    except Exception as e:
        messagebox.showinfo("Error!!!...", f"The playlist doesn't exist.\n{e}")
        return "", ""

def create_dir(name): #Creamos el directorio para almacenar las canciones
    try:
        new_name = name
        if validate_name(name) == True:
            new_name = name
        else:
            char = ['\\', '/', ':', '*', '?', '"', '<', '>', '|', "'", '.', ',']
            for c in char:
                if c in name:
                    new_name = name.replace(c, "")

        os.mkdir(new_name)
        return new_name
    except FileExistsError:
        new_name = ""
        while new_name == "":
            new_name = simpledialog.askstring("New name", "The directory already exists\nEnter a new name for the directory:")

            if new_name == None or validate_name(new_name) != True:
                messagebox.showinfo("Error!!!...", "Enter a valid name")
                new_name = ""

        return create_dir(new_name)

def validate_name(name):
    # Lista de caracteres no permitidos en nombres de carpetas en Windows
    char = ['\\', '/', ':', '*', '?', '"', '<', '>', '|', '.', ',']
    
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

def download_music(name_music, name_dir, i, total):
    try:
        # Buscar videos relacionados con el nombre de la música en YouTube
        Search = VideosSearch(name_music, limit = 1)

        result = Search.result()
        
        # Obtener la URL del primer video de la búsqueda
        url_video = result['result'][-1]['link']

        # Crear objeto YouTube
        video = YouTube(url_video, on_progress_callback=on_progress)

        if i == 0:
            show_message()

        textbox.config(state=tk.DISABLED)
        btn_download.config(state=tk.DISABLED)

        # Seleccionar solo las corrientes de audio y realizamos la descarga
        #video.streams.filter(only_audio=True).first().download(output_path=name_dir)
        label_size.config(text=f"{0.0}MB - {round((video.streams.get_audio_only().filesize/1048576), 2)}MB {0:.0%} Complete")
        label_count.config(text=f"{i+1} of {total} Songs")
        bar.pack()
        label_size.pack()
        label_D.config(text=f"Downloading '{video.title}.mp3'")
        bar['value']=0

        video.streams.get_audio_only().download(output_path=name_dir)
        
        new_name_music = video.title
        char = ['\\', '/', ':', '*', '?', '"', '<', '>', '|', "'", '.', ',']
        for c in char:
            if c in new_name_music:
                new_name_music = new_name_music.replace(c, "")

        if os.path.isfile(name_dir+'\\'+new_name_music+'.mp3'):
            os.remove(name_dir+'\\'+new_name_music+'.mp3')
        
        os.rename(os.path.join(name_dir, new_name_music+'.mp4'), os.path.join(name_dir, new_name_music+'.mp3'))

        text_area.config(state=tk.NORMAL) 
        text_area.tag_configure("colorG", foreground="green")
        text_area.insert(tk.END,  f"> '{new_name_music}.mp3' -> Successful download.\n", "colorG")
        text_area.config(state=tk.DISABLED)

        if i == (total-1):
            messagebox.showinfo("", "Download complete")
            textbox.config(state=tk.NORMAL)
            textbox.delete(0, tk.END)
            label_D.config(text=f"")
            label_count.config(text=f"")
            label_size.config(text=f"")
            bar['value']=0
            bar.pack_forget()
            btn_download.config(state=tk.NORMAL)

    except Exception as e:
        #messagebox.showinfo("", "Descarga incompleta")
        if i == (total-1):
            btn_download.config(state=tk.NORMAL)
            textbox.config(state=tk.NORMAL)

        text_area.config(state=tk.NORMAL)
        text_area.tag_configure("colorR", foreground="red")
        text_area.insert(tk.END, f">Fail download.\n'{e}'\n", "colorR")
        text_area.config(state=tk.DISABLED)

def on_progress(stream, chunk, bytes_remaining):
    if alert.winfo_viewable() == 1:
        for widget in alert.winfo_children():
            widget.destroy()
        alert.withdraw()
    
    total = stream.filesize #limite
    segmen = total - bytes_remaining #segmento
    long = 50

    percentage = segmen / total
    complete = int(percentage * long)
    bar['value']=(complete*2)
    label_size.config(text=f"{round((segmen/1048576), 2)}MB - {round((total/1048576), 2)}MB {percentage:.0%} Complete")
    window.update_idletasks()
    #print(f"[{'=' * complete}{'-' * missing}]{percentage:.2%}", end = "\r")

def show_message():
    alert.deiconify() 
    tk.Label(alert, text="starting download", font=("Bold", 14)).pack()

def close_button():
    pass 

#Settings of window 
window = tk.Tk()

alert = tk.Toplevel(window)
alert.title("Please wait...")
alert.attributes('-toolwindow', True)
alert.protocol("WM_DELETE_WINDOW", close_button)
screen_width = alert.winfo_screenwidth()
screen_height = alert.winfo_screenheight()
x_position = (screen_width - 250) // 2
y_position = (screen_height - 50) // 2
alert.geometry("250x50+{}+{}".format(x_position, y_position))
alert.withdraw()

window.title("Download playlist")
window.resizable(width=False, height=False)
screen_width = window.winfo_screenwidth()
screen_height = window.winfo_screenheight()
x_position = (screen_width - 600) // 2
y_position = (screen_height - 500) // 2
window.geometry("600x500+{}+{}".format(x_position, y_position))

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

label_D = tk.Label(window, text="", font=("Bold", 13))
label_D.pack(pady=10)

bar = Progressbar(window, length=500)

label_count = tk.Label(window, text="", font=("Bold", 12))
label_count.pack()

label_size = tk.Label(window, text="", font=("Bold", 12))
#label_size.pack()

window.mainloop()

#Los temerarios
#https://open.spotify.com/playlist/1IzIMoFRUoLCg4GMkvmNPs?si=f28c40f6020a466b
#The outfield
#https://open.spotify.com/playlist/67qH0bKuwuKbqK2INYVOSz
#Electronica
#https://open.spotify.com/playlist/751fGb0bC9Zpcl6gElqTud
#Carla Morison
#https://open.spotify.com/playlist/5LsncNJlhYEmsdZqThRNg1
#Banda
#https://open.spotify.com/playlist/45egBgOmsmHcGfS3wK7qSM
#http://localhost/?code=AQC7ozfoqYnHoWQiwrFbSEBFjkTTHz4-GM-j-lNAt7i6dftsmHUadvzEmgLx478tZeSoMHXBeLIAMqGXB4og3vPM8YyjAYdRPhbnvZV_8is0CMoWLEOGH_cVLK1vMAQ7WhKdfphvwxJBqQACgsUwVvzTEK03w__DA9DNzoS_PJRsXazOXiCNK3C0QA4
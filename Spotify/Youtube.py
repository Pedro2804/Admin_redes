# Importamos la librería tkinter para la interfaz grafica
import tkinter as tk
from tkinter import messagebox
# Importamos la libreria urllib.parse para verificar las URL's ingresadas
from urllib.parse import urlparse
# Importamos la librería pytube para descargar videos de YouTube
from pytube import YouTube
import os

def is_url(url):
    try:
        result = urlparse(url)
        return all([result.scheme, result.netloc])
    except ValueError:
        return False
    
def get_URL():
    #Pedimos al usuario el link de su playlist de Spotify
    video_link = textbox.get()
    text_area.delete("1.0", tk.END)

    if(video_link != '' and is_url(video_link)):
        #Descomponemos la URL a un array, separando al url por '/'
        playlist_array = video_link.split('/')

        #Verificamos que la URL pertenesca a un video
        if(len(playlist_array) > 3):
            if('?' in playlist_array[3]):
                #Descomponemos la ultima parte de la URL donde se encuentra el ID de la playlist separado por '?'
                video_id =  playlist_array[3].split('?')
                if video_id[0] == 'watch':
                    option = var.get()
                    i=1
                    limit = 100
                    print("\nDownloading")
                    download_music(video_link, option)
                    bar = bar_progres(i, limit, 100)
                    print(f"{bar}", end = "\r")
                    i += 1

                    textbox.delete(0, tk.END)
                    print("\n\nDownload complete\n")   
                else:
                    messagebox.showinfo("Error!!!...", "Enter a valid URL")
        else:
            messagebox.showinfo("Error!!!...", "Enter a URL for the watch")
    else:
        messagebox.showinfo("Error!!!...", "Enter a URL")
    textbox.delete(0, tk.END)

def download_music(url_video, option):
    try:
        # Crear objeto YouTube
        video = YouTube(url_video)

        if option == 1:
            video.streams.filter(only_audio=True).first().download()
            #char = ['\\', '/', ':', '*', '?', '"', '<', '>', '|', '(', ')', '-']
            #for c in char:
                #if c in name_music:
                    #name_music = name_music.replace(c, "")

            #os.rename(os.path.join(name_dir, name_music+'.mp4'), os.path.join(name_dir, name_music+'.mp3'))
        else:
            video.streams.get_highest_resolution().download()

        text_area.config(state=tk.NORMAL) 
        text_area.insert(tk.END,  f">'{video}' successful download.\n")
        text_area.config(state=tk.DISABLED)

    except Exception as e:
        text_area.config(state=tk.NORMAL) 
        text_area.insert(tk.END, f">'{video}' fail download.\n'{e}'\n")
        text_area.config(state=tk.DISABLED)

def bar_progres(segment, total, long):
    porcent = segment / total
    complete = int(porcent * long)
    missing = long - complete
    bar = f"[{'#' * complete}{'°' * missing}{porcent:.2%}]"
    return bar

#Settings of window 
window = tk.Tk()
window.title("Download music")
window.resizable(width=False, height=False)
screen_width = window.winfo_screenwidth()
screen_height = window.winfo_screenheight()
x_position = (screen_width - 600) // 2
y_position = (screen_height - 400) // 2
window.geometry("600x400+{}+{}".format(x_position, y_position))

#Settings of textbox
label_btn = tk.Label(window, text="URL of video", font=("Bold", 14))
label_btn.pack(pady=10)
textbox = tk.Entry(window, width=60, font=("Calibri", 11))
textbox.pack(pady=1)

var = tk.IntVar()
# Crear radio buttons
radio_button1 = tk.Radiobutton(window, text="Audio", variable=var, value=1,  font=("Bold", 12))
radio_button2 = tk.Radiobutton(window, text="Video", variable=var, value=2,  font=("Bold", 12))

radio_button1.pack()
radio_button2.pack()

text_area = tk.Text(window, height=10, width=60, state=tk.DISABLED)
text_area.pack()

#Settings of Button
btn_download = tk.Button(window, text="Download", font=("Bold", 12), command=get_URL)
btn_download.pack(pady=10)

window.mainloop()

#https://open.spotify.com/playlist/1IzIMoFRUoLCg4GMkvmNPs?si=f28c40f6020a466b
#https://www.youtube.com/watch?v=-ao4rU5T5iE
#https://www.youtube.com/watch?v=qXa8LjXNshs
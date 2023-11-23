# Importamos la librería tkinter para la interfaz grafica
import tkinter as tk
from tkinter import messagebox
from tkinter.ttk import *
# Importamos la libreria urllib.parse para verificar las URL's ingresadas
from urllib.parse import urlparse
# Importamos la librería pytube para descargar videos de YouTube
from pytube import YouTube
import os
import threading

def is_url(url):
    try:
        result = urlparse(url)
        return result.netloc in {"www.youtube.com", "youtube.com", "youtu.be"}
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
                    if option > 0:
                        bar['value']=0
                        download_thread = threading.Thread(target=download_music, args=(video_link, option))
                        download_thread.start()
                    else:
                        messagebox.showinfo("Error!!!...", "Seleccione una opción")
                else:
                    messagebox.showinfo("Error!!!...", "Ingrese una URL válida")
                    textbox.delete(0, tk.END)
        else:
            messagebox.showinfo("Error!!!...", "Ingrese una URL de video")
            textbox.delete(0, tk.END)
    else:
        messagebox.showinfo("Error!!!...", "Ingrese una URL de YouTube")
        textbox.delete(0, tk.END)

def download_music(url_video, option):
    try:
        # Crear objeto YouTube
        video = YouTube(url_video, on_progress_callback=on_progress)

        show_message()
        textbox.config(state=tk.DISABLED)
        btn_download.config(state=tk.DISABLED)

        # Ruta completa de la carpeta de Descargas usando la variable de entorno
        download_path = os.path.join(os.path.expanduser("~"), "Downloads")

        new_name_music = video.title
        char = ['\\', '/', ':', '*', '?', '"', '<', '>', '|', "'", '.', ',']
        for c in char:
            if c in new_name_music:
                new_name_music = new_name_music.replace(c, "")

        extens = ''
        if option == 1:
            label_size.config(text=f"{0.0}MB - {round((video.streams.get_audio_only().filesize/1048576), 2)}MB {0:.0%} Completado")
            bar.pack()
            label_D.config(text=f"Descargando '{video.title}.mp3'")

            video.streams.get_audio_only().download(output_path=download_path)

            if os.path.isfile(download_path+'\\'+new_name_music+'.mp3'):
                os.remove(download_path+'\\'+new_name_music+'.mp3')

            os.rename(os.path.join(download_path, new_name_music+'.mp4'), os.path.join(download_path, new_name_music+'.mp3'))
            type = "Audio"
            extens = '.mp3'
        else:
            label_size.config(text=f"{0.0}MB - {round((video.streams.get_highest_resolution().filesize/1048576), 2)}MB {0:.0%} Completado")
            bar.pack()
            label_D.config(text=f"Descargando '{video.title}.mp4'")

            if os.path.isfile(download_path+'\\'+new_name_music+'.mp4'):
                os.remove(download_path+'\\'+new_name_music+'.mp4')

            video.streams.get_highest_resolution().download(output_path=download_path)
            type = "Video"
            extens = '.mp4'

        text_area.config(state=tk.NORMAL)
        text_area.tag_configure("colorG", foreground="green")
        text_area.insert(tk.END,  f"> {type}: '{video.title}{extens}' -> Descarga exitosa.\n", "colorG")
        text_area.config(state=tk.DISABLED)
        
        messagebox.showinfo("", "Descarga completa")
        textbox.config(state=tk.NORMAL)
        textbox.delete(0, tk.END)
        label_D.config(text=f"")
        label_size.config(text=f"")
        bar['value']=0
        bar.pack_forget()
        var.set(0)
        btn_download.config(state=tk.NORMAL)

    except Exception as e:
        messagebox.showinfo("", "Descarga incompleta")
        btn_download.config(state=tk.NORMAL)
        textbox.config(state=tk.NORMAL)
        text_area.config(state=tk.NORMAL) 
        text_area.tag_configure("colorR", foreground="red")
        text_area.insert(tk.END, f"> Fallo en la descarga -> {e}\n", "colorR")
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
    label_size.config(text=f"{round((segmen/1048576), 2)}MB - {round((total/1048576), 2)}MB {percentage:.0%} Completado")
    window.update_idletasks()
    #print(f"[{'=' * complete}{'-' * missing}]{percentage:.2%}", end = "\r")

def show_message():
    alert.deiconify()
    tk.Label(alert, text="Iniciando descarga", font=("Bold", 14)).pack()

def close_button():
    pass 

#Settings of window 
window = tk.Tk()

alert = tk.Toplevel(window)
alert.title("Por favor espere")
alert.attributes('-toolwindow', True)
alert.protocol("WM_DELETE_WINDOW", close_button)
screen_width = alert.winfo_screenwidth()
screen_height = alert.winfo_screenheight()
x_position = (screen_width - 250) // 2
y_position = (screen_height - 50) // 2
alert.geometry("250x50+{}+{}".format(x_position, y_position))
alert.withdraw()

window.title("Descarga de música y video")
window.resizable(width=False, height=False)
screen_width = window.winfo_screenwidth()
screen_height = window.winfo_screenheight()
x_position = (screen_width - 600) // 2
y_position = (screen_height - 450) // 2
window.geometry("600x460+{}+{}".format(x_position, y_position))

#Settings of textbox
label_btn = tk.Label(window, text="URL de YouTube", font=("Bold", 14))
label_btn.pack(pady=10)
textbox = tk.Entry(window, width=65, font=("Calibri", 11))
textbox.pack(pady=1)

var = tk.IntVar()
# Crear radio buttons
radio_button1 = tk.Radiobutton(window, text="Audio", variable=var, value=1,  font=("Bold", 12))
radio_button2 = tk.Radiobutton(window, text="Video", variable=var, value=2,  font=("Bold", 12))

radio_button1.pack()
radio_button2.pack()

text_area = tk.Text(window, height=10, width=65, state=tk.DISABLED)
text_area.pack()

#Settings of Button
btn_download = tk.Button(window, text="Descargar", font=("Bold", 12), command=get_URL)
btn_download.pack(pady=10)

label_D = tk.Label(window, text="", font=("Bold", 13))
label_D.pack(pady=10)

bar = Progressbar(window, length=500)

label_size = tk.Label(window, text="", font=("Bold", 12))
label_size.pack()

window.mainloop()

#https://open.spotify.com/playlist/1IzIMoFRUoLCg4GMkvmNPs?si=f28c40f6020a466b
#https://www.youtube.com/watch?v=-ao4rU5T5iE
#https://www.youtube.com/watch?v=qXa8LjXNshs
#https://www.youtube.com/watch?v=iAMAqUB7ScE
#https://www.youtube.com/watch?v=R1wwopVP7-A
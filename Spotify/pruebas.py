from tkinter import messagebox, simpledialog
import tkinter as tk

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

new_name = ""
while new_name == "":
    new_name = simpledialog.askstring("New name", "Enter a new name for the directory.:")

    if new_name == None:
        break
    
    if validate_name(new_name) != True:
        messagebox.showinfo("Error!!!...", "Enter a valid name")
        new_name = ""

print(new_name)
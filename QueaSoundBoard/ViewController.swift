//
//  ViewController.swift
//  QueaSoundBoard
//
//  Created by Ruben Freddy Quea Jacho on 31/10/23.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate{
    

    @IBOutlet weak var tablaGrabaciones: UITableView!
    
    var grabaciones:[Grabacion] = []
    var reproducirAudio:AVAudioPlayer?
    var nameGrabacion:String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tablaGrabaciones.dataSource = self
        tablaGrabaciones.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            grabaciones = try context.fetch(Grabacion.fetchRequest())
            tablaGrabaciones.reloadData()
        } catch  {
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return grabaciones.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        let grabacion = grabaciones[indexPath.row]
        cell.textLabel?.text = grabacion.nombre
        cell.detailTextLabel?.text = obtenerDuracionFormateada(audioData: grabacion.audio!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let grabacion = grabaciones[indexPath.row]
        do {
            reproducirAudio = try AVAudioPlayer(data: grabacion.audio! as Data)
            reproducirAudio?.delegate = self
            reproducirAudio?.play()
            nameGrabacion = grabacion.nombre!
            print("Reproduciendo \(nameGrabacion!)")


        } catch {
            print("Error al reproducir el audio: \(error.localizedDescription)")
        }
        tablaGrabaciones.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let grabacion = grabaciones[indexPath.row]
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            context.delete(grabacion)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            do {
                grabaciones = try context.fetch(Grabacion.fetchRequest())
                tablaGrabaciones.reloadData()
            }catch  {}
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Pausa \(nameGrabacion!)")
    }
    
    func obtenerDuracionFormateada(audioData: Data) -> String? {
        do {
            let audioPlayer = try AVAudioPlayer(data: audioData)
            let duration = Int(audioPlayer.duration) // Duración en segundos
            let minutos = duration / 60
            let segundos = duration % 60

            // Utilizamos String(format:) para formatear los minutos y segundos con dos dígitos
            let duracionFormateada = String(format: "%02d:%02d", minutos, segundos)
            
            return duracionFormateada
        } catch {
            print("Error al obtener la duración del audio: \(error.localizedDescription)")
            return nil
        }
    }

}


import AudioKit
import AVFoundation
import SwiftUI

class TunerViewModel: ObservableObject {
    let engine = AudioEngine()
    var mic: AudioEngine.InputNode!
    var tracker: PitchTracker!
    var silence: Fader!

    @Published var pitch: Float = 0.0
    @Published var note: String = "—"

    init() {
        // Configura il microfono
        guard let input = engine.input else {
            print("Errore: Nessun input microfono disponibile")
            return
        }
        mic = input

        // Configura il tracker per rilevare il pitch
        tracker = PitchTracker(input)
        tracker.start()

        silence = Fader(input, gain: 0)
        engine.output = silence

        do {
            try engine.start()
        } catch {
            print("Errore durante l'avvio dell'engine audio: \(error.localizedDescription)")
        }

        // Aggiorna i dati in tempo reale
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.updatePitch()
        }
    }

    func updatePitch() {
        if let detectedPitch = tracker.frequency, detectedPitch > 0 {
            pitch = detectedPitch
            note = noteName(from: detectedPitch)
        } else {
            pitch = 0.0
            note = "—"
        }
    }

    func noteName(from frequency: Float) -> String {
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let A440: Float = 440.0

        // Calcolo del numero di semitoni di distanza da A4
        let semitonesFromA4 = 12 * log2(frequency / A440)
        let roundedSemitones = Int(round(semitonesFromA4))

        // Calcolo dell'indice della nota e dell'ottava
        let noteIndex = (roundedSemitones + 9) % 12 // "+9" per mappare A4 -> indice 9
        let octave = 4 + (roundedSemitones + 9) / 12

        if frequency < 20 || frequency > 5000 {
            return "—" // Nessuna nota rilevata
        }

        return "\(notes[noteIndex])\(octave)"
    }
}

struct TunerView: View {
    @StateObject var viewModel = TunerViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Tuner")
                .font(.largeTitle)
                .padding()

            Text("Nota: \(viewModel.note)")
                .font(.system(size: 48))
                .bold()

            Text("Frequenza: \(viewModel.pitch, specifier: "%.2f") Hz")
                .font(.title)

            Spacer()
        }
        .padding()
    }
}

@main
struct TunerApp: App {
    var body: some Scene {
        WindowGroup {
            TunerView()
        }
    }
}

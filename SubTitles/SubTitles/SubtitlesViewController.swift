//
//  SubtitlesViewController.swift
//  SubTitles
//
//  Created by María Camila Angel on 27/10/16.
//  Copyright © 2016 M01. All rights reserved.
//

import UIKit
import Speech

class SubtitlesViewController: UIViewController, SFSpeechRecognizerDelegate {

    var subtitles: SavedSubObject?
    var originalSubs = [Int: String]()
    var translatedSubs = [Int: String]()
    var currentIndex = 0
    let mostCommonWords = ["the", "be", "to", "of", "and", "a", "in", "that", "have", "I"]
    var maxOriginalIndex = 0
    
    weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var currentSub: UILabel!
    @IBOutlet weak var microphoneButton: UIButton!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicatorView.hidesWhenStopped = true
        self.view.addSubview(activityIndicatorView)
        self.activityIndicatorView = activityIndicatorView
        self.currentSub.numberOfLines = 0
        
        parseSubtitles()
        
        microphoneButton.isEnabled = false  //2
        
        speechRecognizer?.delegate = self  //3
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            var isButtonEnabled = false
            
            switch authStatus {  //5
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.microphoneButton.isEnabled = isButtonEnabled
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func parseSubtitles() {
        activityIndicatorView.startAnimating()
        let fileManager = FileManager.default
        let documents = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let pathOriginal = documents.appendingPathComponent((subtitles!.archivoOriginal)!).path
        let pathTranslated = documents.appendingPathComponent((subtitles!.archivoTraduccion)!).path
        
        DispatchQueue.global(qos: .background).async {
            self.parseFile(pathOriginal, original: true)
            self.parseFile(pathTranslated, original: false)
            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()
                self.currentSub.text = self.translatedSubs[self.currentIndex]
            }
        }
    }
    
    func parseFile(_ filePath: String, original: Bool) {
        
        var ignoreFirst = true
        var ignoreSecond = true
        var index = 0
        var text = ""
        if let aStreamReader = StreamReader(path: filePath) {
            defer {
                aStreamReader.close()
            }
            while let line = aStreamReader.nextLine() {
                let trimmedline = line.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                if(trimmedline.isEmpty){
                    if original {
                        originalSubs[index] = text
                    } else {
                        translatedSubs[index] = text
                    }
                    index += 1
                    text = ""
                    ignoreFirst = true
                    ignoreSecond = true
                } else if (!ignoreFirst){
                    if(!ignoreSecond){
                        text = line
                    } else {
                        ignoreSecond = false
                    }
                } else {
                    ignoreFirst = false
                }
                
            }
            maxOriginalIndex = index
        }
    }

    @IBAction func nextSubtitle(_ sender: AnyObject) {
        currentIndex += 1
        currentSub.text = self.translatedSubs[self.currentIndex]
    }
    
    @IBAction func previousSubtitle(_ sender: AnyObject) {
        if (currentIndex > 0){
            currentIndex -= 1
            currentSub.text = self.translatedSubs[self.currentIndex]
        }
    }
    
    @IBAction func recordAudio(_ sender: AnyObject) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            microphoneButton.isEnabled = false
            microphoneButton.setTitle("Start Recording", for: .normal)
        } else {
            print("arranco a grabar")
            startRecording()
            microphoneButton.setTitle("Stop Recording", for: .normal)
        }
    }
    
    func updateSubtitles(speech: String){
        
        let words = getUsefulWords(string: speech);
        let maxPosition = currentIndex + 50;
        var bestIndex = currentIndex;
        var bestScore = 0;
        var i = 0
        while(i < maxPosition && i < maxOriginalIndex){
            var score = 0
            let subtitle = self.originalSubs[i]
            for w in words {
                if (subtitle?.contains(w))! {
                    score += 1;
                }
            }
            
            if (Double((subtitle?.characters.count)!) > (2.5 * Double(speech.characters.count))) {
                score = score/2
            }
            
            if(score > bestScore){
                bestIndex = i;
                bestScore = score
            }
            i += 1
        }
        
        let found = bestIndex != currentIndex;
        
        if (!found) {
            print("Sorry. Our algorithm failed. Try the paid version.")
        }
        else{
            print(bestIndex)
            print(self.originalSubs[self.currentIndex])
            print(self.translatedSubs[self.currentIndex])
            currentIndex = bestIndex;
            currentSub.text = self.translatedSubs[self.currentIndex]
        }
        
    }
    
    func getUsefulWords(string: String) -> [String]{
        
        let words = string.components(separatedBy: " ")
        var usefulWords = [String]()
        
        for w in words {
            if (!mostCommonWords.contains(w)) {
                usefulWords.append(w);
            }
        }
        
        return usefulWords;
    }
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                //self.textView.text = result?.bestTranscription.formattedString
                
                isFinal = (result?.isFinal)!
                if (isFinal){
                    let speech = result?.bestTranscription.formattedString
                    self.updateSubtitles(speech: speech!);
                    print(result?.bestTranscription.formattedString)
                }
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.microphoneButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        //textView.text = "Say something, I'm listening!"
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneButton.isEnabled = true
        } else {
            microphoneButton.isEnabled = false
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

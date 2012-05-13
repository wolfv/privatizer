Plugin.classnames = ["messageBody", "content noh", "tlTxFe"];

/*
Vorschläge zur Poritionierung:
1. Textfeld auf Startseite für Status-Update
	Textfeld: class="uiTextareaAutogrow input mentionsTextarea textInput DOMControl_placeholder"
	Position: id="uiComposerMessageBoxControls"
	
2. Kommentarfelder auf Startseite
	Textfeld: class="enter_submit uiTextareaNoResize uiTextareaAutogrow textBox mentionsTextarea textInput"
	Position: class="UIImageBlock clearfix mentionsAddComment"

3. Chatfelder auf Startseite
    Textfeld: 
*/

// Erzeugt zwei Arrays:
// Im ersten Array sind die Text-Felder gespeichert - im zweiten die dazugehörigen PadLock Positionen
Plugin.text_areas = new Array()
Plugin.padlock_positions = new Array()



// Für Status-Update-Feld:
var Text_Areas1 = document.getElementsByClassName("uiTextareaAutogrow input mentionsTextarea textInput DOMControl_placeholder")
var Padlock_Positions1 = document.getElementById("uiComposerMessageBoxControls")
if( Text_Areas1 && Padlock_Positions1 ){
    Plugin.text_areas.push(Text_Areas1[0])
    Plugin.padlock_positions.push(Padlock_Positions1)
}

// Für Kommentar-Felder:
var Text_Areas2 = document.getElementsByClassName("enter_submit uiTextareaNoResize uiTextareaAutogrow textBox mentionsTextarea textInput")
var Padlock_Positions2 = document.getElementsByClassName("UIImageBlock clearfix mentionsAddComment")
if( Text_Areas2 && Padlock_Positions2 ){
    for( var i=0; i<Text_Areas2.length; i++ ){
        Plugin.text_areas.push(Text_Areas2[i])
        Plugin.padlock_positions.push(Padlock_Positions2[i])
    }
}

console.log(Plugin.text_areas.length + " relevante Text-Felder gefunden")
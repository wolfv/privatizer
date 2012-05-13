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


// Funktion findet zu Textfeld die zugehörige Position für den Padlock
// Und fügt ihn in das DOM ein

Plugin.findPosition = function(textarea, padlock) {

	if( textarea.classList.contains("uiTextareaAutogrow") 
			&& textarea.getAttribute("name") == "xhpc_message") {
		position = document.getElementsByClassName('uiComposerMessageBoxControls')[0];
		position.appendChild(padlock)
		padlock.style.float = "right";
		padlock.style.position = "relative";
		return;
	}

	else if (textarea.classList.contains("uiTextareaNoResize")) {
		position = textarea.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode;
		position.appendChild(padlock)
		padlock.style.float = "right"
		padlock.style.position = "relative"
		return;
	}

	else if (textarea.classList.contains("MessagingComposerBody")) {
		position = textarea.parentNode.nextSibling;
		position.appendChild(padlock)
		padlock.style.position = "relative";
		padlock.style.float = "right";
	}
	else {
		position = textarea.parentNode;
		position.appendChild(padlock)
	}
	return
}
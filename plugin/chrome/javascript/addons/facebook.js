Plugin.classnames = ["messageBody", "content noh", "tlTxFe", "commentBody", "fbChatMessage"];

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
	notfound = true
	if( textarea.classList.contains("uiTextareaAutogrow") 
			&& textarea.getAttribute("name") == "xhpc_message") {
		position = document.getElementsByClassName('uiComposerBarRightArea')[0];
		position.insertBefore(padlock, position.firstChild)
        padlock.style.cssFloat = "left"
		padlock.style.position = "relative";
        padlock.style.margin = "-2px";

	}

	else if (notfound && textarea.classList.contains("uiTextareaNoResize")) {
		position = textarea.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode;
		position.appendChild(padlock)
		padlock.style.float = "right"
		padlock.style.position = "relative"
	}

	else if (notfound && textarea.classList.contains("MessagingComposerBody")) {
		position = textarea.parentNode.nextSibling;
		position.appendChild(padlock)
		padlock.style.position = "relative";
		padlock.style.float = "right";
	}
	else {
		position = textarea.parentNode;
		position.appendChild(padlock)
	}
	if (textarea.classList.contains("enter_submit") || textarea.parentNode.parentNode.classList.contains("fbNubFlyoutFooter")) {
		textarea.enter_submit = true
		window.addEventListener('keydown', function(e) {	
			if(e.target == textarea) {
				if(e.keyCode == 13 && e.shiftKey == false && textarea.encrypted == false) {
					e.preventDefault()
					e.stopPropagation()
					textarea.uncryptedText = textarea.value
					if(padlock.getAttribute('key') != "") {
						window.privatizer.crypt_before_send(textarea, padlock)
					}
				}
				else if (e.keyCode == 13 && e.shiftKey == false && textarea.encrypted == true) {
					textarea.encrypted = false
				}
			}
		}, true)
	}
	return
	
}
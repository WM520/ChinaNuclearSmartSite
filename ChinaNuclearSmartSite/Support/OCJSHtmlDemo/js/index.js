function buttonDivAction() {
	window.webkit.messageHandlers.currentCookies.postMessage({
		"body": "buttonActionMessage"
	});
}

function alertAction(message) {
	
	alert(message);
//    print(message);
//	console.log(message);
}

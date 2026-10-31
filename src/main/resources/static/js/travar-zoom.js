// Trava o zoom do navegador na tela do mapa (a tela foi pensada para ser vista a 100%).
// Uma página não consegue FORÇAR o zoom do navegador para 100%; aqui bloqueamos os gestos
// e atalhos que mudam o zoom. Ctrl+0 continua liberado: é o jeito de voltar para 100%.
(function () {
	"use strict";

	var TECLAS_DE_ZOOM = ["+", "-", "=", "_", "Add", "Subtract"];

	// Ctrl/Cmd + "+" e Ctrl/Cmd + "-"
	document.addEventListener("keydown", function (event) {
		if ((event.ctrlKey || event.metaKey) && TECLAS_DE_ZOOM.indexOf(event.key) !== -1) {
			event.preventDefault();
		}
	});

	// Ctrl + roda do mouse e pinça do touchpad (o navegador entrega como wheel com ctrlKey)
	window.addEventListener("wheel", function (event) {
		if (event.ctrlKey) {
			event.preventDefault();
		}
	}, {passive: false});

	// Pinça no Safari (macOS e iOS)
	["gesturestart", "gesturechange", "gestureend"].forEach(function (tipo) {
		document.addEventListener(tipo, function (event) {
			event.preventDefault();
		});
	});
})();

/*
 * Controles de áudio da leitura em voz alta (acessibilidade).
 *
 * Funciona como um "complemento": não altera o código que já lê as questões
 * (quiz-gamificado.js e first-test.html). Ele faz duas coisas:
 *
 *  1. Ao lado de cada botão ".botao-ouvir" coloca um botão de volume (que abre
 *     um controle deslizante vertical) e um rótulo de velocidade ("1x") que abre
 *     um menu de velocidades, no estilo do YouTube.
 *  2. Intercepta window.speechSynthesis.speak para aplicar o volume e a
 *     velocidade escolhidos em qualquer leitura feita pela página.
 *
 * "1x" corresponde à velocidade que a página já usava (rate 0.85); as demais
 * opções multiplicam essa base. Se o usuário mudar algo durante a leitura, ela
 * continua a partir da próxima palavra (sem repetir a atual) já com o novo ajuste.
 *
 * Enquanto há leitura, aparece um botão de pausa (pause.png) que pausa e
 * continua do ponto onde parou, e o botão "Ouvir" vira "Parar a leitura".
 */
(function () {
    'use strict';

    if (!('speechSynthesis' in window) || !window.SpeechSynthesisUtterance) {
        return;
    }

    var VELOCIDADES = [0.5, 1, 1.5, 2];
    var CHAVE_VOLUME = 'teachstation.audio.volume';
    var CHAVE_VELOCIDADE = 'teachstation.audio.velocidade';

    var sintese = window.speechSynthesis;
    var falarOriginal = sintese.speak.bind(sintese);

    var ajustes = {
        volume: lerNumero(CHAVE_VOLUME, 1, 0, 1),
        velocidade: lerNumero(CHAVE_VELOCIDADE, 1, 0.5, 2)
    };
    if (VELOCIDADES.indexOf(ajustes.velocidade) === -1) {
        ajustes.velocidade = 1;
    }

    // Leitura em andamento (para poder retomar do ponto atual após um ajuste)
    var leitura = null;
    var reinicioPendente = null;
    var pausado = false;
    var ajustePendente = false; // volume/velocidade mudou com a leitura pausada
    var atualizacaoPendente = null;

    // ---------- Preferências do usuário (só conveniência; funciona sem) ----------

    function lerNumero(chave, padrao, min, max) {
        try {
            var valor = parseFloat(window.localStorage.getItem(chave));
            if (!isNaN(valor) && valor >= min && valor <= max) {
                return valor;
            }
        } catch (e) { /* armazenamento indisponível */ }
        return padrao;
    }

    function salvar(chave, valor) {
        try {
            window.localStorage.setItem(chave, String(valor));
        } catch (e) { /* armazenamento indisponível */ }
    }

    // ---------- Interceptação da fala ----------

    function aplicarAjustes(fala) {
        if (typeof fala.__velocidadeBase !== 'number') {
            fala.__velocidadeBase = fala.rate || 1;
        }
        fala.volume = ajustes.volume;
        fala.rate = Math.min(10, Math.max(0.1, fala.__velocidadeBase * ajustes.velocidade));
    }

    var cancelarOriginal = sintese.cancel.bind(sintese);
    var pausarOriginal = sintese.pause.bind(sintese);
    var continuarOriginal = sintese.resume.bind(sintese);

    // Posição logo após a palavra que começou a ser lida
    function fimDaPalavra(texto, inicio, comprimento) {
        if (comprimento > 0) {
            return inicio + comprimento;
        }
        var resto = texto.slice(inicio);
        var palavra = resto.match(/^\s*\S+/);
        return inicio + (palavra ? palavra[0].length : resto.length);
    }

    function encerrarLeitura(registro) {
        if (leitura === registro) {
            leitura = null;
            pausado = false;
            ajustePendente = false;
        }
        agendarAtualizacao();
    }

    /*
     * Guarda até onde a leitura chegou. O índice salvo é o FIM da palavra que
     * está sendo falada: assim, ao recomeçar depois de um ajuste de volume ou
     * velocidade, a leitura segue da próxima palavra em vez de repetir a atual.
     */
    function acompanhar(fala, texto, inicio) {
        var registro = {fala: fala, texto: texto, inicio: inicio, indice: inicio};
        leitura = registro;
        fala.addEventListener('boundary', function (e) {
            if (leitura !== registro || typeof e.charIndex !== 'number') return;
            if (e.name && e.name !== 'word') return;
            registro.indice = fimDaPalavra(registro.texto, registro.inicio + e.charIndex, e.charLength || 0);
        });
        fala.addEventListener('start', agendarAtualizacao);
        fala.addEventListener('end', function () { encerrarLeitura(registro); });
        fala.addEventListener('error', function () { encerrarLeitura(registro); });
    }

    sintese.speak = function (fala) {
        if (fala instanceof window.SpeechSynthesisUtterance) {
            aplicarAjustes(fala);
            if (!fala.__retomada) {
                // Leitura nova feita pela página: começa do zero e sem pausa
                clearTimeout(reinicioPendente);
                pausado = false;
                ajustePendente = false;
                if (sintese.paused) continuarOriginal();
                acompanhar(fala, fala.text, 0);
            }
        }
        var resultado = falarOriginal(fala);
        agendarAtualizacao();
        return resultado;
    };

    // Qualquer cancelamento (da página ou do botão "Parar") encerra a leitura e a pausa
    sintese.cancel = function () {
        clearTimeout(reinicioPendente);
        leitura = null;
        pausado = false;
        ajustePendente = false;
        cancelarOriginal();
        if (sintese.paused) continuarOriginal(); // evita que a próxima leitura já comece pausada
        agendarAtualizacao();
    };

    // Recomeça a leitura atual logo após a última palavra lida, com os ajustes atuais
    function falarRestante() {
        var anterior = leitura;
        if (!anterior) return;
        var deslocamento = anterior.texto.slice(anterior.indice).search(/[^\s.,;:!?]/);
        if (deslocamento < 0) { // não sobrou nada para ler
            sintese.cancel();
            return;
        }
        var inicio = anterior.indice + deslocamento;
        var nova = new window.SpeechSynthesisUtterance(anterior.texto.slice(inicio));
        nova.lang = anterior.fala.lang;
        nova.voice = anterior.fala.voice;
        nova.pitch = anterior.fala.pitch;
        nova.__velocidadeBase = anterior.fala.__velocidadeBase;
        nova.__retomada = true;

        clearTimeout(reinicioPendente);
        leitura = null;
        cancelarOriginal();
        if (sintese.paused) continuarOriginal();
        pausado = false;
        ajustePendente = false;
        acompanhar(nova, anterior.texto, inicio);
        sintese.speak(nova);
    }

    // Volume/velocidade não mudam no meio de uma fala: é preciso recomeçar do ponto atual
    function retomarComAjustes() {
        if (!leitura) return;
        if (pausado) { // aplica só quando o usuário continuar
            ajustePendente = true;
            return;
        }
        clearTimeout(reinicioPendente);
        reinicioPendente = setTimeout(function () {
            if (leitura && !pausado && sintese.speaking) {
                falarRestante();
            }
        }, 250);
    }

    function pausar() {
        if (!leitura || pausado) return;
        clearTimeout(reinicioPendente);
        pausado = true;
        pausarOriginal();
        atualizarTodos();
    }

    function continuar() {
        if (!leitura || !pausado) return;
        if (ajustePendente) {
            falarRestante(); // continua de onde parou, já com o novo ajuste
        } else {
            pausado = false;
            continuarOriginal(); // continua exatamente de onde parou
        }
        atualizarTodos();
    }

    function estado() {
        if (!leitura) return 'parado';
        return pausado ? 'pausado' : 'tocando';
    }

    function agendarAtualizacao() {
        clearTimeout(atualizacaoPendente);
        atualizacaoPendente = setTimeout(atualizarTodos, 0);
    }

    // ---------- Interface ----------

    var controles = []; // para manter todos os controles da página sincronizados

    function rotuloVelocidade(v) {
        return (v === 2 ? '2.0' : String(v)) + 'x';
    }

    function atualizarTodos() {
        controles.forEach(function (c) { c.atualizar(); });
    }

    function fecharTodos(exceto) {
        controles.forEach(function (c) {
            if (c !== exceto) c.fechar();
        });
    }

    function criarControle(botaoOuvir) {
        var caixa = document.createElement('div');
        caixa.className = 'controle-audio';

        // --- Volume ---
        var grupoVolume = document.createElement('div');
        grupoVolume.className = 'controle-audio-grupo';

        var botaoVolume = document.createElement('button');
        botaoVolume.type = 'button';
        botaoVolume.className = 'controle-audio-botao controle-audio-volume';
        botaoVolume.setAttribute('aria-haspopup', 'true');
        botaoVolume.setAttribute('aria-expanded', 'false');

        var iconeVolume = document.createElement('span');
        iconeVolume.className = 'controle-audio-icone';
        iconeVolume.setAttribute('aria-hidden', 'true');
        botaoVolume.appendChild(iconeVolume);

        var painelVolume = document.createElement('div');
        painelVolume.className = 'controle-audio-painel controle-audio-painel-volume';
        painelVolume.hidden = true;

        var valorVolume = document.createElement('span');
        valorVolume.className = 'controle-audio-valor';

        var deslizante = document.createElement('input');
        deslizante.type = 'range';
        deslizante.min = '0';
        deslizante.max = '100';
        deslizante.step = '5';
        deslizante.className = 'controle-audio-deslizante';
        deslizante.setAttribute('orient', 'vertical'); // Firefox antigo
        deslizante.setAttribute('aria-label', 'Volume da leitura');
        deslizante.setAttribute('aria-orientation', 'vertical');

        painelVolume.appendChild(valorVolume);
        painelVolume.appendChild(deslizante);
        grupoVolume.appendChild(botaoVolume);
        grupoVolume.appendChild(painelVolume);

        // --- Velocidade ---
        var grupoVelocidade = document.createElement('div');
        grupoVelocidade.className = 'controle-audio-grupo';

        var botaoVelocidade = document.createElement('button');
        botaoVelocidade.type = 'button';
        botaoVelocidade.className = 'controle-audio-botao controle-audio-velocidade';
        botaoVelocidade.setAttribute('aria-haspopup', 'menu');
        botaoVelocidade.setAttribute('aria-expanded', 'false');

        var menuVelocidade = document.createElement('div');
        menuVelocidade.className = 'controle-audio-painel controle-audio-menu';
        menuVelocidade.setAttribute('role', 'menu');
        menuVelocidade.setAttribute('aria-label', 'Velocidade da leitura');
        menuVelocidade.hidden = true;

        var tituloMenu = document.createElement('p');
        tituloMenu.className = 'controle-audio-menu-titulo';
        tituloMenu.textContent = 'Velocidade';
        menuVelocidade.appendChild(tituloMenu);

        var opcoes = VELOCIDADES.map(function (v) {
            var opcao = document.createElement('button');
            opcao.type = 'button';
            opcao.className = 'controle-audio-opcao';
            opcao.setAttribute('role', 'menuitemradio');
            opcao.dataset.velocidade = String(v);
            opcao.textContent = v === 1 ? 'Normal (1x)' : rotuloVelocidade(v);
            opcao.addEventListener('click', function () {
                ajustes.velocidade = v;
                salvar(CHAVE_VELOCIDADE, v);
                atualizarTodos();
                fecharMenu(true);
                retomarComAjustes();
            });
            menuVelocidade.appendChild(opcao);
            return opcao;
        });

        grupoVelocidade.appendChild(botaoVelocidade);
        grupoVelocidade.appendChild(menuVelocidade);

        // --- Pausar / continuar (só aparece enquanto há uma leitura em andamento) ---
        var botaoPausa = document.createElement('button');
        botaoPausa.type = 'button';
        botaoPausa.className = 'controle-audio-botao controle-audio-pausa';
        botaoPausa.hidden = true;

        var iconePausa = document.createElement('span');
        iconePausa.className = 'controle-audio-icone-pausa';
        iconePausa.setAttribute('aria-hidden', 'true');
        botaoPausa.appendChild(iconePausa);

        botaoPausa.addEventListener('click', function () {
            if (pausado) continuar(); else pausar();
        });

        // --- Montagem: o botão original vai para dentro da caixa ---
        var textoOuvir = botaoOuvir.textContent;
        botaoOuvir.parentNode.insertBefore(caixa, botaoOuvir);
        caixa.appendChild(botaoOuvir);
        caixa.appendChild(botaoPausa);
        caixa.appendChild(grupoVolume);
        caixa.appendChild(grupoVelocidade);

        // --- Comportamento ---

        // Durante a leitura (tocando ou pausada) o botão "Ouvir" vira "Parar".
        // Fase de captura na caixa: roda antes do clique original da página.
        caixa.addEventListener('click', function (e) {
            if (leitura && botaoOuvir.contains(e.target)) {
                e.stopPropagation();
                e.preventDefault();
                sintese.cancel();
            }
        }, true);

        function abrirVolume() {
            fecharTodos(controle);
            fecharMenu(false);
            painelVolume.hidden = false;
            botaoVolume.setAttribute('aria-expanded', 'true');
            deslizante.focus();
        }

        function fecharVolume(devolverFoco) {
            if (painelVolume.hidden) return;
            painelVolume.hidden = true;
            botaoVolume.setAttribute('aria-expanded', 'false');
            if (devolverFoco) botaoVolume.focus();
        }

        function abrirMenu() {
            fecharTodos(controle);
            fecharVolume(false);
            menuVelocidade.hidden = false;
            botaoVelocidade.setAttribute('aria-expanded', 'true');
            var atual = menuVelocidade.querySelector('[aria-checked="true"]') || opcoes[0];
            atual.focus();
        }

        function fecharMenu(devolverFoco) {
            if (menuVelocidade.hidden) return;
            menuVelocidade.hidden = true;
            botaoVelocidade.setAttribute('aria-expanded', 'false');
            if (devolverFoco) botaoVelocidade.focus();
        }

        botaoVolume.addEventListener('click', function () {
            if (painelVolume.hidden) abrirVolume(); else fecharVolume(false);
        });

        botaoVelocidade.addEventListener('click', function () {
            if (menuVelocidade.hidden) abrirMenu(); else fecharMenu(false);
        });

        deslizante.addEventListener('input', function () {
            ajustes.volume = parseInt(deslizante.value, 10) / 100;
            salvar(CHAVE_VOLUME, ajustes.volume);
            atualizarTodos();
            retomarComAjustes();
        });

        // Setas para navegar no menu de velocidades
        menuVelocidade.addEventListener('keydown', function (e) {
            var i = opcoes.indexOf(document.activeElement);
            if (e.key === 'ArrowDown') {
                e.preventDefault();
                opcoes[(i + 1) % opcoes.length].focus();
            } else if (e.key === 'ArrowUp') {
                e.preventDefault();
                opcoes[(i - 1 + opcoes.length) % opcoes.length].focus();
            }
        });

        caixa.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') {
                if (!painelVolume.hidden) fecharVolume(true);
                if (!menuVelocidade.hidden) fecharMenu(true);
            }
        });

        var controle = {
            caixa: caixa,
            fechar: function () {
                fecharVolume(false);
                fecharMenu(false);
            },
            atualizar: function () {
                var situacao = estado();
                if (situacao === 'parado' && document.activeElement === botaoPausa) {
                    botaoOuvir.focus(); // não deixa o foco sumir junto com o botão
                }
                botaoPausa.hidden = situacao === 'parado';
                botaoPausa.classList.toggle('pausado', situacao === 'pausado');
                var rotuloPausa = situacao === 'pausado' ? 'Continuar a leitura' : 'Pausar a leitura';
                botaoPausa.setAttribute('aria-label', rotuloPausa);
                botaoPausa.title = rotuloPausa;
                var textoBotao = situacao === 'parado' ? textoOuvir : '⏹ Parar a leitura';
                if (botaoOuvir.textContent !== textoBotao) {
                    botaoOuvir.textContent = textoBotao;
                }

                var porcento = Math.round(ajustes.volume * 100);
                botaoVolume.classList.toggle('mudo', ajustes.volume === 0);
                botaoVolume.setAttribute('aria-label', 'Volume da leitura: ' + porcento + '%');
                botaoVolume.title = 'Volume: ' + porcento + '%';
                deslizante.value = String(porcento);
                deslizante.setAttribute('aria-valuetext', porcento + '%');
                deslizante.style.setProperty('--preenchido', porcento + '%');
                valorVolume.textContent = porcento + '%';

                botaoVelocidade.textContent = rotuloVelocidade(ajustes.velocidade);
                botaoVelocidade.setAttribute('aria-label',
                    'Velocidade da leitura: ' + rotuloVelocidade(ajustes.velocidade));
                botaoVelocidade.title = 'Velocidade da leitura';
                opcoes.forEach(function (opcao) {
                    var marcada = parseFloat(opcao.dataset.velocidade) === ajustes.velocidade;
                    opcao.setAttribute('aria-checked', marcada ? 'true' : 'false');
                    opcao.tabIndex = -1;
                });
            }
        };

        controle.atualizar();
        return controle;
    }

    // Fecha os painéis ao clicar fora
    document.addEventListener('click', function (e) {
        controles.forEach(function (c) {
            if (!c.caixa.contains(e.target)) c.fechar();
        });
    });

    // ---------- Encontrar os botões (inclusive os criados depois pelo JavaScript do quiz) ----------

    function aprimorar(raiz) {
        controles = controles.filter(function (c) { return document.body.contains(c.caixa); });
        var botoes = (raiz.querySelectorAll ? raiz : document).querySelectorAll('.botao-ouvir');
        Array.prototype.forEach.call(botoes, function (botao) {
            if (botao.__controleAudio || botao.hidden) return;
            botao.__controleAudio = true;
            controles.push(criarControle(botao));
        });
    }

    function iniciar() {
        aprimorar(document);
        new MutationObserver(function (mudancas) {
            var adicionou = mudancas.some(function (m) { return m.addedNodes.length > 0; });
            if (adicionou) aprimorar(document);
        }).observe(document.body, {childList: true, subtree: true});
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', iniciar);
    } else {
        iniciar();
    }
})();
